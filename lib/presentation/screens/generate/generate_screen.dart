import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/qr_data_model.dart';
import '../../../models/qr_type.dart';
import '../../../services/qr_service.dart';
import '../../../services/storage_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/qr_view_box.dart';
import '../scan/scan_result_screen.dart';

/// Created Codes Screen with 8 Creation Categories (including Image QR)
class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  List<QRDataModel> _createdCodesList = [];
  bool _isLoading = true;

  // Selection Mode State
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  // Creation State
  bool _isCreating = false;
  QRType? _selectedType;

  // Image Picker
  final ImagePicker _imagePicker = ImagePicker();
  String? _selectedImagePath;

  // Input Controllers
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // Wi-Fi Controllers
  final TextEditingController _wifiSsidController = TextEditingController();
  final TextEditingController _wifiPassController = TextEditingController();

  // vCard Controllers
  final TextEditingController _vcardNameController = TextEditingController();
  final TextEditingController _vcardPhoneController = TextEditingController();
  final TextEditingController _vcardEmailController = TextEditingController();
  final TextEditingController _vcardCompanyController = TextEditingController();
  final TextEditingController _vcardAddressController = TextEditingController();

  // Event / Invitation Controllers
  final TextEditingController _eventTitleController = TextEditingController();
  final TextEditingController _eventLocationController = TextEditingController();
  final TextEditingController _eventDateTimeController = TextEditingController();
  final TextEditingController _eventNoteController = TextEditingController();

  String _qrPayload = '';

  @override
  void initState() {
    super.initState();
    _loadCreatedCodes();

    _textController.addListener(_updatePayload);
    _numberController.addListener(_updatePayload);
    _websiteController.addListener(_updatePayload);
    _locationController.addListener(_updatePayload);

    _wifiSsidController.addListener(_updatePayload);
    _wifiPassController.addListener(_updatePayload);

    _vcardNameController.addListener(_updatePayload);
    _vcardPhoneController.addListener(_updatePayload);
    _vcardEmailController.addListener(_updatePayload);
    _vcardCompanyController.addListener(_updatePayload);
    _vcardAddressController.addListener(_updatePayload);

    _eventTitleController.addListener(_updatePayload);
    _eventLocationController.addListener(_updatePayload);
    _eventDateTimeController.addListener(_updatePayload);
    _eventNoteController.addListener(_updatePayload);
  }

  Future<void> _loadCreatedCodes() async {
    setState(() {
      _isLoading = true;
    });
    final list = await StorageService.getCreatedCodes();
    if (mounted) {
      setState(() {
        _createdCodesList = list;
        _isLoading = false;
        _selectedIds.removeWhere((id) => !list.any((item) => item.id == id));
        if (_selectedIds.isEmpty) {
          _isSelectionMode = false;
        }
      });
    }
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _enterSelectionMode(String initialId) {
    setState(() {
      _isSelectionMode = true;
      _selectedIds.clear();
      _selectedIds.add(initialId);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedIds.length == _createdCodesList.length) {
        _selectedIds.clear();
        _isSelectionMode = false;
      } else {
        _selectedIds.addAll(_createdCodesList.map((e) => e.id));
      }
    });
  }

  Future<void> _deleteSelectedItems() async {
    if (_selectedIds.isEmpty) return;

    final int count = _selectedIds.length;
    final bool isAll = count == _createdCodesList.length;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAll ? 'Xóa tất cả mã đã tạo' : 'Xóa mã đã chọn'),
        content: Text(
          isAll
              ? 'Bạn có chắc chắn muốn xóa toàn bộ ${_createdCodesList.length} mã đã tạo?'
              : 'Bạn có chắc chắn muốn xóa $count mã đã chọn?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      for (final id in _selectedIds) {
        await StorageService.deleteCreatedItem(id);
      }
      _exitSelectionMode();
      _loadCreatedCodes();
    }
  }

  void _updatePayload() {
    if (_selectedType == null) return;
    setState(() {
      switch (_selectedType!) {
        case QRType.text:
          _qrPayload = _textController.text.trim();
          break;
        case QRType.number:
          final num = _numberController.text.trim();
          _qrPayload = num.isNotEmpty ? 'tel:$num' : '';
          break;
        case QRType.website:
          final url = _websiteController.text.trim();
          if (url.isNotEmpty) {
            _qrPayload = url.startsWith('http') ? url : 'https://$url';
          } else {
            _qrPayload = '';
          }
          break;
        case QRType.location:
          final loc = _locationController.text.trim();
          _qrPayload = loc.isNotEmpty ? QRService.buildGoogleMapsUrl(loc) : '';
          break;
        case QRType.wifi:
          final ssid = _wifiSsidController.text.trim();
          final pass = _wifiPassController.text.trim();
          if (ssid.isNotEmpty) {
            _qrPayload = 'WIFI:S:$ssid;P:$pass;T:WPA;;';
          } else {
            _qrPayload = '';
          }
          break;
        case QRType.vcard:
          final name = _vcardNameController.text.trim();
          if (name.isNotEmpty || _vcardPhoneController.text.isNotEmpty) {
            _qrPayload = QRService.buildVCardString(
              name: name,
              phone: _vcardPhoneController.text.trim(),
              email: _vcardEmailController.text.trim(),
              company: _vcardCompanyController.text.trim(),
              address: _vcardAddressController.text.trim(),
            );
          } else {
            _qrPayload = '';
          }
          break;
        case QRType.event:
          final title = _eventTitleController.text.trim();
          if (title.isNotEmpty) {
            _qrPayload = QRService.buildEventString(
              title: title,
              location: _eventLocationController.text.trim(),
              dateTime: _eventDateTimeController.text.trim(),
              description: _eventNoteController.text.trim(),
            );
          } else {
            _qrPayload = '';
          }
          break;
        case QRType.image:
          if (_selectedImagePath != null) {
            _qrPayload = 'IMG:${_selectedImagePath!}';
          } else {
            _qrPayload = '';
          }
          break;
      }
    });
  }

  Future<void> _pickImageForQr() async {
    try {
      final XFile? file =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        setState(() {
          _selectedImagePath = file.path;
          _updatePayload();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể chọn ảnh: $e')),
        );
      }
    }
  }

  void _openCreationFlow() {
    setState(() {
      _isCreating = true;
      _selectedType = null;
      _selectedImagePath = null;
      _qrPayload = '';
      _clearAllInputs();
    });
  }

  void _cancelCreationFlow() {
    setState(() {
      _isCreating = false;
      _selectedType = null;
      _selectedImagePath = null;
      _qrPayload = '';
    });
  }

  void _clearAllInputs() {
    _textController.clear();
    _numberController.clear();
    _websiteController.clear();
    _locationController.clear();
    _wifiSsidController.clear();
    _wifiPassController.clear();
    _vcardNameController.clear();
    _vcardPhoneController.clear();
    _vcardEmailController.clear();
    _vcardCompanyController.clear();
    _vcardAddressController.clear();
    _eventTitleController.clear();
    _eventLocationController.clear();
    _eventDateTimeController.clear();
    _eventNoteController.clear();
  }

  void _selectCategory(QRType type) {
    setState(() {
      _selectedType = type;
      _selectedImagePath = null;
      _qrPayload = '';
      _clearAllInputs();
    });
  }

  Future<void> _saveAndFinishCreation() async {
    if (_qrPayload.isEmpty) return;

    final QRDataModel model =
        QRService.parseRawData(_qrPayload, isGenerated: true);
    await StorageService.saveCreatedItem(model);

    _cancelCreationFlow();
    _loadCreatedCodes();

    if (mounted) {
      // Direct navigation to ScanResultScreen upon creation
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ScanResultScreen(qrData: model),
        ),
      );
    }
  }

  String _formatTimestamp(DateTime dt) {
    return DateFormat('dd-MM-yyyy hh:mm a').format(dt);
  }

  @override
  void dispose() {
    _textController.dispose();
    _numberController.dispose();
    _websiteController.dispose();
    _locationController.dispose();
    _wifiSsidController.dispose();
    _wifiPassController.dispose();
    _vcardNameController.dispose();
    _vcardPhoneController.dispose();
    _vcardEmailController.dispose();
    _vcardCompanyController.dispose();
    _vcardAddressController.dispose();
    _eventTitleController.dispose();
    _eventLocationController.dispose();
    _eventDateTimeController.dispose();
    _eventNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAllSelected = _createdCodesList.isNotEmpty &&
        _selectedIds.length == _createdCodesList.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: _isCreating
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: _selectedType != null
                    ? () => setState(() => _selectedType = null)
                    : _cancelCreationFlow,
              )
            : (_isSelectionMode
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    tooltip: 'Hủy chọn',
                    onPressed: _exitSelectionMode,
                  )
                : null),
        title: Text(
          _isCreating
              ? (_selectedType != null ? _selectedType!.displayName : 'Create')
              : (_isSelectionMode
                  ? 'Đã chọn ${_selectedIds.length}'
                  : 'Created codes'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_isCreating && !_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
              tooltip: 'Tạo mã QR mới',
              onPressed: _openCreationFlow,
            ),
          if (!_isCreating && _isSelectionMode) ...[
            IconButton(
              icon: Icon(
                isAllSelected
                    ? Icons.select_all_rounded
                    : Icons.deselect_rounded,
                color: Colors.white,
              ),
              tooltip: isAllSelected ? 'Bỏ chọn tất cả' : 'Chọn tất cả',
              onPressed: _toggleSelectAll,
            ),
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: Colors.white),
              tooltip: 'Xóa mục đã chọn',
              onPressed: _deleteSelectedItems,
            ),
          ],
        ],
      ),
      body: _isCreating
          ? (_selectedType == null
              ? _buildCategoryGrid()
              : _buildFormAndPreview())
          : _buildCreatedCodesList(),
    );
  }

  /// Main Created Codes List View
  Widget _buildCreatedCodesList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_createdCodesList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'You haven\'t created any\ncodes yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              color: Color(0xFF999999),
              fontWeight: FontWeight.w400,
              height: 1.3,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _createdCodesList.length,
      separatorBuilder: (_, _) => const Divider(
        height: 1,
        thickness: 1,
        color: Color(0xFFF0F0F0),
      ),
      itemBuilder: (context, index) {
        final item = _createdCodesList[index];
        final bool isSelected = _selectedIds.contains(item.id);

        return Container(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                item.type.icon,
                color: const Color(0xFF6BB5C5),
                size: 28,
              ),
            ),
            title: Text(
              item.type.displayName,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              _formatTimestamp(item.timestamp),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
            trailing: _isSelectionMode
                ? Checkbox(
                    value: isSelected,
                    activeColor: AppColors.primary,
                    onChanged: (_) => _toggleSelection(item.id),
                  )
                : const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Color(0xFFD0D0D0),
                  ),
            onLongPress: () {
              if (!_isSelectionMode) {
                _enterSelectionMode(item.id);
              } else {
                _toggleSelection(item.id);
              }
            },
            onTap: () {
              if (_isSelectionMode) {
                _toggleSelection(item.id);
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ScanResultScreen(qrData: item),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  /// 8-Category Grid Selection View (Including Image QR)
  Widget _buildCategoryGrid() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 16),
            child: Text(
              'QR-Code',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.0,
            children: [
              _buildCategoryCard(QRType.text, Icons.notes_rounded, 'Text'),
              _buildCategoryCard(QRType.number, Icons.phone_rounded, 'Number'),
              _buildCategoryCard(QRType.website, Icons.web_rounded, 'Website'),
              _buildCategoryCard(
                  QRType.location, Icons.location_on_rounded, 'Location'),
              _buildCategoryCard(QRType.wifi, Icons.wifi_rounded, 'Wi-Fi'),
              _buildCategoryCard(QRType.vcard, Icons.badge_rounded, 'vCard'),
              _buildCategoryCard(
                  QRType.event, Icons.insert_invitation_rounded, 'Thiệp mời'),
              _buildCategoryCard(QRType.image, Icons.image_rounded, 'QR Ảnh'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(QRType type, IconData icon, String label) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFEEEEEE), width: 1),
      ),
      child: InkWell(
        onTap: () => _selectCategory(type),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: type.color,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// In-page creation form and live preview
  Widget _buildFormAndPreview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Live Preview Box
          Center(
            child: QrViewBox(
              qrData: _qrPayload,
              size: 190,
              foregroundColor: _selectedType!.color,
            ),
          ),

          const SizedBox(height: 24),

          // Dynamic Field Input
          _buildInputForSelectedType(),

          const SizedBox(height: 24),

          // Action Buttons
          CustomButton(
            text: 'Tạo mã QR',
            icon: Icons.check_circle_outline_rounded,
            color: _selectedType!.color,
            onPressed: _qrPayload.isNotEmpty ? _saveAndFinishCreation : null,
          ),
        ],
      ),
    );
  }

  Widget _buildInputForSelectedType() {
    switch (_selectedType!) {
      case QRType.text:
        return TextField(
          controller: _textController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Nhập nội dung văn bản...',
          ),
        );
      case QRType.number:
        return TextField(
          controller: _numberController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            hintText: 'Nhập số điện thoại...',
            prefixIcon: Icon(Icons.phone_rounded),
          ),
        );
      case QRType.website:
        return TextField(
          controller: _websiteController,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            hintText: 'https://example.com',
            prefixIcon: Icon(Icons.link_rounded),
          ),
        );
      case QRType.location:
        return TextField(
          controller: _locationController,
          decoration: const InputDecoration(
            hintText: 'Nhập địa chỉ hoặc tọa độ (Google Maps)...',
            prefixIcon: Icon(Icons.location_on_rounded),
          ),
        );
      case QRType.wifi:
        return Column(
          children: [
            TextField(
              controller: _wifiSsidController,
              decoration: const InputDecoration(
                hintText: 'Tên mạng Wi-Fi (SSID)...',
                prefixIcon: Icon(Icons.wifi_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _wifiPassController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Mật khẩu Wi-Fi...',
                prefixIcon: Icon(Icons.lock_rounded),
              ),
            ),
          ],
        );
      case QRType.vcard:
        return Column(
          children: [
            TextField(
              controller: _vcardNameController,
              decoration: const InputDecoration(
                hintText: 'Họ và tên...',
                prefixIcon: Icon(Icons.person_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _vcardPhoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: 'Số điện thoại...',
                prefixIcon: Icon(Icons.phone_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _vcardEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Email...',
                prefixIcon: Icon(Icons.email_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _vcardCompanyController,
              decoration: const InputDecoration(
                hintText: 'Công ty / Chức danh...',
                prefixIcon: Icon(Icons.business_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _vcardAddressController,
              decoration: const InputDecoration(
                hintText: 'Địa chỉ...',
                prefixIcon: Icon(Icons.location_city_rounded),
              ),
            ),
          ],
        );
      case QRType.event:
        return Column(
          children: [
            TextField(
              controller: _eventTitleController,
              decoration: const InputDecoration(
                hintText: 'Tiêu đề thiệp mời / Sự kiện...',
                prefixIcon: Icon(Icons.insert_invitation_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _eventLocationController,
              decoration: const InputDecoration(
                hintText: 'Địa điểm tổ chức...',
                prefixIcon: Icon(Icons.place_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _eventDateTimeController,
              decoration: const InputDecoration(
                hintText: 'Ngày & Giờ (Ví dụ: 20:00 - 25/12/2026)...',
                prefixIcon: Icon(Icons.event_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _eventNoteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Ghi chú / Lời mời...',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),
          ],
        );
      case QRType.image:
        return Column(
          children: [
            if (_selectedImagePath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(_selectedImagePath!),
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
            ],
            CustomButton(
              text: _selectedImagePath == null
                  ? 'Chọn ảnh từ thư viện'
                  : 'Đổi ảnh khác',
              icon: Icons.photo_library_rounded,
              isSecondary: true,
              onPressed: _pickImageForQr,
            ),
          ],
        );
    }
  }
}
