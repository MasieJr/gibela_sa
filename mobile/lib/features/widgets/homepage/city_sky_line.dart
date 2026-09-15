import 'package:flutter/material.dart';

class CitySkyLine extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final buildingPaint = Paint()..color = const Color(0x28FFFFFF);
    final hillPaint = Paint()..color = const Color(0x38FFFFFF);

    // Render buildings
    final buildings = [
      Rect.fromLTWH(20, size.height - 110, 42, 110),
      Rect.fromLTWH(75, size.height - 130, 48, 130),
      Rect.fromLTWH(135, size.height - 85, 38, 85),
      Rect.fromLTWH(185, size.height - 150, 60, 150),
      Rect.fromLTWH(260, size.height - 100, 46, 100),
      Rect.fromLTWH(315, size.height - 135, 52, 135),
    ];

    for (var building in buildings) {
      canvas.drawRect(building, buildingPaint);
    }

    // Rolling green hill foreground
    final hillPath = Path()
      ..moveTo(0, size.height - 20)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height - 70,
        size.width,
        size.height - 30,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(hillPath, hillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
