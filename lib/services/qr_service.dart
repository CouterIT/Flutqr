import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/qr_data_model.dart';
import '../models/qr_type.dart';

/// Service xử lý business logic liên quan đến mã QR.
///
/// Chịu trách nhiệm:
/// - Phát hiện loại QR từ chuỗi thô (pattern matching)
/// - Parse chuỗi QR thành QRDataModel
/// - Xây dựng chuỗi theo chuẩn (vCard, event, Google Maps URL)
/// - Thực hiện hành động: mở URL, gọi điện, copy, share
///
/// Class này không chứa UI code — chỉ xử lý dữ liệu và gọi platform APIs.
/// Private constructor ngăn khởi tạo instance — tất cả method đều static.
class QRService {
  QRService._();

  /// Tự động phát hiện loại QR dựa trên pattern matching của chuỗi thô.
  ///
  /// Thứ tự check quan trọng — check các pattern đặc biệt trước
  /// (WiFi, vCard, event có prefix rõ ràng), rồi đến URL/số điện thoại,
  /// cuối cùng fallback về text thường.
  static QRType detectType(String rawValue) {
    final clean = rawValue.trim();
    final lower = clean.toLowerCase();

    // Ảnh: bắt đầu bằng "IMG:" hoặc "file://" hoặc kết thúc bằng đuôi ảnh
    if (clean.startsWith('IMG:') || clean.startsWith('file://') || lower.endsWith('.jpg') || lower.endsWith('.png') || lower.endsWith('.jpeg')) {
      return QRType.image;
    } else if (clean.startsWith('WIFI:') || clean.startsWith('wifi:')) {
      return QRType.wifi;
    } else if (clean.startsWith('BEGIN:VCARD')) {
      return QRType.vcard;
    } else if (clean.startsWith('BEGIN:VEVENT')) {
      return QRType.event;
    } else if (lower.contains('maps.google.com') || lower.endsWith('.goo.gl/maps')) {
      return QRType.location;
    } else if (lower.startsWith('http://') ||
        lower.startsWith('https://') ||
        lower.startsWith('www.')) {
      return QRType.website;
    } else if (lower.startsWith('tel:') ||
        RegExp(r'^\+?[0-9]{8,15}$').hasMatch(clean)) {
      return QRType.number;
    }

    // Fallback: mọi thứ khác đều là text thường
    return QRType.text;
  }

  /// Tạo URL tìm kiếm Google Maps từ chuỗi địa chỉ.
  ///
  /// Dùng `Uri.encodeComponent` để mã hóa ký tự đặc biệt (dấu cách, dấu phẩy...)
  /// thành dạng URL-safe trước khi ghép vào query parameter.
  static String buildGoogleMapsUrl(String input) {
    final clean = input.trim();
    if (clean.isEmpty) return '';
    final encoded = Uri.encodeComponent(clean);
    return 'https://www.google.com/maps/search/?api=1&query=$encoded';
  }

  /// Xây dựng chuỗi vCard 3.0 từ các thông tin liên hệ.
  ///
  /// vCard là chuẩn quốc tế để trao đổi thông tin danh bạ.
  /// Mỗi field chỉ được thêm vào chuỗi nếu không rỗng —
  /// tránh tạo QR chứa thông tin thừa.
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

  /// Xây dựng chuỗi iCalendar VEVENT cho thiệp mời / sự kiện.
  ///
  /// VEVENT là chuẩn iCalendar dùng để tạo sự kiện trong lịch.
  /// dtstart dùng định dạng số (VD: 20261225T200000) hoặc text tự do.
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

  /// Parse chuỗi QR thô thành QRDataModel hoàn chỉnh.
  ///
  /// Flow: detect type → sinh ID từ timestamp → tạo title hiển thị theo type →
  /// trả về model để lưu vào storage hoặc hiển thị trên UI.
  /// `isGenerated` phân biệt mã tạo trong app (true) vs mã quét từ camera (false).
  static QRDataModel parseRawData(String rawValue, {bool isGenerated = false}) {
    final type = detectType(rawValue);
    final String id = DateTime.now().millisecondsSinceEpoch.toString();
    String title = rawValue;

    // Tạo title hiển thị phù hợp với từng loại QR
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
      case QRType.image:
        title = 'QR Ảnh';
        break;
      case QRType.text:
        // Rút gọn text dài để hiển thị vừa vặn trong list item
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

  /// Mở URL trong trình duyệt bên ngoài (browser app của thiết bị).
  ///
  /// Đảm bảo URL luôn có prefix "http://" hoặc "https://"
  /// vì `canLaunchUrl` sẽ trả false nếu URL thiếu scheme.
  static Future<bool> launchURL(String rawUrl) async {
    final String formattedUrl =
        rawUrl.startsWith('http') ? rawUrl : 'https://$rawUrl';
    final Uri uri = Uri.parse(formattedUrl);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Mở ứng dụng điện thoại với số điện thoại đã điền sẵn.
  ///
  /// Xóa prefix "tel:" nếu có vì `Uri.parse('tel:...')` cần số thuần.
  static Future<bool> launchPhoneDialer(String rawNumber) async {
    final String cleanNumber = rawNumber.replaceFirst('tel:', '').trim();
    final Uri uri = Uri.parse('tel:$cleanNumber');
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }

  /// Sao chép text vào clipboard hệ thống.
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// Chia sẻ nội dung QR qua native share sheet.
  static Future<void> shareContent(String text, {String? subject}) async {
    await Share.share(text, subject: subject ?? 'Mã QR từ FlutQR');
  }
}
