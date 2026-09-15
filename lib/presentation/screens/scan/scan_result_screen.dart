import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/qr_data_model.dart';
import '../../../models/qr_type.dart';
import '../../../services/qr_service.dart';

/// Scan Result Screen matching Screenshot 2 design without color palette row
class ScanResultScreen extends StatelessWidget {
  final QRDataModel qrData;

  const ScanResultScreen({
    super.key,
    required this.qrData,
  });

  String get _typeTitle {
    switch (qrData.type) {
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
    }
  }

  IconData get _typeIcon {
    switch (qrData.type) {
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
    }
  }

  String get _actionLabelText {
    switch (qrData.type) {
      case QRType.website:
        return 'Open URL\nin google';
      case QRType.number:
        return 'Gọi số điện thoại\n(Phone Dialer)';
      case QRType.location:
        return 'Mở vị trí\ntrên Google Maps';
      case QRType.text:
        return 'Sao chép văn bản';
      case QRType.wifi:
        return 'Sao chép thông tin Wi-Fi';
      case QRType.vcard:
        return 'Sao chép danh bạ';
      case QRType.event:
        return 'Sao chép thông tin sự kiện';
    }
  }

  void _performMainAction(BuildContext context) {
    if (qrData.type == QRType.website || qrData.type == QRType.location) {
      QRService.launchURL(qrData.rawValue);
    } else if (qrData.type == QRType.number) {
      QRService.launchPhoneDialer(qrData.rawValue);
    } else {
      QRService.copyToClipboard(qrData.rawValue);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã sao chép nội dung!'),
          duration: Duration(seconds: 2),
        ),
      );
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
            onPressed: () {
              QRService.shareContent(qrData.rawValue);
            },
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

                    // Centered Rendered QR Code
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: QrImageView(
                          data: qrData.rawValue,
                          version: QrVersions.auto,
                          size: 220,
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

                    const SizedBox(height: 36),

                    // Main Action Text (e.g. "Open URL in google")
                    Center(
                      child: InkWell(
                        onTap: () => _performMainAction(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Text(
                            _actionLabelText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // URL / Payload details display at bottom with aligned layout
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          qrData.type == QRType.website ||
                                  qrData.type == QRType.location
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
                          onTap: () => _performMainAction(context),
                          child: Text(
                            qrData.rawValue,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF4285F4), // Blue link color
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
