import 'package:flutter/material.dart';

class GreetingCard extends StatelessWidget {
  final String name;
  final String? greeting;
  const GreetingCard({
    super.key,
    required this.name,
    this.greeting = 'Good Morning',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.apartment_rounded, color: Colors.white, size: 28),
            const SizedBox(width: 8),
            Text(
              '$greeting, $name',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 21,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'May your day be as bright as the sun in\nthe morning.',
          style: TextStyle(color: Colors.white70, fontSize: 13.5, height: 1.35),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
