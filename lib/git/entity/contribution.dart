import 'package:flutter_control/core.dart';

class Contribution {
  final List<YearContribution> years;
  final List<DayContribution> days;

  int get total => years.fold<int>(0, (count, item) => count += item.count);

  const Contribution({
    this.years,
    this.days,
  });

  factory Contribution.fromJson(Map data) => Contribution(
        years: Parse.toList(data['years'], converter: (data) => YearContribution.fromJson(data)),
        days: Parse.toList(data['contributions'], converter: (data) => DayContribution.fromJson(data)),
      );
}

class YearContribution {
  final String year;
  final int count;

  const YearContribution({
    this.year,
    this.count,
  });

  factory YearContribution.fromJson(Map data) => YearContribution(
        year: data['year'],
        count: Parse.toInteger(data['total']),
      );
}

class DayContribution {
  final String date;
  final int count;
  final int intensity;

  const DayContribution({
    this.date,
    this.count,
    this.intensity,
  });

  factory DayContribution.fromJson(Map data) => DayContribution(
        date: data['date'],
        count: Parse.toInteger(data['count']),
        intensity: Parse.toInteger(data['intensity']),
      );
}
