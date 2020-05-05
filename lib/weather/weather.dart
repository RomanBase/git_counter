import 'dart:async';

import 'package:flutter_control/core.dart';
import 'package:geolocator/geolocator.dart';

import 'weather_repo.dart';

class LocationModel extends ControlModel with StateControl {
  bool _isPermissionGranted = false;

  bool get isPermissionGranted => _isPermissionGranted;

  double _lat;

  double get lat => _lat;

  double _lng;

  double get lng => _lng;

  String _place;

  String get place => _place;

  bool get isAvailable => _lat != null && _lng != null;

  Future<bool> checkPermission() async {
    final status = await Geolocator().checkGeolocationPermissionStatus();

    _isPermissionGranted = status == GeolocationStatus.granted;

    return _isPermissionGranted;
  }

  Future<void> requestCurrentGps() async {
    final position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setPlace(position.latitude, position.longitude, '-');
  }

  void setPlace(double lat, double lng, String name) {
    _lat = lat;
    _lng = lng;
    _place = name;

    notifyState();
  }
}

class TemperatureModel extends ControlModel with StateControl {
  double _temperature;

  double get temperature => _temperatureByUnit(_temperature);

  double get temperatureC => _temperature;

  double get temperatureF => _toF(_temperature);

  double _low;

  double get low => _temperatureByUnit(_low);

  double _high;

  double get high => _temperatureByUnit(_high);

  TemperatureUnit _unit = TemperatureUnit.C;

  TemperatureUnit get unit => _unit;

  set unit(TemperatureUnit value) {
    _unit = value;
    notifyState();
  }

  String get unitSign => unit == TemperatureUnit.C ? 'C' : 'F';

  bool get isAvailable => _temperature != null;

  void setTemperatures({
    @required double temperature,
    double low,
    double high,
    TemperatureUnit unit: TemperatureUnit.C,
  }) {
    assert(temperature != null);

    if (unit == TemperatureUnit.C) {
      _temperature = temperature;
      _low = low ?? temperature - 4;
      _high = high ?? temperature + 4;
    } else {
      _temperature = _toC(temperature);
      _low = _toC(low ?? temperature - 4);
      _high = _toC(high ?? temperature + 4);
    }

    notifyState();
  }

  double _temperatureByUnit(double value) {
    switch (unit) {
      case TemperatureUnit.C:
        return value;
      case TemperatureUnit.F:
        return _toF(value);
    }

    return 0.0;
  }

  double _toC(double value) => (value - 32) * (5 / 9);

  double _toF(double value) => value * (5 / 9) + 32;
}

enum TemperatureUnit { C, F }

class WeatherControl extends BaseControl {
  final location = LocationModel();
  final temperature = TemperatureModel();

  Timer _timer;

  WeatherRepo get repo => Control.get<WeatherRepo>();

  @override
  void onInit(Map args) async {
    super.onInit(args);

    reload();
  }

  Future reload() async {
    await fetchGps();

    if (location.isAvailable) {
      await fetchWeather(location.lat, location.lng);
    }

    _timer = Timer(Duration(minutes: 5) - Duration(minutes: 5 % DateTime.now().minute, seconds: DateTime.now().second), reload);
  }

  Future fetchGps() async {
    if (!location.isPermissionGranted) {
      if (await location.checkPermission()) {
        printDebug('permission granted');
      } else {
        printDebug('permission rejected');
        return;
      }
    }

    await location.requestCurrentGps();
  }

  Future fetchWeather(double lat, double lng) async {
    await repo.getWeatherByGps(lat, lng).then((weather) {
      location.setPlace(weather.coord.lat, weather.coord.lon, weather.nameWithCountry);

      temperature.setTemperatures(
        temperature: weather.data.temp,
        low: weather.data.tempMin,
        high: weather.data.tempMax,
        unit: TemperatureUnit.C,
      );
    }).catchError((err) {
      printDebug(err.toString());
    });
  }

  @override
  void dispose() {
    super.dispose();

    location.dispose();
    temperature.dispose();
    _timer?.cancel();
  }
}
