import 'package:flutter/material.dart';
import 'package:gibela_sa/core/models/journey.dart';
import 'package:gibela_sa/core/models/place.dart';
import 'package:gibela_sa/core/network/api_client.dart';
import 'package:gibela_sa/features/widgets/maproute/map_view.dart';
import 'package:gibela_sa/features/widgets/maproute/route_header.dart';
import 'package:gibela_sa/features/widgets/maproute/routes_modal.dart';

class MapRoutePage extends StatefulWidget {
  final Place origin;
  final Place destination;

  const MapRoutePage({
    super.key,
    required this.origin,
    required this.destination,
  });

  @override
  State<MapRoutePage> createState() => _MapRoutePageState();
}

class _MapRoutePageState extends State<MapRoutePage> {
  late final ApiClient _api;

  bool isLoading = true;
  Journey? journey;

  @override
  void initState() {
    super.initState();

    _api = ApiClient();

    getRoutes();
  }

  Future<void> getRoutes() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await _api.planTrip(
        widget.origin.latitude,
        widget.origin.longitude,
        widget.destination.latitude,
        widget.destination.longitude,
      );

      if (!mounted) return;

      setState(() {
        journey = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      debugPrint('Error getting journey: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MapView(journey: journey),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: RouteHeader(
                departure: widget.origin.name,
                destination: widget.destination.name,
              ),
            ),
          ),

          RoutesModal(isLoading: isLoading, journey: journey),
        ],
      ),
    );
  }
}
