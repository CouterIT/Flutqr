import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/qr_data_model.dart';
import '../../../models/qr_type.dart';
import '../../../services/qr_service.dart';
import '../../../services/qr_gen_api_service.dart';
import '../../../services/storage_service.dart';
import '../../../core/utils/selection_controller.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/qr_list_item.dart';
import '../../widgets/generate/category_grid_item.dart';
import '../scan/scan_result_screen.dart';
import 'generate_form_widget.dart';

/// Screen quản lý mã QR đã tạo — hiển thị list + flow tạo mã mới.
///
/// Có 3 trạng thái chính:
/// 1. **Xem list**: hiển thị danh sách mã đã tạo, long-press để chọn/xóa
/// 2. **Chọn loại**: hiển thị grid 8 loại QR để chọn
/// 3. **Điền form**: hiển thị form nhập liệu + preview QR live
class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => GenerateScreenState();
}

class GenerateScreenState extends State<GenerateScreen> {
  /// GlobalKey cho RepaintBoundary trong preview QR — dùng khi export PNG.
  final GlobalKey _previewQrKey = GlobalKey();
  List<QRDataModel> _createdCodesList = [];
  bool _isLoading = true;
  final SelectionController _sel = SelectionController();

  /// Lưu callback reference để removeListener đúng (tránh memory leak).
  late final VoidCallback _onSelChanged = () => setState(() {});

  // Trạng thái tạo mã mới
  bool _isCreating = false;
  bool _isSaving = false;
  QRType? _selectedType;
  String _qrPayload = '';
  String? _logoPath;

  /// Reset toàn bộ state của screen về vị trí ban đầu (danh sách mã đã tạo).
  void resetState() {
    if (mounted) {
      _sel.exit();
      setState(() {
        _isCreating = false;
        _selectedType = null;
        _qrPayload = '';
      });
      _loadCreatedCodes();
    }
  }

  @override
  void initState() {
    super.initState();
    _sel.addListener(_onSelChanged);
    _loadCreatedCodes();
  }

  @override
  void dispose() {
    _sel.removeListener(_onSelChanged);
    _sel.dispose();
    super.dispose();
  }

  /// Tải danh sách mã đã tạo từ SharedPreferences.
  ///
  /// Sau khi load, gọi `_sel.cleanUp` để dọn dẹp các ID đã chọn
  /// không còn tồn tại (trường hợp xóa từ nơi khác).
  Future<void> _loadCreatedCodes() async {
    setState(() => _isLoading = true);
    final list = await StorageService.getCreatedCodes();
    if (mounted) {
      _sel.cleanUp(list.map((e) => e.id).toList());
      setState(() {
        _createdCodesList = list;
        _isLoading = false;
      });
    }
  }

