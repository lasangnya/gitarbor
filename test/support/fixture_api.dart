import 'dart:convert';
import 'dart:io';

import 'package:gitarbor/data/github_api.dart';

/// Replays the recorded `example/lantern` responses from
/// `test/fixtures/lantern`, counting calls per method.
class FixtureGitHubApi implements GitHubApi {
  FixtureGitHubApi({this.dir = 'test/fixtures/lantern'});

  final String dir;

  /// Calls per method name (`getRepo`, `compare`, ...).
  final calls = <String, int>{};

  /// Branch names passed to [compare] as the head, in call order.
  final comparedBranches = <String>[];

  /// Base branch passed to [compare] per head branch.
  final compareBases = <String, String>{};

  void _count(String name) => calls[name] = (calls[name] ?? 0) + 1;

  Object _read(String path) {
    final f = File('$dir/$path');
    if (!f.existsSync()) {
      throw const RepoNotFoundException('No such fixture.');
    }
    return jsonDecode(f.readAsStringSync()) as Object;
  }

  List<Map<String, dynamic>> _list(String path, int max) {
    final all = (_read(path) as List).cast<Map<String, dynamic>>();
    return all.length > max ? all.sublist(0, max) : all;
  }

  @override
  Future<Map<String, dynamic>> getRepo(String owner, String repo) async {
    _count('getRepo');
    if ('$owner/$repo'.toLowerCase() != 'example/lantern') {
      throw const RepoNotFoundException('Repository not found.');
    }
    return _read('repo.json') as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> listBranches(
    String owner,
    String repo,
  ) async {
    _count('listBranches');
    return _list('branches.json', 1 << 30);
  }

  @override
  Future<List<Map<String, dynamic>>> listPulls(
    String owner,
    String repo, {
    int max = 300,
  }) async {
    _count('listPulls');
    return _list('pulls.json', max);
  }

  @override
  Future<Map<String, dynamic>> compare(
    String owner,
    String repo,
    String base,
    String head,
  ) async {
    _count('compare');
    comparedBranches.add(head);
    compareBases[head] = base;
    return _read('compare/${head.replaceAll('/', '__')}.json')
        as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> listCommits(
    String owner,
    String repo,
    String sha, {
    int max = 300,
  }) async {
    _count('listCommits');
    return _list('commits_main.json', max);
  }

  @override
  Future<List<Map<String, dynamic>>> pullCommits(
    String owner,
    String repo,
    int number, {
    int max = 250,
  }) async {
    _count('pullCommits');
    return _list('pull_commits/$number.json', max);
  }
}
