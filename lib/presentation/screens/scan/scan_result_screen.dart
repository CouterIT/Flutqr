import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/qr_exporter.dart';
import '../../../models/qr_data_model.dart';
import '../../../models/qr_type.dart';
import '../../../services/qr_service.dart';
import '../../widgets/scan/scan_action_buttons.dart';

/// Scan Result Screen with 2 side-by-side action buttons under QR code
class ScanResultScreen extends StatefulWidget {
  final QRDataModel qrData;

  const ScanResultScreen({super.key, required this.qrData});

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  final GlobalKey _qrBoundaryKey = GlobalKey();
  bool _isSaving = false;

  QRType get _type => widget.qrData.type;

  String get _secondaryActionLabel {
    switch (_type) {
      case QRType.website: return 'Mở Web';
      case QRType.number: return 'Gọi điện';
      case QRType.location: return 'Mở Maps';
      case QRType.image: return 'Chia sẻ ảnh';
      default: return 'Sao chép';
    }
  }

  IconData get _secondaryActionIcon {
    switch (_type) {
      case QRType.website: return Icons.open_in_browser_rounded;
      case QRType.number: return Icons.call_rounded;
      case QRType.location: return Icons.map_rounded;
      case QRType.image: return Icons.share_rounded;
      default: return Icons.copy_rounded;
    }
  }

  void _performMainAction() {
    if (_type == QRType.website || _type == QRType.location) {
      QRService.launchURL(widget.qrData.rawValue);
    } else if (_type == QRType.number) {
      QRService.launchPhoneDialer(widget.qrData.rawValue);
    } else if (_type == QRType.image) {
      final filePath = widget.qrData.rawValue.replaceFirst('IMG:', '');
      final imageFile = File(filePath);
      if (imageFile.existsSync()) {
        Share.shareXFiles([XFile(imageFile.path)], text: 'Ảnh từ FlutQR');
      } else {
        QrExporter.shareQrImage(_qrBoundaryKey, text: 'Mã QR Ảnh từ FlutQR');
      }
    } else {
      QRService.copyToClipboard(widget.qrData.rawValue);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã sao chép nội dung!'), duration: Duration(seconds: 2)),
      );
    }
  }

  Future<void> _shareQrImageFile() async {
    await QrExporter.shareQrImage(_qrBoundaryKey, text: 'Mã QR (${_type.displayName}): ${widget.qrData.title}');
  }

  Future<void> _saveQrImageToDevice() async {
    setState(() => _isSaving = true);
    final isSuccess = await QrExporter.saveQrImageToDevice(_qrBoundaryKey, customName: _type.displayName);
    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isSuccess ? 'Đã lưu hình ảnh mã QR vào thư viện ảnh thành công!' : 'Không thể lưu mã QR, vui lòng kiểm tra quyền thư viện ảnh!'),
          duration: Duration(seconds: isSuccess ? 3 : 2),
          action: isSuccess ? SnackBarAction(label: 'Chia sẻ', textColor: Colors.white, onPressed: _shareQrImageFile) : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUrl = _type == QRType.website || _type == QRType.location;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('QR-Code', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.share_rounded, color: Colors.white), onPressed: _shareQrImageFile),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1))),
              child: Row(
                children: [
                  Icon(_type.icon, color: const Color(0xFF6BB5C5), size: 24),
                  const SizedBox(width: 16),
                  Text(_type.displayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 36),
                    Center(
                      child: RepaintBoundary(
                        key: _qrBoundaryKey,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFEEEEEE), width: 1.5)),
                          child: QrImageView(
                            data: widget.qrData.rawValue,
                            version: QrVersions.auto,
                            size: 210,
                            eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                            dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ScanActionButtons(
                      isSaving: _isSaving,
                      secondaryActionLabel: _secondaryActionLabel,
                      secondaryActionIcon: _secondaryActionIcon,
                      onSavePressed: _saveQrImageToDevice,
                      onActionPressed: _performMainAction,
                    ),
                    const SizedBox(height: 32),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isUrl ? 'URL :' : 'Nội dung :', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: _performMainAction,
                          child: Text(
                            widget.qrData.rawValue,
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: Color(0xFF4285F4), decoration: TextDecoration.underline, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
