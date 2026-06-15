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
    @JsonKey(name: 'full_name') required String fullName,
    String? description,
    @JsonKey(name: 'created_at') DateTime? createdAt, // Nullable
    @JsonKey(name: 'stargazers_count')
    @Default(0)
    int starCount, // Default to 0
    String? primaryLanguage,
    @JsonKey(name: 'default_branch') @Default('main') String defaultBranch,
  }) = _RepoMeta;

  factory RepoMeta.fromJson(Map<String, dynamic> json) =>
      _$RepoMetaFromJson(json);
}

@freezed
abstract class ContributorBranch with _$ContributorBranch {
  const factory ContributorBranch({
    required String login,
    @JsonKey(name: 'avatar_url') String? avatarUrl, // Nullable
    required List<GitBranch> branches,
    @Default(0) int totalCommits,
  }) = _ContributorBranch;
}

enum BranchStatus { active, merged, stale }

@freezed
abstract class GitBranch with _$GitBranch {
  const factory GitBranch({
    required String name,
    @Default(BranchStatus.active) BranchStatus status,
    @Default(0) int commitCount,
    DateTime? lastCommitDate, // Nullable
  }) = _GitBranch;
}
