import 'package:flutter/material.dart';
import 'package:gibela_sa/features/widgets/homepage/city_sky_line.dart';

class Splash extends StatelessWidget {
  final double topPadding;
  final double height;
  final List<Color> gradientColors;

  const Splash({
    super.key,
    required this.topPadding,
    this.height = 310.0,
    this.gradientColors = const [
      Color(0xFF2C7D90),
      Color(0xFF388E9F),
      Color(0xFF459DAA),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: topPadding + 10,
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomPaint(painter: CitySkyLine()),
            ),
          ],
        ),
      ),
    );
  }
}
