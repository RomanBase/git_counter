import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_control/core.dart';
import 'package:git_counter/counter_control.dart';
import 'package:git_counter/counter_page.dart';
import 'package:git_counter/counter_repo.dart';

void main() => runApp(MainApp());

class MainApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return ControlRoot(
      debug: true,
      initializers: {
        CounterRepo: (_) => CounterRepo(),
        CounterControl: (_) => CounterControl(),
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
          primaryColor: Color(0xFF151515),
          primaryColorLight: Color(0xFF202020),
          primaryColorDark: Color(0xFF101010),
          accentColor: Color(0x30CCFFFF),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
