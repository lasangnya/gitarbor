import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import 'etag_cache.dart';
import 'github_api.dart';

/// Rate-limit state from the latest response headers.
class RateLimit {
  const RateLimit({
    required this.remaining,
    required this.limit,
    required this.resetAt,
  });

  final int remaining;
  final int limit;
  final DateTime resetAt;
}

class GitHubClient implements GitHubApi {
  GitHubClient({Dio? dio, String? token, this.cache}) : _dio = dio ?? Dio() {
    this.token = token;
    _dio.options
      ..baseUrl = 'https://api.github.com'
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 30)
      ..responseType = ResponseType.plain
      // Every status is handled here, 304 included.
      ..validateStatus = (_) => true;
  }

  final Dio _dio;
  final EtagCache? cache;
  String? _token;

  /// Rate limit seen on the most recent response, if it carried one.
  RateLimit? lastRateLimit;

  String? get token => _token;
  set token(String? t) => _token = (t == null || t.isEmpty) ? null : t;

  @override
  Future<Map<String, dynamic>> getRepo(String owner, String repo) async {
    final page = await _get('/repos/$owner/$repo');
    return page.json as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> listBranches(String owner, String repo) =>
      _paged('/repos/$owner/$repo/branches', max: 1 << 30);

  @override
  Future<List<Map<String, dynamic>>> listPulls(
    String owner,
    String repo, {
    int max = 300,
  }) => _paged(
    '/repos/$owner/$repo/pulls',
    query: {'state': 'all', 'sort': 'updated', 'direction': 'desc'},
    max: max,
  );

  @override
  Future<Map<String, dynamic>> compare(
    String owner,
    String repo,
    String base,
    String head,
  ) async {
    final spec = '${Uri.encodeComponent(base)}...${Uri.encodeComponent(head)}';
    final page = await _get('/repos/$owner/$repo/compare/$spec');
    return page.json as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> listCommits(
    String owner,
    String repo,
    String sha, {
    int max = 300,
  }) => _paged('/repos/$owner/$repo/commits', query: {'sha': sha}, max: max);

  @override
  Future<List<Map<String, dynamic>>> pullCommits(
    String owner,
    String repo,
    int number, {
    int max = 250,
  }) => _paged('/repos/$owner/$repo/pulls/$number/commits', max: max);

  Future<List<Map<String, dynamic>>> _paged(
    String path, {
    Map<String, String> query = const {},
    required int max,
  }) async {
    final out = <Map<String, dynamic>>[];
    String? url = Uri(
      path: path,
      queryParameters: {...query, 'per_page': '100'},
    ).toString();
    while (url != null && out.length < max) {
      final page = await _get(url);
      out.addAll((page.json as List).cast<Map<String, dynamic>>());
      url = page.next;
    }
    return out.length > max ? out.sublist(0, max) : out;
  }

  Future<_Page> _get(String url) async {
    final cached = await cache?.get(_cacheKey(url));
    final Response<String> res;
    try {
      res = await _dio.get<String>(
        url,
        options: Options(
          headers: {
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28',
            if (_token != null) 'Authorization': 'Bearer $_token',
            if (cached != null) 'If-None-Match': cached.etag,
          },
        ),
      );
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Could not reach GitHub.');
    }
    _readRateLimit(res);
    final status = res.statusCode ?? 0;

    if (status == 304 && cached != null) {
      return _Page(jsonDecode(cached.body), _nextLink(cached.link));
    }
    if (status >= 200 && status < 300) {
      final body = res.data ?? '';
      final link = res.headers.value('link');
      final etag = res.headers.value('etag');
      if (etag != null && cache != null) {
        try {
          await cache!.put(
            _cacheKey(url),
            CachedResponse(etag: etag, body: body, link: link),
          );
        } on Object {
          // A cache that cannot write only costs a refetch.
        }
      }
      return _Page(jsonDecode(body), _nextLink(link));
    }
    throw _mapError(res, status);
  }

  /// The token is part of the key so one account's private data is never
  /// replayed for another.
  String _cacheKey(String url) => '${_token ?? ''}|$url';

  GitHubException _mapError(Response<String> res, int status) {
    final remaining = res.headers.value('x-ratelimit-remaining');
    final exhausted = remaining == '0';
    if (status == 404) {
      return const RepoNotFoundException(
        'Repository not found, or it is private.',
      );
    }
    if ((status == 403 || status == 429) && (exhausted || status == 429)) {
      return RateLimitException(
        'GitHub rate limit reached.',
        resetAt:
            _epoch(res.headers.value('x-ratelimit-reset')) ??
            DateTime.now().add(const Duration(minutes: 1)),
      );
    }
    if (status == 401 || status == 403) {
      return UnauthorizedException(
        status == 401
            ? 'The GitHub token was rejected.'
            : 'GitHub refused access to this repository.',
      );
    }
    return NetworkException('GitHub answered with status $status.');
  }

  void _readRateLimit(Response<String> res) {
    final remaining = int.tryParse(
      res.headers.value('x-ratelimit-remaining') ?? '',
    );
    final limit = int.tryParse(res.headers.value('x-ratelimit-limit') ?? '');
    final reset = _epoch(res.headers.value('x-ratelimit-reset'));
    if (remaining != null && limit != null && reset != null) {
      lastRateLimit = RateLimit(
        remaining: remaining,
        limit: limit,
        resetAt: reset,
      );
    }
  }

  static DateTime? _epoch(String? s) {
    final n = int.tryParse(s ?? '');
    return n == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(n * 1000, isUtc: true);
  }

  static String? _nextLink(String? link) {
    if (link == null) return null;
    final m = RegExp(r'<([^>]+)>\s*;\s*rel="next"').firstMatch(link);
    return m?.group(1);
  }
}

class _Page {
  const _Page(this.json, this.next);
  final Object? json;
  final String? next;
}
