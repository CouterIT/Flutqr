import 'package:intl/intl.dart';

/// Các helper format dữ liệu hiển thị trên UI — ngày giờ, URL, text rút gọn.
///
/// Private constructor ngăn khởi tạo instance — tất cả method đều static.
class Formatters {
  Formatters._();

  /// Format DateTime thành chuỗi dễ đọc: "15/09/2026 20:40".
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  /// Chuyển timestamp thành text thời gian tương đối.
  ///
  /// Ưu tiên hiển thị thời gian gần ("Vừa xong", "5 phút trước"),
  /// fallback về ngày cụ thể khi > 7 ngày — giúp người dùng
  /// nắm nhanh thời gian mà không cần đọc ngày đầy đủ.
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  /// Rút gọn text quá dài để hiển thị trong list, tránh vỡ layout.
  /// Nếu text <= maxLength thì giữ nguyên, nếu dài hơn thì cắt và thêm "...".
  static String truncateText(String text, {int maxLength = 35}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Trích xuất tên miền (host) từ URL.
  /// Ví dụ: "https://google.com/search" → "google.com".
  /// Nếu URL không hợp lệ, trả về nguyên gốc để tránh crash.
  static String getDomainFromUrl(String url) {
    try {
      final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
      return uri.host.isNotEmpty ? uri.host : url;
    } catch (_) {
      return url;
    }
  }
}
