import 'package:flutter/material.dart';

/// App color palette definition
class AppColors {
  AppColors._();

  // Brand Primary & Accent
  static const Color primary = Color(0xFF3B49B6); // Deep Blue (matching screenshot)
  static const Color primaryDark = Color(0xFF2C3792);
  static const Color primaryLight = Color(0xFF5A68D8);
  static const Color secondary = Color(0xFF06B6D4); // Cyan


  // Background & Surface
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;

  // Text colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Status Badge Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);

  // QR Type Specific Badge Colors
  static const Color typeUrl = Color(0xFF3B82F6);
  static const Color typeText = Color(0xFF6B7280);
  static const Color typeWifi = Color(0xFF10B981);
  static const Color typeEmail = Color(0xFF8B5CF6);
  static const Color typePhone = Color(0xFFF59E0B);
  static const Color typeContact = Color(0xFFEC4899);
}
