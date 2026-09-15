import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../models/qr_type.dart';
import '../../../services/qr_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/qr_view_box.dart';

/// QR Creation form with live preview
class GenerateFormWidget extends StatefulWidget {
  final QRType type;
  final GlobalKey? repaintKey;
  final ValueChanged<String> onPayloadChanged;
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

    for (final entry in _controllers.entries) {
      for (final c in entry.value) {
        c.addListener(_updatePayload);
      }
    }
  }

  @override
  void dispose() {
    for (final entry in _controllers.entries) {
      for (final c in entry.value) {
        c.removeListener(_updatePayload);
        c.dispose();
      }
    }
    super.dispose();
  }

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

    widget.onPayloadChanged(payload);
  }

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
          Center(
            child: QrViewBox(
              qrData: '',
              size: 190,
              foregroundColor: widget.type.color,
              repaintKey: widget.repaintKey,
            ),
          ),
          const SizedBox(height: 24),
          _buildInput(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInput() {
    final c = _controllers[widget.type]!;
    switch (widget.type) {
      case QRType.text:
        return TextField(controller: c[0], maxLines: 4, decoration: const InputDecoration(hintText: 'Nhập nội dung văn bản...'));
      case QRType.number:
        return TextField(controller: c[0], keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: 'Nhập số điện thoại...', prefixIcon: Icon(Icons.phone_rounded)));
      case QRType.website:
        return TextField(controller: c[0], keyboardType: TextInputType.url, decoration: const InputDecoration(hintText: 'https://example.com', prefixIcon: Icon(Icons.link_rounded)));
      case QRType.location:
        return TextField(controller: c[0], decoration: const InputDecoration(hintText: 'Nhập địa chỉ hoặc tọa độ...', prefixIcon: Icon(Icons.location_on_rounded)));
      case QRType.wifi:
        return Column(children: [
          TextField(controller: c[0], decoration: const InputDecoration(hintText: 'Tên mạng Wi-Fi (SSID)...', prefixIcon: Icon(Icons.wifi_rounded))),
          const SizedBox(height: 12),
          TextField(controller: c[1], obscureText: true, decoration: const InputDecoration(hintText: 'Mật khẩu Wi-Fi...', prefixIcon: Icon(Icons.lock_rounded))),
        ]);
      case QRType.vcard:
        return Column(children: [
          TextField(controller: c[0], decoration: const InputDecoration(hintText: 'Họ và tên...', prefixIcon: Icon(Icons.person_rounded))),
          const SizedBox(height: 12),
          TextField(controller: c[1], keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: 'Số điện thoại...', prefixIcon: Icon(Icons.phone_rounded))),
          const SizedBox(height: 12),
          TextField(controller: c[2], keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'Email...', prefixIcon: Icon(Icons.email_rounded))),
          const SizedBox(height: 12),
          TextField(controller: c[3], decoration: const InputDecoration(hintText: 'Công ty / Chức danh...', prefixIcon: Icon(Icons.business_rounded))),
          const SizedBox(height: 12),
          TextField(controller: c[4], decoration: const InputDecoration(hintText: 'Địa chỉ...', prefixIcon: Icon(Icons.location_city_rounded))),
        ]);
      case QRType.event:
        return Column(children: [
          TextField(controller: c[0], decoration: const InputDecoration(hintText: 'Tiêu đề thiệp mời...', prefixIcon: Icon(Icons.insert_invitation_rounded))),
          const SizedBox(height: 12),
          TextField(controller: c[1], decoration: const InputDecoration(hintText: 'Địa điểm tổ chức...', prefixIcon: Icon(Icons.place_rounded))),
          const SizedBox(height: 12),
          TextField(controller: c[2], decoration: const InputDecoration(hintText: 'Ngày & Giờ...', prefixIcon: Icon(Icons.event_rounded))),
          const SizedBox(height: 12),
          TextField(controller: c[3], maxLines: 3, decoration: const InputDecoration(hintText: 'Ghi chú / Lời mời...', prefixIcon: Icon(Icons.notes_rounded))),
        ]);
      case QRType.image:
        return Column(children: [
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
