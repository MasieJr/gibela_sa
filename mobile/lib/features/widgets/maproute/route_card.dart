import 'package:flutter/material.dart';
import 'package:gibela_sa/core/theme/app_colors.dart';
import 'package:gibela_sa/features/widgets/maproute/routes_modal.dart';

class RouteCard extends StatelessWidget {
  final RouteOption route;
  final bool isSelected;
  final VoidCallback? onTap;

  const RouteCard({
    super.key,
    required this.route,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final transferLegs = route.legs.where((leg) => leg.isTransfer).toList();

    final normalLegs = route.legs.where((leg) => !leg.isTransfer).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: const Color(0xFFF95B2C), width: 2)
            : Border.all(color: Colors.transparent, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route.duration,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${route.departureTime} - '
                          '${route.arrivalTime}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),

                    Text(
                      route.fare,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (int i = 0; i < normalLegs.length; i++) ...[
                      _buildLegBadge(normalLegs[i]),

                      if (i < normalLegs.length - 1)
                        const Icon(
                          Icons.chevron_right,
                          color: Colors.white38,
                          size: 16,
                        ),
                    ],
                  ],
                ),

                if (transferLegs.isNotEmpty) ...[
                  const SizedBox(height: 12),

                  for (final transfer in transferLegs)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: _buildTransferRow(transfer),
                    ),
                ],

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        route.routeName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),

                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFFF95B2C),
                        size: 20,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegBadge(TransitLeg leg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: leg.color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(leg.icon, color: Colors.white, size: 14),

          if (leg.label != null) ...[
            const SizedBox(width: 4),

            Text(
              leg.label!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransferRow(TransitLeg leg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.swap_horiz_rounded,
            size: 18,
            color: Color(0xFFF95B2C),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              leg.label ?? 'Transfer',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
