import 'package:flutter/material.dart';
import 'package:maplibre/maplibre.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  MapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapLibreMap(
        onMapCreated: (controller) {
          // Store the map controller for later use. You can use it to control
          // the map programmatically.
          _mapController = controller;
        },
        onStyleLoaded: (style) {
          // Add your sources and layers here or do any other setup after the
          // style has been loaded.
          debugPrint('Map loaded 😎');
        },
      ),
    );
  }
}
