/// Các hằng số về kích thước, khoảng cách, và giá trị UI cố định.
///
/// Tập trung tất cả magic numbers tại 1 nơi — dễ thay đổi và bảo trì.
/// Private constructor ngăn khởi tạo instance.
class AppDimens {
  AppDimens._();

  // ================= Border Radius =================
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusPill = 28.0;
  static const double radiusCircular = 24.0;

  // ================= Padding =================
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 12.0;
  static const double paddingDefault = 16.0;
  static const double paddingLarge = 20.0;
  static const double paddingXLarge = 24.0;

  // ================= Spacing =================
  static const double spacingTiny = 2.0;
  static const double spacingSmall = 4.0;
  static const double spacingMedium = 6.0;
  static const double spacingDefault = 8.0;
  static const double spacingLarge = 12.0;
  static const double spacingXL = 14.0;
  static const double spacingXXL = 16.0;
  static const double spacingHuge = 24.0;
  static const double spacingXHuge = 32.0;
  static const double spacingTop = 36.0;

  // ================= Icon Sizes =================
  static const double iconSmall = 16.0;
  static const double iconMedium = 20.0;
  static const double iconLarge = 22.0;
  static const double iconXL = 26.0;
  static const double iconXXL = 28.0;
  static const double iconHuge = 48.0;
  static const double iconEmptyState = 64.0;

  // ================= Font Sizes =================
  static const double fontSizeSmall = 10.0;
  static const double fontSizeCaption = 11.0;
  static const double fontSizeBodySmall = 12.0;
  static const double fontSizeBody = 13.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeBodyLarge = 15.0;
  static const double fontSizeTitle = 16.0;
  static const double fontSizeLarge = 17.0;
  static const double fontSizeHeadline = 18.0;
  static const double fontSizeXL = 20.0;
  static const double fontSizeEmptyState = 24.0;

  // ================= QR Code Sizes =================
  static const double qrPreviewSize = 210.0;
  static const double qrViewBoxSize = 220.0;
  static const double qrLogoSize = 36.0;
  static const double qrCutoutSize = 260.0;

  // ================= Scanner =================
  static const double scannerCutoutSize = 260.0;
  static const double scannerOverlayOpacity = 0.6;
  static const double scannerLaserHeight = 2.5;
  static const double scannerCornerLength = 24.0;
  static const double scannerCornerWidth = 4.0;

  // ================= Button =================
  static const double buttonHeight = 56.0;
  static const double buttonPaddingH = 20.0;
  static const double buttonPaddingV = 14.0;

  // ================= Image =================
  static const double imagePreviewHeight = 160.0;
  static const double exportPixelRatio = 3.0;

  // ================= Divider =================
  static const double dividerHeight = 1.0;
  static const double dividerThickness = 1.0;

  // ================= Border =================
  static const double borderWidthThin = 1.0;
  static const double borderWidthMedium = 1.5;

  // ================= Shadow =================
  static const double shadowBlurRadius = 16.0;
  static const double shadowBlurSmall = 8.0;
  static const double shadowSpreadRadius = 2.0;

  // ================= Timeouts =================
  static const Duration timeoutApi = Duration(seconds: 10);
  static const Duration timeoutUpload = Duration(seconds: 25);

  // ================= Debounce =================
  static const Duration debounceDuration = Duration(milliseconds: 500);

  // ================= Text Truncation =================
  static const int maxTextLength = 30;
  static const int maxTruncateLength = 35;

  // ================= AppBar =================
  static const double appBarTitleFontSize = 20.0;
  static const double appBarIconSize = 28.0;

  // ================= SnackBar =================
  static const Duration snackBarShort = Duration(seconds: 2);
  static const Duration snackBarMedium = Duration(seconds: 3);

  // ================= Animation =================
  static const Duration animationDuration = Duration(seconds: 2);
}
