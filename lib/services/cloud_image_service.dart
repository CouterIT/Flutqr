import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Model kết quả tải ảnh lên Imgbb Cloud.
class CloudImageResponse {
  final bool success;
  final String? url;
  final String? displayUrl;
  final String? deleteUrl;
  final String? errorMessage;

  const CloudImageResponse({
    required this.success,
    this.url,
    this.displayUrl,
    this.deleteUrl,
    this.errorMessage,
  });
}

/// Service chịu trách nhiệm tải ảnh lên Imgbb Cloud Storage.
///
/// Imgbb API v1 tự động lưu trữ hình ảnh trên đám mây và trả về liên kết
/// HTTPS công khai. Nhờ đó, bất kỳ ai quét mã QR cũng có thể truy cập
/// và xem được hình ảnh gốc trên mọi thiết bị.
class CloudImageService {
  CloudImageService._();

  /// API Key Imgbb (Bạn có thể lấy miễn phí tại https://api.imgbb.com)
  /// Điền API Key của bạn vào đây nếu có key riêng.
  static String imgbbApiKey = '3569b38e357045ceed58dfadfd649b2e';

  static const String _uploadEndpoint = 'https://api.imgbb.com/1/upload';

  /// Tải tệp ảnh từ thiết bị lên Imgbb Đám mây.
  ///
  /// - `imageFile`: Tệp hình ảnh trên thiết bị.
  /// - Trả về `CloudImageResponse` chứa đường link HTTPS public hoặc thông báo lỗi.
  static Future<CloudImageResponse> uploadImage(File imageFile) async {
    if (!imageFile.existsSync()) {
      return const CloudImageResponse(
        success: false,
        errorMessage: 'Tệp hình ảnh không tồn tại trên thiết bị.',
      );
    }

    if (imgbbApiKey.trim().isEmpty) {
      return const CloudImageResponse(
        success: false,
        errorMessage: 'Chưa điền Imgbb API Key trong cloud_image_service.dart',
      );
    }

    try {
      // Đọc byte ảnh và mã hóa sang dạng Base64
      final List<int> imageBytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      // Gửi request POST dạng form-data đến Imgbb API v1
      final response = await http.post(
        Uri.parse(_uploadEndpoint),
        body: {
          'key': imgbbApiKey.trim(),
          'image': base64Image,
        },
      ).timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final data = jsonResponse['data'];
          final String directUrl = data['url'] as String;
          final String? displayUrl = data['display_url'] as String?;
          final String? deleteUrl = data['delete_url'] as String?;

          return CloudImageResponse(
            success: true,
            url: directUrl,
            displayUrl: displayUrl ?? directUrl,
            deleteUrl: deleteUrl,
          );
        }
      }

      // Xử lý khi API trả về thông báo lỗi
      final Map<String, dynamic>? errJson = jsonDecode(response.body);
      final String errDetail = errJson?['error']?['message'] ?? 'Status ${response.statusCode}';

      return CloudImageResponse(
        success: false,
        errorMessage: 'Tải ảnh lên Imgbb thất bại: $errDetail',
      );
    } catch (e) {
      debugPrint('Lỗi tải ảnh lên Imgbb: $e');
      return CloudImageResponse(
        success: false,
        errorMessage: 'Không thể kết nối đến máy chủ Imgbb Cloud ($e)',
      );
    }
  }
}
