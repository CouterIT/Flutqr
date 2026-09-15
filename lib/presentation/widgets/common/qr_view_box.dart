import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/constants/app_colors.dart';

/// Widget hiển thị mã QR trong card container bo tròn.
///
/// Hỗ trợ 2 trạng thái:
/// - **Empty**: hiển thị placeholder icon + text "Chưa có dữ liệu"
/// - **Rendered**: hiển thị QR code image với viền + shadow
///
/// `repaintKey` truyền vào để wrap trong `RepaintBoundary` —
/// cho phép capture widget thành PNG khi share/lưu ảnh QR.
class QrViewBox extends StatelessWidget {
  /// Dữ liệu QR — nếu rỗng thì hiển thị empty state.
  final String qrData;
  final double size;
  final Color foregroundColor;
  final Color backgroundColor;
  final Widget? logoWidget;
  /// GlobalKey cho RepaintBoundary — parent truyền vào để export PNG.
  final GlobalKey? repaintKey;

  const QrViewBox({
    super.key,
    required this.qrData,
    this.size = 220,
    this.foregroundColor = AppColors.textPrimary,
    this.backgroundColor = Colors.white,
    this.logoWidget,
    this.repaintKey,
  });

  @override
  Widget build(BuildContext context) {
    // Empty state: chưa có dữ liệu QR
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

    // QR rendered: hiển thị mã QR trong card
    final Widget qrCard = Container(
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
        version: QrVersions.auto, // Tự động chọn version phù hợp với độ dài data
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

    // Nếu có repaintKey thì wrap trong RepaintBoundary để export PNG
    if (repaintKey != null) {
      return RepaintBoundary(
        key: repaintKey,
        child: qrCard,
      );
    }

    return qrCard;
  }
}
