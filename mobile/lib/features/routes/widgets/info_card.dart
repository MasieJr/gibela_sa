import 'package:flutter/material.dart';
import 'package:gibela_sa/features/routes/models/taxi_route.dart';
import 'package:gibela_sa/features/routes/widgets/info_row.dart';

class InfoCard extends StatelessWidget {
  final TaxiRoute route;

  const InfoCard({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          InfoRow(
            icon: Icons.local_taxi_outlined,
            label: 'Transport',
            value: 'Minibus Taxi',
          ),

          const Divider(height: 24),

          InfoRow(
            icon: Icons.route_outlined,
            label: 'Route ID',
            value: route.id.toString(),
          ),

          const Divider(height: 24),

          InfoRow(
            icon: Icons.check_circle_outline,
            label: 'Status',
            value: route.status,
          ),
        ],
      ),
    );
  }
}
