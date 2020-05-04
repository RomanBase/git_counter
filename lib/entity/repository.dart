import 'package:flutter_control/core.dart';
import 'package:git_counter/entity/user.dart';

class Repository extends RepositoryCounter {
  final int id;
  final String name;
  final bool private;
  final bool fork;
  final bool archived;
  final bool disabled;

  final User owner;

  Repository({
    this.id,
    this.name,
    this.private,
    this.fork,
    this.archived,
    this.disabled,
    int forks,
    int stars,
    int watchers,
    int issues,
    this.owner,
  }) : super(
          forks: forks,
          stars: stars,
          watchers: watchers,
          issues: issues,
        );

  factory Repository.fromJson(Map data) => Repository(
        id: data['id'],
        name: data['name'],
        private: Parse.toBool(data['private'], defaultValue: true),
        fork: Parse.toBool(data['fork']),
        archived: Parse.toBool(data['private']),
        disabled: Parse.toBool(data['fork']),
        forks: Parse.toInteger(data['forks_count']),
        stars: Parse.toInteger(data['stargazers_count']),
        watchers: Parse.toInteger(data['watchers_count']),
        issues: Parse.toInteger(data['open_issues_count']),
        owner: User.fromJson(data['owner']),
      );

  static List<Repository> toList(List json) => Parse.toList(json, converter: (data) => Repository.fromJson(data));
}

class RepositoryCounter {
  final int forks;
  final int stars;
  final int watchers;
  final int issues;

  const RepositoryCounter({
    this.forks: 0,
    this.stars: 0,
    this.watchers: 0,
    this.issues: 0,
  });

  operator +(RepositoryCounter other) => RepositoryCounter(
        forks: forks + other.forks,
        stars: stars + other.stars,
        watchers: watchers + other.watchers,
        issues: issues + other.issues,
      );
}
