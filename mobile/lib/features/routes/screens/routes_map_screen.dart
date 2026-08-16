import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../data/routes_api.dart';
import '../models/taxi_route.dart';

class RoutesMapScreen extends StatefulWidget {
  const RoutesMapScreen({super.key});

  @override
  State<RoutesMapScreen> createState() => _RoutesMapScreenState();
}

class _RoutesMapScreenState extends State<RoutesMapScreen> {
  MapLibreMapController? _mapController;

  final RoutesApi routesApi = GetIt.I<RoutesApi>();

  Future<void> addRoutesToMap(List<TaxiRoute> routes) async {
    if (_mapController == null || routes.isEmpty) return;

    final geoJson = {
      'type': 'FeatureCollection',
      'features': routes.map((route) {
        return {
          'type': 'Feature',
          'properties': {
            'id': route.id,
            'name': route.name,
            'origin': route.origin,
            'destination': route.destination,
            'status': route.status,
          },
          'geometry': {
            'type': 'LineString',
            'coordinates': route.geometry.coordinates,
          },
        };
      }).toList(),
    };

    debugPrint('Adding ${routes.length} routes to GeoJSON source...');

    await _mapController!.addSource(
      'taxi-routes',
      GeojsonSourceProperties(data: geoJson),
    );

    await _mapController!.addLineLayer(
      'taxi-routes',
      'taxi-routes-layer',
      LineLayerProperties(lineColor: '#FF0000', lineWidth: 5, lineOpacity: 1.0),
    );

    debugPrint('Taxi routes layer added');
  }

  Future<void> loadRoutes() async {
    try {
      debugPrint('Loading taxi routes...');

      final routes = await routesApi.getRoutes();

      debugPrint('Received ${routes.length} routes');

      await addRoutesToMap(routes);
    } catch (e, stackTrace) {
      debugPrint('Failed to load routes: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapLibreMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(-26.1055, 28.104),
          zoom: 14,
        ),

        styleString: 'https://tiles.openfreemap.org/styles/liberty',

        onMapCreated: (controller) {
          _mapController = controller;
        },

        onStyleLoadedCallback: () {
          loadRoutes();
        },
      ),
    );
  }
}
