import 'package:flutter/material.dart';

import '../../../services/virustotal_service.dart';

/// Widget hiển thị badge đánh giá an toàn của URL từ VirusTotal API.
///
/// Quản lý trạng thái:
/// 1. Chưa điền API Key trong code -> Thông báo điền API Key vào virustotal_service.dart
/// 2. Đang kiểm tra -> Hiển thị loading spinner (sử dụng Expanded để chống tràn khung)
/// 3. Kết quả an toàn (Clean) -> Badge xanh lá
/// 4. Kết quả nghi ngờ / Nguy hiểm (Suspicious / Malicious) -> Badge cam / đỏ
/// 5. Lỗi -> Badge xám kèm nút thử lại
class VirusTotalBadgeWidget extends StatefulWidget {
  final String url;
  final ValueChanged<VirusTotalReport>? onReportLoaded;

  const VirusTotalBadgeWidget({
    super.key,
    required this.url,
    this.onReportLoaded,
  });

  @override
  State<VirusTotalBadgeWidget> createState() => _VirusTotalBadgeWidgetState();
}

class _VirusTotalBadgeWidgetState extends State<VirusTotalBadgeWidget> {
  bool _isLoading = true;
  VirusTotalReport? _report;

  /// Lấy API Key duy nhất từ VirusTotalService.defaultApiKey trong mã nguồn
  String get _apiKey => VirusTotalService.defaultApiKey.trim();

  @override
  void initState() {
    super.initState();
    _checkSafety();
  }

  @override
  void didUpdateWidget(covariant VirusTotalBadgeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _checkSafety();
    }
  }

  Future<void> _checkSafety() async {
    if (_apiKey.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final report = await VirusTotalService.checkUrlSafety(
      url: widget.url,
      apiKey: _apiKey,
    );

    if (mounted) {
      setState(() {
        _report = report;
        _isLoading = false;
      });
      widget.onReportLoaded?.call(report);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Trường hợp chưa điền API Key trong code
    if (_apiKey.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Row(
          children: [
            Icon(Icons.shield_outlined, color: Color(0xFF6B7280), size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kiểm tra an toàn với VirusTotal',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF374151)),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Chưa điền defaultApiKey trong virustotal_service.dart',
                    style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 2. Trường hợp đang tải dữ liệu (dùng Expanded chống lỗi overflow)
    if (_isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF3B82F6)),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Đang phân tích độ an toàn qua VirusTotal...',
                style: TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    // 3. Trường hợp lỗi hoặc vượt quota
    final report = _report;
    if (report == null || report.status == 'error' || report.status == 'quota_exceeded') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                report?.message ?? 'Chưa thể kiểm tra trang web này.',
                style: const TextStyle(fontSize: 12, color: Color(0xFFB45309)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 20, color: Color(0xFFD97706)),
              onPressed: _checkSafety,
              tooltip: 'Thử lại',
            ),
          ],
        ),
      );
    }

    // 4. Trường hợp hiển thị kết quả kiểm tra thành công
    Color bgColor;
    Color borderColor;
    Color iconColor;
    IconData iconData;
    String badgeTitle;

    if (report.isMalicious) {
      bgColor = const Color(0xFFFEF2F2);
      borderColor = const Color(0xFFFCA5A5);
      iconColor = const Color(0xFFDC2626);
      iconData = Icons.gpp_bad_rounded;
      badgeTitle = 'CẢNH BÁO NGUY HIỂM!';
    } else if (report.isSuspicious) {
      bgColor = const Color(0xFFFFF7ED);
      borderColor = const Color(0xFFFDBA74);
      iconColor = const Color(0xFFEA580C);
      iconData = Icons.warning_amber_rounded;
      badgeTitle = 'CẢNH BÁO NGHI NGỜ';
    } else {
      bgColor = const Color(0xFFF0FDF4);
      borderColor = const Color(0xFF86EFAC);
      iconColor = const Color(0xFF16A34A);
      iconData = Icons.verified_user_rounded;
      badgeTitle = 'TRANG WEB AN TOÀN';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(iconData, color: iconColor, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  badgeTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            report.message,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade800,
              height: 1.35,
            ),
          ),
          if (report.total > 0) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildStatChip('An toàn: ${report.harmless}', const Color(0xFF16A34A)),
                if (report.suspicious > 0)
                  _buildStatChip('Nghi ngờ: ${report.suspicious}', const Color(0xFFEA580C)),
                if (report.malicious > 0)
                  _buildStatChip('Độc hại: ${report.malicious}', const Color(0xFFDC2626)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
