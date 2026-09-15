import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

/// Enum defining supported QR payload types (7 total)
enum QRType {
  text,
  number,
  website,
  location,
  wifi,
  vcard,
  event,
}

extension QRTypeExtension on QRType {
  String get displayName {
    switch (this) {
      case QRType.text:
        return 'Text';
      case QRType.number:
        return 'Number';
      case QRType.website:
        return 'Website';
      case QRType.location:
        return 'Location';
      case QRType.wifi:
        return 'Wi-Fi';
      case QRType.vcard:
        return 'vCard';
      case QRType.event:
        return 'Thiệp mời';
    }
  }

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
    }
  }

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
    }
  }
}
