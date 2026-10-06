/// The GitHub REST calls the tree needs, returning decoded JSON.
///
/// [GitHubClient] implements this over HTTP; tests replay recorded fixtures.
abstract interface class GitHubApi {
  /// `GET /repos/{owner}/{repo}`
  Future<Map<String, dynamic>> getRepo(String owner, String repo);

  /// `GET /repos/{owner}/{repo}/branches`, every page.
  Future<List<Map<String, dynamic>>> listBranches(String owner, String repo);

  /// `GET /repos/{owner}/{repo}/pulls?state=all&sort=updated&direction=desc`,
  /// up to [max] pull requests.
  Future<List<Map<String, dynamic>>> listPulls(
    String owner,
    String repo, {
    int max = 300,
  });

  /// `GET /repos/{owner}/{repo}/compare/{base}...{head}`
  Future<Map<String, dynamic>> compare(
    String owner,
    String repo,
    String base,
    String head,
  );

  /// `GET /repos/{owner}/{repo}/commits?sha={sha}`, up to [max] commits.
  Future<List<Map<String, dynamic>>> listCommits(
    String owner,
    String repo,
    String sha, {
    int max = 300,
  });

  /// `GET /repos/{owner}/{repo}/pulls/{number}/commits`, up to [max] commits.
  Future<List<Map<String, dynamic>>> pullCommits(
    String owner,
    String repo,
    int number, {
    int max = 250,
  });
}

sealed class GitHubException implements Exception {
  const GitHubException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// 404: the repository does not exist, or it is private and we lack access.
class RepoNotFoundException extends GitHubException {
  const RepoNotFoundException(super.message);
}

/// 401, or 403 without an exhausted rate limit: the token is bad or lacks
/// scope.
class UnauthorizedException extends GitHubException {
  const UnauthorizedException(super.message);
}

/// The hourly limit is used up; [resetAt] says when it refills.
class RateLimitException extends GitHubException {
  const RateLimitException(super.message, {required this.resetAt});
  final DateTime resetAt;
}

/// No connection, a timeout, or a 5xx from GitHub.
class NetworkException extends GitHubException {
  const NetworkException(super.message);
}
