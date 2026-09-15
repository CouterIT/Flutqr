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

  const ScanResultScreen({
    super.key,
    required this.qrData,
  });

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  final GlobalKey _qrBoundaryKey = GlobalKey();
  bool _isSaving = false;

  String get _typeTitle {
    switch (widget.qrData.type) {
      case QRType.website:
        return 'Website';
      case QRType.text:
        return 'Văn bản';
      case QRType.number:
        return 'Number';
      case QRType.location:
        return 'Location';
      case QRType.wifi:
        return 'Wi-Fi';
      case QRType.vcard:
        return 'vCard';
      case QRType.event:
        return 'Thiệp mời';
      case QRType.image:
        return 'QR Ảnh';
    }
  }

  IconData get _typeIcon {
    switch (widget.qrData.type) {
      case QRType.website:
        return Icons.web_rounded;
      case QRType.text:
        return Icons.notes_rounded;
      case QRType.number:
        return Icons.phone_rounded;
      case QRType.location:
        return Icons.location_on_rounded;
      case QRType.wifi:
        return Icons.wifi_rounded;
      case QRType.vcard:
        return Icons.badge_rounded;
      case QRType.event:
        return Icons.insert_invitation_rounded;
      case QRType.image:
        return Icons.image_rounded;
    }
  }

  String get _secondaryActionLabel {
    switch (widget.qrData.type) {
      case QRType.website:
        return 'Mở Web';
      case QRType.number:
        return 'Gọi điện';
      case QRType.location:
        return 'Mở Maps';
      case QRType.image:
        return 'Chia sẻ ảnh';
      case QRType.text:
      case QRType.wifi:
      case QRType.vcard:
      case QRType.event:
        return 'Sao chép';
    }
  }

  IconData get _secondaryActionIcon {
    switch (widget.qrData.type) {
      case QRType.website:
        return Icons.open_in_browser_rounded;
      case QRType.number:
        return Icons.call_rounded;
      case QRType.location:
        return Icons.map_rounded;
      case QRType.image:
        return Icons.share_rounded;
      case QRType.text:
      case QRType.wifi:
      case QRType.vcard:
      case QRType.event:
        return Icons.copy_rounded;
    }
  }

  void _performMainAction() {
    if (widget.qrData.type == QRType.website ||
        widget.qrData.type == QRType.location) {
      QRService.launchURL(widget.qrData.rawValue);
    } else if (widget.qrData.type == QRType.number) {
      QRService.launchPhoneDialer(widget.qrData.rawValue);
    } else if (widget.qrData.type == QRType.image) {
      final String filePath = widget.qrData.rawValue.replaceFirst('IMG:', '');
      final File imageFile = File(filePath);
      if (imageFile.existsSync()) {
        Share.shareXFiles([XFile(imageFile.path)], text: 'Ảnh từ FlutQR');
      } else {
        QrExporter.shareQrImage(_qrBoundaryKey, text: 'Mã QR Ảnh từ FlutQR');
      }
    } else {
      QRService.copyToClipboard(widget.qrData.rawValue);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã sao chép nội dung!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _shareQrImageFile() async {
    await QrExporter.shareQrImage(
      _qrBoundaryKey,
      text: 'Mã QR ($_typeTitle): ${widget.qrData.title}',
    );
  }

  Future<void> _saveQrImageToDevice() async {
    setState(() {
      _isSaving = true;
    });

    final bool isSuccess = await QrExporter.saveQrImageToDevice(
      _qrBoundaryKey,
      customName: _typeTitle,
    );

    setState(() {
      _isSaving = false;
    });

    if (mounted) {
      if (isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã lưu hình ảnh mã QR vào thư viện ảnh thành công!'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Chia sẻ',
              textColor: Colors.white,
              onPressed: _shareQrImageFile,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể lưu mã QR vào máy, vui lòng kiểm tra quyền thư viện ảnh!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'QR-Code',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            tooltip: 'Chia sẻ hình ảnh mã QR',
            onPressed: _shareQrImageFile,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Sub-header Banner: Type Title (Website / Text / etc.)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _typeIcon,
                    color: const Color(0xFF6BB5C5),
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    _typeTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 36),

                    // Centered Rendered QR Code wrapped in RepaintBoundary
                    Center(
                      child: RepaintBoundary(
                        key: _qrBoundaryKey,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFFEEEEEE), width: 1.5),
                          ),
                          child: QrImageView(
                            data: widget.qrData.rawValue,
                            version: QrVersions.auto,
                            size: 210,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: Colors.black,
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 2 Action Buttons Side-by-Side
                    ScanActionButtons(
                      isSaving: _isSaving,
                      secondaryActionLabel: _secondaryActionLabel,
                      secondaryActionIcon: _secondaryActionIcon,
                      onSavePressed: _saveQrImageToDevice,
                      onActionPressed: _performMainAction,
                    ),

                    const SizedBox(height: 32),

                    // Payload details display at bottom
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.qrData.type == QRType.website ||
                                  widget.qrData.type == QRType.location
                              ? 'URL :'
                              : 'Nội dung :',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: _performMainAction,
                          child: Text(
                            widget.qrData.rawValue,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF4285F4),
                              decoration: TextDecoration.underline,
                              height: 1.35,
                            ),
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
