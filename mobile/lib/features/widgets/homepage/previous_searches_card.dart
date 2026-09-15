import 'package:flutter/material.dart';
import 'package:gibela_sa/features/widgets/global/base_card.dart';
import 'package:gibela_sa/features/widgets/homepage/search_item.dart';

class PreviousSearchesCard extends StatelessWidget {
  const PreviousSearchesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your previous searches',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 18),
          SearchItem(title: 'Monumen Nasional'),
          const SizedBox(height: 16),
          SearchItem(title: 'Central Park Mall'),
          const SizedBox(height: 16),
          SearchItem(title: 'Stasiun Gambir'),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
