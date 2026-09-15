import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';

/// Enum classifying the payload of a QR code
enum QRType {
  url,
  text,
  wifi,
  email,
  phone,
  contact,
}

extension QRTypeExtension on QRType {
  String get displayName {
    switch (this) {
      case QRType.url:
        return AppStrings.typeUrl;
      case QRType.text:
        return AppStrings.typeText;
      case QRType.wifi:
        return AppStrings.typeWifi;
      case QRType.email:
        return AppStrings.typeEmail;
      case QRType.phone:
        return AppStrings.typePhone;
      case QRType.contact:
        return 'Danh bạ';
    }
  }

  IconData get icon {
    switch (this) {
      case QRType.url:
        return Icons.link_rounded;
      case QRType.text:
        return Icons.text_snippet_rounded;
      case QRType.wifi:
        return Icons.wifi_rounded;
      case QRType.email:
        return Icons.email_rounded;
      case QRType.phone:
        return Icons.phone_rounded;
      case QRType.contact:
        return Icons.person_rounded;
    }
  }

  Color get color {
    switch (this) {
      case QRType.url:
        return AppColors.typeUrl;
      case QRType.text:
        return AppColors.typeText;
      case QRType.wifi:
        return AppColors.typeWifi;
      case QRType.email:
        return AppColors.typeEmail;
      case QRType.phone:
        return AppColors.typePhone;
      case QRType.contact:
        return AppColors.typeContact;
    }
  }
}
