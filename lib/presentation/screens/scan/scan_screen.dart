import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../models/qr_data_model.dart';
import '../../../services/qr_service.dart';
import '../../../services/storage_service.dart';
import '../../widgets/scanner_overlay.dart';
import 'scan_result_screen.dart';

/// Live Camera Scan Screen featuring floating pill controls & gallery image picker
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  final ImagePicker _imagePicker = ImagePicker();
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    _processQrCode(rawValue);
  }

  Future<void> _processQrCode(String rawValue) async {
    setState(() {
      _isProcessing = true;
    });

    _controller.stop();

    // Parse data & save to history
    final QRDataModel model = QRService.parseRawData(rawValue, isGenerated: false);
    await StorageService.saveItem(model);

    if (mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ScanResultScreen(qrData: model),
        ),
      );

      // Reset controller when returning
      setState(() {
        _isProcessing = false;
      });
      _controller.start();
    }
  }

  Future<void> _pickImageFromGallery() async {
    if (_isProcessing) return;

    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (file == null) return;

      final BarcodeCapture? capture = await _controller.analyzeImage(file.path);

      if (capture != null && capture.barcodes.isNotEmpty) {
        final String? rawValue = capture.barcodes.first.rawValue;
        if (rawValue != null && rawValue.isNotEmpty) {
          _processQrCode(rawValue);
          return;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không tìm thấy mã QR trong ảnh vừa chọn'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi đọc ảnh: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Camera Preview
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Custom Viewfinder Overlay
          const ScannerOverlay(
            scanLineColor: AppColors.primary,
          ),

          // Top Header Instruction
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                AppStrings.scanInstruction,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Bottom Control Pill Bar (Matching Screenshot 1)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ValueListenableBuilder<MobileScannerState>(
                  valueListenable: _controller,
                  builder: (context, state, child) {
                    final bool isTorchOn = state.torchState == TorchState.on;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Flash Toggle Button
                        IconButton(
                          iconSize: 26,
                          icon: Icon(
                            isTorchOn
                                ? Icons.flash_on_rounded
                                : Icons.flash_on_outlined,
                            color: isTorchOn
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                          onPressed: () => _controller.toggleTorch(),
                        ),

                        // Vertical Divider
                        Container(
                          height: 24,
                          width: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: AppColors.border,
                        ),

                        // Gallery Picker Button
                        IconButton(
                          iconSize: 26,
                          icon: const Icon(
                            Icons.collections_outlined,
                            color: AppColors.textPrimary,
                          ),
                          onPressed: _pickImageFromGallery,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
