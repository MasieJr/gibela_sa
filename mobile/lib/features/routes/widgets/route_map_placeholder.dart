import 'package:flutter/material.dart';
import 'package:gibela_sa/features/routes/models/taxi_route.dart';
import 'package:gibela_sa/features/routes/widgets/route_map.dart';

class RouteMapPlaceholder extends StatelessWidget {
  final TaxiRoute route;

  const RouteMapPlaceholder({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE4E8E5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Embedded Map filling the card
            Positioned.fill(child: RouteMapScreen(initialRoute: route)),

            // Floating Route Map Badge / Header
            Positioned(
              left: 16,
              top: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Color(0xFF176B5B),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Route map',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
