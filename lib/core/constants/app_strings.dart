/// Tập trung tất cả chuỗi UI tiếng Việt của ứng dụng.
///
/// Khi cần sửa nội dung hiển thị, chỉ cần sửa tại đây.
/// Private constructor ngăn khởi tạo instance — class chỉ chứa static constants.
class AppStrings {
  AppStrings._();

  // ================= Tên ứng dụng =================
  static const String appName = 'FlutQR';
  static const String appSubtitle = 'Quét & Tạo mã QR nhanh chóng';

  // ================= Thanh điều hướng =================
  static const String tabScan = 'Quét mã';
  static const String tabGenerate = 'Tạo mã';
  static const String tabHistory = 'Lịch sử';

  // ================= Screen quét =================
  static const String scanTitle = 'Quét mã QR';
  static const String scanInstruction = 'Di chuyển ống kính tới vùng chứa mã QR';
  static const String torchOn = 'Đã bật đèn';
  static const String torchOff = 'Đèn flash';
  static const String pickFromGallery = 'Thư viện ảnh';
  static const String switchCamera = 'Đổi camera';
  static const String scanQrNotFound = 'Không tìm thấy mã QR trong ảnh vừa chọn';
  static const String scanError = 'Lỗi khi đọc ảnh';

  // ================= Screen kết quả quét =================
  static const String resultTitle = 'Kết quả quét';
  static const String qrCodeTitle = 'QR-Code';
  static const String resultType = 'Loại mã';
  static const String rawContent = 'Nội dung';
  static const String urlLabel = 'URL :';
  static const String contentLabel = 'Nội dung :';
  static const String parsedDetails = 'Chi tiết thông tin';
  static const String btnOpenLink = 'Mở liên kết';
  static const String btnOpenWeb = 'Mở Web';
  static const String btnCallPhone = 'Gọi điện';
  static const String btnOpenMaps = 'Mở Maps';
  static const String btnViewOnline = 'Xem ảnh Online';
  static const String btnShareImage = 'Chia sẻ ảnh';
  static const String btnCopy = 'Sao chép';
  static const String btnShare = 'Chia sẻ';
  static const String btnConnectWifi = 'Kết nối Wi-Fi';
  static const String copiedToClipboard = 'Đã sao chép nội dung!';
  static const String btnSaveQr = 'Lưu ảnh QR';
  static const String btnSaveSuccess = 'Đã lưu hình ảnh mã QR vào thư viện ảnh thành công!';
  static const String btnSaveFailed = 'Không thể lưu mã QR, vui lòng kiểm tra quyền thư viện ảnh!';
  static const String btnShareAction = 'Chia sẻ';
  static const String errorCannotOpenBrowser = 'Không thể mở trình duyệt. Vui lòng kiểm tra lại liên kết hoặc trình duyệt thiết bị.';
  static const String shareQrText = 'Mã QR từ FlutQR';
  static const String shareImageText = 'Ảnh từ FlutQR';

  // ================= Warning Dialog =================
  static const String warningTitle = 'Cảnh báo nguy hiểm!';
  static const String warningContent = 'VirusTotal phát hiện đường link này có nguy cơ lừa đảo (phishing) hoặc chứa mã độc.\n\nBạn có chắc chắn vẫn muốn tiếp tục truy cập không?';
  static const String warningCancel = 'Hủy (Khuyên dùng)';
  static const String warningContinue = 'Vẫn tiếp tục';

  // ================= Screen tạo mã =================
  static const String generateTitle = 'Tạo mã QR';
  static const String createNew = 'Tạo mới';
  static const String createdCodes = 'Mã đã tạo';
  static const String emptyCreated = 'Bạn chưa tạo mã QR nào';
  static const String typeText = 'Văn bản';
  static const String typeUrl = 'Đường dẫn (URL)';
  static const String typeWifi = 'Mạng Wi-Fi';
  static const String typeEmail = 'Email';
  static const String typePhone = 'Số điện thoại';
  static const String qrCategoryTitle = 'QR-Code';

  // ================= Placeholder cho input =================
  static const String hintText = 'Nhập nội dung văn bản...';
  static const String hintUrl = 'https://example.com';
  static const String hintWifiSsid = 'Tên mạng Wi-Fi (SSID)...';
  static const String hintWifiPass = 'Mật khẩu Wi-Fi...';
  static const String hintEmail = 'email@example.com';
  static const String hintPhone = 'Nhập số điện thoại...';
  static const String hintLocation = 'Nhập địa chỉ hoặc tọa độ...';
  static const String hintVcardName = 'Họ và tên...';
  static const String hintVcardPhone = 'Số điện thoại...';
  static const String hintVcardEmail = 'Email...';
  static const String hintVcardCompany = 'Công ty / Chức danh...';
  static const String hintVcardAddress = 'Địa chỉ...';
  static const String hintEventTitle = 'Tiêu đề thiệp mời...';
  static const String hintEventLocation = 'Địa điểm tổ chức...';
  static const String hintEventDateTime = 'Ngày & Giờ...';
  static const String hintEventNote = 'Ghi chú / Lời mời...';

  static const String btnGenerate = 'Tạo mã QR';
  static const String btnDownload = 'Lưu mã';
  static const String qrGeneratedSuccess = 'Đã tạo mã QR thành công!';

  // ================= Image Upload =================
  static const String pickImageFromGallery = 'Chọn ảnh từ thư viện';
  static const String changeImage = 'Đổi ảnh khác';
  static const String uploadingImage = 'Đang tải lên...';
  static const String uploadingToCloud = 'Đang tải ảnh lên Imgbb Cloud...';
  static const String uploadSuccess = 'Đã tải lên Imgbb Cloud thành công!';
  static const String uploadError = 'Không thể tải ảnh lên Imgbb Cloud.';

  // ================= Screen lịch sử =================
  static const String historyTitle = 'Lịch sử';
  static const String historyTabAll = 'Tất cả';
  static const String historyTabScanned = 'Đã quét';
  static const String historyTabGenerated = 'Đã tạo';
  static const String historySearchHint = 'Tìm kiếm lịch sử...';
  static const String emptyHistory = 'Chưa có lịch sử quét nào';
  static const String clearHistory = 'Xóa lịch sử';
  static const String confirmClearHistory = 'Bạn có chắc chắn muốn xóa toàn bộ lịch sử?';
  static const String cancel = 'Hủy';
  static const String confirm = 'Xác nhận';
  static const String delete = 'Xóa';
  static const String itemDeleted = 'Đã xóa khỏi lịch sử';

  // ================= Dialog xóa =================
  static const String deleteSelected = 'Xóa mục đã chọn';
  static const String deleteAllCreated = 'Xóa tất cả mã đã tạo';
  static const String deleteAllHistory = 'Xóa tất cả lịch sử';
  static const String confirmDeleteSingle = 'Bạn có chắc chắn muốn xóa mục đã chọn?';
  static const String confirmDeleteAll = 'Bạn có chắc chắn muốn xóa toàn bộ mục đã chọn?';

  // ================= Selection =================
  static const String selectedCountLabel = 'Đã chọn';

  // ================= QR Detail =================
  static const String labelUrl = 'URL :';
  static const String labelContent = 'Nội dung :';

  // ================= Thông báo lỗi =================
  static const String errorGeneric = 'Đã xảy ra lỗi, vui lòng thử lại';
  static const String errorCameraPermission = 'Vui lòng cấp quyền truy cập camera';
  static const String errorInvalidUrl = 'Đường dẫn liên kết không hợp lệ';
}
