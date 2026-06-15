import 'package:freezed_annotation/freezed_annotation.dart';

part 'repo_models.freezed.dart';
part 'repo_models.g.dart';

@freezed
abstract class RepoTree with _$RepoTree {
  const factory RepoTree({
    required RepoMeta repo,
    required List<ContributorBranch> contributors,
  }) = _RepoTree;
}

@freezed
abstract class RepoMeta with _$RepoMeta {
  const factory RepoMeta({
    required String name,
    required String fullName,
    String? description,
    required DateTime createdAt,
    required int starCount,
    String? primaryLanguage,
    required String defaultBranch,
  }) = _RepoMeta;

  factory RepoMeta.fromJson(Map<String, dynamic> json) => _$RepoMetaFromJson(json);
}

@freezed
abstract class ContributorBranch with _$ContributorBranch {
  const factory ContributorBranch({
    required String login,
    required String avatarUrl,
    required List<GitBranch> branches,
    required int totalCommits,
  }) = _ContributorBranch;
}

enum BranchStatus { active, merged, stale }

@freezed
abstract class GitBranch with _$GitBranch {
  const factory GitBranch({
    required String name,
    required BranchStatus status,
    required int commitCount,
    required DateTime lastCommitDate,
  }) = _GitBranch;
}