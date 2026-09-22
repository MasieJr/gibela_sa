import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gibela_sa/core/models/journey.dart';
import 'package:maplibre/maplibre.dart';

class MapView extends StatefulWidget {
  final Journey? journey;

  const MapView({super.key, required this.journey});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  MapController? _mapController;
  bool _styleLoaded = false;

  int _drawnLegCount = 0;

  final List<String> _markerSourceIds = [];
  final List<String> _markerLayerIds = [];

  @override
  void didUpdateWidget(covariant MapView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.journey != widget.journey && _styleLoaded) {
      _drawJourney();
    }
  }

  Future<void> _drawJourney() async {
    final controller = _mapController;
    final journey = widget.journey;

    if (controller == null || journey == null) {
      return;
    }

    final style = controller.style;

    if (style == null) {
      return;
    }

    await _clearJourney(style);

    await _drawJourneyLines(style, journey);

    await _drawJourneyMarkers(style, journey);

    _drawnLegCount = journey.legs.length;

    await _fitJourney();
  }

  // =========================================================
  // CLEAR OLD JOURNEY
  // =========================================================

  Future<void> _clearJourney(dynamic style) async {
    // Remove marker layers first.
    for (final layerId in _markerLayerIds) {
      try {
        await style.removeLayer(layerId);
      } catch (e) {
        debugPrint('Could not remove marker layer $layerId: $e');
      }
    }

    // Then marker sources.
    for (final sourceId in _markerSourceIds) {
      try {
        await style.removeSource(sourceId);
      } catch (e) {
        debugPrint('Could not remove marker source $sourceId: $e');
      }
    }

    _markerLayerIds.clear();
    _markerSourceIds.clear();

    // Remove journey lines.
    for (int i = 0; i < _drawnLegCount; i++) {
      final sourceId = 'journey-source-$i';
      final layerId = 'journey-layer-$i';

      try {
        await style.removeLayer(layerId);
      } catch (e) {
        debugPrint('Could not remove layer $layerId: $e');
      }

      try {
        await style.removeSource(sourceId);
      } catch (e) {
        debugPrint('Could not remove source $sourceId: $e');
      }
    }

    _drawnLegCount = 0;
  }

  // =========================================================
  // DRAW ROUTE LINES
  // =========================================================

  Future<void> _drawJourneyLines(dynamic style, Journey journey) async {
    for (int i = 0; i < journey.legs.length; i++) {
      final leg = journey.legs[i];

      final sourceId = 'journey-source-$i';
      final layerId = 'journey-layer-$i';

      final geoJson = {
        'type': 'Feature',
        'properties': {'legType': leg.type},
        'geometry': {
          'type': 'MultiLineString',
          'coordinates': leg.geometry.coordinates
              .map(
                (line) => line.map((point) => [point.lon, point.lat]).toList(),
              )
              .toList(),
        },
      };

      await style.addSource(
        GeoJsonSource(id: sourceId, data: jsonEncode(geoJson)),
      );

      await style.addLayer(
        LineStyleLayer(
          id: layerId,
          sourceId: sourceId,
          layout: const {'line-cap': 'round', 'line-join': 'round'},
          paint: {
            'line-color': leg.isWalking ? '#64748B' : '#F95B2C',
            'line-width': leg.isWalking ? 4.0 : 6.0,
            'line-opacity': 0.9,
            if (leg.isWalking) 'line-dasharray': [2.0, 2.0],
          },
        ),
      );
    }
  }

  // =========================================================
  // DRAW MARKERS
  // =========================================================

  Future<void> _drawJourneyMarkers(dynamic style, Journey journey) async {
    debugPrint('DRAWING JOURNEY MARKERS');

    // START
    await _addMarker(
      style: style,
      id: 'start',
      point: journey.origin,
      color: '#16A34A',
      radius: 9,
    );

    // BOARD TAXI
    await _addMarker(
      style: style,
      id: 'boarding',
      point: journey.boardingPoint,
      color: '#F95B2C',
      radius: 7,
    );

    // TRANSFER
    final transferPoint = journey.transferPoint;

    if (transferPoint != null) {
      debugPrint(
        'Transfer marker: '
        '${transferPoint.lat}, ${transferPoint.lon}',
      );

      await _addMarker(
        style: style,
        id: 'transfer',
        point: transferPoint,
        color: '#2563EB',
        radius: 10,
      );
    }

    // DROP OFF
    await _addMarker(
      style: style,
      id: 'dropoff',
      point: journey.dropOffPoint,
      color: '#F95B2C',
      radius: 7,
    );

    // DESTINATION
    await _addMarker(
      style: style,
      id: 'destination',
      point: journey.destination,
      color: '#DC2626',
      radius: 9,
    );
  }

  Future<void> _addMarker({
    required dynamic style,
    required String id,
    required Geographic point,
    required String color,
    required double radius,
  }) async {
    final sourceId = 'journey-marker-$id-source';
    final layerId = 'journey-marker-$id-layer';

    final geoJson = {
      'type': 'Feature',
      'properties': {'type': id},
      'geometry': {
        'type': 'Point',
        'coordinates': [point.lon, point.lat],
      },
    };

    debugPrint(
      'Adding $id marker at '
      '${point.lat}, ${point.lon}',
    );

    await style.addSource(
      GeoJsonSource(id: sourceId, data: jsonEncode(geoJson)),
    );

    _markerSourceIds.add(sourceId);

    await style.addLayer(
      CircleStyleLayer(
        id: layerId,
        sourceId: sourceId,
        paint: {
          'circle-radius': radius,
          'circle-color': color,
          'circle-stroke-color': '#FFFFFF',
          'circle-stroke-width': 3.0,
          'circle-opacity': 1.0,
        },
      ),
    );

    _markerLayerIds.add(layerId);
  }

  // =========================================================
  // CAMERA
  // =========================================================

  Future<void> _fitJourney() async {
    final controller = _mapController;
    final journey = widget.journey;

    if (controller == null || journey == null) {
      return;
    }

    final points = <Geographic>[
      journey.origin,
      ...journey.legs.expand((leg) => leg.geometry.flattened),
      journey.destination,
    ];

    if (points.isEmpty) {
      return;
    }

    double minLat = points.first.lat;
    double maxLat = points.first.lat;
    double minLon = points.first.lon;
    double maxLon = points.first.lon;

    for (final point in points) {
      if (point.lat < minLat) {
        minLat = point.lat;
      }

      if (point.lat > maxLat) {
        maxLat = point.lat;
      }

      if (point.lon < minLon) {
        minLon = point.lon;
      }

      if (point.lon > maxLon) {
        maxLon = point.lon;
      }
    }

    await controller.fitBounds(
      bounds: LngLatBounds(
        longitudeWest: minLon,
        longitudeEast: maxLon,
        latitudeSouth: minLat,
        latitudeNorth: maxLat,
      ),
      padding: const EdgeInsets.fromLTRB(50, 130, 50, 340),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return MapLibreMap(
      options: MapOptions(
        initZoom: 11,
        initCenter: Geographic(lon: 28.0473, lat: -26.2041),
        initStyle: 'https://tiles.openfreemap.org/styles/positron',
      ),
      children: const [
        SourceAttribution(showMapLibre: true),
        MapCompass(),
        MapControlButtons(),
      ],
      onMapCreated: (controller) {
        _mapController = controller;
      },
      onStyleLoaded: (style) async {
        debugPrint('Map loaded 😎');

        _styleLoaded = true;

        if (widget.journey != null) {
          await _drawJourney();
        }
      },
    );
  }
}
