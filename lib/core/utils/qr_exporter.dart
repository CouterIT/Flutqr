import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Helper utility for capturing, sharing, and saving QR code PNG image files
class QrExporter {
  QrExporter._();

  /// Captures rendered RepaintBoundary widget as PNG byte array
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
      debugPrint('Error capturing QR PNG: $e');
      return null;
    }
  }

  /// Shares the actual rendered QR image file (.png) via native Share sheet
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
      debugPrint('Error sharing QR image: $e');
    }
  }

  /// Saves the rendered QR image (.png) directly to device photo gallery
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
      debugPrint('Error saving QR image via Gal: $e');
      try {
        final tempDir = await getTemporaryDirectory();
        final String fileName = 'QR_${DateTime.now().millisecondsSinceEpoch}.png';
        final File file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(pngBytes);
        return true;
      } catch (err) {
        debugPrint('Error in fallback save: $err');
        return false;
      }
    }
  }
}
