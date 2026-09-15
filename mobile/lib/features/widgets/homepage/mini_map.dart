import 'package:flutter/material.dart';
import 'package:gibela_sa/core/config/location.dart';
import 'package:maplibre/maplibre.dart';

class MiniMap extends StatefulWidget {
  final double height;

  const MiniMap({
    super.key,
    this.height = 250.0, // Default compact height for homepage preview
  });

  @override
  State<MiniMap> createState() => _MiniMapState();
}

class _MiniMapState extends State<MiniMap> {
  Geographic? _currentPosition;
  bool _isLoading = true;
  MapController? _mapController;

  @override
  void initState() {
    super.initState();
    _loadInitialLocation();
  }

  void _useFallbackLocation() {
    if (!mounted) return;
    setState(() {
      _currentPosition = const Geographic(lon: 28.0473, lat: -26.2041);
      _isLoading = false;
    });
  }

  Future<void> _loadInitialLocation() async {
    try {
      final position = await getCurrentLocation();

      if (!mounted) return;

      if (position != null) {
        setState(() {
          _currentPosition = Geographic(
            lon: position.longitude,
            lat: position.latitude,
          );
          _isLoading = false;
        });
      } else {
        _useFallbackLocation();
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      _useFallbackLocation();
    }
  }

  Future<void> goToMyLocation() async {
    final position = await getCurrentLocation();
    if (position == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not retrieve current location')),
        );
      }
      return;
    }

    final target = Geographic(lon: position.longitude, lat: position.latitude);

    _mapController?.animateCamera(center: target, zoom: 14);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            if (_isLoading || _currentPosition == null)
              Container(
                color: Colors.grey.shade100,
                child: const Center(child: CircularProgressIndicator()),
              )
            else
              MapLibreMap(
                options: MapOptions(
                  initZoom: 11,
                  initCenter: _currentPosition!,
                  initStyle: 'https://tiles.openfreemap.org/styles/positron',
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                children: const [SourceAttribution()],
                onStyleLoaded: (style) {
                  debugPrint('Map loaded 😎');
                },
              ),

            // Embedded My Location floating button
            if (!_isLoading && _currentPosition != null)
              Positioned(
                right: 12,
                bottom: 12,
                child: FloatingActionButton.small(
                  heroTag: 'mini_map_my_location_btn',
                  onPressed: goToMyLocation,
                  child: const Icon(Icons.my_location),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
