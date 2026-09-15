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
      return QRType.vcard;
    } else if (clean.startsWith('BEGIN:VEVENT')) {
      return QRType.event;
    } else if (lower.contains('maps.google.com') || lower.contains('goo.gl/maps')) {
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

  /// Helper to build vCard 3.0 string
  static String buildVCardString({
    required String name,
    required String phone,
    required String email,
    required String company,
    required String address,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('BEGIN:VCARD');
    buffer.writeln('VERSION:3.0');
    if (name.isNotEmpty) buffer.writeln('FN:$name');
    if (phone.isNotEmpty) buffer.writeln('TEL:$phone');
    if (email.isNotEmpty) buffer.writeln('EMAIL:$email');
    if (company.isNotEmpty) buffer.writeln('ORG:$company');
    if (address.isNotEmpty) buffer.writeln('ADR:;;$address;;;;');
    buffer.write('END:VCARD');
    return buffer.toString();
  }

  /// Helper to build iCalendar VEVENT string for Invitations / Events
  static String buildEventString({
    required String title,
    required String location,
    required String dateTime,
    required String description,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('BEGIN:VEVENT');
    if (title.isNotEmpty) buffer.writeln('SUMMARY:$title');
    if (location.isNotEmpty) buffer.writeln('LOCATION:$location');
    if (dateTime.isNotEmpty) buffer.writeln('DTSTART:$dateTime');
    if (description.isNotEmpty) buffer.writeln('DESCRIPTION:$description');
    buffer.write('END:VEVENT');
    return buffer.toString();
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
      case QRType.wifi:
        title = 'Mạng Wi-Fi';
        break;
      case QRType.vcard:
        title = 'Danh bạ vCard';
        break;
      case QRType.event:
        title = 'Thiệp mời / Sự kiện';
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
