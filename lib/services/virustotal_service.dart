import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/constants/api_keys.dart';

/// Model lưu trữ kết quả phân tích độ an toàn của URL từ VirusTotal.
class VirusTotalReport {
  final int malicious;
  final int suspicious;
  final int harmless;
  final int undetected;
  final int total;
  final String status; // 'clean', 'suspicious', 'malicious', 'error', 'quota_exceeded', 'no_key'
  final String message;

  const VirusTotalReport({
    this.malicious = 0,
    this.suspicious = 0,
    this.harmless = 0,
    this.undetected = 0,
    this.total = 0,
    required this.status,
    required this.message,
  });

  /// Kiểm tra xem URL có hoàn toàn an toàn hay không
  bool get isSafe => status == 'clean' || (malicious == 0 && suspicious == 0 && status != 'error');

  /// Kiểm tra xem URL có độc hại/lừa đảo hay không
  bool get isMalicious => malicious > 0;

  /// Kiểm tra xem URL có thuộc dạng nghi ngờ không
  bool get isSuspicious => suspicious > 0 && malicious == 0;
}

/// Service tương tác với VirusTotal API v3.
///
/// Chịu trách nhiệm:
/// - Mã hóa URL thành VirusTotal URL Identifier (Base64URL no padding)
/// - Gọi API GET /urls/{id} hoặc POST /urls nếu URL mới
/// - Cache kết quả trong bộ nhớ để tiết kiệm quota API
class VirusTotalService {
  VirusTotalService._();

  static const String _baseUrl = 'https://www.virustotal.com/api/v3';

  /// API Key từ --dart-define hoặc storage
  static String get defaultApiKey => ApiKeys.virustotalApiKey;

  /// Cache kết quả kiểm tra URL trong phiên làm việc
  static final Map<String, VirusTotalReport> _cache = {};

  /// Tạo VirusTotal URL ID từ chuỗi URL (Base64URL mà không có kí tự '=' padding).
  static String getUrlId(String url) {
    final cleanUrl = url.startsWith('http') ? url : 'https://$url';
    final bytes = utf8.encode(cleanUrl.trim());
    final base64Str = base64Url.encode(bytes);
    return base64Str.replaceAll('=', '');
  }

  /// Kiểm tra độ an toàn của URL qua VirusTotal API v3.
  static Future<VirusTotalReport> checkUrlSafety({
    required String url,
    required String apiKey,
  }) async {
    final cleanUrl = url.startsWith('http') ? url : 'https://$url';

    if (apiKey.isEmpty) {
      return const VirusTotalReport(
        status: 'no_key',
        message: 'Chưa cấu hình VirusTotal API Key.',
      );
    }

    // Kiểm tra cache trước
    if (_cache.containsKey(cleanUrl)) {
      return _cache[cleanUrl]!;
    }

    try {
      final urlId = getUrlId(cleanUrl);
      final response = await http.get(
        Uri.parse('$_baseUrl/urls/$urlId'),
        headers: {
          'x-apikey': apiKey,
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final attributes = data['data']['attributes'];
        final stats = attributes['last_analysis_stats'] as Map<String, dynamic>?;

        if (stats != null) {
          final malicious = (stats['malicious'] as num?)?.toInt() ?? 0;
          final suspicious = (stats['suspicious'] as num?)?.toInt() ?? 0;
          final harmless = (stats['harmless'] as num?)?.toInt() ?? 0;
          final undetected = (stats['undetected'] as num?)?.toInt() ?? 0;
          final total = malicious + suspicious + harmless + undetected;

          String status = 'clean';
          String msg = 'Trang web an toàn ($harmless/$total nhà cung cấp xác nhận)';

          if (malicious > 0) {
            status = 'malicious';
            msg = 'Cảnh báo nguy hiểm! Có $malicious nhà cung cấp đánh giá trang này độc hại / lừa đảo.';
          } else if (suspicious > 0) {
            status = 'suspicious';
            msg = 'Cảnh báo nghi ngờ! Có $suspicious nhà cung cấp đánh giá trang này có nguy cơ.';
          }

          final report = VirusTotalReport(
            malicious: malicious,
            suspicious: suspicious,
            harmless: harmless,
            undetected: undetected,
            total: total,
            status: status,
            message: msg,
          );

          _cache[cleanUrl] = report;
          return report;
        }
      } else if (response.statusCode == 404) {
        // Nếu URL chưa từng kiểm tra trên VirusTotal -> Submit URL mới
        return await _submitAndCheckUrl(cleanUrl, apiKey);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return const VirusTotalReport(
          status: 'error',
          message: 'API Key không hợp lệ hoặc bị từ chối.',
        );
      } else if (response.statusCode == 429) {
        return const VirusTotalReport(
          status: 'quota_exceeded',
          message: 'Đã vượt quá giới hạn truy vấn API (Quota Exceeded).',
        );
      }
    } catch (e) {
      debugPrint('Lỗi kết nối VirusTotal API: $e');
    }

    return const VirusTotalReport(
      status: 'error',
      message: 'Không thể kết nối đến VirusTotal API.',
    );
  }

  /// Gửi URL mới lên VirusTotal để phân tích khi URL chưa tồn tại trong cơ sở dữ liệu.
  static Future<VirusTotalReport> _submitAndCheckUrl(String url, String apiKey) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/urls'),
        headers: {
          'x-apikey': apiKey,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'url': url},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 202) {
        return const VirusTotalReport(
          status: 'clean',
          message: 'Đã gửi trang web phân tích mới lên VirusTotal thành công.',
        );
      }
    } catch (e) {
      debugPrint('Lỗi submit URL mới lên VirusTotal: $e');
    }
    return const VirusTotalReport(
      status: 'error',
      message: 'Trang web chưa có trong CSDL VirusTotal.',
    );
  }
}
