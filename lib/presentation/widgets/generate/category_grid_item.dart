import 'package:flutter/material.dart';

import '../../../models/qr_type.dart';

/// Card item trong grid chọn loại QR khi tạo mã mới.
///
/// Hiển thị icon loại QR + tên loại. Nhấn để chọn loại này
/// và chuyển sang form nhập liệu tương ứng.
class CategoryGridItem extends StatelessWidget {
  final QRType type;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const CategoryGridItem({
    super.key,
    required this.type,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFEEEEEE), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 28,
                color: type.color,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
