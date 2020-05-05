import 'dart:async';

import 'package:flutter_control/core.dart';
import 'package:git_counter/clock/invert_clipper.dart';
import 'package:git_counter/weather/weather.dart';
import 'package:intl/intl.dart';

import 'clock_progress.dart';

class ClockControl extends BaseControl {
  final date = StringControl();
  final hour = StringControl();
  final minute = StringControl();

  final hProgress = DoubleControl.inRange();
  final mProgress = DoubleControl.inRange();
  final sProgress = DoubleControl.inRange();

  Timer _timer;
  DateTime _time;

  @override
  void onInit(Map args) {
    super.onInit(args);

    _time = DateTime.now();

    _tick();
  }

  void _tick() {
    _time = DateTime.now();

    date.value = DateFormat('EEE, MMM dd').format(_time);
    hour.value = DateFormat('H').format(_time);
    minute.value = DateFormat('mm').format(_time);

    hProgress.value = ((_time.hour >= 12 ? _time.hour - 12 : _time.hour) * 3600 + _time.minute * 60) / (12.0 * 3600.0);
    mProgress.value = (_time.minute * 60 + _time.second) / 3600.0;
    sProgress.value = _time.second / 60.0;

    _cancelTimer();

    _timer = Timer(Duration(seconds: 1) - Duration(milliseconds: _time.millisecond), _tick);
  }

  void _cancelTimer() {
    if (_timer != null) {
      if (_timer.isActive) {
        _timer.cancel();
      }
    }

    _timer = null;
  }

  @override
  void dispose() {
    super.dispose();

    _cancelTimer();
    hour.dispose();
    minute.dispose();
    hProgress.dispose();
    mProgress.dispose();
  }
}

class ClockSeconds extends SingleControlWidget<ClockControl> with ThemeProvider {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: InvertedCircleClipper(
        stroke: 16.0,
        padding: 0.0,
      ),
      child: FieldBuilder<double>(
        control: control.sProgress,
        builder: (context, value) => ClockProgress(
          progress: value,
          colors: [theme.primaryColor, theme.primaryColorLight, theme.fontAccent.body2.color],
          stops: [0.0, 0.75, 1.0],
        ),
      ),
    );
  }
}

class Clock extends SingleControlWidget<ClockControl> with ThemeProvider {
  @override
  ClockControl initControl() => ClockControl();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Stack(
          children: <Widget>[
            //Hours Text
            Column(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Container(),
                ),
                FieldBuilderGroup(
                  controls: [
                    control.hour,
                    control.minute,
                  ],
                  builder: (context, values) => TimeDisplay(
                    hour: values[0],
                    minute: values[1],
                    ofCenter: false,
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    margin: EdgeInsets.only(top: 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        FieldBuilder<String>(
                          control: control.date,
                          builder: (context, value) => Text(
                            value,
                            style: fontAccent.body2,
                          ),
                        ),
                        SizedBox(
                          height: theme.paddingQuad,
                        ),
                        NotifierBuilder<TemperatureModel>(
                          control: Control.get<WeatherControl>().temperature,
                          builder: (context, model) {
                            if (model.isAvailable) {
                              return TemperatureDisplay(
                                temperature: '${model.temperature.toInt()}°${model.unitSign}',
                              );
                            }

                            return TemperatureDisplay(temperature: '-');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TimeDisplay extends StatelessWidget with ThemeProvider {
  final String hour;
  final String minute;
  final bool ofCenter;

  TimeDisplay({
    Key key,
    this.hour,
    this.minute,
    this.ofCenter: false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    invalidateTheme(context);

    if (ofCenter) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                hour,
                style: fontAccent.display1,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: theme.paddingQuad),
            child: Text(
              ':',
              style: fontAccent.display1,
            ),
          ),
          Expanded(
            child: Text(
              minute,
              style: fontAccent.display1,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          hour,
          style: fontAccent.display1,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: theme.paddingQuad),
          child: Text(
            ':',
            style: fontAccent.display1,
          ),
        ),
        Text(
          minute,
          style: fontAccent.display1,
        ),
      ],
    );
  }
}

class TemperatureDisplay extends StatelessWidget with ThemeProvider {
  final String temperature;
  final String low;
  final String high;

  TemperatureDisplay({
    Key key,
    @required this.temperature,
    this.low,
    this.high,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    invalidateTheme(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          temperature,
          style: theme.fontAccent.body2,
        ),
        if (low != null || high != null)
          SizedBox(
            width: theme.paddingHalf,
          ),
        if (low != null)
          Image.asset(
            asset.icon('arrow_down'),
            width: theme.iconSize,
            height: theme.iconSize,
            color: fontAccent.body2.color,
          ),
        if (low != null)
          Text(
            low,
            style: fontAccent.body2,
          ),
        if (high != null)
          Image.asset(
            asset.icon('arrow_up'),
            width: theme.iconSize,
            height: theme.iconSize,
            color: fontAccent.body2.color,
          ),
        if (high != null)
          Text(
            high,
            style: fontAccent.body2,
          ),
      ],
    );
  }
}
