import 'package:flutter/material.dart';
import 'package:gibela_sa/features/routes/models/taxi_route.dart';
import 'package:gibela_sa/features/routes/widgets/info_card.dart';
import 'package:gibela_sa/features/routes/widgets/location_card.dart';
import 'package:gibela_sa/features/routes/widgets/route_map_placeholder.dart';
import 'package:gibela_sa/features/routes/widgets/route_status.dart';

class RouteContent extends StatelessWidget {
  final TaxiRoute route;

  const RouteContent({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: const Color(0xFFF7F8F6),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            route.name,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RouteMapPlaceholder(route: route),
                const SizedBox(height: 24),
                Text(
                  route.name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                RouteStatus(status: route.status),
                const SizedBox(height: 24),
                LocationCard(
                  icon: Icons.trip_origin,
                  title: 'Starting point',
                  value: route.origin,
                ),
                const SizedBox(height: 12),
                LocationCard(
                  icon: Icons.location_on,
                  title: 'Destination',
                  value: route.destination,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Route information',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                InfoCard(route: route),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
