import 'package:flutter/material.dart';

class RouteStatus extends StatelessWidget {
  final String status;

  const RouteStatus({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isVerified = status.toLowerCase() == 'verified';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: isVerified ? const Color(0xFFE7F3EF) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified : Icons.info_outline,
            size: 16,
            color: isVerified ? const Color(0xFF176B5B) : Colors.black54,
          ),
          const SizedBox(width: 6),
          Text(
            isVerified ? 'Verified route' : status,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isVerified ? const Color(0xFF176B5B) : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
