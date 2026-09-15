import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

/// Định nghĩa 8 loại dữ liệu QR mà ứng dụng hỗ trợ.
///
/// Mỗi loại có format nội dung riêng — ví dụ WiFi dùng chuẩn `WIFI:S:...;P:...`,
/// vCard dùng chuẩn `BEGIN:VCARD`, event dùng `BEGIN:VEVENT`.
/// Enum này được dùng để detect type khi quét, hiển thị icon/màu trên UI,
/// và phân nhánh logic xử lý trong QRService.
enum QRType {
  text,
  number,
  website,
  location,
  wifi,
  vcard,
  event,
  image,
}

/// Extension bổ sung thuộc tính hiển thị cho QRType.
///
/// Thay vì switch到处 mỗi khi cần tên/icon/màu, ta gọi trực tiếp
/// `type.displayName`, `type.icon`, `type.color` — code gọn hơn và dễ bảo trì.
extension QRTypeExtension on QRType {
  /// Tên hiển thị tiếng Việt của loại QR, dùng trên UI (grid item, badge, AppBar...).
  String get displayName {
    switch (this) {
      case QRType.text:
        return 'Văn bản';
      case QRType.number:
        return 'Số điện thoại';
      case QRType.website:
        return 'Website';
      case QRType.location:
        return 'Vị trí';
      case QRType.wifi:
        return 'Wi-Fi';
      case QRType.vcard:
        return 'vCard';
      case QRType.event:
        return 'Thiệp mời';
      case QRType.image:
        return 'QR Ảnh';
    }
  }

  /// Icon Material biểu tượng cho mỗi loại QR, hiển thị trong grid và list.
  IconData get icon {
    switch (this) {
      case QRType.text:
        return Icons.notes_rounded;
      case QRType.number:
        return Icons.phone_rounded;
      case QRType.website:
        return Icons.web_rounded;
      case QRType.location:
        return Icons.location_on_rounded;
      case QRType.wifi:
        return Icons.wifi_rounded;
      case QRType.vcard:
        return Icons.badge_rounded;
      case QRType.event:
        return Icons.insert_invitation_rounded;
      case QRType.image:
        return Icons.image_rounded;
    }
  }

  /// Màu riêng biệt cho mỗi loại QR, dùng làm màu badge, QR preview, và button.
  Color get color {
    switch (this) {
      case QRType.text:
        return AppColors.primary;
      case QRType.number:
        return const Color(0xFF10B981);
      case QRType.website:
        return const Color(0xFF3B82F6);
      case QRType.location:
        return const Color(0xFFEF4444);
      case QRType.wifi:
        return const Color(0xFF8B5CF6);
      case QRType.vcard:
        return const Color(0xFFF59E0B);
      case QRType.event:
        return const Color(0xFFEC4899);
      case QRType.image:
        return const Color(0xFFE11D48);
    }
  }
}
