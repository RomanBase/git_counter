import 'dart:async';

import 'package:flutter_control/core.dart';
import 'package:git_counter/git/counter_repo.dart';

import 'entity/repository.dart';

class CounterModel extends ControlModel with StateControl {
  final String name;

  int _count = 0;

  int get count => _count;

  String _message;

  String get message => _message;

  CounterModel(this.name);

  void update(int count, [String message]) {
    _count = count;
    _message = message;

    notifyState();
  }
}

class CounterControl extends BaseControl {
  CounterRepo get repo => Control.get<CounterRepo>();

  final loading = LoadingControl();
  final repositories = ListControl<Repository>();

  final stars = CounterModel('stars');
  final watchers = CounterModel('watchers');
  final issues = CounterModel('issues');
  final follows = CounterModel('followers');
  final sponsors = CounterModel('sponsors');
  final contributions = CounterModel('contributions');

  Timer _timer;

  String _username = 'RomanBase';

  String get username => _username;

  @override
  void onInit(Map args) {
    super.onInit(args);

    repositories.subscribe(_countRepos);

    reload();
  }

  @override
  Future<void> reload() async {
    loading.progress();

    final user = repo.getUser(username).then((user) {
      follows.update(user.followers);
    }).catchError((err) {
      printDebug(err.toString());
    });

    final repos = repo.getAllRepos(username).then((items) {
      repositories.setValue(items);
    }).catchError((err) {
      printDebug(err.toString());
    });

    final contribution = repo.getContributions(username).then((contribution) {
      contributions.update(contribution.total);
    }).catchError((err) {
      printDebug(err.toString());
    });

    await Future.wait([
      user,
      repos,
      contribution,
    ]);

    loading.done();

    _timer = Timer(Duration(minutes: 60) - Duration(minutes: DateTime.now().minute, seconds: DateTime.now().second), reload);
  }

  void _countRepos(List<Repository> repos) {
    RepositoryCounter counter = RepositoryCounter();

    repos.forEach((repo) {
      if (repo.owner.name == username) {
        counter += repo;
      }
    });

    stars.update(counter.stars);
    watchers.update(counter.forks);
    issues.update(counter.issues);
  }

  @override
  void dispose() {
    super.dispose();

    loading.dispose();
    repositories.dispose();
    stars.dispose();
    watchers.dispose();
    issues.dispose();
    follows.dispose();
    sponsors.dispose();
    contributions.dispose();

    _timer?.cancel();
  }
}
