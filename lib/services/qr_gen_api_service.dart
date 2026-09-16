import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/constants/app_dimens.dart';

/// Model kết quả từ QR Gen API.
class QrGenResponse {
  final bool success;
  final Uint8List? imageBytes;
  final String? errorMessage;

  const QrGenResponse({
    required this.success,
    this.imageBytes,
    this.errorMessage,
  });
}

/// Service gọi QR Gen API (qrgenapp.com) để generate QR code có logo.
///
/// - Không cần API key
/// - Hỗ trợ logo overlay (ảnh center)
/// - Fallback về render local (qr_flutter) nếu API fail
class QrGenApiService {
  QrGenApiService._();

  static const String _endpoint = 'https://qrgenapp.com/api/qr';

  /// Tạo QR code PNG có logo.
  ///
  /// - `data`: Nội dung QR (URL, text, etc.)
  /// - `logoFile`: File ảnh logo trên thiết bị
  /// - Trả về `QrGenResponse` chứa PNG bytes hoặc lỗi
  static Future<QrGenResponse> generateWithLogo({
    required String data,
    required File logoFile,
  }) async {
    if (data.isEmpty) {
      return const QrGenResponse(success: false, errorMessage: 'Nội dung QR không được để trống');
    }

    if (!logoFile.existsSync()) {
      return const QrGenResponse(success: false, errorMessage: 'File logo không tồn tại');
    }

    try {
      // Đọc logo và encode base64
      final logoBytes = await logoFile.readAsBytes();
      final logoBase64 = base64Encode(logoBytes);

      // Xác định mime type
      final ext = logoFile.path.split('.').last.toLowerCase();
      final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';

      // Gọi API
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data': data,
          'logo': 'data:$mimeType;base64,$logoBase64',
          'size': 512,
          'format': 'png',
          'color': '#000000',
          'bgColor': '#FFFFFF',
        }),
      ).timeout(AppDimens.timeoutUpload);

      if (response.statusCode == 200) {
        // API trả về PNG bytes
        if (response.headers['content-type']?.contains('image') == true) {
          return QrGenResponse(success: true, imageBytes: response.bodyBytes);
        }

        // API trả về JSON với base64 image
        final json = jsonDecode(response.body);
        if (json['image'] != null) {
          final imageBytes = base64Decode(json['image']);
          return QrGenResponse(success: true, imageBytes: imageBytes);
        }
      }

      return QrGenResponse(
        success: false,
        errorMessage: 'QR Gen API trả về status ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('Lỗi QR Gen API: $e');
      return QrGenResponse(
        success: false,
        errorMessage: 'Không thể kết nối QR Gen API: $e',
      );
    }
  }
}
