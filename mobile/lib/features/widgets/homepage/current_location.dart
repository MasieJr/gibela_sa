import 'package:flutter/material.dart';
import 'package:gibela_sa/features/widgets/base_card.dart';
import 'package:gibela_sa/features/widgets/homepage/demo_map.dart';

class CurrentLocation extends StatelessWidget {
  const CurrentLocation({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map Preview Container
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 125,
              width: double.infinity,
              color: const Color(0xFFEFF3F6),
              child: Stack(
                children: [
                  CustomPaint(size: Size.infinite, painter: DemoMap()),
                  const Positioned(
                    top: 16,
                    right: 36,
                    child: Text(
                      'Cresta',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A5568),
                      ),
                    ),
                  ),
                  // Location Marker Pin
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A3FF).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        height: 18,
                        width: 18,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00A3FF),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Your current location',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Cresta Shopping Centre, Cresta, Johanessburg',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
