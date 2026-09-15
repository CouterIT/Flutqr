import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Overlay camera scanner — tạo hiệu ứng tối với vùng cutout trong suốt
/// và animated laser line chạy qua lại.
///
/// Kết cấu UI:
/// 1. `CustomPaint` vẽ overlay tối (dark background) với cutout hình chữ nhật bo tròn
/// 2. Corner accents (4 góc) — viền màu nổi bật để highlight vùng scan
/// 3. Animated laser line — đường kẻ chạy từ trên xuống dưới liên tục
///
/// Kỹ thuật: dùng `Path.combine(PathOperation.difference, ...)` để
/// "khoét" hình chữ nhật ra khỏi nền tối — vùng cutout sẽ trong suốt,
/// cho phép camera preview hiển thị phía sau.
class ScannerOverlay extends StatefulWidget {
  /// Kích thước vùng cutout (hình vuông).
  final double cutoutSize;
  /// Màu nền tối bao quanh (60% opacity mặc định).
  final Color overlayColor;
  /// Màu đường laser line và corner accents.
  final Color scanLineColor;

  const ScannerOverlay({
    super.key,
    this.cutoutSize = 260,
    this.overlayColor = const Color(0x99000000),
    this.scanLineColor = AppColors.primary,
  });

  @override
  State<ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<ScannerOverlay>
    with SingleTickerProviderStateMixin {
  /// AnimationController quản lý chu trình lặp của laser line.
  ///
  /// `repeat(reverse: true)` tạo hiệu ứng laser chạy lên xuống liên tục.
  /// Duration 2s cho 1 chu kỳ — laser đi từ trên xuống rồi quay lại.
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this, // SingleTickerProviderStateMixin cung cấp Ticker
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Animation từ 0.0 → 1.0 với easeInOut — laser di chuyển mượt mà
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Layer 1: Nền tối với cutout + corner accents (vẽ bằng CustomPainter)
        CustomPaint(
          size: Size.infinite,
          painter: _ScannerOverlayPainter(
            cutoutSize: widget.cutoutSize,
            overlayColor: widget.overlayColor,
            borderColor: widget.scanLineColor,
          ),
        ),
        // Layer 2: Laser line animation — di chuyển trong vùng cutout
        Center(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              // Tính offset vertical dựa trên animation value (0→1)
              final double topOffset = (widget.cutoutSize - 20) * _animation.value;
              return Container(
                width: widget.cutoutSize,
                height: widget.cutoutSize,
                padding: const EdgeInsets.all(10),
                alignment: Alignment.topLeft,
                child: Transform.translate(
                  offset: Offset(0, topOffset),
                  child: Container(
                    height: 2.5,
                    width: widget.cutoutSize - 20,
                    decoration: BoxDecoration(
                      color: widget.scanLineColor,
                      boxShadow: [
                        BoxShadow(
                          color: widget.scanLineColor.withValues(alpha: 0.8),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// CustomPainter vẽ nền tối + cutout + 4 corner accents.
///
/// Kỹ thuật chính: `Path.combine(PathOperation.difference, ...)` —
/// tạo path nền tối bao phủ toàn màn hình, rồi "khoét" vùng cutout
/// bằng cách trừ đi path hình chữ nhật bo tròn.
class _ScannerOverlayPainter extends CustomPainter {
  final double cutoutSize;
  final Color overlayColor;
  final Color borderColor;

  _ScannerOverlayPainter({
    required this.cutoutSize,
    required this.overlayColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Tính vị trí cutout (căn giữa màn hình)
    final double left = (size.width - cutoutSize) / 2;
    final double top = (size.height - cutoutSize) / 2;
    final Rect cutoutRect = Rect.fromLTWH(left, top, cutoutSize, cutoutSize);

    final Paint overlayPaint = Paint()..color = overlayColor;

    // Tạo path nền tối bao phủ toàn màn hình
    final Path backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    // Tạo path cutout — hình chữ nhật bo tròn 20px
    final Path cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(cutoutRect, const Radius.circular(20)));

    // Phép trừ: nền tối MINUS cutout = overlay với vùng trong suốt
    final Path finalPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    canvas.drawPath(finalPath, overlayPaint);

    // Vẽ 4 corner accents — viền màu nổi bật tại 4 góc vùng cutout
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    const double cornerLength = 24.0; // Độ dài mỗi cạnh góc
    const double radius = 20.0; // Bán kính bo tròn

    // Góc trên trái
    canvas.drawPath(
      Path()
        ..moveTo(left, top + cornerLength)
        ..lineTo(left, top + radius)
        ..arcToPoint(Offset(left + radius, top), radius: const Radius.circular(radius))
        ..lineTo(left + cornerLength, top),
      borderPaint,
    );

    // Góc trên phải
    canvas.drawPath(
      Path()
        ..moveTo(left + cutoutSize - cornerLength, top)
        ..lineTo(left + cutoutSize - radius, top)
        ..arcToPoint(Offset(left + cutoutSize, top + radius), radius: const Radius.circular(radius))
        ..lineTo(left + cutoutSize, top + cornerLength),
      borderPaint,
    );

    // Góc dưới trái
    canvas.drawPath(
      Path()
        ..moveTo(left, top + cutoutSize - cornerLength)
        ..lineTo(left, top + cutoutSize - radius)
        ..arcToPoint(Offset(left + radius, top + cutoutSize), radius: const Radius.circular(radius))
        ..lineTo(left + cornerLength, top + cutoutSize),
      borderPaint,
    );

    // Góc dưới phải
    canvas.drawPath(
      Path()
        ..moveTo(left + cutoutSize - cornerLength, top + cutoutSize)
        ..lineTo(left + cutoutSize - radius, top + cutoutSize)
        ..arcToPoint(Offset(left + cutoutSize, top + cutoutSize - radius), radius: const Radius.circular(radius))
        ..lineTo(left + cutoutSize, top + cutoutSize - cornerLength),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
