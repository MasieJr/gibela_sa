import 'package:flutter/material.dart';
import 'package:gibela_sa/core/theme/app_colors.dart';
import 'package:gibela_sa/features/widgets/destination/location_field.dart';
import 'package:go_router/go_router.dart';

class InputHeader extends StatelessWidget {
  final TextEditingController destinationController;
  final TextEditingController originController;

  const InputHeader({
    super.key,
    required this.destinationController,
    required this.originController,
  });

  void _swapLocations() {
    final temp = originController.text;
    originController.text = destinationController.text;
    destinationController.text = temp;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF1E293B),
                    size: 20,
                  ),
                  onPressed: () => context.pop(),
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Plan Your Taxi Route',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 40), // Balance back button spacing
            ],
          ),
          const SizedBox(height: 18),

          // Origin & Destination Inputs with Connector Line
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Visual Dot-Line Indicator
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF00A3FF),
                        width: 3,
                      ),
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 38,
                    color: const Color(0xFFCBD5E1),
                  ),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF95B2C),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Text Fields
              Expanded(
                child: Column(
                  children: [
                    LocationField(
                      controller: originController,
                      hint: 'Pickup location or rank',
                      isOrigin: true,
                    ),
                    const SizedBox(height: 10),
                    LocationField(
                      controller: destinationController,
                      hint: 'Where do you want to go?',
                      isOrigin: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Swap Button
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.swap_vert_rounded,
                    color: Color(0xFF475569),
                  ),
                  onPressed: _swapLocations,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
