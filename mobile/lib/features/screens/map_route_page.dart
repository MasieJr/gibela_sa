import 'package:flutter/material.dart';
import 'package:gibela_sa/features/widgets/maproute/map_view.dart';
import 'package:gibela_sa/features/widgets/maproute/route_header.dart';

class MapRoutePage extends StatefulWidget {
  final String origin;
  final String destination;

  const MapRoutePage({
    super.key,
    required this.origin,
    required this.destination,
  });

  @override
  State<MapRoutePage> createState() => _MapRoutePageState();
}

class _MapRoutePageState extends State<MapRoutePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MapView(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: RouteHeader(
                departure: widget.origin,
                destination: widget.destination,
              ),
            ),
          ),
          // ActionButtons(),
          // RoutesModal(),
        ],
      ),
    );
  }
}
