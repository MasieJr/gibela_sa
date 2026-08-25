import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 21, color: Colors.black54),

        const SizedBox(width: 12),

        Expanded(
          child: Text(label, style: const TextStyle(color: Colors.black54)),
        ),

        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
