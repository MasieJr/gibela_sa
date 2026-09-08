import 'package:flutter/material.dart';
import 'package:gibela_sa/features/widgets/maproute/map_view.dart';

class MapRoute extends StatelessWidget {
  const MapRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(child: MapView());
  }
}
