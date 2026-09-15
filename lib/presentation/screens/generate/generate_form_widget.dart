import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../models/qr_type.dart';
import '../../../services/qr_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/qr_view_box.dart';

/// Form nhập liệu + preview QR live khi tạo mã QR mới.
///
/// Mỗi loại QR có form input khác nhau:
/// - Text: 1 ô textarea
/// - Number: 1 ô số điện thoại
/// - Website: 1 ô URL
/// - Location: 1 ô địa chỉ
/// - WiFi: 2 ô (SSID + mật khẩu)
/// - vCard: 5 ô (tên, SĐT, email, công ty, địa chỉ)
/// - Event: 4 ô (tiêu đề, địa điểm, ngày giờ, ghi chú)
/// - Image: nút chọn ảnh + preview
///
/// Widget này emit payload QR về parent qua callback `onPayloadChanged`
/// để parent update preview QR và quản lý nút "Tạo mã".
class GenerateFormWidget extends StatefulWidget {
  /// Loại QR đang tạo — quyết định form input nào được hiển thị.
  final QRType type;

  /// GlobalKey cho RepaintBoundary — parent truyền vào để export PNG.
  final GlobalKey? repaintKey;

  /// Callback mỗi khi nội dung form thay đổi — payload QR được gửi về parent.
  final ValueChanged<String> onPayloadChanged;

  /// Callback khi người dùng muốn hủy tạo mã.
  final VoidCallback onCancel;

  const GenerateFormWidget({
    super.key,
    required this.type,
    this.repaintKey,
    required this.onPayloadChanged,
    required this.onCancel,
  });

  @override
  State<GenerateFormWidget> createState() => _GenerateFormWidgetState();
}

class _GenerateFormWidgetState extends State<GenerateFormWidget> {
  final ImagePicker _imagePicker = ImagePicker();
  String? _selectedImagePath;

  /// Map lưu TextEditingController cho mỗi loại QR.
  ///
  /// Mỗi loại có số lượng field khác nhau:
  /// - text/number/website/location: 1 controller
  /// - wifi: 2 controllers (SSID + password)
  /// - vcard: 5 controllers (name, phone, email, company, address)
  /// - event: 4 controllers (title, location, dateTime, note)
  late final Map<QRType, List<TextEditingController>> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {
      QRType.text: [TextEditingController()],
      QRType.number: [TextEditingController()],
      QRType.website: [TextEditingController()],
      QRType.location: [TextEditingController()],
      QRType.wifi: [TextEditingController(), TextEditingController()],
      QRType.vcard: List.generate(5, (_) => TextEditingController()),
      QRType.event: List.generate(4, (_) => TextEditingController()),
    };

