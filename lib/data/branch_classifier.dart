import 'models/repo_models.dart';

/// Branches with no commit for this long are stale.
const staleAfter = Duration(days: 90);

/// v1 draws at most this many branches, the most recently active.
const maxBranches = 40;

/// One branch to fetch and classify, before its commits are known.
class BranchPlan {
  const BranchPlan({
    required this.name,
    required this.exists,
    this.parent,
    this.pr,
  });

  final String name;

  /// Still listed by `GET /branches`. False means recovered from a PR.
  final bool exists;

  /// Branch it forked from; null is the default branch.
  final String? parent;

  /// The newest pull request whose head is this branch.
  final Map<String, dynamic>? pr;

  int? get prNumber => pr?['number'] as int?;
  bool get prMerged => pr?['merged_at'] != null;
}

/// Works out which branches to draw and what each forked from.
///
/// Existing branches come from [branchesJson]; deleted ones are recovered
/// from closed pull requests whose head branch is gone. Pull requests from
/// forks are ignored because their heads are not branches of this repo.
List<BranchPlan> planBranches({
  required String repoFullName,
  required String defaultBranch,
  required List<Map<String, dynamic>> branchesJson,
  required List<Map<String, dynamic>> pullsJson,
}) {
  final existing = <String>{for (final b in branchesJson) b['name'] as String}
    ..remove(defaultBranch);

  // Newest PR per head branch. The API returns them by update time, but
  // sort again so fixtures and odd pages can't change the answer.
  final pulls = [...pullsJson]
    ..sort((a, b) => _date(b['updated_at']).compareTo(_date(a['updated_at'])));
  final latestPr = <String, Map<String, dynamic>>{};
  for (final pr in pulls) {
    final head = pr['head'] as Map<String, dynamic>?;
    final ref = head?['ref'] as String?;
    if (ref == null || ref == defaultBranch) continue;
    final headRepo = (head?['repo'] as Map<String, dynamic>?)?['full_name'];
    if (headRepo != null &&
        (headRepo as String).toLowerCase() != repoFullName.toLowerCase()) {
      continue;
    }
    latestPr.putIfAbsent(ref, () => pr);
  }

  final deleted = <String>{
    for (final e in latestPr.entries)
      if (!existing.contains(e.key) && e.value['state'] == 'closed') e.key,
  };
  final known = {...existing, ...deleted};

  final parents = <String, String?>{};
  for (final name in known) {
    final base =
        (latestPr[name]?['base'] as Map<String, dynamic>?)?['ref'] as String?;
    parents[name] =
        base != null && base != defaultBranch && known.contains(base)
        ? base
        : null;
  }
  _breakCycles(parents);

  return [
    for (final name in [...existing, ...deleted]..sort())
      BranchPlan(
        name: name,
        exists: existing.contains(name),
        parent: parents[name],
        pr: latestPr[name],
      ),
  ];
}

void _breakCycles(Map<String, String?> parents) {
  for (final start in parents.keys) {
    final seen = <String>{start};
    var cur = parents[start];
    while (cur != null) {
      if (!seen.add(cur)) {
        parents[start] = null;
        break;
      }
      cur = parents[cur];
    }
  }
}

/// Turns fetched data into drawable branches.
///
/// [compares] holds `compare/{parent}...{branch}` responses for existing
/// branches; [pullCommits] holds `pulls/{n}/commits` keyed by PR number,
/// needed for deleted branches and for merged branches whose commits are
/// already all on the parent.
List<Branch> classifyBranches({
  required List<BranchPlan> plans,
  required Map<String, Map<String, dynamic>> compares,
  required Map<int, List<Map<String, dynamic>>> pullCommits,
  required DateTime now,
}) {
  final out = <Branch>[];
  for (final plan in plans) {
    final branch = plan.exists
        ? _classifyExisting(plan, compares[plan.name], pullCommits, now)
        : _classifyDeleted(plan, pullCommits);
    if (branch != null) out.add(branch);
  }
  return out;
}

Branch? _classifyExisting(
  BranchPlan plan,
  Map<String, dynamic>? cmp,
  Map<int, List<Map<String, dynamic>>> pullCommits,
  DateTime now,
) {
  if (cmp == null) return null;
  final cmpStatus = cmp['status'] as String?;
  var commits = _newestFirst(
    (cmp['commits'] as List? ?? const []).cast<Map<String, dynamic>>(),
  );
  var count = (cmp['ahead_by'] as int?) ?? commits.length;
  final base = cmp['merge_base_commit'] as Map<String, dynamic>?;
  final forkDate = base == null ? null : _commitDate(base);

  final mergedAt = _maybeDate(plan.pr?['merged_at']);
  final newest = commits.isEmpty ? null : commits.first.date;
  // A merged PR counts unless work continued on the branch afterwards.
  final prMerged =
      mergedAt != null && (newest == null || !newest.isAfter(mergedAt));
  final merged = prMerged || cmpStatus == 'behind' || cmpStatus == 'identical';

  // A fast-forwarded or rebased branch has nothing ahead of its parent;
  // its PR still knows which commits it carried.
  if (commits.isEmpty && plan.prNumber != null) {
    final prc = pullCommits[plan.prNumber];
    if (prc != null) {
      commits = _newestFirst(prc);
      count = commits.length;
    }
  }

  final lastActivity = newest ?? mergedAt ?? forkDate;
  final BranchStatus status;
  if (merged) {
    status = BranchStatus.merged;
  } else if (lastActivity != null &&
      now.difference(lastActivity) < staleAfter) {
    status = BranchStatus.active;
  } else {
    status = BranchStatus.stale;
  }

  return Branch(
    name: plan.name,
    status: status,
    commits: commits,
    commitCount: count,
    parent: plan.parent,
    forkSha: base?['sha'] as String?,
    forkDate: forkDate,
    lastActivity: lastActivity,
    author: _mainAuthor(commits) ?? _prUser(plan.pr),
    prNumber: plan.prNumber,
  );
}

