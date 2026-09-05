import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: MediaQuery.of(context).size.height * 0.45,
      child: Column(
        children: [
          _buildMapControlBtn(Icons.layers),
          const SizedBox(height: 12),
          _buildMapControlBtn(Icons.navigation_outlined),
        ],
      ),
    );
  }
}

Widget _buildMapControlBtn(IconData icon) {
  return CircleAvatar(
    backgroundColor: const Color(0xFF232730),
    radius: 22,
    child: IconButton(
      icon: Icon(icon, color: Colors.white, size: 20),
      onPressed: () {},
    ),
  );
}
