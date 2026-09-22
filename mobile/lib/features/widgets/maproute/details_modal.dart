import 'package:flutter/material.dart';
import 'package:gibela_sa/core/models/journey.dart';
import 'package:gibela_sa/core/theme/app_colors.dart';

class DetailsModal extends StatelessWidget {
  final Journey journey;
  final VoidCallback onBack;

  const DetailsModal({super.key, required this.journey, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final totalMinutes = (journey.totalDuration / 60).ceil();

    return DraggableScrollableSheet(
      initialChildSize: 0.42,
      minChildSize: 0.08,
      maxChildSize: 0.90,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 16)],
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              _buildHandle(),

              _buildHeader(),

              const Divider(height: 1, color: Colors.white12),

              _buildSummary(totalMinutes),

              const SizedBox(height: 20),

              _buildJourneySteps(),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        height: 4,
        width: 36,
        decoration: BoxDecoration(
          color: Colors.white38,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),

          const SizedBox(width: 4),

          const Expanded(
            child: Text(
              'Journey details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(int totalMinutes) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDuration(totalMinutes),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  journey.hasTransfer
                      ? '${journey.taxiLegs.length} taxis · 1 transfer'
                      : 'Direct taxi',
                  style: const TextStyle(fontSize: 14, color: Colors.white60),
                ),
              ],
            ),
          ),

          Text(
            journey.totalFare > 0
                ? 'R${_formatFare(journey.totalFare)}'
                : 'Fare unavailable',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneySteps() {
    final widgets = <Widget>[];

    for (int i = 0; i < journey.legs.length; i++) {
      final leg = journey.legs[i];

      if (leg.isWalking) {
        widgets.add(_buildWalkingStep(leg));
      }

      if (leg.isTaxi) {
        widgets.add(_buildTaxiStep(leg));

        // Consecutive taxi legs =
        // transfer at the current taxi's
        // destination rank.
        if (i + 1 < journey.legs.length && journey.legs[i + 1].isTaxi) {
          widgets.add(
            _buildTransferStep(leg.route?.destinationRank.name ?? 'Taxi Rank'),
          );
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: widgets),
    );
  }

  Widget _buildWalkingStep(JourneyLeg leg) {
    final minutes = ((leg.durationSeconds ?? 0) / 60).ceil();

    final distance = _formatDistance(leg.distanceMeters ?? 0);

    return _JourneyStep(
      icon: Icons.directions_walk_rounded,
      title: 'Walk $distance',
      subtitle: '$minutes min',
      iconColor: Colors.grey,
    );
  }

  Widget _buildTaxiStep(JourneyLeg leg) {
    final route = leg.route;

    final minutes = ((leg.durationSeconds ?? 0) / 60).ceil();

    final distance = _formatDistance(leg.distanceMeters ?? 0);

    final fare = route?.fare;

    return _JourneyStep(
      icon: Icons.local_taxi_rounded,
      title: route?.name ?? 'Taxi',
      subtitle: [
        '$distance · $minutes min',
        if (fare != null) 'R${_formatFare(fare)}',
      ].join(' · '),
      iconColor: const Color(0xFFF95B2C),
    );
  }

  Widget _buildTransferStep(String rankName) {
    return _JourneyStep(
      icon: Icons.swap_vert_rounded,
      title: 'Change taxis',
      subtitle: rankName,
      iconColor: const Color(0xFF2563EB),
    );
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }

    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  String _formatDuration(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours == 0) {
      return '$minutes min';
    }

    if (minutes == 0) {
      return '$hours hr';
    }

    return '$hours hr $minutes min';
  }

  String _formatFare(double fare) {
    if (fare == fare.roundToDouble()) {
      return fare.toInt().toString();
    }

    return fare.toStringAsFixed(2);
  }
}

class _JourneyStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;

  const _JourneyStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 19, color: iconColor),
                ),

                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: Colors.white12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.white60),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
