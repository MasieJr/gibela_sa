import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand & Accent Colors
  static const Color primaryTeal = Color(0xFF2C7D90);
  static const Color mediumTeal = Color(0xFF388E9F);
  static const Color lightTeal = Color(0xFF459DAA);
  static const Color taxiOrange = Color(0xFFF95B2C);
  static const Color accentBlue = Color(0xFF00A3FF);

  // Background & Surface
  static const Color background = Color(0xFFF9FAFC);
  static const Color cardSurface = Colors.white;
  static const Color inputBackground = Color(0xFFF1F5F9);
  static const Color chipBackground = Color(0xFFF8FAFC);

  // Typography & Content
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textLight = Colors.white;
  static const Color textLightSubtle = Color(0xB3FFFFFF); // ~70% white

  // Borders & Dividers
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFF1F5F9);
  static const Color connectorLine = Color(0xFFCBD5E1);

  // Decorative & Silhouette Layers
  static const Color headerBuilding = Color(0x28FFFFFF);
  static const Color headerHills = Color(0x38FFFFFF);
  static const Color cardShadow = Color(0x0A000000);
  static const Color bottomBarShadow = Color(0x0D000000);

  // Gradients
  static const LinearGradient headerGradient = LinearGradient(
    colors: [primaryTeal, mediumTeal, lightTeal],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
