import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitarbor/data/github_api.dart';
import 'package:gitarbor/data/github_auth.dart';
import 'package:gitarbor/data/repo_repository.dart';
import 'package:gitarbor/state/app_state.dart';
import 'package:gitarbor/ui/theme.dart';

import '../support/fixture_api.dart';

class MemorySecretStore implements SecretStore {
  final map = <String, String>{};
  @override
  Future<String?> read(String key) async => map[key];
  @override
  Future<void> write(String key, String value) async => map[key] = value;
  @override
  Future<void> delete(String key) async => map.remove(key);
}

/// Fixture API whose getRepo throws [error].
class ThrowingApi extends FixtureGitHubApi {
  ThrowingApi(this.error);
  final GitHubException error;
  @override
  Future<Map<String, dynamic>> getRepo(String owner, String repo) async =>
      throw error;
}

Widget testApp(Widget home, {GitHubApi? api}) => ProviderScope(
  overrides: [
    repoRepositoryProvider.overrideWithValue(
      RepoRepository(
        api ?? FixtureGitHubApi(),
        clock: () => DateTime.utc(2026, 10, 5, 12),
      ),
    ),
    appDirProvider.overrideWithValue(null),
    tokenStoreProvider.overrideWithValue(
      TokenStore(store: MemorySecretStore()),
    ),
  ],
  child: MaterialApp(
    theme: buildTheme(GitarborTokens.day, Brightness.light),
    home: home,
  ),
);

void setSize(WidgetTester tester, double w, double h) {
  tester.view.physicalSize = Size(w, h);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Pumps in steps; never settles because TreeView ticks forever.
Future<void> pumpFor(WidgetTester tester, Duration total) async {
  const step = Duration(milliseconds: 100);
  for (var d = Duration.zero; d < total; d += step) {
    await tester.pump(step);
  }
}
