import 'dart:convert';

import 'package:flutter_control/core.dart';
import 'package:http/http.dart' as http;

import 'entity/contribution.dart';
import 'entity/repository.dart';
import 'entity/user.dart';

class CounterRepo {
  static const url = 'https://api.github.com';

  static const usersUrl = '$url/users/{user}';

  static const reposUrl = '$usersUrl/repos';

  static const followersUrl = '$usersUrl/followers';

  static const subsUrl = '$usersUrl/subscriptions';

  static const repoUrl = '$url/{user}/{repo}';

  static const statsUrl = '$reposUrl/stats';

  static const participationUrl = '$statsUrl/participation';

  static const contributionsUrl = 'https://github-contributions-api.now.sh/v1/{user}';

  String _formatUserUrl(String url, String user) => Parse.format(
        url,
        {
          'user': user,
        },
      );

  String _formatRepoUrl(String url, String user, String repo) => Parse.format(
        url,
        {
          'user': user,
          'repo': repo,
        },
      );

  Future<User> getUser(String username) async {
    final response = await http.get(_formatUserUrl(usersUrl, username));

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }

    throw response.body ?? response.reasonPhrase;
  }

  Future<List<Repository>> getRepos(String username, [int page = 1, int count = 30]) async {
    final response = await http.get(_formatUserUrl(reposUrl, username) + '?page=$page&per_page=$count');

    if (response.statusCode == 200) {
      return Repository.toList(jsonDecode(response.body));
    }

    throw response.body ?? response.reasonPhrase;
  }

  Future<List<Repository>> getAllRepos(String username) async {
    return _getRepos(username, List(), 1, 100);
  }

  Future<List<Repository>> _getRepos(String username, List<Repository> fill, int page, int count) async {
    final list = await getRepos(username, page, count);

    fill.addAll(list);

    if (list.length == count) {
      return _getRepos(username, fill, page + 1, count);
    }

    return fill;
  }

  Future<Contribution> getContributions(String username) async {
    final response = await http.get(_formatUserUrl(contributionsUrl, username));

    if (response.statusCode == 200) {
      return Contribution.fromJson(jsonDecode(response.body));
    }

    throw response.body ?? response.reasonPhrase;
  }
}
