import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/qr_data_model.dart';
import '../../../models/qr_type.dart';
import '../../../services/qr_service.dart';
import '../../../services/storage_service.dart';
import '../../../core/utils/selection_controller.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/qr_list_item.dart';
import '../../widgets/generate/category_grid_item.dart';
import '../scan/scan_result_screen.dart';
import 'generate_form_widget.dart';

/// Created Codes Screen with 8 Creation Categories (including Image QR)
class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  final GlobalKey _previewQrKey = GlobalKey();
  List<QRDataModel> _createdCodesList = [];
  bool _isLoading = true;
  final SelectionController _sel = SelectionController();

  // Creation State
  bool _isCreating = false;
  QRType? _selectedType;
  String _qrPayload = '';

  @override
  void initState() {
    super.initState();
    _sel.addListener(() => setState(() {}));
    _loadCreatedCodes();
  }

  @override
  void dispose() {
    _sel.removeListener(() {});
    _sel.dispose();
    super.dispose();
  }

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
      for (final id in _sel.selectedIds) {
        await StorageService.deleteCreatedItem(id);
      }
      _sel.exit();
      _loadCreatedCodes();
    }
  }

  void _openCreationFlow() {
    setState(() {
      _isCreating = true;
      _selectedType = null;
      _qrPayload = '';
    });
  }

  void _cancelCreationFlow() {
    setState(() {
      _isCreating = false;
      _selectedType = null;
      _qrPayload = '';
    });
  }

  Future<void> _saveAndFinish() async {
    if (_qrPayload.isEmpty) return;
    final model = QRService.parseRawData(_qrPayload, isGenerated: true);
    await StorageService.saveCreatedItem(model);
    _cancelCreationFlow();
    _loadCreatedCodes();
    if (mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ScanResultScreen(qrData: model)));
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
              ? (_selectedType != null ? _selectedType!.displayName : 'Create')
              : (_sel.isSelectionMode ? 'Đã chọn ${_sel.count}' : 'Mã đã tạo'),
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          if (!_isCreating && !_sel.isSelectionMode)
            IconButton(
              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
              onPressed: _openCreationFlow,
            ),
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

  Widget _buildCreatedCodesList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_createdCodesList.isEmpty) {
      return const Center(
        child: Text('Bạn chưa tạo mã QR nào', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, color: Color(0xFF999999), fontWeight: FontWeight.w400, height: 1.3)),
      );
    }
    return ListView.separated(
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
    );
  }

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

  Widget _buildForm() {
    return Column(
      children: [
        Expanded(
          child: GenerateFormWidget(
            type: _selectedType!,
            repaintKey: _previewQrKey,
            onPayloadChanged: (payload) => setState(() => _qrPayload = payload),
            onCancel: _cancelCreationFlow,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Tạo mã QR',
              icon: Icons.check_circle_outline_rounded,
              color: _selectedType!.color,
              onPressed: _qrPayload.isNotEmpty ? _saveAndFinish : null,
            ),
          ),
        ),
      ],
    );
  }
}
