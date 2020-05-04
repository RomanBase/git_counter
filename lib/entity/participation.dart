import 'dart:math' as math;

import 'package:flutter_control/core.dart';

class Participation {
  final List<int> all;
  final List<int> owner;

  int get ownerCount => owner.reduce((a, b) => a + b);

  int get allCount => all.reduce((a, b) => a + b);

  int get othersCount => allCount - ownerCount;

  const Participation({
    this.all,
    this.owner,
  });

  factory Participation.fromJson(Map data) => Participation(
        all: Parse.toList<int>(data['all']),
        owner: Parse.toList<int>(data['owner']),
      );

  Participation combine(List<Participation> list) {
    final all = List<int>.filled(list.fold(0, (max, item) => math.max(max, item.all.length)), 0);
    final owner = List<int>.filled(all.length, 0);

    for (int i = 0; i < all.length; i++) {
      list.forEach((participation) {
        if (i < participation.all.length) {
          all[i] = all[i] + participation.all[i];
          owner[i] = owner[i] + participation.owner[i];
        }
      });
    }

    return Participation(
      all: all,
      owner: owner,
    );
  }
}
