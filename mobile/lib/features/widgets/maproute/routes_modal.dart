import 'package:flutter/material.dart';
import 'package:gibela_sa/core/theme/app_colors.dart';
import 'package:gibela_sa/features/widgets/maproute/route_card.dart';

class RouteOption {
  final String duration;
  final String departureTime;
  final String arrivalTime;
  final String fare;
  final String frequencyText;
  final List<TransitLeg> legs;

  RouteOption({
    required this.duration,
    required this.departureTime,
    required this.arrivalTime,
    required this.fare,
    required this.frequencyText,
    required this.legs,
  });
}

class TransitLeg {
  final IconData icon;
  final String? label;
  final Color? color;
  final int? walkMinutes;

  TransitLeg.walk(this.walkMinutes)
    : icon = Icons.directions_walk,
      label = null,
      color = Colors.grey;

  TransitLeg.transit({
    required this.icon,
    required this.label,
    required this.color,
  }) : walkMinutes = null;
}

class RoutesModal extends StatelessWidget {
  RoutesModal({super.key});

  final List<RouteOption> routes = [
    RouteOption(
      duration: '9h 19m',
      departureTime: '20:17',
      arrivalTime: '05:36 (Sun)',
      fare: 'R 90',
      frequencyText: 'every 15 min from Home Affairs, Malibongwe Drv',
      legs: [
        TransitLeg.walk(19),
        TransitLeg.transit(
          icon: Icons.directions_bus,
          label: 'Metro...',
          color: Colors.green.shade700,
        ),
        TransitLeg.transit(
          icon: Icons.airport_shuttle,
          label: 'Metro...',
          color: Colors.green.shade700,
        ),
        TransitLeg.transit(
          icon: Icons.airport_shuttle,
          label: 'Metro...',
          color: Colors.green.shade700,
        ),
        TransitLeg.walk(25),
      ],
    ),
    RouteOption(
      duration: '9h 28m',
      departureTime: '20:17',
      arrivalTime: '05:44 (Sun)',
      fare: 'R 90',
      frequencyText: 'every 20 min from Banbury Cross',
      legs: [
        TransitLeg.walk(19),
        TransitLeg.transit(
          icon: Icons.directions_bus,
          label: 'Metro...',
          color: Colors.green.shade700,
        ),
        TransitLeg.transit(
          icon: Icons.airport_shuttle,
          label: 'Metro...',
          color: Colors.green.shade700,
        ),
        TransitLeg.transit(
          icon: Icons.directions_bus,
          label: 'Helen...',
          color: Colors.green.shade700,
        ),
        TransitLeg.walk(24),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.42,
      minChildSize: 0.18,
      maxChildSize: 0.90,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: AppColors.background, blurRadius: 16)],
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              // Grab handle
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  height: 4,
                  width: 36,
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title and Actions
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    const Text(
                      'Taxi Routes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.tune,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.share,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const Divider(color: AppColors.textPrimary, height: 1),

              // Route Results List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: routes.length,
                separatorBuilder: (_, _) =>
                    const Divider(color: AppColors.textPrimary, thickness: 2),
                itemBuilder: (context, index) =>
                    RouteCard(route: routes[index]),
              ),
            ],
          ),
        );
      },
    );
  }
}
