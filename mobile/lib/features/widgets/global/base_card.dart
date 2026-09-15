import 'package:flutter/material.dart';

class BaseCard extends StatelessWidget {
  final Widget child;
  final double marginBottom;
  const BaseCard({super.key, required this.child, this.marginBottom = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: marginBottom),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
