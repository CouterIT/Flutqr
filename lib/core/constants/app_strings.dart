/// Vietnamese UI Strings and labels
class AppStrings {
  AppStrings._();

  // App Name
  static const String appName = 'FlutQR';
  static const String appSubtitle = 'Quét & Tạo mã QR nhanh chóng';

  // Navigation Tabs
  static const String tabScan = 'Quét mã';
  static const String tabGenerate = 'Tạo mã';
  static const String tabHistory = 'Lịch sử';

  // Scan Screen
  static const String scanTitle = 'Quét mã QR';
  static const String scanInstruction = 'Di chuyển ống kính tới vùng chứa mã QR';
  static const String torchOn = 'Đã bật đèn';
  static const String torchOff = 'Đèn flash';
  static const String pickFromGallery = 'Thư viện ảnh';
  static const String switchCamera = 'Đổi camera';

  // Scan Result Screen
  static const String resultTitle = 'Kết quả quét';
  static const String resultType = 'Loại mã';
  static const String rawContent = 'Nội dung';
  static const String parsedDetails = 'Chi tiết thông tin';
  static const String btnOpenLink = 'Mở liên kết';
  static const String btnCopy = 'Sao chép';
  static const String btnShare = 'Chia sẻ';
  static const String btnConnectWifi = 'Kết nối Wi-Fi';
  static const String copiedToClipboard = 'Đã sao chép vào bộ nhớ tạm!';

  // Generate Screen
  static const String generateTitle = 'Tạo mã QR';
  static const String typeText = 'Văn bản';
  static const String typeUrl = 'Đường dẫn (URL)';
  static const String typeWifi = 'Mạng Wi-Fi';
  static const String typeEmail = 'Email';
  static const String typePhone = 'Số điện thoại';

  // Generate Placeholders
  static const String hintText = 'Nhập nội dung văn bản...';
  static const String hintUrl = 'https://example.com';
  static const String hintWifiSsid = 'Tên mạng Wi-Fi (SSID)';
  static const String hintWifiPass = 'Mật khẩu Wi-Fi';
  static const String hintEmail = 'email@example.com';
  static const String hintPhone = '0901234567';

  static const String btnGenerate = 'Tạo mã QR';
  static const String btnDownload = 'Lưu mã';
  static const String qrGeneratedSuccess = 'Đã tạo mã QR thành công!';

  // History Screen
  static const String historyTitle = 'Lịch sử';
  static const String historyTabAll = 'Tất cả';
  static const String historyTabScanned = 'Đã quét';
  static const String historyTabGenerated = 'Đã tạo';
  static const String historySearchHint = 'Tìm kiếm lịch sử...';
  static const String emptyHistory = 'Chưa có lịch sử nào';
  static const String clearHistory = 'Xóa lịch sử';
  static const String confirmClearHistory = 'Bạn có chắc chắn muốn xóa toàn bộ lịch sử?';
  static const String cancel = 'Hủy';
  static const String confirm = 'Xác nhận';
  static const String itemDeleted = 'Đã xóa khỏi lịch sử';

  // Common Errors & Messages
  static const String errorGeneric = 'Đã xảy ra lỗi, vui lòng thử lại';
  static const String errorCameraPermission = 'Vui lòng cấp quyền truy cập camera';
  static const String errorInvalidUrl = 'Đường dẫn liên kết không hợp lệ';
}
