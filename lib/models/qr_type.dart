import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

/// Enum restricting QR creation to 4 primary types: text, number, website, location
enum QRType {
  text,
  number,
  website,
  location,
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
    }
  }
}
