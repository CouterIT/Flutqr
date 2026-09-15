import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/qr_data_model.dart';
import '../../../models/qr_type.dart';
import '../../../services/qr_service.dart';

/// Scan Result Screen supporting all 7 QR payload types
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
  int _selectedTemplateIndex = 0;

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
    }
  }

  String get _actionLabelText {
    switch (widget.qrData.type) {
      case QRType.website:
        return 'Open URL\nin google';
      case QRType.text:
        return 'Sao chép văn bản';
      case QRType.number:
        return 'Gọi số điện thoại';
      case QRType.location:
        return 'Mở vị trí\ntrên Google Maps';
      case QRType.wifi:
        return 'Sao chép thông tin Wi-Fi';
      case QRType.vcard:
        return 'Sao chép danh bạ';
      case QRType.event:
        return 'Sao chép thông tin sự kiện';
    }
  }

  void _performMainAction() {
    if (widget.qrData.type == QRType.website ||
        widget.qrData.type == QRType.location) {
      QRService.launchURL(widget.qrData.rawValue);
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
              QRService.shareContent(widget.qrData.rawValue);
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

                    const SizedBox(height: 36),

                    // Main Action Text
                    InkWell(
                      onTap: _performMainAction,
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

                    const SizedBox(height: 40),

                    // Customization Palette Presets Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildTemplateIcon(
                            index: 0,
                            child: const Icon(
                              Icons.photo_library_outlined,
                              size: 24,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _buildTemplateIcon(
                            index: 1,
                            child: const Icon(
                              Icons.block_rounded,
                              size: 24,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _buildColorPresetThumbnail(index: 2, color: Colors.lightBlue),
                          const SizedBox(width: 10),
                          _buildColorPresetThumbnail(index: 3, color: Colors.cyan),
                          const SizedBox(width: 10),
                          _buildColorPresetThumbnail(index: 4, color: Colors.brown),
                          const SizedBox(width: 10),
                          _buildColorPresetThumbnail(index: 5, color: Colors.indigo),
                          const SizedBox(width: 10),
                          _buildColorPresetThumbnail(index: 6, color: Colors.teal),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Details display at bottom
                    Align(
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: widget.qrData.type == QRType.website ||
                                      widget.qrData.type == QRType.location
                                  ? 'URL : '
                                  : 'Nội dung : ',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: _performMainAction,
                                child: Text(
                                  widget.qrData.rawValue,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF4285F4),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateIcon({required int index, required Widget child}) {
    final bool isSelected = _selectedTemplateIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTemplateIndex = index),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _buildColorPresetThumbnail({required int index, required Color color}) {
    final bool isSelected = _selectedTemplateIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTemplateIndex = index),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.qr_code_2_rounded,
            size: 24,
            color: color,
          ),
        ),
      ),
    );
  }
}
