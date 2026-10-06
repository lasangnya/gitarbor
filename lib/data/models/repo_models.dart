import 'package:freezed_annotation/freezed_annotation.dart';

part 'repo_models.freezed.dart';

/// How a branch is drawn: a growing limb, a drooping dry limb, a blossoming
/// limb or a cut stub.
enum BranchStatus { active, stale, merged, pruned }

@freezed
abstract class Author with _$Author {
  const factory Author({
    required String login,
    String? avatarUrl,
    @Default(0) int commits,
  }) = _Author;
}

@freezed
abstract class Commit with _$Commit {
  const factory Commit({
    required String sha,

    /// First line of the commit message.
    required String message,

    /// GitHub login, or the git author name when the commit is not linked
    /// to an account.
    required String author,
    required DateTime date,
  }) = _Commit;
}

@freezed
abstract class Branch with _$Branch {
  const Branch._();

  const factory Branch({
    required String name,
    required BranchStatus status,

    /// The branch no longer exists on GitHub and was recovered from a PR.
    @Default(false) bool deleted,

    /// Commits on this branch that are not on its parent, newest first.
    /// May be fewer than [commitCount] when GitHub truncates the list.
    @Default(<Commit>[]) List<Commit> commits,
    @Default(0) int commitCount,

    /// The branch it forked from; null means the default branch (the trunk).
    String? parent,

    /// Merge base with the parent, used to place the fork on the trunk.
    String? forkSha,
    DateTime? forkDate,

    /// Newest commit, or the PR close date for a pruned branch.
    DateTime? lastActivity,

    /// Login of the author with the most commits on the branch.
    String? author,
    int? prNumber,
  }) = _Branch;

  bool get isSubBranch => parent != null;
}

@freezed
abstract class RepoSnapshot with _$RepoSnapshot {
  const RepoSnapshot._();

  const factory RepoSnapshot({
    required String owner,
    required String name,
    String? description,
    @Default(0) int stars,
    required String defaultBranch,

    /// Newest commits of the default branch, newest first.
    @Default(<Commit>[]) List<Commit> trunkCommits,

    /// Drawn branches, most recently active first.
    @Default(<Branch>[]) List<Branch> branches,

    /// Authors sorted by commit count, highest first.
    @Default(<Author>[]) List<Author> authors,

    /// Branches left out by the branch cap.
    @Default(0) int omittedBranches,
    required DateTime fetchedAt,
  }) = _RepoSnapshot;

  String get fullName => '$owner/$name';

  int get totalCommits =>
      trunkCommits.length + branches.fold(0, (n, b) => n + b.commitCount);

  int countOf(BranchStatus s) => branches.where((b) => b.status == s).length;
}
