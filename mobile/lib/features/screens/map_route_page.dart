import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();

    _api = ApiClient();
  }

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
                departure: widget.origin.name,
                destination: widget.destination.name,
              ),
            ),
          ),
          // ActionButtons(),
          RoutesModal(isLoading: isLoading),
        ],
      ),
    );
  }
}
