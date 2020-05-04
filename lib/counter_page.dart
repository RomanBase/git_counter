import 'dart:ui';

import 'package:flutter_control/core.dart';
import 'package:git_counter/counter_control.dart';

class CounterPage extends SingleControlWidget<CounterControl> with ThemeProvider {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    CounterItemWidget(
                      title: 'stars',
                      model: control.stars,
                      icon: 'star',
                      alignment: Alignment.topLeft,
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(),
                    ),
                    CounterItemWidget(
                      title: 'watchers',
                      model: control.watchers,
                      icon: 'watch',
                      alignment: Alignment.topRight,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: <Widget>[
                    CounterItemWidget(
                      title: 'contributions',
                      model: control.contributions,
                      icon: 'contrib',
                      alignment: Alignment.bottomLeft,
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(),
                    ),
                    CounterItemWidget(
                      title: 'issues',
                      model: control.issues,
                      icon: 'warning',
                      alignment: Alignment.bottomRight,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Center(
            child: Container(
              width: device.min * 0.65,
              height: device.min * 0.65,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(device.min * 0.325),
                color: theme.primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColorLight.withOpacity(0.75),
                    offset: Offset(-6.0, -6.0),
                    spreadRadius: 6.0,
                    blurRadius: 12.0,
                  ),
                  BoxShadow(
                    color: theme.primaryColorDark,
                    offset: Offset(6.0, 6.0),
                    spreadRadius: 6.0,
                    blurRadius: 12.0,
                  ),
                ],
              ),
              child: Container(
                margin: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(device.min * 0.325),
                  color: theme.primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColorDark,
                      offset: Offset(-2.0, -2.0),
                      spreadRadius: 2.0,
                      blurRadius: 4.0,
                    ),
                    BoxShadow(
                      color: theme.primaryColorLight.withOpacity(0.5),
                      offset: Offset(2.0, 2.0),
                      spreadRadius: 2.0,
                      blurRadius: 4.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
          LoadingBuilder(
            control: control.loading,
          ),
        ],
      ),
    );
  }
}

class CounterItemWidget extends StateboundWidget<CounterModel> with ThemeProvider {
  final String title;
  final String icon;
  final Alignment alignment;

  Alignment get boxAlign => alignment.add(Alignment(0.0, -alignment.y));

  double get width => device.max * 0.25;

  double get height => device.min * 0.25;

  CounterItemWidget({
    @required CounterModel model,
    this.title,
    this.icon: 'report_problem',
    this.alignment: Alignment.center,
  }) : super(control: model);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Align(
        alignment: boxAlign,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.horizontal(
              left: alignment.x > 0 ? Radius.circular(height * 0.5) : Radius.zero,
              right: alignment.x < 0 ? Radius.circular(height * 0.5) : Radius.zero,
            ),
            color: theme.primaryColor,
            boxShadow: [
              BoxShadow(
                color: theme.primaryColorLight.withOpacity(0.75),
                offset: Offset(-4.0, -4.0),
                spreadRadius: 4.0,
                blurRadius: 8.0,
              ),
              BoxShadow(
                color: theme.primaryColorDark,
                offset: Offset(4.0, 4.0),
                spreadRadius: 4.0,
                blurRadius: 8.0,
              ),
            ],
          ),
          child: Stack(
            children: <Widget>[
              Align(
                alignment: alignment,
                child: Image.asset(
                  asset.icon(icon),
                  color: theme.primaryColorDark,
                  height: double.infinity,
                  width: double.infinity,
                  alignment: alignment,
                ),
              ),
              Center(
                child: Text(
                  control.count.toString(),
                  style: TextStyle(
                    fontSize: 42.0,
                    fontWeight: FontWeight.bold,
                    color: theme.accentColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
