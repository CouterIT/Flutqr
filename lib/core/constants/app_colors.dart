import 'package:flutter/material.dart';

/// Định nghĩa bảng màu tập trung cho toàn bộ ứng dụng.
///
/// Các nhóm màu chính:
/// - Brand colors: màu chính (primary) và màu phụ (secondary)
/// - Text colors: 3 cấp độ đọc — chính, phụ, và mờ
/// - Status colors: thành công, cảnh báo, lỗi, thông tin
/// - QR type colors: mỗi loại QR có màu riêng để dễ phân biệt trên UI
///
/// Khi cần thay đổi màu sắc app, chỉ cần sửa tại đây — tất cả screen sẽ tự cập nhật.
/// Private constructor ngăn khởi tạo instance — class chỉ chứa static constants.
class AppColors {
  AppColors._();

  //Màu thương hiệu
  static const Color primary = Color(0xFF3B49B6); // Xanh dương đậm — màu chính của app
  static const Color primaryDark = Color(0xFF2C3792);
  static const Color primaryLight = Color(0xFF5A68D8);
  static const Color secondary = Color(0xFF06B6D4); // Cyan — màu nhấn

  //Nền và bề mặt
  static const Color background = Color(0xFFF8FAFC); // Nền Scaffold — xám rất nhạt
  static const Color surface = Colors.white; // Nền AppBar, card, dialog
  static const Color cardBackground = Colors.white;

  //Màu chữ
  static const Color textPrimary = Color(0xFF0F172A); // Đọc chính — tiêu đề, nội dung chính
  static const Color textSecondary = Color(0xFF64748B); // Đọc phụ — mô tả, subtitle
  static const Color textMuted = Color(0xFF94A3B8); // Mờ — placeholder, hint text

  //Màu trạng thái
  static const Color success = Color(0xFF10B981); // Xanh lá — thành công
  static const Color warning = Color(0xFFF59E0B); // Vàng — cảnh báo
  static const Color error = Color(0xFFEF4444); // Đỏ — lỗi, xóa
  static const Color info = Color(0xFF3B82F6); // Xanh dương — thông tin

  //Viền và phân cách
  static const Color border = Color(0xFFE2E8F0); // Viền input, card
  static const Color divider = Color(0xFFF1F5F9); // Đường phân cách danh sách

  //Màu theo loại QR
  static const Color typeUrl = Color(0xFF3B82F6);
  static const Color typeText = Color(0xFF6B7280);
  static const Color typeWifi = Color(0xFF10B981);
  static const Color typeEmail = Color(0xFF8B5CF6);
  static const Color typePhone = Color(0xFFF59E0B);
  static const Color typeContact = Color(0xFFEC4899);
}
