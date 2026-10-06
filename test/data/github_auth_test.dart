import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitarbor/data/github_auth.dart';

import '../support/fake_adapter.dart';

class MemorySecretStore implements SecretStore {
  final map = <String, String>{};

  @override
  Future<String?> read(String key) async => map[key];

  @override
  Future<void> write(String key, String value) async => map[key] = value;

  @override
  Future<void> delete(String key) async => map.remove(key);
}

void main() {
  late List<Duration> delays;
  late FakeAdapter adapter;

  GitHubAuth make(List<Map<String, Object?>> tokenReplies) {
    delays = [];
    final replies = [...tokenReplies];
    adapter = FakeAdapter((o) {
      if (o.uri.path == '/login/device/code') {
        return jsonBody({
          'device_code': 'dc123',
          'user_code': 'WDJB-MJHT',
          'verification_uri': 'https://github.com/login/device',
          'expires_in': 900,
          'interval': 5,
        });
      }
      return jsonBody(replies.removeAt(0));
    });
    return GitHubAuth(
      dio: Dio()..httpClientAdapter = adapter,
      clientId: 'cid',
      delay: (d) async => delays.add(d),
    );
  }

  test('start returns the device code', () async {
    final auth = make([]);
    final code = await auth.start();
    expect(code.userCode, 'WDJB-MJHT');
    expect(code.deviceCode, 'dc123');
    expect(code.verificationUri, 'https://github.com/login/device');
    expect(code.interval, 5);
    final req = adapter.requests.single;
    expect(req.headers['Accept'], 'application/json');
    expect(req.data, {'client_id': 'cid', 'scope': 'repo'});
  });

  test('pending, then slow_down, then a token', () async {
    final auth = make([
      {'error': 'authorization_pending'},
      {'error': 'slow_down'},
      {'access_token': 'gho_abc', 'token_type': 'bearer'},
    ]);
    final code = await auth.start();
    final token = await auth.poll(code);
    expect(token, 'gho_abc');
    expect(delays.map((d) => d.inSeconds), [5, 5, 10]);
    final poll = adapter.requests.last;
    expect(poll.uri.toString(), 'https://github.com/login/oauth/access_token');
    expect(poll.data, {
      'client_id': 'cid',
      'device_code': 'dc123',
      'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
    });
  });

  test('expired_token throws AuthException', () async {
    final auth = make([
      {'error': 'authorization_pending'},
      {'error': 'expired_token'},
    ]);
    final code = await auth.start();
    await expectLater(
      auth.poll(code),
      throwsA(
        isA<AuthException>().having(
          (e) => e.message,
          'message',
          contains('expired'),
        ),
      ),
    );
  });

  test('access_denied throws AuthException', () async {
    final auth = make([
      {'error': 'access_denied'},
    ]);
    final code = await auth.start();
    await expectLater(auth.poll(code), throwsA(isA<AuthException>()));
  });

  test('start surfaces GitHub errors', () async {
    final auth = GitHubAuth(
      dio: Dio()
        ..httpClientAdapter = FakeAdapter(
          (_) => jsonBody({
            'error': 'unauthorized_client',
            'error_description': 'Device flow is disabled.',
          }),
        ),
      clientId: 'cid',
    );
    await expectLater(auth.start(), throwsA(isA<AuthException>()));
  });

  test('TokenStore reads, writes and clears', () async {
    final backing = MemorySecretStore();
    final store = TokenStore(store: backing);
    expect(await store.read(), isNull);
    await store.write('gho_abc');
    expect(await store.read(), 'gho_abc');
    expect(backing.map, {'github_token': 'gho_abc'});
    await store.clear();
    expect(await store.read(), isNull);
  });
}
