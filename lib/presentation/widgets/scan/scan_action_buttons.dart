import 'package:flutter/material.dart';

import '../common/custom_button.dart';

/// 2 nút action nằm ngang trong ScanResultScreen.
///
/// - Nút trái: "Lưu ảnh QR" (secondary/outlined) — lưu PNG vào gallery
/// - Nút phải: action chính theo loại QR (primary) — mở web/gọi điện/sao chép...
///
/// `isSaving` control loading state của nút trái — hiển thị spinner
/// và disable nút để tránh spam khi đang lưu ảnh.
class ScanActionButtons extends StatelessWidget {
  final bool isSaving;
  final String secondaryActionLabel;
  final IconData secondaryActionIcon;
  final VoidCallback onSavePressed;
  final VoidCallback onActionPressed;

  const ScanActionButtons({
    super.key,
    required this.isSaving,
    required this.secondaryActionLabel,
    required this.secondaryActionIcon,
    required this.onSavePressed,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Nút "Lưu ảnh QR" — outlined, có loading state
        Expanded(
          child: CustomButton(
            text: 'Lưu ảnh QR',
            icon: Icons.download_rounded,
            isSecondary: true,
            isLoading: isSaving,
            onPressed: onSavePressed,
          ),
        ),
        const SizedBox(width: 12),
        // Nút action chính — filled, label/icon thay đổi theo loại QR
        Expanded(
          child: CustomButton(
            text: secondaryActionLabel,
            icon: secondaryActionIcon,
            isSecondary: false,
            onPressed: onActionPressed,
          ),
        ),
      ],
    );
  }
}
