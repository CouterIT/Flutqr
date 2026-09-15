import 'qr_type.dart';

/// Data model biểu diễn 1实体 mã QR — có thể là mã quét được hoặc mã tự tạo.
///
/// Mỗi instance chứa đầy đủ thông tin cần thiết: nội dung gốc (`rawValue`),
/// loại QR (`type`), thời gian (`timestamp`), và cờ phân biệt quét/tạo (`isGenerated`).
/// Model này được serialize/deserialize qua `toMap()`/`fromMap()` để lưu trữ
/// dưới dạng JSON string trong SharedPreferences.
class QRDataModel {
  /// ID duy nhất, sinh từ timestamp milliseconds tại thời điểm tạo.
  final String id;

  /// Nội dung gốc của mã QR (URL, số điện thoại, chuỗi WiFi...).
  final String rawValue;

  /// Loại QR, được detect tự động bởi QRService.detectType().
  final QRType type;

  /// Tiêu đề hiển thị trên UI — được rút gọn hoặc format theo type.
  final String title;

  /// Thời gian quét hoặc tạo mã.
  final DateTime timestamp;

  /// `false` = mã quét từ camera, `true` = mã tự tạo trong app.
  final bool isGenerated;

  /// Metadata dự phòng cho các dữ liệu mở rộng trong tương lai.
  final Map<String, String>? metadata;

  const QRDataModel({
    required this.id,
    required this.rawValue,
    required this.type,
    required this.title,
    required this.timestamp,
    this.isGenerated = false,
    this.metadata,
  });

  /// Chuyển model sang Map để lưu vào SharedPreferences.
  ///
  /// DateTime được convert sang ISO 8601 string,
  /// enum được lưu bằng `.name` (text, number, website...).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rawValue': rawValue,
      'type': type.name,
      'title': title,
      'timestamp': timestamp.toIso8601String(),
      'isGenerated': isGenerated,
      'metadata': metadata,
    };
  }

  /// Tạo QRDataModel từ Map JSON được lưu trong SharedPreferences.
  ///
  /// `firstWhere` map string type từ JSON sang enum QRType.
  /// Nếu type không hợp lệ (data corrupt hoặc version mới), fallback về `QRType.text`.
  factory QRDataModel.fromMap(Map<String, dynamic> map) {
    return QRDataModel(
      id: map['id'] as String,
      rawValue: map['rawValue'] as String,
      type: QRType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => QRType.text,
      ),
      title: map['title'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      isGenerated: (map['isGenerated'] as bool?) ?? false,
      metadata: map['metadata'] != null
          ? Map<String, String>.from(map['metadata'] as Map)
          : null,
    );
  }
}
