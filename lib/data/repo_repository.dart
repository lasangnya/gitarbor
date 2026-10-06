import 'dart:async';

import 'branch_classifier.dart';
import 'github_api.dart';
import 'models/repo_models.dart';

/// Progress while a repository is planted. The Growing screen grows the
/// tree a little further on each event.
sealed class PlantEvent {
  const PlantEvent();
}

class FoundRepo extends PlantEvent {
  const FoundRepo({
    required this.owner,
    required this.name,
    required this.defaultBranch,
    this.description,
    this.stars = 0,
  });
  final String owner;
  final String name;
  final String defaultBranch;
  final String? description;
  final int stars;
}

/// Commit history of [done] of [total] branches has been fetched.
class FetchingBranches extends PlantEvent {
  const FetchingBranches(this.done, this.total);
  final int done;
  final int total;
}

class MappedBranches extends PlantEvent {
  const MappedBranches({required this.counts, required this.omitted});
  final Map<BranchStatus, int> counts;
  final int omitted;
  int get total => counts.values.fold(0, (a, b) => a + b);
}

class CountedCommits extends PlantEvent {
  const CountedCommits({
    required this.commits,
    required this.authors,
    this.since,
  });
  final int commits;
  final int authors;
  final DateTime? since;
}

class Planted extends PlantEvent {
  const Planted(this.snapshot);
  final RepoSnapshot snapshot;
}

class RepoRepository {
  RepoRepository(this.api, {DateTime Function()? clock, this.concurrency = 6})
    : _clock = clock ?? DateTime.now;

  final GitHubApi api;
  final int concurrency;
  final DateTime Function() _clock;

  /// Existing branches compared per planting. Branch listings carry no
  /// dates, so the ones with the most recent PRs go first.
  static const maxCompared = 100;

  /// Fetches and classifies [owner]/[repo]. Errors arrive as
  /// [GitHubException]s on the stream. Cancelling the subscription stops
  /// further requests.
  Stream<PlantEvent> plant(String owner, String repo) {
    late final StreamController<PlantEvent> ctrl;
    var cancelled = false;
    ctrl = StreamController<PlantEvent>(
      onListen: () async {
        try {
          await _plant(owner, repo, (e) {
            if (!cancelled) ctrl.add(e);
          }, () => cancelled);
        } catch (e, st) {
          if (!cancelled) ctrl.addError(e, st);
        } finally {
          if (!cancelled) await ctrl.close();
        }
      },
      onCancel: () => cancelled = true,
    );
    return ctrl.stream;
  }

  Future<void> _plant(
    String owner,
    String repo,
    void Function(PlantEvent) emit,
    bool Function() cancelled,
  ) async {
    final meta = await api.getRepo(owner, repo);
    final fullName = meta['full_name'] as String? ?? '$owner/$repo';
    final [realOwner, realName] = fullName.split('/');
    final defaultBranch = meta['default_branch'] as String? ?? 'main';
    emit(
      FoundRepo(
        owner: realOwner,
        name: realName,
        defaultBranch: defaultBranch,
        description: meta['description'] as String?,
        stars: meta['stargazers_count'] as int? ?? 0,
      ),
    );
    if (cancelled()) return;

    final (branchesJson, pullsJson) = await (
      api.listBranches(realOwner, realName),
      api.listPulls(realOwner, realName),
    ).wait;
    if (cancelled()) return;

    final allPlans = planBranches(
      repoFullName: fullName,
      defaultBranch: defaultBranch,
      branchesJson: branchesJson,
      pullsJson: pullsJson,
    );
    final plans = _pickPlans(allPlans);
    final skipped = allPlans.length - plans.length;

    final trunkFuture = api.listCommits(realOwner, realName, defaultBranch);
    final compares = <String, Map<String, dynamic>>{};
    final pullCommits = <int, List<Map<String, dynamic>>>{};
    var done = 0;
    emit(FetchingBranches(0, plans.length));

    Future<void> fetch(BranchPlan p) async {
      if (p.exists) {
        final cmp = await api.compare(
          realOwner,
          realName,
          p.parent ?? defaultBranch,
          p.name,
        );
        compares[p.name] = cmp;
        // Fast-forwarded or rebased merges leave nothing ahead; the PR
        // still lists the commits.
        if ((cmp['ahead_by'] as int? ?? 0) == 0 && p.prMerged) {
          pullCommits[p.prNumber!] = await api.pullCommits(
            realOwner,
            realName,
            p.prNumber!,
          );
        }
      } else if (p.prNumber != null) {
        pullCommits[p.prNumber!] = await api.pullCommits(
          realOwner,
          realName,
          p.prNumber!,
        );
      }
      done++;
      emit(FetchingBranches(done, plans.length));
    }

    final queue = [...plans];
    Future<void> worker() async {
      while (queue.isNotEmpty && !cancelled()) {
        await fetch(queue.removeAt(0));
      }
    }

    await Future.wait([for (var i = 0; i < concurrency; i++) worker()]);
    final trunkJson = await trunkFuture;
    if (cancelled()) return;

    final classified = classifyBranches(
      plans: plans,
      compares: compares,
      pullCommits: pullCommits,
      now: _clock(),
    );
    final (:kept, :omitted) = capBranches(classified);
    emit(
      MappedBranches(
        counts: {
          for (final s in BranchStatus.values)
            s: kept.where((b) => b.status == s).length,
        },
        omitted: omitted + skipped,
      ),
    );

    final trunk = trunkJson.map(parseCommit).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final authors = aggregateAuthors(trunk, kept);
    final allDates = [
      for (final c in trunk) c.date,
      for (final b in kept)
        for (final c in b.commits) c.date,
    ];
    final snapshot = RepoSnapshot(
      owner: realOwner,
      name: realName,
      description: meta['description'] as String?,
      stars: meta['stargazers_count'] as int? ?? 0,
      defaultBranch: defaultBranch,
      trunkCommits: trunk,
      branches: kept,
      authors: authors,
      omittedBranches: omitted + skipped,
      fetchedAt: _clock(),
    );
    emit(
      CountedCommits(
        commits: snapshot.totalCommits,
        authors: authors.length,
        since: allDates.isEmpty
            ? null
            : allDates.reduce((a, b) => a.isBefore(b) ? a : b),
      ),
    );
    emit(Planted(snapshot));
  }

  /// Every deleted branch (their PR dates are known) plus up to
  /// [maxCompared] existing branches, those with recent PRs first.
  List<BranchPlan> _pickPlans(List<BranchPlan> plans) {
    final existing = plans.where((p) => p.exists).toList()
      ..sort((a, b) {
        final da = a.pr?['updated_at'] as String? ?? '';
        final db = b.pr?['updated_at'] as String? ?? '';
        final c = db.compareTo(da);
        return c != 0 ? c : a.name.compareTo(b.name);
      });
    final deleted = plans.where((p) => !p.exists).toList()
      ..sort((a, b) {
        final da = a.pr?['closed_at'] as String? ?? '';
        final db = b.pr?['closed_at'] as String? ?? '';
        return db.compareTo(da);
      });
    final keep = {...existing.take(maxCompared), ...deleted.take(maxBranches)};
    return [
      for (final p in plans)
        if (keep.contains(p)) p,
    ];
  }
}
