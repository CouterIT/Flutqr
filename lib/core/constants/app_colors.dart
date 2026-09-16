import 'package:flutter/material.dart';

/// Định nghĩa bảng màu tập trung cho toàn bộ ứng dụng.
///
/// Khi cần thay đổi màu sắc app, chỉ cần sửa tại đây — tất cả screen sẽ tự cập nhật.
/// Private constructor ngăn khởi tạo instance — class chỉ chứa static constants.
class AppColors {
  AppColors._();

  // ================= Màu thương hiệu =================
  static const Color primary = Color(0xFF3B49B6);
  static const Color primaryDark = Color(0xFF2C3792);
  static const Color primaryLight = Color(0xFF5A68D8);
  static const Color secondary = Color(0xFF06B6D4);

  // ================= Nền và bề mặt =================
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;

  // ================= Màu chữ =================
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // ================= Màu trạng thái =================
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ================= Viền và phân cách =================
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);

  // ================= Màu QR Type Icons =================
  static const Color qrTypeIcon = Color(0xFF6BB5C5); // Màu icon QR type trong list & result

  // ================= Màu QR Type =================
  static const Color typeUrl = Color(0xFF3B82F6);
  static const Color typeText = Color(0xFF6B7280);
  static const Color typeWifi = Color(0xFF10B981);
  static const Color typeEmail = Color(0xFF8B5CF6);
  static const Color typePhone = Color(0xFFF59E0B);
  static const Color typeContact = Color(0xFFEC4899);

  // ================= Màu hardcoded hay dùng =================
  static const Color lightBorder = Color(0xFFEEEEEE);
  static const Color lightDivider = Color(0xFFF0F0F0);
  static const Color textDark = Color(0xFF333333);
  static const Color textLink = Color(0xFF4285F4);
  static const Color textArrow = Color(0xFFD0D0D0);
  static const Color emptyStateText = Color(0xFF999999);

  // ================= Màu VirusTotal Badge =================
  static const Color vtBgSafe = Color(0xFFF0FDF4);
  static const Color vtBorderSafe = Color(0xFF86EFAC);
  static const Color vtIconSafe = Color(0xFF16A34A);
  static const Color vtBgSuspicious = Color(0xFFFFF7ED);
  static const Color vtBorderSuspicious = Color(0xFFFDBA74);
  static const Color vtIconSuspicious = Color(0xFFEA580C);
  static const Color vtBgMalicious = Color(0xFFFEF2F2);
  static const Color vtBorderMalicious = Color(0xFFFCA5A5);
  static const Color vtIconMalicious = Color(0xFFDC2626);
  static const Color vtBgError = Color(0xFFFFFBEB);
  static const Color vtBorderError = Color(0xFFFDE68A);
  static const Color vtIconError = Color(0xFFD97706);
  static const Color vtBgLoading = Color(0xFFF9FAFB);
  static const Color vtBorderLoading = Color(0xFFE5E7EB);
  static const Color vtTextLoading = Color(0xFF4B5563);
  static const Color vtBgNoKey = Color(0xFFF3F4F6);
  static const Color vtBorderNoKey = Color(0xFFE5E7EB);
  static const Color vtTextNoKey = Color(0xFF374151);
  static const Color vtTextNoKeySub = Color(0xFF6B7280);

  // ================= Màu Image Upload =================
  static const Color uploadBgLoading = Color(0xFFEFF6FF);
  static const Color uploadBorderLoading = Color(0xFFBFDBFE);
  static const Color uploadTextLoading = Color(0xFF1D4ED8);
  static const Color uploadIconLoading = Color(0xFF2563EB);
  static const Color uploadBgSuccess = Color(0xFFF0FDF4);
  static const Color uploadBorderSuccess = Color(0xFF86EFAC);
  static const Color uploadIconSuccess = Color(0xFF16A34A);
  static const Color uploadTextSuccess = Color(0xFF15803D);
  static const Color uploadBgError = Color(0xFFFEF2F2);
  static const Color uploadBorderError = Color(0xFFFCA5A5);
  static const Color uploadTextError = Color(0xFFB91C1C);
  static const Color uploadIconError = Color(0xFFDC2626);

  // ================= Màu Scanner =================
  static const Color scannerOverlay = Color(0x99000000);
  static const Color scannerBannerBg = Color(0x8C000000);
}
