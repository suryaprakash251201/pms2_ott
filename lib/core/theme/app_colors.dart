import 'package:flutter/material.dart';

/// App color palette - Premium OTT theme inspired by Netflix/Disney+
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFFE50914); // Netflix Red
  static const Color primaryLight = Color(0xFFFF5252);
  static const Color primaryDark = Color(0xFFB20710);

  // Background Colors (Dark Theme)
  static const Color backgroundDark = Color(0xFF141414);
  static const Color surfaceDark = Color(0xFF1F1F1F);
  static const Color cardDark = Color(0xFF2A2A2A);

  // Background Colors (Light Theme)
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB3B3B3);
  static const Color textPrimaryLight = Color(0xFF141414);
  static const Color textSecondaryLight = Color(0xFF757575);

  // Accent Colors
  static const Color accent = Color(0xFF00D9FF); // Cyan accent
  static const Color success = Color(0xFF46D369);
  static const Color warning = Color(0xFFFFB74D);
  static const Color error = Color(0xFFE50914);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient overlayGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xCC000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Glassmorphism
  static Color glassBackground = Colors.white.withOpacity(0.1);
  static Color glassBorder = Colors.white.withOpacity(0.2);
}
