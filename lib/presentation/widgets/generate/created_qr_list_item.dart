import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/qr_data_model.dart';
import '../../../models/qr_type.dart';

/// Item widget displaying a single generated QR code in the Generate screen list
class CreatedQrListItem extends StatelessWidget {
  final QRDataModel item;
  final bool isSelected;
  final bool isSelectionMode;
  final ValueChanged<bool?>? onSelectionChanged;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const CreatedQrListItem({
    super.key,
    required this.item,
    required this.isSelected,
    required this.isSelectionMode,
    this.onSelectionChanged,
    required this.onTap,
    required this.onLongPress,
  });

  String _formatTimestamp(DateTime dt) {
    return DateFormat('dd-MM-yyyy hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isSelected
          ? AppColors.primary.withValues(alpha: 0.08)
          : Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            item.type.icon,
            color: const Color(0xFF6BB5C5),
            size: 28,
          ),
        ),
        title: Text(
          item.type.displayName,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          _formatTimestamp(item.timestamp),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textMuted,
          ),
        ),
        trailing: isSelectionMode
            ? Checkbox(
                value: isSelected,
                activeColor: AppColors.primary,
                onChanged: onSelectionChanged,
              )
            : const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Color(0xFFD0D0D0),
              ),
        onLongPress: onLongPress,
        onTap: onTap,
      ),
    );
  }
}
