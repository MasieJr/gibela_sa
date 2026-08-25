import 'package:flutter/material.dart';
import 'package:gibela_sa/features/routes/widgets/error_view.dart';
import 'package:gibela_sa/features/routes/widgets/route_content.dart';

import '../../../core/network/api_client.dart';
import '../api/routes_api.dart';
import '../models/taxi_route.dart';

class RouteDetailsPage extends StatefulWidget {
  final String routeId;

  const RouteDetailsPage({super.key, required this.routeId});

  @override
  State<RouteDetailsPage> createState() => _RouteDetailsPageState();
}

class _RouteDetailsPageState extends State<RouteDetailsPage> {
  late final RoutesApi routesApi;

  TaxiRoute? route;

  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();

    routesApi = RoutesApi(ApiClient().dio);

    loadRoute();
  }

  Future<void> loadRoute() async {
    try {
      final result = await routesApi.getRouteById(widget.routeId);

      if (!mounted) return;

      setState(() {
        route = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = 'Unable to load route';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return ErrorView(
        message: error!,
        onRetry: () {
          setState(() {
            isLoading = true;
            error = null;
          });

          loadRoute();
        },
      );
    }

    if (route == null) {
      return const Center(child: Text('Route not found'));
    }

    return RouteContent(route: route!);
  }
}
