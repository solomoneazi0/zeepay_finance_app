import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // prevent instantiation

  // ─── Brand ────────────────────────────────────────────
  static const Color primary = Color(0xFF3DBE6C); // ZePay green
  static const Color primaryDark = Color(0xFF2DA055); // darker green
  static const Color primaryLight = Color(0xFFE8F8EF); // soft green bg

  // ─── Light Mode ───────────────────────────────────────
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightBorder = Color(0xFFE0E0E0);

  // ─── Dark Mode ────────────────────────────────────────
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF252525);
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFF9E9E9E);
  static const Color darkBorder = Color(0xFF2C2C2C);

  // ─── Semantic ─────────────────────────────────────────
  static const Color success = Color(0xFF3DBE6C);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF1E88E5);

  // ─── Service Icon Backgrounds ─────────────────────────
  static const Color zeRideBg = Color(0xFFE3F2FD);
}
