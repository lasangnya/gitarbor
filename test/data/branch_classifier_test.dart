import 'package:flutter_test/flutter_test.dart';
import 'package:gitarbor/data/branch_classifier.dart';
import 'package:gitarbor/data/models/repo_models.dart';
import 'package:gitarbor/data/repo_repository.dart';

import '../support/fixture_api.dart';

final now = DateTime.utc(2026, 10, 5, 12);

void main() {
  late FixtureGitHubApi api;
  late List<PlantEvent> events;
  late RepoSnapshot snap;

  setUp(() async {
    api = FixtureGitHubApi();
    events = await RepoRepository(
      api,
      clock: () => now,
    ).plant('example', 'lantern').toList();
    snap = (events.last as Planted).snapshot;
  });

  Branch branch(String name) =>
      snap.branches.singleWhere((b) => b.name == name);

  test('event order', () {
    expect(events.first, isA<FoundRepo>());
    final found = events.first as FoundRepo;
    expect(found.defaultBranch, 'main');
    expect(found.stars, 1280);
    final fetching = events.whereType<FetchingBranches>().toList();
    expect(fetching.first.done, 0);
    expect(fetching.last.done, fetching.last.total);
    expect(fetching.last.total, 11);
    expect(fetching, hasLength(12));
    final types = events.map((e) => e.runtimeType).toList();
    expect(types.sublist(types.length - 3), [
      MappedBranches,
      CountedCommits,
      Planted,
    ]);
    expect(
      types.indexOf(MappedBranches),
      greaterThan(types.lastIndexOf(FetchingBranches)),
    );
  });

  test('mapped and counted events', () {
    final mapped = events.whereType<MappedBranches>().single;
    expect(mapped.counts, {
      BranchStatus.active: 5,
      BranchStatus.stale: 1,
      BranchStatus.merged: 4,
      BranchStatus.pruned: 1,
    });
    expect(mapped.total, 11);
    expect(mapped.omitted, 0);
    final counted = events.whereType<CountedCommits>().single;
    expect(counted.commits, 51);
    expect(counted.authors, 7);
    expect(counted.since, DateTime.utc(2025, 7, 20, 10));
  });

  test('status, deleted flag and parent of every branch', () {
    const expected = {
      'refactor/router': (BranchStatus.merged, true),
      'experiment/wasm-build': (BranchStatus.stale, false),
      'feature/old-editor': (BranchStatus.pruned, true),
      'fix/rss-dates': (BranchStatus.merged, true),
      'feature/i18n': (BranchStatus.active, false),
      'feature/dark-mode': (BranchStatus.merged, false),
      'release/2.0': (BranchStatus.active, false),
      'feature/plugin-api': (BranchStatus.active, false),
      'docs/getting-started': (BranchStatus.active, false),
      'feature/i18n-rtl': (BranchStatus.active, false),
      'chore/ci-cache': (BranchStatus.merged, false),
    };
    expect(snap.branches, hasLength(expected.length));
    for (final e in expected.entries) {
      final b = branch(e.key);
      expect((b.status, b.deleted), e.value, reason: e.key);
      expect(b.parent, e.key == 'feature/i18n-rtl' ? 'feature/i18n' : isNull);
    }
    expect(branch('feature/i18n-rtl').isSubBranch, isTrue);
    expect(api.compareBases['feature/i18n-rtl'], 'feature/i18n');
    expect(api.compareBases['feature/i18n'], 'main');
  });

  test('fork pull request is ignored', () {
    expect(snap.branches.map((b) => b.name), isNot(contains('patch-1')));
    expect(snap.branches.any((b) => b.prNumber == 8), isFalse);
  });

  test('authors and pull request numbers', () {
    expect(branch('refactor/router').author, 'rahul-dev');
    expect(branch('feature/old-editor').prNumber, 2);
    expect(branch('feature/dark-mode').prNumber, 4);
    expect(branch('feature/i18n-rtl').prNumber, 5);
    expect(branch('feature/i18n').prNumber, isNull);
    expect(branch('feature/i18n').author, 'aiko-t');
  });

  test('commit counts', () {
    expect(branch('refactor/router').commitCount, 5);
    expect(branch('feature/i18n').commitCount, 6);
    expect(
      branch('feature/i18n').commits.first.date,
      DateTime.utc(2026, 10, 3, 10),
    );
    expect(snap.trunkCommits, hasLength(12));
    expect(snap.totalCommits, 51);
  });

  test('authors are aggregated and sorted', () {
    expect(
      [for (final a in snap.authors) (a.login, a.commits)],
      [
        ('aiko-t', 11),
        ('rahul-dev', 10),
        ('tomasz', 9),
        ('mira', 8),
        ('junpark', 7),
        ('lena', 5),
        ('Mira K', 1),
      ],
    );
  });

  test('unlinked commit falls back to the git author name', () {
    final rss = branch('fix/rss-dates');
    expect(rss.commits.map((c) => c.author).toSet(), {'mira', 'Mira K'});
    expect(rss.commits.where((c) => c.author == 'Mira K'), hasLength(1));
    expect(rss.author, 'mira');
  });

  test('fast-forward merged branch picks up its PR commits', () {
    final ci = branch('chore/ci-cache');
    expect(ci.status, BranchStatus.merged);
    expect(ci.deleted, isFalse);
    expect(ci.commits, hasLength(2));
    expect(ci.commitCount, 2);
    expect(ci.author, 'junpark');
    expect(api.calls['pullCommits'], 4); // 3 deleted + the fast-forward
    expect(ci.lastActivity, DateTime.utc(2026, 9, 10, 12));
  });

  test('stale and pruned dates', () {
    expect(
      branch('experiment/wasm-build').lastActivity,
      DateTime.utc(2025, 8, 10, 10),
    );
    expect(
      branch('feature/old-editor').lastActivity,
      DateTime.utc(2026, 3, 10, 9),
    );
    expect(branch('feature/old-editor').author, 'lena');
  });

  test('capBranches keeps the most recent and re-parents orphans', () {
    // Make feature/i18n old and hang it under release/2.0, so that the
    // sub-branch's parent is dropped but the grandparent is kept.
    final branches = [
      for (final b in snap.branches)
        if (b.name == 'feature/i18n')
          b.copyWith(parent: 'release/2.0', lastActivity: DateTime.utc(2020))
        else
          b,
    ];
    final (:kept, :omitted) = capBranches(branches, max: 3);
    expect(kept.map((b) => b.name), [
      'feature/i18n-rtl',
      'release/2.0',
      'feature/plugin-api',
    ]);
    expect(omitted, 8);
    expect(kept.first.parent, 'release/2.0');
  });

  test('capBranches re-parents to the trunk when no ancestor is kept', () {
    final (:kept, omitted: _) = capBranches(snap.branches, max: 1);
    expect(kept.single.name, 'feature/i18n-rtl');
    expect(kept.single.parent, isNull);
  });

  test('unknown repository surfaces as an error event', () async {
    final stream = RepoRepository(api, clock: () => now).plant('no', 'such');
    await expectLater(stream, emitsError(anything));
  });
}
