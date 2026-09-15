import 'package:flutter/material.dart';

import '../common/custom_button.dart';

/// 2 Side-by-Side Action Buttons widget for ScanResultScreen
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
