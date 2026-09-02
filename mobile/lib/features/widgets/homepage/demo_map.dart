import 'package:flutter/material.dart';

class DemoMap extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final streetPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    final minorStreetPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Major intersecting paths
    final path = Path()
      ..moveTo(0, size.height * 0.6)
      ..lineTo(size.width * 0.4, size.height * 0.45)
      ..lineTo(size.width, size.height * 0.7);

    canvas.drawPath(path, streetPaint);

    final path2 = Path()
      ..moveTo(size.width * 0.35, 0)
      ..lineTo(size.width * 0.4, size.height);

    canvas.drawPath(path2, streetPaint);

    // Minor streets
    for (double i = 20; i < size.width; i += 50) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + 15, size.height),
        minorStreetPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
