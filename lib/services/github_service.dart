import 'package:dio/dio.dart';
import '../models/repo_models.dart';

class GithubService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://api.github.com/'));

  Future<RepoMeta> getRepoMeta(String owner, String repo) async{
    final response = await _dio.get('repos/$owner/$repo');
    return RepoMeta.fromJson(response.data);
  }

  //TODO : 1. Fetch contributors 2. Fetch Branches 3. Fetch closed PRs
}