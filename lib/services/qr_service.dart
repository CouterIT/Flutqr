import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/qr_data_model.dart';
import '../models/qr_type.dart';

/// Business service for parsing QR string content and performing smart actions
class QRService {
  QRService._();

  /// Auto detect QR payload type based on pattern matching
  static QRType detectType(String rawValue) {
    final clean = rawValue.trim();
    final lower = clean.toLowerCase();

    if (clean.startsWith('WIFI:') || clean.startsWith('wifi:')) {
      return QRType.wifi;
    } else if (clean.startsWith('BEGIN:VCARD')) {
      return QRType.contact;
    } else if (lower.startsWith('http://') ||
        lower.startsWith('https://') ||
        lower.startsWith('www.')) {
      return QRType.url;
    } else if (lower.startsWith('mailto:') ||
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(clean)) {
      return QRType.email;
    } else if (lower.startsWith('tel:') ||
        RegExp(r'^\+?[0-9]{8,15}$').hasMatch(clean)) {
      return QRType.phone;
    }

    return QRType.text;
  }

  /// Parse raw QR value into QRDataModel entity
  static QRDataModel parseRawData(String rawValue, {bool isGenerated = false}) {
    final type = detectType(rawValue);
    final String id = DateTime.now().millisecondsSinceEpoch.toString();
    Map<String, String>? metadata;
    String title = rawValue;

    switch (type) {
      case QRType.wifi:
        metadata = parseWifiString(rawValue);
        title = 'Wi-Fi: ${metadata['ssid'] ?? 'Không tên'}';
        break;
      case QRType.url:
        title = rawValue.startsWith('http') ? rawValue : 'https://$rawValue';
        break;
      case QRType.email:
        title = rawValue.replaceFirst('mailto:', '');
        break;
      case QRType.phone:
        title = rawValue.replaceFirst('tel:', '');
        break;
      case QRType.contact:
        title = 'Danh bạ VCard';
        break;
      case QRType.text:
        title = rawValue.length > 30 ? '${rawValue.substring(0, 30)}...' : rawValue;
        break;
    }

    return QRDataModel(
      id: id,
      rawValue: rawValue,
      type: type,
      title: title,
      timestamp: DateTime.now(),
      isGenerated: isGenerated,
      metadata: metadata,
    );
  }

  /// Parse Wi-Fi format: WIFI:S:MySSID;P:MyPassword;T:WPA;;
  static Map<String, String> parseWifiString(String raw) {
    final Map<String, String> result = {};
    try {
      final ssidMatch = RegExp(r'S:(.*?);').firstMatch(raw);
      final passMatch = RegExp(r'P:(.*?);').firstMatch(raw);
      final typeMatch = RegExp(r'T:(.*?);').firstMatch(raw);

      if (ssidMatch != null) result['ssid'] = ssidMatch.group(1) ?? '';
      if (passMatch != null) result['password'] = passMatch.group(1) ?? '';
      if (typeMatch != null) result['authType'] = typeMatch.group(1) ?? 'WPA';
    } catch (_) {}
    return result;
  }

  /// Open URL in external browser
  static Future<bool> launchURL(String rawUrl) async {
    final String formattedUrl =
        rawUrl.startsWith('http') ? rawUrl : 'https://$rawUrl';
    final Uri uri = Uri.parse(formattedUrl);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Copy text content to system Clipboard
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// Share QR raw content via platform native Share sheet
  static Future<void> shareContent(String text, {String? subject}) async {
    await Share.share(text, subject: subject ?? 'Mã QR từ FlutQR');
  }
}
