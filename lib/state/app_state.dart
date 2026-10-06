import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/etag_cache.dart';
import '../data/github_api.dart';
import '../data/github_auth.dart';
import '../data/github_client.dart';
import '../data/models/repo_models.dart';
import '../data/repo_repository.dart';

/// The app's support directory: settings, recent trees and the HTTP cache
/// live here. Overridden in main(); null in tests means memory only.
final appDirProvider = Provider<Directory?>((ref) => null);

// ---------------------------------------------------------------- settings

enum ThemeChoice { system, day, night }

class Settings {
  const Settings({this.theme = ThemeChoice.system, this.reduceMotion = false});
  final ThemeChoice theme;

  /// Freeze the wind and growth animations, on top of the system setting.
  final bool reduceMotion;

  Settings copyWith({ThemeChoice? theme, bool? reduceMotion}) => Settings(
    theme: theme ?? this.theme,
    reduceMotion: reduceMotion ?? this.reduceMotion,
  );

  Map<String, Object> toJson() => {
    'theme': theme.name,
    'reduceMotion': reduceMotion,
  };

  factory Settings.fromJson(Map<String, dynamic> j) => Settings(
    theme: ThemeChoice.values.asNameMap()[j['theme']] ?? ThemeChoice.system,
    reduceMotion: j['reduceMotion'] == true,
  );
}

class SettingsNotifier extends Notifier<Settings> {
  File? get _file {
    final dir = ref.read(appDirProvider);
    return dir == null ? null : File('${dir.path}/settings.json');
  }

  @override
  Settings build() {
    final f = _file;
    if (f != null && f.existsSync()) {
      try {
        return Settings.fromJson(
          jsonDecode(f.readAsStringSync()) as Map<String, dynamic>,
        );
      } on FormatException {
        // Fall through to defaults.
      }
    }
    return const Settings();
  }

  void set(Settings s) {
    state = s;
    _file?.writeAsString(jsonEncode(s.toJson()));
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, Settings>(
  SettingsNotifier.new,
);

// ------------------------------------------------------------------ GitHub

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

/// The signed-in GitHub token, from the device flow or pasted by hand.
class TokenNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    try {
      return await ref.read(tokenStoreProvider).read();
    } catch (_) {
      // No keychain (e.g. unsigned debug build): behave as signed out.
      return null;
    }
  }

  Future<void> save(String token) async {
    final t = token.trim();
    state = AsyncData(t);
    try {
      await ref.read(tokenStoreProvider).write(t);
    } catch (_) {
      // Kept for this session only.
    }
  }

  Future<void> signOut() async {
    state = const AsyncData(null);
    try {
      await ref.read(tokenStoreProvider).clear();
    } catch (_) {}
  }
}

final tokenProvider = AsyncNotifierProvider<TokenNotifier, String?>(
  TokenNotifier.new,
);

final githubAuthProvider = Provider<GitHubAuth>((ref) => GitHubAuth());

final githubClientProvider = Provider<GitHubClient>((ref) {
  final dir = ref.watch(appDirProvider);
  return GitHubClient(
    cache: dir == null
        ? MemoryEtagCache()
        : FileEtagCache(Directory('${dir.path}/http-cache')),
  );
});

/// What [RepoRepository] talks to; tests override it with fixtures.
final githubApiProvider = Provider<GitHubApi>((ref) {
  final client = ref.watch(githubClientProvider);
  client.token = ref.watch(tokenProvider).value;
  return client;
});

final repoRepositoryProvider = Provider<RepoRepository>(
  (ref) => RepoRepository(ref.watch(githubApiProvider)),
);

// ------------------------------------------------------------ recent trees

class RecentTree {
  const RecentTree({
    required this.fullName,
    required this.branches,
    required this.commits,
    required this.plantedAt,
  });
  final String fullName;
  final int branches;
  final int commits;
  final DateTime plantedAt;

  Map<String, Object> toJson() => {
    'fullName': fullName,
    'branches': branches,
    'commits': commits,
    'plantedAt': plantedAt.toIso8601String(),
  };

