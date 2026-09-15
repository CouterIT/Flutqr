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

    if (lower.contains('maps.google.com') || lower.contains('goo.gl/maps')) {
      return QRType.location;
    } else if (lower.startsWith('http://') ||
        lower.startsWith('https://') ||
        lower.startsWith('www.')) {
      return QRType.website;
    } else if (lower.startsWith('tel:') ||
        RegExp(r'^\+?[0-9]{8,15}$').hasMatch(clean)) {
      return QRType.number;
    }

    return QRType.text;
  }

  /// Helper to build Google Maps location search URL
  static String buildGoogleMapsUrl(String input) {
    final clean = input.trim();
    if (clean.isEmpty) return '';
    final encoded = Uri.encodeComponent(clean);
    return 'https://www.google.com/maps/search/?api=1&query=$encoded';
  }

  /// Parse raw QR value into QRDataModel entity
  static QRDataModel parseRawData(String rawValue, {bool isGenerated = false}) {
    final type = detectType(rawValue);
    final String id = DateTime.now().millisecondsSinceEpoch.toString();
    String title = rawValue;

    switch (type) {
      case QRType.website:
        title = rawValue.startsWith('http') ? rawValue : 'https://$rawValue';
        break;
      case QRType.number:
        title = rawValue.replaceFirst('tel:', '');
        break;
      case QRType.location:
        title = 'Vị trí Google Maps';
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
    );
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
