import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../api/routes_api.dart';
import '../models/taxi_route.dart';

class RouteMapScreen extends StatefulWidget {
  final String? routeId;
  final TaxiRoute? initialRoute;

  const RouteMapScreen({super.key, this.routeId, this.initialRoute})
    : assert(
        routeId != null || initialRoute != null,
        'Either routeId or initialRoute must be provided',
      );

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  static const String _sourceId = 'single-taxi-route';
  static const String _layerId = 'single-taxi-route-layer';

  final RoutesApi _routesApi = GetIt.I<RoutesApi>();
  MapLibreMapController? _mapController;
  TaxiRoute? _currentRoute;
  bool _routeRendered = false;

  @override
  void initState() {
    super.initState();
    _currentRoute = widget.initialRoute;
  }

  Future<void> addRouteToMap(TaxiRoute route) async {
    if (!mounted || _mapController == null) return;

    final geoJson = {
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

    debugPrint('Rendering route: ${route.name} (${route.id})');

    try {
      if (_routeRendered) {
        await _mapController!.setGeoJsonSource(_sourceId, geoJson);
      } else {
        await _mapController!.addSource(
          _sourceId,
          GeojsonSourceProperties(data: geoJson),
        );

        await _mapController!.addLineLayer(
          _sourceId,
          _layerId,
          const LineLayerProperties(
            lineColor: '#FF0000',
            lineWidth: 5.0,
            lineOpacity: 1.0,
            lineCap: 'round',
            lineJoin: 'round',
          ),
        );
        _routeRendered = true;
      }
    } catch (e) {
      debugPrint('Error updating route layer/source: $e');
    }

    await _fitMapToRoute(route);
  }

  Future<void> _fitMapToRoute(TaxiRoute route) async {
    if (!mounted || _mapController == null) return;

    final bounds = _calculateBounds(route);
    if (bounds == null) return;

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted || _mapController == null) return;

    await _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        bounds,
        left: 50,
        top: 100,
        right: 50,
        bottom: 100,
      ),
    );
  }

  LatLngBounds? _calculateBounds(TaxiRoute route) {
    if (route.geometry.coordinates.isEmpty) return null;

    double? minLat;
    double? maxLat;
    double? minLng;
    double? maxLng;

    for (final coordinate in route.geometry.coordinates) {
      final lng = (coordinate[0] as num).toDouble();
      final lat = (coordinate[1] as num).toDouble();

      minLat = minLat == null ? lat : (lat < minLat ? lat : minLat);
      maxLat = maxLat == null ? lat : (lat > maxLat ? lat : maxLat);
      minLng = minLng == null ? lng : (lng < minLng ? lng : minLng);
      maxLng = maxLng == null ? lng : (lng > maxLng ? lng : maxLng);
    }

    if (minLat == null || maxLat == null || minLng == null || maxLng == null) {
      return null;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  Future<void> loadRoute() async {
    try {
      if (_currentRoute != null) {
        await addRouteToMap(_currentRoute!);
        return;
      }

      if (widget.routeId != null) {
        debugPrint('Fetching taxi route ${widget.routeId}...');
        final route = await _routesApi.getRouteById(widget.routeId!);
        _currentRoute = route;
        await addRouteToMap(route);
      }
    } catch (e, stackTrace) {
      debugPrint('Failed to load route: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapLibreMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(-26.1055, 28.104),
          zoom: 10,
        ),
        styleString: 'https://tiles.openfreemap.org/styles/liberty',
        onMapCreated: (controller) {
          _mapController = controller;
        },
        onStyleLoadedCallback: () {
          loadRoute();
        },
      ),
    );
  }
}