    // Thêm listener cho tất cả controllers — mỗi lần text thay đổi thì update payload
    for (final entry in _controllers.entries) {
      for (final c in entry.value) {
        c.addListener(_updatePayload);
      }
    }
  }

  @override
  void dispose() {
    // Gỡ listener rồi dispose tất cả controllers để tránh memory leak
    for (final entry in _controllers.entries) {
      for (final c in entry.value) {
        c.removeListener(_updatePayload);
        c.dispose();
      }
    }
    super.dispose();
  }

  /// Đọc giá trị từ form → build QR payload theo type → gửi về parent.
  ///
  /// Mỗi type có format payload riêng:
  /// - text: nội dung thường
  /// - number: `tel:0901234567`
  /// - website: `https://example.com`
  /// - location: Google Maps URL
  /// - wifi: `WIFI:S:SSID;P:password;T:WPA;;`
  /// - vCard: chuẩn vCard 3.0
  /// - event: chuẩn iCalendar VEVENT
  /// - image: `IMG:/path/to/image`
  void _updatePayload() {
    final c = _controllers[widget.type]!;
    String payload = '';

    switch (widget.type) {
      case QRType.text:
        payload = c[0].text.trim();
      case QRType.number:
        final num = c[0].text.trim();
        payload = num.isNotEmpty ? 'tel:$num' : '';
      case QRType.website:
        final url = c[0].text.trim();
        payload = url.isNotEmpty ? (url.startsWith('http') ? url : 'https://$url') : '';
      case QRType.location:
        final loc = c[0].text.trim();
        payload = loc.isNotEmpty ? QRService.buildGoogleMapsUrl(loc) : '';
      case QRType.wifi:
        final ssid = c[0].text.trim();
        payload = ssid.isNotEmpty ? 'WIFI:S:$ssid;P:${c[1].text.trim()};T:WPA;;' : '';
      case QRType.vcard:
        // Chỉ build vCard nếu có ít nhất tên hoặc SĐT
        if (c[0].text.isNotEmpty || c[1].text.isNotEmpty) {
          payload = QRService.buildVCardString(
            name: c[0].text.trim(),
            phone: c[1].text.trim(),
            email: c[2].text.trim(),
            company: c[3].text.trim(),
            address: c[4].text.trim(),
          );
        }
      case QRType.event:
        // Chỉ build event nếu có tiêu đề
        if (c[0].text.isNotEmpty) {
          payload = QRService.buildEventString(
            title: c[0].text.trim(),
            location: c[1].text.trim(),
            dateTime: c[2].text.trim(),
            description: c[3].text.trim(),
          );
        }
      case QRType.image:
        payload = _selectedImagePath != null ? 'IMG:$_selectedImagePath' : '';
    }

    // Gửi payload về parent để update preview QR realtime
    widget.onPayloadChanged(payload);
  }

  /// Mở gallery để người dùng chọn ảnh cho loại QR "Image".
  Future<void> _pickImage() async {
    final file = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _selectedImagePath = file.path);
      _updatePayload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Preview QR — hiển thị realtime khi nhập liệu
          Center(
            child: QrViewBox(
              qrData: '',
              size: 190,
              foregroundColor: widget.type.color,
              repaintKey: widget.repaintKey,
            ),
          ),
          const SizedBox(height: 24),
          // Form input thay đổi theo loại QR
          _buildInput(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Xây dựng form input phù hợp với loại QR đang chọn.
  Widget _buildInput() {
    final c = _controllers[widget.type]!;
    switch (widget.type) {
      case QRType.text:
        return TextField(
          controller: c[0],
          maxLines: 4,
          textAlignVertical: TextAlignVertical.top,
          decoration: const InputDecoration(
            hintText: 'Nhập nội dung văn bản...',
            alignLabelWithHint: true,
          ),
        );
      case QRType.number:
        return TextField(
          controller: c[0],
          keyboardType: TextInputType.phone,
          textAlignVertical: TextAlignVertical.center,
          decoration: const InputDecoration(
            hintText: 'Nhập số điện thoại...',
            prefixIcon: Icon(Icons.phone_rounded),
          ),
        );
      case QRType.website:
        return TextField(
          controller: c[0],
          keyboardType: TextInputType.url,
          textAlignVertical: TextAlignVertical.center,
          decoration: const InputDecoration(
            hintText: 'https://example.com',
            prefixIcon: Icon(Icons.link_rounded),
          ),
        );
      case QRType.location:
        return TextField(
          controller: c[0],
          textAlignVertical: TextAlignVertical.center,
          decoration: const InputDecoration(
            hintText: 'Nhập địa chỉ hoặc tọa độ...',
            prefixIcon: Icon(Icons.location_on_rounded),
          ),
        );
      case QRType.wifi:
        return Column(children: [
          TextField(
            controller: c[0],
            textAlignVertical: TextAlignVertical.center,
            decoration: const InputDecoration(
              hintText: 'Tên mạng Wi-Fi (SSID)...',
              prefixIcon: Icon(Icons.wifi_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: c[1],
            obscureText: true,
            textAlignVertical: TextAlignVertical.center,
            decoration: const InputDecoration(
              hintText: 'Mật khẩu Wi-Fi...',
              prefixIcon: Icon(Icons.lock_rounded),
            ),
          ),
        ]);
      case QRType.vcard:
        return Column(children: [
          TextField(
            controller: c[0],
            textAlignVertical: TextAlignVertical.center,
            decoration: const InputDecoration(
              hintText: 'Họ và tên...',
              prefixIcon: Icon(Icons.person_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: c[1],
            keyboardType: TextInputType.phone,
            textAlignVertical: TextAlignVertical.center,
            decoration: const InputDecoration(
              hintText: 'Số điện thoại...',
              prefixIcon: Icon(Icons.phone_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: c[2],
            keyboardType: TextInputType.emailAddress,
            textAlignVertical: TextAlignVertical.center,
            decoration: const InputDecoration(
              hintText: 'Email...',
              prefixIcon: Icon(Icons.email_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: c[3],
            textAlignVertical: TextAlignVertical.center,
            decoration: const InputDecoration(
              hintText: 'Công ty / Chức danh...',
              prefixIcon: Icon(Icons.business_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: c[4],
            textAlignVertical: TextAlignVertical.center,
            decoration: const InputDecoration(
              hintText: 'Địa chỉ...',
              prefixIcon: Icon(Icons.location_city_rounded),
            ),
          ),
        ]);
      case QRType.event:
        return Column(children: [
          TextField(
            controller: c[0],
            textAlignVertical: TextAlignVertical.center,
            decoration: const InputDecoration(
              hintText: 'Tiêu đề thiệp mời...',
              prefixIcon: Icon(Icons.insert_invitation_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: c[1],
            textAlignVertical: TextAlignVertical.center,
            decoration: const InputDecoration(
              hintText: 'Địa điểm tổ chức...',
              prefixIcon: Icon(Icons.place_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: c[2],
            textAlignVertical: TextAlignVertical.center,
            decoration: const InputDecoration(
              hintText: 'Ngày & Giờ...',
              prefixIcon: Icon(Icons.event_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: c[3],
            textAlignVertical: TextAlignVertical.center,
            decoration: const InputDecoration(
              hintText: 'Ghi chú / Lời mời...',
              prefixIcon: Icon(Icons.notes_rounded),
            ),
          ),
        ]);
      case QRType.image:
        return Column(children: [
          // Hiển thị preview ảnh nếu đã chọn
          if (_selectedImagePath != null) ...[
            ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(File(_selectedImagePath!), height: 160, width: double.infinity, fit: BoxFit.cover)),
            const SizedBox(height: 16),
          ],
          CustomButton(
            text: _selectedImagePath == null ? 'Chọn ảnh từ thư viện' : 'Đổi ảnh khác',
            icon: Icons.photo_library_rounded,
            isSecondary: true,
            onPressed: _pickImage,
          ),
        ]);
    }
  }
}
