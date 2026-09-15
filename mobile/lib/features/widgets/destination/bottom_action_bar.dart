import 'package:flutter/material.dart';
import 'package:gibela_sa/core/models/place.dart';
import 'package:go_router/go_router.dart';

class BottomActionBar extends StatelessWidget {
  final Place? origin;
  final Place? destination;

  const BottomActionBar({
    super.key,
    required this.destination,
    required this.origin,
  });

  @override
  Widget build(BuildContext context) {
    final canSearch = origin != null && destination != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: canSearch
              ? () {
                  context.push(
                    '/routes',
                    extra: {'origin': origin, 'destination': destination},
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF95B2C),
            disabledBackgroundColor: const Color(0xFFF95B2C)
                .withValues(alpha: 0.4),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            'Find Taxi Routes',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
