import 'package:flutter/material.dart';

class MapRoute extends StatelessWidget {
  const MapRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF1E2638),
        child: const Center(
          child: Text(
            'Map View (MapLibre / GoogleMap)',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      ),
    );
  }
}
