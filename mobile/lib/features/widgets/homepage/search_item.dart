import 'package:flutter/material.dart';

class SearchItem extends StatelessWidget {
  final String title;
  const SearchItem({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.access_time_filled_rounded,
          color: Color(0xFF94A3B8),
          size: 20,
        ),
        const SizedBox(width: 14),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }
}