  /// Xóa các mã đã chọn — hiện dialog xác nhận + SnackBar undo.
  Future<void> _deleteSelected() async {
    if (_sel.selectedIds.isEmpty) return;
    final count = _sel.selectedIds.length;
    final isAll = _sel.isAllSelected(_createdCodesList.length);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isAll ? 'Xóa tất cả mã đã tạo' : 'Xóa mã đã chọn'),
        content: Text(isAll
            ? 'Bạn có chắc chắn muốn xóa toàn bộ ${_createdCodesList.length} mã đã tạo?'
            : 'Bạn có chắc chắn muốn xóa $count mã đã chọn?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final deletedItems = _createdCodesList
          .where((item) => _sel.selectedIds.contains(item.id))
          .toList();

      await StorageService.deleteCreatedItems(_sel.selectedIds.toList());
      _sel.exit();
      _loadCreatedCodes();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa $count mã'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Hoàn tác',
              textColor: Colors.white,
              onPressed: () async {
                for (final item in deletedItems) {
                  await StorageService.saveCreatedItem(item);
                }
                _loadCreatedCodes();
              },
            ),
          ),
        );
      }
    }
  }

  /// Bắt đầu flow tạo mã mới — chuyển sang trạng thái chọn loại.
  void _openCreationFlow() {
    setState(() {
      _isCreating = true;
      _selectedType = null;
      _qrPayload = '';
    });
  }

  /// Hủy flow tạo mã — quay về trạng thái xem list.
  void _cancelCreationFlow() {
    setState(() {
      _isCreating = false;
      _selectedType = null;
      _qrPayload = '';
      _logoPath = null;
    });
  }

  /// Hoàn tất tạo mã — parse payload → lưu vào storage → reload list → navigate sang result screen.
  Future<void> _saveAndFinish() async {
    if (_qrPayload.isEmpty || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      // Nếu có logo → gọi QR Gen API để tạo QR có logo
      Uint8List? qrImageBytes;
      String? apiLogoPath;
      if (_logoPath != null && _logoPath!.isNotEmpty) {
        final logoFile = File(_logoPath!);
        if (logoFile.existsSync()) {
          final apiResponse = await QrGenApiService.generateWithLogo(
            data: _qrPayload,
            logoFile: logoFile,
          );
          if (apiResponse.success) {
            qrImageBytes = apiResponse.imageBytes;
            // Lưu QR có logo ra file để hiển thị sau này
            final appDir = await Directory.systemTemp.createTemp('flutqr_');
            apiLogoPath = '${appDir.path}/qr_logo_${DateTime.now().millisecondsSinceEpoch}.png';
            await File(apiLogoPath).writeAsBytes(qrImageBytes!);
          } else {
            debugPrint('QR Gen API failed: ${apiResponse.errorMessage}, fallback về render local');
          }
        }
      }

      final model = QRService.parseRawData(_qrPayload, isGenerated: true);

      // Lưu logoPath vào metadata nếu có
      QRDataModel finalModel = model;
      if (_logoPath != null && _logoPath!.isNotEmpty) {
        final metadata = {
          ...?model.metadata,
          'logoPath': _logoPath!,
          'hasLogo': 'true',
          if (apiLogoPath != null) 'apiLogoPath': apiLogoPath,
        };
        finalModel = QRDataModel(
          id: model.id,
          rawValue: model.rawValue,
          type: model.type,
          title: model.title,
          timestamp: model.timestamp,
          isGenerated: model.isGenerated,
          metadata: metadata,
        );
      }

      await StorageService.saveCreatedItem(finalModel);
      _cancelCreationFlow();
      _loadCreatedCodes();
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ScanResultScreen(qrData: finalModel)));
      }
    } catch (e) {
      debugPrint('Lỗi tạo mã QR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tạo mã QR: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAllSel = _sel.isAllSelected(_createdCodesList.length);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        // Leading button thay đổi theo trạng thái: back (tạo), close (chọn), hoặc ẩn
        leading: _isCreating
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: _selectedType != null ? () => setState(() => _selectedType = null) : _cancelCreationFlow,
              )
            : (_sel.isSelectionMode
                ? IconButton(icon: const Icon(Icons.close_rounded, color: Colors.white), onPressed: _sel.exit)
                : null),
        title: Text(
          _isCreating
              ? (_selectedType != null ? _selectedType!.displayName : 'Tạo mới')
              : (_sel.isSelectionMode ? 'Đã chọn ${_sel.count}' : 'Mã đã tạo'),
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          // Nút "+" để bắt đầu tạo mã mới
          if (!_isCreating && !_sel.isSelectionMode)
            IconButton(
              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
              onPressed: _openCreationFlow,
            ),
          // Nút toolbar khi đang chọn nhiều: chọn/bỏ chọn tất cả + xóa
          if (!_isCreating && _sel.isSelectionMode) ...[
            IconButton(
              icon: Icon(isAllSel ? Icons.select_all_rounded : Icons.deselect_rounded, color: Colors.white),
              tooltip: isAllSel ? 'Bỏ chọn tất cả' : 'Chọn tất cả',
              onPressed: () => _sel.toggleAll(_createdCodesList.map((e) => e.id).toList()),
            ),
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: Colors.white),
              onPressed: _deleteSelected,
            ),
          ],
        ],
      ),
      body: _isCreating
          ? (_selectedType == null ? _buildCategoryGrid() : _buildForm())
          : _buildCreatedCodesList(),
    );
  }

  /// Hiển thị danh sách mã QR đã tạo.
  Widget _buildCreatedCodesList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_createdCodesList.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_rounded, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 12),
            const Text(
              'Bạn chưa tạo mã QR nào',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.textMuted, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nhấn + để tạo mã mới',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadCreatedCodes,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _createdCodesList.length,
        separatorBuilder: (_, _) => const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
        itemBuilder: (context, index) {
          final item = _createdCodesList[index];
          return QrListItem(
            item: item,
            isSelected: _sel.isSelected(item.id),
            isSelectionMode: _sel.isSelectionMode,
            onSelectionChanged: (_) => _sel.toggle(item.id, listLength: _createdCodesList.length),
            onLongPress: () {
              if (!_sel.isSelectionMode) {
                _sel.enter(item.id);
              } else {
                _sel.toggle(item.id, listLength: _createdCodesList.length);
              }
            },
            onTap: () {
              if (_sel.isSelectionMode) {
                _sel.toggle(item.id, listLength: _createdCodesList.length);
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ScanResultScreen(qrData: item)));
              }
            },
          );
        },
      ),
    );
  }

  /// Hiển thị grid 8 loại QR để người dùng chọn khi tạo mới.
  ///
  /// Dùng `QRType.values.map()` để tạo grid tự động từ enum —
  /// khi thêm loại QR mới, chỉ cần thêm vào enum là grid tự cập nhật.
  Widget _buildCategoryGrid() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 16),
            child: Text('QR-Code', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.0,
            children: QRType.values.map((type) => CategoryGridItem(
              type: type,
              icon: type.icon,
              label: type.displayName,
              onTap: () => setState(() {
                _selectedType = type;
                _qrPayload = '';
              }),
            )).toList(),
          ),
        ],
      ),
    );
  }

  /// Hiển thị form nhập liệu + nút "Tạo mã QR".
  ///
  /// Form nằm trong GenerateFormWidget — tách riêng để code gọn hơn.
  /// Nút "Tạo mã" ở bên ngoài form để quản lý state `_qrPayload` tại parent.
  Widget _buildForm() {
    return Column(
      children: [
        Expanded(
          child: GenerateFormWidget(
            type: _selectedType!,
            repaintKey: _previewQrKey,
            onPayloadChanged: (payload) => setState(() => _qrPayload = payload),
            onCancel: _cancelCreationFlow,
            onLogoChanged: (path) => setState(() => _logoPath = path),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: _isSaving ? 'Đang lưu...' : 'Tạo mã QR',
              icon: _isSaving ? null : Icons.check_circle_outline_rounded,
              color: _selectedType!.color,
              isLoading: _isSaving,
              onPressed: (_qrPayload.isNotEmpty && !_isSaving) ? _saveAndFinish : null,
            ),
          ),
        ),
      ],
    );
  }
}
