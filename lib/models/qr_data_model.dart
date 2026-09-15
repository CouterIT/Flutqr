import 'qr_type.dart';

/// Data model representing scanned or generated QR code entity
class QRDataModel {
  final String id;
  final String rawValue;
  final QRType type;
  final String title;
  final DateTime timestamp;
  final bool isGenerated;
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

  /// Map object to JSON for SharedPreferences storage
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

  /// Factory constructor to deserialize JSON map into QRDataModel
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
