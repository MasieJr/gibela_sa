import 'package:flutter/material.dart';
import 'package:gibela_sa/core/models/journey.dart';
import 'package:gibela_sa/core/models/place.dart';
import 'package:gibela_sa/core/network/api_client.dart';
import 'package:gibela_sa/features/widgets/maproute/details_modal.dart';
import 'package:gibela_sa/features/widgets/maproute/map_view.dart';
import 'package:gibela_sa/features/widgets/maproute/route_header.dart';
import 'package:gibela_sa/features/widgets/maproute/routes_modal.dart';

enum JourneySheet { routes, details }

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
  JourneySheet _activeSheet = JourneySheet.routes;
  late final ApiClient _api;
  bool isLoading = true;
  List<Journey> journeys = [];
  Journey? selectedJourney;

  @override
  void initState() {
    super.initState();

    _api = ApiClient();

    getRoutes();
  }

  void _selectJourney(Journey journey) {
    setState(() {
      selectedJourney = journey;
      _activeSheet = JourneySheet.details;
    });
  }

  void _showRoutes() {
    setState(() {
      _activeSheet = JourneySheet.routes;
    });
  }

  Future<void> getRoutes() async {
    setState(() {
      isLoading = true;
    });

    try {
      final results = await _api.planTrip(
        widget.origin.latitude,
        widget.origin.longitude,
        widget.destination.latitude,
        widget.destination.longitude,
      );

      if (!mounted) return;

      debugPrint('Found ${results.length} journeys');

      for (final journey in results) {
        final taxiLeg = journey.taxiLeg;

        debugPrint('Route: ${taxiLeg?.route?.name}');
      }

      setState(() {
        journeys = results;
        selectedJourney = results.isNotEmpty ? results.first : null;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        journeys = [];
        selectedJourney = null;
        isLoading = false;
      });

      debugPrint('Error getting journeys: $e');
    }
  }

  // void _selectJourney(Journey journey) {
  //   setState(() {
  //     selectedJourney = journey;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MapView(journey: selectedJourney),

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

          // RoutesModal(
          //   isLoading: isLoading,
          //   journeys: journeys,
          //   selectedJourney: selectedJourney,
          //   onJourneySelected: _selectJourney,
          // ),
          if (_activeSheet == JourneySheet.routes)
            RoutesModal(
              isLoading: isLoading,
              journeys: journeys,
              selectedJourney: selectedJourney,
              onJourneySelected: _selectJourney,
            )
          else if (selectedJourney != null)
            DetailsModal(journey: selectedJourney!, onBack: _showRoutes),
        ],
      ),
    );
  }
}
