import 'package:flutter/material.dart';

class InvertedCircleClipper extends CustomClipper<Path> {
  final Offset center;
  final double radius;
  final double stroke;
  final double padding;

  const InvertedCircleClipper({
    this.center,
    this.radius,
    this.stroke: 8.0,
    this.padding: 0.0,
  });

  @override
  Path getClip(Size size) {
    return Path()
      ..addOval(Rect.fromCircle(center: center ?? Offset(size.width * 0.5, size.height * 0.5), radius: (radius ?? size.width * 0.5) - padding - stroke))
      ..addOval(Rect.fromCircle(center: center ?? Offset(size.width * 0.5, size.height * 0.5), radius: (radius ?? size.width * 0.5) - padding))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => (oldClipper as InvertedCircleClipper)?.radius != radius;
}
