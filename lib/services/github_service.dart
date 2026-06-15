import 'package:dio/dio.dart';
import '../models/repo_models.dart';

class GitHubService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.github.com/',
      headers: {
        'Accept': 'application/vnd.github.v3+json',
        // 'Authorization': 'token YOUR_TOKEN',
        // Add this later for higher rate limits
      },
    ),
  );

  /// Fetch basic repo details
  Future<RepoMeta> getRepoMeta(String owner, String repo) async {
    final response = await _dio.get('repos/$owner/$repo');
    return RepoMeta.fromJson(response.data);
  }

  /// Fetch contributors (used for the major limbs)
  Future<List<Map<String, dynamic>>> getContributors(
    String owner,
    String repo,
  ) async {
    final response = await _dio.get('repos/$owner/$repo/contributors');
    return List<Map<String, dynamic>>.from(response.data);
  }

  /// Fetch current active branches
  Future<List<Map<String, dynamic>>> getBranches(
    String owner,
    String repo,
  ) async {
    final response = await _dio.get('repos/$owner/$repo/branches');
    return List<Map<String, dynamic>>.from(response.data);
  }

  /// Fetch merged PRs to recover deleted branch names
  Future<List<Map<String, dynamic>>> getMergedPRs(
    String owner,
    String repo,
  ) async {
    final response = await _dio.get(
      'repos/$owner/$repo/pulls',
      queryParameters: {'state': 'closed', 'per_page': 100},
    );
    return List<Map<String, dynamic>>.from(response.data);
  }
}
