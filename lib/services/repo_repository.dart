import '../models/repo_models.dart';
import 'github_service.dart';

class RepoRepository {
  final GitHubService _api = GitHubService();

  Future<RepoTree> getFullTree(String owner, String repoName) async {
    // 1. Fetch everything in parallel for speed
    final results = await Future.wait([
      _api.getRepoMeta(owner, repoName),
      _api.getContributors(owner, repoName),
      _api.getBranches(owner, repoName),
      _api.getMergedPRs(owner, repoName),
    ]);

    final meta = results[0] as RepoMeta;
    final rawContributors = results[1] as List<Map<String, dynamic>>;
    final rawBranches = results[2] as List<Map<String, dynamic>>;
    final rawPRs = results[3] as List<Map<String, dynamic>>;

    // 2. Map of Login -> List of GitBranch (The grouping "bucket")
    final Map<String, List<GitBranch>> branchMap = {};

    // 3. Process Merged PRs (The historical branches)
    // Most deleted branches were originally part of a Pull Request.
    for (var pr in rawPRs) {
      if (pr['merged_at'] == null) continue;

      final author = pr['user']['login'];
      final branchName = pr['head']['ref'];

      final branch = GitBranch(
        name: branchName,
        status: BranchStatus.merged,
        commitCount: 1, // Placeholder: PRs don't show commit count in list
        lastCommitDate: DateTime.parse(pr['merged_at']),
      );

      branchMap.putIfAbsent(author, () => []).add(branch);
    }

    // 4. Process Active Branches
    // Note: To be truly "smart", we'd fetch the last commit of each branch
    // to find the owner, but for now, we'll assign them to the repo owner
    // or keep them as "Main" growth.
    for (var b in rawBranches) {
      final name = b['name'];
      if (name == meta.defaultBranch) continue; // Skip main trunk

      final branch = GitBranch(
        name: name,
        status: BranchStatus.active,
        commitCount: 0,
        lastCommitDate: DateTime.now(), // Placeholder
      );

      // Simple logic: if we saw this branch in a PR, it's already assigned.
      // If not, we could put it in a "General" bucket or skip.
    }

    // 5. Build the Contributor models with their specific branches
    final contributors = rawContributors.map((c) {
      final login = c['login'];
      return ContributorBranch(
        login: login,
        avatarUrl: c['avatar_url'],
        totalCommits: c['contributions'],
        branches: branchMap[login] ?? [], // Inject the branches we found!
      );
    }).toList();

    return RepoTree(repo: meta, contributors: contributors);
  }
}