Branch _classifyDeleted(
  BranchPlan plan,
  Map<int, List<Map<String, dynamic>>> pullCommits,
) {
  final pr = plan.pr!;
  final commits = _newestFirst(pullCommits[plan.prNumber] ?? const []);
  final merged = plan.prMerged;
  return Branch(
    name: plan.name,
    status: merged ? BranchStatus.merged : BranchStatus.pruned,
    deleted: true,
    commits: commits,
    commitCount: (pr['commits'] as int?) ?? commits.length,
    parent: plan.parent,
    // No merge base for a deleted branch: use the PR's base commit, dated
    // by the first commit of the PR.
    forkSha: (pr['base'] as Map<String, dynamic>?)?['sha'] as String?,
    forkDate: commits.isEmpty ? null : commits.last.date,
    lastActivity: _maybeDate(merged ? pr['merged_at'] : pr['closed_at']),
    author: _mainAuthor(commits) ?? _prUser(pr),
    prNumber: plan.prNumber,
  );
}

/// Keeps the [max] most recently active branches. A kept sub-branch whose
/// parent was dropped re-attaches to the nearest kept ancestor, or the trunk.
({List<Branch> kept, int omitted}) capBranches(
  List<Branch> branches, {
  int max = maxBranches,
}) {
  final sorted = [...branches]
    ..sort((a, b) {
      final c = (b.lastActivity ?? _epoch).compareTo(a.lastActivity ?? _epoch);
      return c != 0 ? c : a.name.compareTo(b.name);
    });
  final kept = sorted.take(max).toList();
  final keptNames = {for (final b in kept) b.name};
  final parentOf = {for (final b in branches) b.name: b.parent};
  String? keptAncestor(String? p) {
    while (p != null && !keptNames.contains(p)) {
      p = parentOf[p];
    }
    return p;
  }

  return (
    kept: [
      for (final b in kept)
        keptNames.contains(b.parent) || b.parent == null
            ? b
            : b.copyWith(parent: keptAncestor(b.parent)),
    ],
    omitted: sorted.length - kept.length,
  );
}

/// Commit counts per author over the trunk and every branch.
List<Author> aggregateAuthors(List<Commit> trunk, List<Branch> branches) {
  final counts = <String, int>{};
  for (final c in [...trunk, for (final b in branches) ...b.commits]) {
    counts[c.author] = (counts[c.author] ?? 0) + 1;
  }
  final authors =
      [for (final e in counts.entries) Author(login: e.key, commits: e.value)]
        ..sort((a, b) {
          final c = b.commits.compareTo(a.commits);
          return c != 0 ? c : a.login.compareTo(b.login);
        });
  return authors;
}

/// Parses one item of a GitHub commit list (`commits`, `compare`,
/// `pulls/{n}/commits` all share this shape).
Commit parseCommit(Map<String, dynamic> json) {
  final commit = json['commit'] as Map<String, dynamic>;
  final gitAuthor = commit['author'] as Map<String, dynamic>?;
  final login = (json['author'] as Map<String, dynamic>?)?['login'] as String?;
  final message = (commit['message'] as String? ?? '').split('\n').first;
  return Commit(
    sha: json['sha'] as String,
    message: message.trim(),
    author: login ?? gitAuthor?['name'] as String? ?? 'unknown',
    date: _commitDate(json),
  );
}

List<Commit> _newestFirst(List<Map<String, dynamic>> json) =>
    json.map(parseCommit).toList()..sort((a, b) => b.date.compareTo(a.date));

DateTime _commitDate(Map<String, dynamic> json) {
  final commit = json['commit'] as Map<String, dynamic>;
  final when =
      (commit['author'] as Map<String, dynamic>?)?['date'] ??
      (commit['committer'] as Map<String, dynamic>?)?['date'];
  return _date(when);
}

String? _mainAuthor(List<Commit> commits) {
  if (commits.isEmpty) return null;
  final counts = <String, int>{};
  for (final c in commits) {
    counts[c.author] = (counts[c.author] ?? 0) + 1;
  }
  // Ties go to whoever committed first on the branch.
  String? best;
  var bestN = 0;
  for (final c in commits.reversed) {
    final n = counts[c.author]!;
    if (n > bestN) {
      best = c.author;
      bestN = n;
    }
  }
  return best;
}

String? _prUser(Map<String, dynamic>? pr) =>
    (pr?['user'] as Map<String, dynamic>?)?['login'] as String?;

final _epoch = DateTime.utc(1970);

DateTime _date(Object? v) => v is String ? DateTime.parse(v) : _epoch;
DateTime? _maybeDate(Object? v) => v is String ? DateTime.parse(v) : null;
