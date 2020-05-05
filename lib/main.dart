import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_control/core.dart';
import 'package:git_counter/clock/clock.dart';
import 'package:git_counter/config.dart';
import 'package:git_counter/counter_page.dart';
import 'package:git_counter/git/counter_control.dart';
import 'package:git_counter/git/counter_repo.dart';
import 'package:git_counter/git/graph_repo.dart';
import 'package:git_counter/weather/weather.dart';
import 'package:git_counter/weather/weather_repo.dart';

void main() => runApp(MainApp());

class MainApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return ControlRoot(
      debug: true,
      entries: {
        ClockControl: ClockControl(),
        WeatherControl: WeatherControl(),
      },
      initializers: {
        CounterRepo: (_) => CounterRepo(),
        GraphRepo: (_) => GraphRepo(GraphQLConfig.token /*provide your API KEY*/),
        CounterControl: (_) => CounterControl('RomanBase' /*git username*/),
        WeatherRepo: (_) => WeatherRepo(),
      },
      loader: (context) => InitLoader.of(
        builder: (context) => Container(
          color: Colors.white,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      root: (_, __) => CounterPage(),
      app: (context, key, home) => MaterialApp(
        key: key,
        home: home,
        title: 'Git Counter',
        theme: ThemeData(
          primaryColor: Color(0xFF252525),
          primaryColorLight: Color(0xFF454545),
          primaryColorDark: Color(0xFF050505),
          accentColor: Color(0xFFCCFFFF),
          accentTextTheme: TextTheme(
            display1: TextStyle(fontSize: 64.0, color: Color(0xFFCCFFAA), fontWeight: FontWeight.bold),
            body2: TextStyle(fontSize: 18.0, color: Color(0xFFCCFFAA), fontWeight: FontWeight.w100),
          ),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
