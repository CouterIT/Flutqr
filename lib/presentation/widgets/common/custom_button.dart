import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Nút bấm tái sử dụng với 2 kiểu: primary (đậm) và secondary (viền/outlined).
///
/// Hỗ trợ:
/// - Icon tùy chọn bên trái text
/// - Loading state (thay content bằng spinner)
/// - Custom color (dùng cho nút theo loại QR)
/// - Disabled state khi `onPressed` là null
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isSecondary; // true = OutlinedButton, false = ElevatedButton
  final bool isLoading; // true = hiển thị spinner thay content
  final Color? color; // Custom color, mặc định dùng AppColors.primary

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isSecondary = false,
    this.isLoading = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Style thay đổi theo isSecondary
    final ButtonStyle style = isSecondary
        ? OutlinedButton.styleFrom(
            foregroundColor: color ?? AppColors.primary,
            side: BorderSide(color: color ?? AppColors.primary, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: color ?? AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          );

    // Loading: spinner thay vì text+icon
    final Widget content = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: isSecondary ? (color ?? AppColors.primary) : Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );

    if (isSecondary) {
      return OutlinedButton(
        style: style,
        // Khi loading thì disable nút để tránh spam
        onPressed: isLoading ? null : onPressed,
        child: content,
      );
    }

    return ElevatedButton(
      style: style,
      onPressed: isLoading ? null : onPressed,
      child: content,
    );
  }
}
