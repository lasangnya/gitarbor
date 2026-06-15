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

    // 2. Process Contributors into our models
    final contributors = rawContributors.map((c) {
      return ContributorBranch(
        login: c['login'],
        avatarUrl: c['avatar_url'],
        totalCommits: c['contributions'],
        branches: [], // We will fill this in the next step!
      );
    }).toList();

    // 3. TODO: Assign branches to contributors
    // This is a great exercise for you!
    // Logic: Look at a branch, find who last committed to it,
    // and add it to that contributor's list.

    return RepoTree(repo: meta, contributors: contributors);
  }
}
