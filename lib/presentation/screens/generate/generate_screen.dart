import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../models/qr_data_model.dart';
import '../../../models/qr_type.dart';
import '../../../services/qr_service.dart';
import '../../../services/storage_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/qr_view_box.dart';

/// Real-time QR Code Generator Screen
class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  QRType _selectedType = QRType.text;

  final TextEditingController _textController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _qrPayload = '';

  @override
  void initState() {
    super.initState();
    _textController.addListener(_updatePayload);
    _urlController.addListener(_updatePayload);
    _ssidController.addListener(_updatePayload);
    _passController.addListener(_updatePayload);
    _emailController.addListener(_updatePayload);
    _phoneController.addListener(_updatePayload);
  }

  void _updatePayload() {
    setState(() {
      switch (_selectedType) {
        case QRType.text:
          _qrPayload = _textController.text.trim();
          break;
        case QRType.url:
          _qrPayload = _urlController.text.trim();
          break;
        case QRType.wifi:
          final ssid = _ssidController.text.trim();
          final pass = _passController.text.trim();
          if (ssid.isNotEmpty) {
            _qrPayload = 'WIFI:S:$ssid;P:$pass;T:WPA;;';
          } else {
            _qrPayload = '';
          }
          break;
        case QRType.email:
          final email = _emailController.text.trim();
          _qrPayload = email.isNotEmpty ? 'mailto:$email' : '';
          break;
        case QRType.phone:
          final phone = _phoneController.text.trim();
          _qrPayload = phone.isNotEmpty ? 'tel:$phone' : '';
          break;
        case QRType.contact:
          _qrPayload = _textController.text.trim();
          break;
      }
    });
  }

  void _onTypeSelected(QRType type) {
    setState(() {
      _selectedType = type;
      _updatePayload();
    });
  }

  Future<void> _saveAndShare() async {
    if (_qrPayload.isEmpty) return;

    final QRDataModel model =
        QRService.parseRawData(_qrPayload, isGenerated: true);
    await StorageService.saveItem(model);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.qrGeneratedSuccess),
          duration: Duration(seconds: 2),
        ),
      );
    }

    await QRService.shareContent(_qrPayload);
  }

  @override
  void dispose() {
    _textController.dispose();
    _urlController.dispose();
    _ssidController.dispose();
    _passController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.generateTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // QR Type Selector Horizontal Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTypeChip(QRType.text),
                  _buildTypeChip(QRType.url),
                  _buildTypeChip(QRType.wifi),
                  _buildTypeChip(QRType.email),
                  _buildTypeChip(QRType.phone),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Live Preview Box
            Center(
              child: QrViewBox(
                qrData: _qrPayload,
                size: 200,
                foregroundColor: _selectedType.color,
              ),
            ),

            const SizedBox(height: 24),

            // Dynamic Form Inputs
            _buildInputFields(),

            const SizedBox(height: 24),

            // Save & Share Button
            CustomButton(
              text: AppStrings.btnShare,
              icon: Icons.share_rounded,
              color: _selectedType.color,
              onPressed: _qrPayload.isNotEmpty ? _saveAndShare : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(QRType type) {
    final bool isSelected = _selectedType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        selected: isSelected,
        showCheckmark: false,
        avatar: Icon(
          type.icon,
          size: 16,
          color: isSelected ? Colors.white : type.color,
        ),
        label: Text(type.displayName),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: AppColors.surface,
        selectedColor: type.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? type.color : AppColors.border,
          ),
        ),
        onSelected: (_) => _onTypeSelected(type),
      ),
    );
  }

  Widget _buildInputFields() {
    switch (_selectedType) {
      case QRType.text:
        return TextField(
          controller: _textController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: AppStrings.hintText,
          ),
        );
      case QRType.url:
        return TextField(
          controller: _urlController,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            hintText: AppStrings.hintUrl,
            prefixIcon: Icon(Icons.link_rounded),
          ),
        );
      case QRType.wifi:
        return Column(
          children: [
            TextField(
              controller: _ssidController,
              decoration: const InputDecoration(
                hintText: AppStrings.hintWifiSsid,
                prefixIcon: Icon(Icons.wifi_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: AppStrings.hintWifiPass,
                prefixIcon: Icon(Icons.lock_rounded),
              ),
            ),
          ],
        );
      case QRType.email:
        return TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: AppStrings.hintEmail,
            prefixIcon: Icon(Icons.email_rounded),
          ),
        );
      case QRType.phone:
        return TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            hintText: AppStrings.hintPhone,
            prefixIcon: Icon(Icons.phone_rounded),
          ),
        );
      case QRType.contact:
        return TextField(
          controller: _textController,
          decoration: const InputDecoration(
            hintText: AppStrings.hintText,
          ),
        );
    }
  }
}
