import 'package:flutter/material.dart';
import 'package:gibela_sa/core/models/journey.dart';
import 'package:gibela_sa/core/theme/app_colors.dart';
import 'package:gibela_sa/features/widgets/maproute/route_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
  final bool isLoading;
  final Journey? journey;

  const RoutesModal({
    super.key,
    required this.isLoading,
    required this.journey,
  });

  RouteOption? _buildRouteOption() {
    if (journey == null) return null;

    final transitLegs = journey!.legs.map((leg) {
      if (leg.isWalking) {
        final seconds = leg.durationSeconds ?? 0;

        final minutes = (seconds / 60).ceil();

        return TransitLeg.walk(minutes);
      }

      return TransitLeg.transit(
        icon: Icons.local_taxi_rounded,
        label: journey!.route.name,
        color: const Color(0xFFF95B2C),
      );
    }).toList();

    final totalSeconds = journey!.legs.fold<double>(
      0,
      (total, leg) => total + (leg.durationSeconds ?? 0),
    );

    final totalMinutes = (totalSeconds / 60).ceil();

    return RouteOption(
      duration: _formatDuration(totalMinutes),
      departureTime: '--:--',
      arrivalTime: '--:--',
      fare: 'Fare unavailable',
      frequencyText: journey!.route.name,
      legs: transitLegs,
    );
  }

  String _formatDuration(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours == 0) {
      return '${minutes}m';
    }

    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final route = _buildRouteOption();

    return DraggableScrollableSheet(
      initialChildSize: 0.42,
      minChildSize: 0.05,
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

              Skeletonizer(
                enabled: isLoading,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _buildContent(route),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(RouteOption? route) {
    if (isLoading) {
      return RouteCard(
        route: RouteOption(
          duration: '25 min',
          departureTime: '12:00',
          arrivalTime: '12:25',
          fare: 'R 25',
          frequencyText: 'Taxi route loading...',
          legs: [
            TransitLeg.walk(5),
            TransitLeg.transit(
              icon: Icons.local_taxi,
              label: 'Taxi',
              color: Colors.orange,
            ),
            TransitLeg.walk(4),
          ],
        ),
      );
    }

    if (route == null) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No taxi route found',
            style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
          ),
        ),
      );
    }

    return RouteCard(route: route);
  }
}
