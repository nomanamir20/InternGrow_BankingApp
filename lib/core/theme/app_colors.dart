import 'package:flutter/material.dart';

/// Centralized color tokens — a single place to re-theme the whole app.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF0B2545);    // Deep navy — trust/banking association
  static const Color primaryDark = Color(0xFF081B36);
  static const Color accent = Color(0xFFD4AF37);       // Gold accent — premium feel
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color income = Color(0xFF16A34A);
  static const Color expense = Color(0xFFDC2626);

  static const Color lightBackground = Color(0xFFF7F8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5E7EB);

  static const Color darkBackground = Color(0xFF0A0E14);
  static const Color darkSurface = Color(0xFF141A24);
  static const Color darkBorder = Color(0xFF2A3441);

  static const Color textPrimaryLight = Color(0xFF1A1D23);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textPrimaryDark = Color(0xFFF5F5F7);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
}