  factory RecentTree.fromJson(Map<String, dynamic> j) => RecentTree(
    fullName: j['fullName'] as String,
    branches: j['branches'] as int,
    commits: j['commits'] as int,
    plantedAt: DateTime.parse(j['plantedAt'] as String),
  );
}

class RecentTreesNotifier extends Notifier<List<RecentTree>> {
  static const max = 8;

  File? get _file {
    final dir = ref.read(appDirProvider);
    return dir == null ? null : File('${dir.path}/recent.json');
  }

  @override
  List<RecentTree> build() {
    final f = _file;
    if (f == null || !f.existsSync()) return const [];
    try {
      return [
        for (final j in jsonDecode(f.readAsStringSync()) as List)
          RecentTree.fromJson(j as Map<String, dynamic>),
      ];
    } on Object {
      return const [];
    }
  }

  void add(RepoSnapshot s) {
    final entry = RecentTree(
      fullName: s.fullName,
      branches: s.branches.length,
      commits: s.totalCommits,
      plantedAt: s.fetchedAt,
    );
    state = [
      entry,
      ...state.where(
        (r) => r.fullName.toLowerCase() != s.fullName.toLowerCase(),
      ),
    ].take(max).toList();
    _file?.writeAsString(jsonEncode([for (final r in state) r.toJson()]));
  }
}

final recentTreesProvider =
    NotifierProvider<RecentTreesNotifier, List<RecentTree>>(
      RecentTreesNotifier.new,
    );

// ---------------------------------------------------------------- planting

/// Everything the Growing screen shows, built up from [PlantEvent]s.
class PlantState {
  const PlantState({
    required this.owner,
    required this.repo,
    this.found,
    this.fetched = 0,
    this.toFetch = 0,
    this.mapped,
    this.counted,
    this.snapshot,
    this.error,
  });

  final String owner, repo;
  final FoundRepo? found;
  final int fetched, toFetch;
  final MappedBranches? mapped;
  final CountedCommits? counted;
  final RepoSnapshot? snapshot;
  final Object? error;

  bool get done => snapshot != null;

  /// 0 to 1, for the progress bar and the growing tree.
  double get progress {
    if (snapshot != null) return 1;
    var p = found == null ? .02 : .1;
    if (toFetch > 0) p += .75 * fetched / toFetch;
    if (mapped != null) p = .9;
    if (counted != null) p = .96;
    return p;
  }

  PlantState copyWith({
    FoundRepo? found,
    int? fetched,
    int? toFetch,
    MappedBranches? mapped,
    CountedCommits? counted,
    RepoSnapshot? snapshot,
    Object? error,
  }) => PlantState(
    owner: owner,
    repo: repo,
    found: found ?? this.found,
    fetched: fetched ?? this.fetched,
    toFetch: toFetch ?? this.toFetch,
    mapped: mapped ?? this.mapped,
    counted: counted ?? this.counted,
    snapshot: snapshot ?? this.snapshot,
    error: error ?? this.error,
  );
}

/// One planting at a time. [start] begins it; [cancel] stops requests.
class PlantNotifier extends Notifier<PlantState?> {
  StreamSubscription<PlantEvent>? _sub;

  @override
  PlantState? build() {
    ref.onDispose(() => _sub?.cancel());
    return null;
  }

  void start(String owner, String repo) {
    _sub?.cancel();
    state = PlantState(owner: owner, repo: repo);
    _sub = ref
        .read(repoRepositoryProvider)
        .plant(owner, repo)
        .listen(_on, onError: (Object e) => state = state?.copyWith(error: e));
  }

  void _on(PlantEvent e) {
    final s = state;
    if (s == null) return;
    state = switch (e) {
      FoundRepo() => s.copyWith(found: e),
      FetchingBranches() => s.copyWith(fetched: e.done, toFetch: e.total),
      MappedBranches() => s.copyWith(mapped: e),
      CountedCommits() => s.copyWith(counted: e),
      Planted() => s.copyWith(snapshot: e.snapshot),
    };
    if (e is Planted) ref.read(recentTreesProvider.notifier).add(e.snapshot);
  }

  void cancel() {
    _sub?.cancel();
    _sub = null;
    state = null;
  }
}

final plantProvider = NotifierProvider<PlantNotifier, PlantState?>(
  PlantNotifier.new,
);
