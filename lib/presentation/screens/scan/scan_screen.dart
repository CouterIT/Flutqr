import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../models/qr_data_model.dart';
import '../../../services/qr_service.dart';
import '../../../services/storage_service.dart';
import '../../widgets/common/scanner_overlay.dart';
import '../../widgets/scan/scan_control_bar.dart';
import 'scan_result_screen.dart';

/// Screen quét mã QR bằng camera real-time.
///
/// Flow chính:
/// 1. Camera detect QR → dừng camera → parse dữ liệu → lưu lịch sử
/// 2. Navigate sang ScanResultScreen hiển thị kết quả
/// 3. Khi quay lại → khởi động camera lại
///
/// Hỗ trợ quét từ camera và từ ảnh trong gallery.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => ScanScreenState();
}

class ScanScreenState extends State<ScanScreen> {
  /// Controller quản lý camera — config speed, hướng camera, trạng thái đèn flash.
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  final ImagePicker _imagePicker = ImagePicker();

  /// Cờ debounce — tránh xử lý liên tục khi camera đang detect.
  bool _isProcessing = false;

  /// Pause camera khi chuyển sang tab khác — tiết kiệm pin và tài nguyên.
  bool _isPaused = false;

  /// Callback được gọi mỗi khi camera detect được barcode/QR.
  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    _processQrCode(rawValue);
  }

  /// Pause camera — gọi từ HomeScreen khi chuyển sang tab khác.
  void pauseCamera() {
    if (!_isPaused && !_isProcessing) {
      _isPaused = true;
      _controller.stop();
    }
  }

  /// Resume camera — gọi từ HomeScreen khi quay lại tab Scan.
  void resumeCamera() {
    if (_isPaused && !_isProcessing) {
      _isPaused = false;
      _controller.start();
    }
  }

  /// Xử lý mã QR: dừng camera → parse → lưu lịch sử → navigate → khởi động lại.
  Future<void> _processQrCode(String rawValue) async {
    setState(() {
      _isProcessing = true;
    });

    // Dừng camera để tránh detect liên tục trong khi đang navigate
    _controller.stop();

    try {
      final QRDataModel model = QRService.parseRawData(rawValue, isGenerated: false);
      await StorageService.saveScannedItem(model);

      if (mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ScanResultScreen(qrData: model),
          ),
        );
      }
    } catch (e) {
      debugPrint('Lỗi xử lý QR code: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xử lý mã QR: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      // Luôn khởi động lại camera và reset state, kể cả khi có lỗi
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        _controller.start();
      }
    }
  }

  /// Chọn ảnh từ gallery rồi phân tích QR码 trong ảnh.
  ///
  /// Dùng `mobile_scanner`'s `analyzeImage` để decode QR từ file ảnh.
  /// Nếu ảnh không chứa QR → hiện SnackBar thông báo.
  Future<void> _pickImageFromGallery() async {
    if (_isProcessing) return;

    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (file == null) return;

      // Phân tích ảnh để tìm QR — không cần mở camera
      final BarcodeCapture? capture = await _controller.analyzeImage(file.path);

      if (capture != null && capture.barcodes.isNotEmpty) {
        final String? rawValue = capture.barcodes.first.rawValue;
        if (rawValue != null && rawValue.isNotEmpty) {
          _processQrCode(rawValue);
          return;
        }
      }

      // Ảnh không chứa mã QR
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
          // Camera preview — chiếm toàn bộ màn hình
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Overlay tối với vùng cutout trong suốt + laser line animation
          const ScannerOverlay(
            scanLineColor: AppColors.primary,
          ),

          // Hướng dẫn quét — hiển thị phía trên cùng
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

          // Thanh điều khiển nổi phía dưới — toggle đèn flash + chọn ảnh từ gallery
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: ScanControlBar(
              controller: _controller,
              onPickImage: _pickImageFromGallery,
            ),
          ),

          // Loading overlay khi đang xử lý QR — hiện spinner giữa màn hình
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    SizedBox(height: 16),
                    Text(
                      'Đang xử lý mã QR...',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
