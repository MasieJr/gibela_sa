import 'package:flutter/material.dart';

class LocationField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool isOrigin;

  const LocationField({
    super.key,
    required this.controller,
    required this.hint,
    this.isOrigin = false,
  });

  @override
  State<LocationField> createState() => _LocationFieldState();
}

class _LocationFieldState extends State<LocationField> {
  @override
  void initState() {
    super.initState();
    // Rebuild when text changes to show/hide the clear icon dynamically
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: TextField(
          controller: widget.controller,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            hintText: widget.hint,
            hintStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF94A3B8),
            ),
            suffixIconConstraints: const BoxConstraints(maxHeight: 20),
            suffixIcon: widget.controller.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      widget.controller.clear();
                    },
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Color(0xFF94A3B8),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
