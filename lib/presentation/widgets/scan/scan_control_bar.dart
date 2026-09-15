import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/constants/app_colors.dart';

/// Thanh điều khiển nổi phía dưới screen quét — hình pill (bo tròn hoàn toàn).
///
/// Chứa 2 nút:
/// - **Toggle đèn flash**: icon thay đổi theo trạng thái torch (bật/tắt)
/// - **Chọn ảnh từ gallery**: mở picker để quét QR码 từ ảnh đã lưu
///
/// Dùng `ValueListenableBuilder` để reactive với `MobileScannerController` —
/// mỗi khi torch state thay đổi (người dùng bật/tắt flash),
/// icon sẽ tự động cập nhật mà không cần rebuild cả widget tree.
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
        // Lắng nghe MobileScannerState — mỗi lần state thay đổi thì rebuild nội dung
        child: ValueListenableBuilder<MobileScannerState>(
          valueListenable: controller,
          builder: (context, state, child) {
            final bool isTorchOn = state.torchState == TorchState.on;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nút toggle flash — icon thay đổi theo trạng thái
                IconButton(
                  iconSize: 26,
                  icon: Icon(
                    isTorchOn
                        ? Icons.flash_on_rounded
                        : Icons.flash_on_outlined,
                    color: isTorchOn
                        ? AppColors.primary // Bật: màu primary
                        : AppColors.textPrimary, // Tắt: màu đen
                  ),
                  onPressed: () => controller.toggleTorch(),
                ),

                // Đường kẻ phân cách
                Container(
                  height: 24,
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: AppColors.border,
                ),

                // Nút chọn ảnh từ gallery
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
