import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Camera Scanner overlay with square cutout, corner accents & animated laser line
class ScannerOverlay extends StatefulWidget {
  final double cutoutSize;
  final Color overlayColor;
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
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

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
        CustomPaint(
          size: Size.infinite,
          painter: _ScannerOverlayPainter(
            cutoutSize: widget.cutoutSize,
            overlayColor: widget.overlayColor,
            borderColor: widget.scanLineColor,
          ),
        ),
        Center(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
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
    final double left = (size.width - cutoutSize) / 2;
    final double top = (size.height - cutoutSize) / 2;
    final Rect cutoutRect = Rect.fromLTWH(left, top, cutoutSize, cutoutSize);

    final Paint overlayPaint = Paint()..color = overlayColor;

    // Draw dark background with cutout
    final Path backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final Path cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(cutoutRect, const Radius.circular(20)));

    final Path finalPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    canvas.drawPath(finalPath, overlayPaint);

    // Draw Corner Accents
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    const double cornerLength = 24.0;
    const double radius = 20.0;

    // Top Left Corner
    canvas.drawPath(
      Path()
        ..moveTo(left, top + cornerLength)
        ..lineTo(left, top + radius)
        ..arcToPoint(Offset(left + radius, top), radius: const Radius.circular(radius))
        ..lineTo(left + cornerLength, top),
      borderPaint,
    );

    // Top Right Corner
    canvas.drawPath(
      Path()
        ..moveTo(left + cutoutSize - cornerLength, top)
        ..lineTo(left + cutoutSize - radius, top)
        ..arcToPoint(Offset(left + cutoutSize, top + radius), radius: const Radius.circular(radius))
        ..lineTo(left + cutoutSize, top + cornerLength),
      borderPaint,
    );

    // Bottom Left Corner
    canvas.drawPath(
      Path()
        ..moveTo(left, top + cutoutSize - cornerLength)
        ..lineTo(left, top + cutoutSize - radius)
        ..arcToPoint(Offset(left + radius, top + cutoutSize), radius: const Radius.circular(radius))
        ..lineTo(left + cornerLength, top + cutoutSize),
      borderPaint,
    );

    // Bottom Right Corner
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
