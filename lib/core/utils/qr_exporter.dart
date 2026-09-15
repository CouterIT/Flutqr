import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Helper chuyển widget QR đang render thành file PNG — chia sẻ hoặc lưu thiết bị.
///
/// Flow chung: render widget → capture PNG bytes → xử lý (share/lưu).
/// Dùng `RepaintBoundary` key để truy cập widget đã render trong tree.
/// Private constructor ngăn khởi tạo instance.
class QrExporter {
  QrExporter._();

  /// Capture widget QR đang render thành mảng PNG bytes.
  ///
  /// `RepaintBoundary` cho phép "bắt" bitmap của widget con mà không affect
  /// widget cha. `pixelRatio: 3.0` capture ở độ phân giải cao 3x
  /// để QR code sắc nét khi chia sẻ hoặc in.
  static Future<Uint8List?> capturePng(GlobalKey key) async {
    try {
      final RenderRepaintBoundary? boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Lỗi khi capture QR PNG: $e');
      return null;
    }
  }

  /// Chia sẻ file PNG của mã QR qua native share sheet.
  ///
  /// Flow: capture PNG → lưu tạm vào temp directory → gọi Share.shareXFiles.
  /// File tạm sẽ bị hệ thống dọn dẹp tự động sau khi share xong.
  static Future<void> shareQrImage(GlobalKey key, {String? text}) async {
    final Uint8List? pngBytes = await capturePng(key);
    if (pngBytes == null) return;

    try {
      final tempDir = await getTemporaryDirectory();
      final String fileName =
          'QR_${DateTime.now().millisecondsSinceEpoch}.png';
      final File file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: text ?? 'Mã QR từ FlutQR',
      );
    } catch (e) {
      debugPrint('Lỗi khi chia sẻ QR: $e');
    }
  }

  /// Lưu file PNG của mã QR vào thư viện ảnh thiết bị.
  ///
  /// Thử lưu bằng `gal` package trước (để ảnh xuất hiện trong Gallery).
  /// Nếu `gal` thất bại (thiếu quyền, lỗi platform), fallback về
  /// lưu file PNG vào temp directory — vẫn đảm bảo dữ liệu không bị mất.
  static Future<bool> saveQrImageToDevice(GlobalKey key,
      {String? customName}) async {
    final Uint8List? pngBytes = await capturePng(key);
    if (pngBytes == null) return false;

    try {
      final String cleanName =
          'QR_${customName?.replaceAll(RegExp(r'[^\w\s-]'), '') ?? DateTime.now().millisecondsSinceEpoch}';
      await Gal.putImageBytes(pngBytes, name: cleanName);
      return true;
    } catch (e) {
      debugPrint('Lỗi lưu QR bằng Gal: $e');
      // Fallback: lưu file PNG vào temp directory
      try {
        final tempDir = await getTemporaryDirectory();
        final String fileName = 'QR_${DateTime.now().millisecondsSinceEpoch}.png';
        final File file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(pngBytes);
        return true;
      } catch (err) {
        debugPrint('Lỗi fallback lưu QR: $err');
        return false;
      }
    }
  }
}
