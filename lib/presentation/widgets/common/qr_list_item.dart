import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/qr_data_model.dart';
import '../../../models/qr_type.dart';

/// Widget item hiển thị 1 mã QR trong danh sách (lịch sử + đã tạo).
///
/// Dùng chung cho cả HistoryScreen và GenerateScreen —
/// hiển thị icon loại QR, tên loại, thời gian, và checkbox khi đang chọn nhiều.
/// Khi không chọn nhiều thì hiển thị mũi tên bên phải.
class QrListItem extends StatelessWidget {
  final QRDataModel item;
  final bool isSelected;
  final bool isSelectionMode;
  final ValueChanged<bool?>? onSelectionChanged;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const QrListItem({
    super.key,
    required this.item,
    required this.isSelected,
    required this.isSelectionMode,
    this.onSelectionChanged,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Nền highlight nhẹ khi item đang được chọn
      color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(item.type.icon, color: AppColors.qrTypeIcon, size: 28),
        ),
        title: Text(
          item.type.displayName,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: AppColors.textPrimary),
        ),
        subtitle: Text(
          DateFormat('dd-MM-yyyy hh:mm a').format(item.timestamp),
          style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
        ),
        trailing: isSelectionMode
            ? Checkbox(value: isSelected, activeColor: AppColors.primary, onChanged: onSelectionChanged)
            : const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFFD0D0D0)),
        onLongPress: onLongPress,
        onTap: onTap,
      ),
    );
  }
}
