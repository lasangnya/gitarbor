import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitarbor/data/etag_cache.dart';
import 'package:gitarbor/data/github_api.dart';
import 'package:gitarbor/data/github_client.dart';

import '../support/fake_adapter.dart';

List<Map<String, Object?>> items(int from, int n) => [
  for (var i = from; i < from + n; i++) {'n': i},
];

(GitHubClient, FakeAdapter) make(
  FakeHandler handler, {
  String? token,
  EtagCache? cache,
}) {
  final adapter = FakeAdapter(handler);
  final dio = Dio()..httpClientAdapter = adapter;
  return (GitHubClient(dio: dio, token: token, cache: cache), adapter);
}

void main() {
  group('paging', () {
    ResponseBody threePages(RequestOptions o) {
      final page = int.parse(o.uri.queryParameters['page'] ?? '1');
      final next = page < 3
          ? '<https://api.github.com/repositories/1/branches?per_page=100&page=${page + 1}>; rel="next", '
                '<https://api.github.com/repositories/1/branches?per_page=100&page=3>; rel="last"'
          : '';
      return jsonBody(
        items((page - 1) * 100, page < 3 ? 100 : 20),
        headers: {if (next.isNotEmpty) 'Link': next},
      );
    }

    test('follows Link rel=next until there is none', () async {
      final (client, adapter) = make(threePages);
      final all = await client.listBranches('o', 'r');
      expect(all, hasLength(220));
      expect(adapter.requests, hasLength(3));
      expect(adapter.requests.first.uri.queryParameters['per_page'], '100');
      expect(all.last['n'], 219);
    });

    test('stops at max and truncates', () async {
      final (client, adapter) = make(threePages);
      final all = await client.pullCommits('o', 'r', 7, max: 150);
      expect(all, hasLength(150));
      expect(adapter.requests, hasLength(2));
      expect(adapter.requests.first.uri.path, '/repos/o/r/pulls/7/commits');
    });

    test('listPulls asks for all states newest first', () async {
      final (client, adapter) = make((_) => jsonBody(<Object>[]));
      await client.listPulls('o', 'r');
      final q = adapter.requests.single.uri.queryParameters;
      expect(q['state'], 'all');
      expect(q['sort'], 'updated');
      expect(q['direction'], 'desc');
    });

    test('listCommits passes the sha', () async {
      final (client, adapter) = make((_) => jsonBody(<Object>[]));
      await client.listCommits('o', 'r', 'main');
      expect(adapter.requests.single.uri.queryParameters['sha'], 'main');
    });
  });

  group('requests', () {
    test('sends the GitHub headers and the bearer token', () async {
      final (client, adapter) = make(
        (_) => jsonBody({'ok': true}),
        token: 'ghp_abc',
      );
      await client.getRepo('o', 'r');
      final h = adapter.requests.single.headers;
      expect(h['Authorization'], 'Bearer ghp_abc');
      expect(h['Accept'], 'application/vnd.github+json');
      expect(h['X-GitHub-Api-Version'], '2022-11-28');
      expect(adapter.requests.single.uri.host, 'api.github.com');
    });

    test(
      'no Authorization header without a token, and the token can change',
      () async {
        final (client, adapter) = make((_) => jsonBody({'ok': true}));
        await client.getRepo('o', 'r');
        expect(
          adapter.requests.last.headers.containsKey('Authorization'),
          isFalse,
        );
        client.token = 'later';
        await client.getRepo('o', 'r');
        expect(adapter.requests.last.headers['Authorization'], 'Bearer later');
        client.token = null;
        await client.getRepo('o', 'r');
        expect(
          adapter.requests.last.headers.containsKey('Authorization'),
          isFalse,
        );
      },
    );

    test('compare encodes branch names on both sides', () async {
      final (client, adapter) = make((_) => jsonBody({'status': 'ahead'}));
      await client.compare('o', 'r', 'feature/i18n', 'feature/i18n-rtl');
      expect(
        adapter.requests.single.uri.toString(),
        'https://api.github.com/repos/o/r/compare/'
        'feature%2Fi18n...feature%2Fi18n-rtl',
      );
    });

    test('reads the rate limit headers', () async {
      final (client, _) = make(
        (_) => jsonBody(
          {},
          headers: {
            'x-ratelimit-remaining': '4321',
            'x-ratelimit-limit': '5000',
            'x-ratelimit-reset': '1790000000',
          },
        ),
      );
      expect(client.lastRateLimit, isNull);
      await client.getRepo('o', 'r');
      expect(client.lastRateLimit!.remaining, 4321);
      expect(client.lastRateLimit!.limit, 5000);
      expect(
        client.lastRateLimit!.resetAt,
        DateTime.fromMillisecondsSinceEpoch(1790000000 * 1000, isUtc: true),
      );
    });
  });

  group('errors', () {
    Future<Object?> failure(
      int status, {
      Map<String, String> headers = const {},
    }) async {
      final (client, _) = make(
        (_) => jsonBody({'message': 'nope'}, status: status, headers: headers),
      );
      try {
        await client.getRepo('o', 'r');
      } on Object catch (e) {
        return e;
      }
      return null;
    }

    test('404 is RepoNotFoundException', () async {
      expect(await failure(404), isA<RepoNotFoundException>());
    });

    test('403 with an exhausted limit is RateLimitException', () async {
      final e = await failure(
        403,
        headers: {
          'x-ratelimit-remaining': '0',
          'x-ratelimit-reset': '1790000000',
        },
      );
      expect(e, isA<RateLimitException>());
      expect(
        (e! as RateLimitException).resetAt,
        DateTime.utc(2026, 9, 21, 14, 13, 20),
      );
    });

    test('429 is RateLimitException', () async {
      final e = await failure(
        429,
        headers: {
          'x-ratelimit-remaining': '0',
          'x-ratelimit-reset': '1790000000',
        },
      );
      expect(e, isA<RateLimitException>());
    });

    test('403 with requests left is UnauthorizedException', () async {
      expect(
        await failure(403, headers: {'x-ratelimit-remaining': '12'}),
        isA<UnauthorizedException>(),
      );
    });

    test('401 is UnauthorizedException', () async {
      expect(await failure(401), isA<UnauthorizedException>());
    });

    test('5xx is NetworkException', () async {
      expect(await failure(500), isA<NetworkException>());
      expect(await failure(503), isA<NetworkException>());
    });

    test('connection errors and timeouts are NetworkException', () async {
      for (final type in [
        DioExceptionType.connectionError,
        DioExceptionType.connectionTimeout,
      ]) {
        final (client, _) = make(
          (o) => throw DioException(requestOptions: o, type: type),
        );
        await expectLater(
          client.getRepo('o', 'r'),
          throwsA(isA<NetworkException>()),
        );
      }
    });
  });

  group('etag cache', () {
    test('second call sends If-None-Match and 304 reuses the body', () async {
      final cache = MemoryEtagCache();
      final (client, adapter) = make((o) {
        if (o.headers['If-None-Match'] == '"v1"') {
          return ResponseBody.fromString('', 304);
        }
        return jsonBody({'name': 'lantern'}, headers: {'etag': '"v1"'});
      }, cache: cache);

      final first = await client.getRepo('o', 'r');
      expect(
        adapter.requests.first.headers.containsKey('If-None-Match'),
        isFalse,
      );
      final second = await client.getRepo('o', 'r');
      expect(adapter.requests.last.headers['If-None-Match'], '"v1"');
      expect(adapter.requests.last.headers['If-None-Match'], isNotNull);
      expect(second, first);
      expect(second['name'], 'lantern');
    });

    test('a cached Link header keeps paging working on 304', () async {
      final cache = MemoryEtagCache();
      var warm = false;
      final (client, adapter) = make((o) {
        final page = int.parse(o.uri.queryParameters['page'] ?? '1');
        if (warm) return ResponseBody.fromString('', 304);
        return jsonBody(
          items(page * 10, 2),
          headers: {
            'etag': '"p$page"',
            if (page == 1)
              'link':
                  '<https://api.github.com/x?per_page=100&page=2>; rel="next"',
          },
        );
      }, cache: cache);

      final cold = await client.listBranches('o', 'r');
      warm = true;
      final hot = await client.listBranches('o', 'r');
      expect(hot, cold);
      expect(hot, hasLength(4));
      expect(adapter.requests, hasLength(4));
    });

    test('FileEtagCache round-trips and misses on unknown urls', () async {
      final dir = await Directory.systemTemp.createTemp('etag');
      addTearDown(() => dir.delete(recursive: true));
      final cache = FileEtagCache(dir);
      expect(await cache.get('https://x/a'), isNull);
      await cache.put(
        'https://x/a',
        const CachedResponse(etag: '"e"', body: '[1]', link: '<u>; rel="next"'),
      );
      final hit = await cache.get('https://x/a');
      expect(hit!.etag, '"e"');
      expect(hit.body, '[1]');
      expect(hit.link, '<u>; rel="next"');
      expect(await cache.get('https://x/b'), isNull);
      expect(dir.listSync().whereType<File>(), hasLength(1));
    });
  });
}
