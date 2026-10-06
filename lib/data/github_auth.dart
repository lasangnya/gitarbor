import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Set with `--dart-define=GITHUB_CLIENT_ID=...`. Without it the app offers
/// only the paste-a-token sign-in.
const githubClientId = String.fromEnvironment(
  'GITHUB_CLIENT_ID',
  defaultValue: 'Ov23liJBtZGYOpno025L',
);

bool get oauthConfigured => githubClientId.isNotEmpty;

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => 'AuthException: $message';
}

class DeviceCode {
  const DeviceCode({
    required this.deviceCode,
    required this.userCode,
    required this.verificationUri,
    required this.expiresIn,
    required this.interval,
  });

  final String deviceCode;

  /// The short code the user types on GitHub.
  final String userCode;
  final String verificationUri;
  final int expiresIn;

  /// Seconds to wait between polls.
  final int interval;
}

/// GitHub OAuth device flow: show [DeviceCode.userCode], send the user to
/// [DeviceCode.verificationUri], then [poll] until they approve.
class GitHubAuth {
  GitHubAuth({
    Dio? dio,
    this.clientId = githubClientId,
    Future<void> Function(Duration)? delay,
  }) : _dio = dio ?? Dio(),
       _delay = delay ?? Future<void>.delayed;

  final Dio _dio;
  final String clientId;
  final Future<void> Function(Duration) _delay;

  Future<Map<String, dynamic>> _post(
    String url,
    Map<String, String> form,
  ) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        url,
        data: form,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {'Accept': 'application/json'},
          responseType: ResponseType.json,
          validateStatus: (_) => true,
        ),
      );
      final data = res.data;
      if (data == null) {
        throw AuthException('GitHub answered with status ${res.statusCode}.');
      }
      return data;
    } on DioException catch (e) {
      throw AuthException(e.message ?? 'Could not reach GitHub.');
    }
  }

  Future<DeviceCode> start({String scope = 'repo'}) async {
    final d = await _post('https://github.com/login/device/code', {
      'client_id': clientId,
      'scope': scope,
    });
    if (d['error'] != null || d['device_code'] == null) {
      throw AuthException(
        (d['error_description'] ?? d['error'] ?? 'Sign-in could not start.')
            as String,
      );
    }
    return DeviceCode(
      deviceCode: d['device_code'] as String,
      userCode: d['user_code'] as String,
      verificationUri: d['verification_uri'] as String,
      expiresIn: d['expires_in'] as int? ?? 900,
      interval: d['interval'] as int? ?? 5,
    );
  }

  /// Waits for the user to approve and returns the access token.
  Future<String> poll(DeviceCode code) async {
    var interval = code.interval;
    var waited = 0;
    while (true) {
      await _delay(Duration(seconds: interval));
      waited += interval;
      final d = await _post('https://github.com/login/oauth/access_token', {
        'client_id': clientId,
        'device_code': code.deviceCode,
        'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
      });
      final token = d['access_token'];
      if (token is String) return token;
      switch (d['error']) {
        case 'authorization_pending':
          break;
        case 'slow_down':
          interval = (d['interval'] as int?) ?? interval + 5;
        case 'expired_token':
          throw const AuthException(
            'The sign-in code expired. Please start again.',
          );
        case 'access_denied':
          throw const AuthException('Sign-in was cancelled on GitHub.');
        case final String e:
          throw AuthException((d['error_description'] as String?) ?? e);
        default:
          throw const AuthException('Unexpected answer from GitHub.');
      }
      if (waited > code.expiresIn) {
        throw const AuthException(
          'The sign-in code expired. Please start again.',
        );
      }
    }
  }
}

/// The three operations [TokenStore] needs from secure storage.
abstract class SecretStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class SecureSecretStore implements SecretStore {
  const SecureSecretStore([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

class TokenStore {
  TokenStore({SecretStore? store})
    : _store = store ?? const SecureSecretStore();

  static const _key = 'github_token';
  final SecretStore _store;

  Future<String?> read() => _store.read(_key);
  Future<void> write(String token) => _store.write(_key, token);
  Future<void> clear() => _store.delete(_key);
}
