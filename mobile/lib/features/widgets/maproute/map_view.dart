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

  /// Keep track of how many journey legs are currently
  /// drawn on the map.
  int _drawnLegCount = 0;

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

    /*
     * Remove the OLD journey first.
     *
     * Layers must be removed before their sources.
     */
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

    /*
     * Draw the newly selected journey.
     */
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

    /*
     * Remember how many layers/sources we just added
     * so they can be removed on the next selection.
     */
    _drawnLegCount = journey.legs.length;

    /*
     * Move camera to the newly selected journey.
     */
    await _fitJourney();
  }

  Future<void> _fitJourney() async {
    final controller = _mapController;
    final journey = widget.journey;

    if (controller == null || journey == null) {
      return;
    }

    final points = journey.legs
        .expand((leg) => leg.geometry.flattened)
        .toList();

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
      padding: const EdgeInsets.fromLTRB(40, 120, 40, 320),
    );
  }

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
