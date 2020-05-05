import 'dart:math' as math;

import 'package:flutter/material.dart';

/// forked from https://github.com/RomanBase/flutter_clock
class ClockProgress extends StatefulWidget {
  final double progress;
  final double radius;
  final EdgeInsets padding;
  final List<Color> colors;
  final List<double> stops;
  final Widget child;

  const ClockProgress({
    Key key,
    this.progress: 0.25,
    this.radius: 0.0,
    this.padding: const EdgeInsets.all(0.0),
    this.colors: const [Colors.orange, Colors.blue],
    this.stops,
    this.child,
  }) : super(key: key);

  @override
  State createState() => _ClockProgressState();
}

class _ClockProgressState extends State<ClockProgress> with TickerProviderStateMixin {
  Tween<double> _progress;
  List<Color> _colors;

  bool _reverse = false;

  AnimationController _progressController;

  @override
  void initState() {
    super.initState();

    _colors = widget.colors;
    _progress = Tween<double>(begin: 0.0, end: widget.progress);

    _progressController = AnimationController(duration: const Duration(seconds: 1), vsync: this);

    _progressController.addStatusListener((status) {
      if (_reverse && status == AnimationStatus.completed) {
        _reverse = false;
        _progress = Tween<double>(begin: 0.0, end: widget.progress);
        _progressController.forward(from: 0.0);
      }
    });

    _progressController.addListener(() => setState(() {}));

    _progressController.forward();
  }

  @override
  void didUpdateWidget(ClockProgress oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.progress - oldWidget.progress < 0.0) {
      _reverse = true;
      _progress = Tween<double>(begin: _progress.end, end: 1.0);

      _progressController.forward(from: 0.0);
    }

    if (!_reverse) {
      _progress = Tween<double>(begin: oldWidget.progress, end: widget.progress);
      _colors = oldWidget.colors;

      _progressController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      constraints: BoxConstraints.expand(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: CustomPaint(
          foregroundPainter: ClockProgressPainter(
            progress: _progress.evaluate(_progressController),
            reverseProgress: _reverse ? _progressController.value : 0.0,
            colors: ColorUtil.lerpColors(_colors, widget.colors, _progressController.value),
            stops: widget.stops,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class ClockProgressPainter extends CustomPainter {
  final double progress;
  final double reverseProgress;
  final List<Color> colors;
  final List<double> stops;

  ClockProgressPainter({
    this.progress: 0.0,
    this.reverseProgress: 0.0,
    @required this.colors,
    this.stops,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0.0) {
      return;
    }

    final center = Offset(size.width * 0.5, size.height * 0.5);
    final radius = math.sqrt(center.dx * center.dx + center.dy * center.dy);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final startAngle = -math.pi * 0.5;
    final endAngle = math.pi * 2.0 * progress;

    Paint paint;

    /*if (kIsWeb) {
      // Shader is broken on web :(
      paint = Paint()..color = colors.last;
    } else {*/
      paint = Paint()
        ..shader = SweepGradient(
          startAngle: endAngle * reverseProgress,
          endAngle: endAngle,
          colors: colors,
          stops: stops,
          tileMode: TileMode.clamp,
          transform: GradientRotation(startAngle),
        ).createShader(rect);
    //}

    canvas.drawArc(
      rect,
      startAngle,
      endAngle,
      true,
      paint,
    );
  }

  @override
  bool shouldRepaint(ClockProgressPainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

extension ColorUtil on Color {
  Color darker(double ratio, {double r: 1.0, double g: 1.0, double b: 1.0}) {
    ratio = 1.0 - ratio;

    return Color.fromARGB(
      alpha,
      _clamp(red * (ratio + ratio * (1.0 - r))),
      _clamp(green * (ratio + ratio * (1.0 - g))),
      _clamp(blue * (ratio + ratio * (1.0 - b))),
    );
  }

  Color lighter(double ratio, {double r: 1.0, double g: 1.0, double b: 1.0}) {
    return Color.fromARGB(
      alpha,
      _clamp(red + 255 * ratio * r),
      _clamp(green + 255 * ratio * g),
      _clamp(blue + 255 * ratio * b),
    );
  }

  int _clamp(double num) {
    return math.min(num.toInt(), 255);
  }

  static Color lerpGradient({@required List<Color> colors, List<double> stops, double t: 0.0}) {
    assert(colors.length > 1);
    assert(stops == null || colors.length == stops.length);

    t = t.clamp(0.0, 1.0);
    int index;

    if (stops != null) {
      index = stops.indexWhere((item) => item >= t) - 1;
      index = index.clamp(0, colors.length - 1);

      t = (t - stops[index]) / (stops[index + 1] - stops[index]);
    } else {
      index = (colors.length * t).floor();
      t = colors.length * t - index;
    }

    final a = colors[index];
    final b = colors[index + 1];

    return Color.lerp(a, b, t);
  }

  static List<Color> lerpColors(List<Color> a, List<Color> b, double t) {
    assert(a.length == b.length);

    final list = List<Color>();

    for (int i = 0; i < a.length; i++) {
      list.add(Color.lerp(a[i], b[i], t));
    }

    return list;
  }
}
