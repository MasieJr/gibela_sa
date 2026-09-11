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
        options: MapOptions(
          initZoom: 11,
          initCenter: Geographic(lon: 28.0473, lat: -26.2041),
          initStyle: 'https://tiles.openfreemap.org/styles/positron',
        ),
        children: [
          SourceAttribution(showMapLibre: true),
          MapCompass(),
          MapControlButtons(),
        ],
        onMapCreated: (controller) {
          _mapController = controller;
        },
        onStyleLoaded: (style) {
          debugPrint('Map loaded 😎');
        },
      ),
    );
  }
}
