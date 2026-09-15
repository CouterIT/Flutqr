import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/constants/app_colors.dart';

/// Floating bottom pill bar widget with flash toggle and gallery picker buttons
class ScanControlBar extends StatelessWidget {
  final MobileScannerController controller;
  final VoidCallback onPickImage;

  const ScanControlBar({
    super.key,
    required this.controller,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ValueListenableBuilder<MobileScannerState>(
          valueListenable: controller,
          builder: (context, state, child) {
            final bool isTorchOn = state.torchState == TorchState.on;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Flash Toggle Button
                IconButton(
                  iconSize: 26,
                  icon: Icon(
                    isTorchOn
                        ? Icons.flash_on_rounded
                        : Icons.flash_on_outlined,
                    color: isTorchOn
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                  onPressed: () => controller.toggleTorch(),
                ),

                // Vertical Divider
                Container(
                  height: 24,
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: AppColors.border,
                ),

                // Gallery Picker Button
                IconButton(
                  iconSize: 26,
                  icon: const Icon(
                    Icons.collections_outlined,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: onPickImage,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
