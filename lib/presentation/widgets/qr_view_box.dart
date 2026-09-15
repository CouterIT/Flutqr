import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/constants/app_colors.dart';

/// Customized QR Display Card Box with rounded borders & background styling
class QrViewBox extends StatelessWidget {
  final String qrData;
  final double size;
  final Color foregroundColor;
  final Color backgroundColor;
  final Widget? logoWidget;

  const QrViewBox({
    super.key,
    required this.qrData,
    this.size = 220,
    this.foregroundColor = AppColors.textPrimary,
    this.backgroundColor = Colors.white,
    this.logoWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (qrData.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.qr_code_2_rounded, size: 48, color: AppColors.textMuted),
              SizedBox(height: 8),
              Text(
                'Chưa có dữ liệu',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),

        ],
      ),
      child: QrImageView(
        data: qrData,
        version: QrVersions.auto,
        size: size,
        eyeStyle: QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: foregroundColor,
        ),
        dataModuleStyle: QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: foregroundColor,
        ),
        embeddedImageStyle: logoWidget != null
            ? const QrEmbeddedImageStyle(size: Size(36, 36))
            : null,
      ),
    );
  }
}
