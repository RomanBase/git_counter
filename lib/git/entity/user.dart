import 'package:flutter_control/core.dart';

class User {
  final int id;
  final String name;
  final int followers;
  final int repos;

  User({
    this.id,
    this.name,
    this.followers,
    this.repos,
  });

  factory User.fromJson(Map data) => User(
        id: data['id'],
        name: data['login'],
        followers: Parse.toInteger(data['followers']),
        repos: Parse.toInteger(data['public_repos']),
      );

  static List<User> toList(List json) => Parse.toList(json, converter: (data) => User.fromJson(data));
}
