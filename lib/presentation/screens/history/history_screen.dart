import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../models/qr_data_model.dart';
import '../../../services/storage_service.dart';
import '../../../core/utils/selection_controller.dart';
import '../../widgets/common/qr_list_item.dart';
import '../scan/scan_result_screen.dart';

/// Screen hiển thị lịch sử mã QR đã quét.
///
/// Hỗ trợ:
/// - Hiển thị danh sách từ mới nhất đến cũ nhất
/// - Long-press để vào chế độ chọn nhiều (multi-select)
/// - Chọn/bỏ chọn tất cả + xóa hàng loạt
/// - Nhấn vào item để xem chi tiết kết quả
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<QRDataModel> _historyList = [];
  bool _isLoading = true;
  final SelectionController _sel = SelectionController();

  @override
  void initState() {
    super.initState();
    // Lắng nghe SelectionController — mỗi lần state selection thay đổi thì rebuild UI
    _sel.addListener(() => setState(() {}));
    _loadHistory();
  }

  @override
  void dispose() {
    _sel.removeListener(() {});
    _sel.dispose();
    super.dispose();
  }

  /// Tải lịch sử quét từ SharedPreferences.
  ///
  /// Sau khi load, gọi `_sel.cleanUp` để xóa các ID đã chọn
  /// không còn tồn tại trong list mới.
  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final list = await StorageService.getScannedHistory();
    if (mounted) {
      _sel.cleanUp(list.map((e) => e.id).toList());
      setState(() {
        _historyList = list;
        _isLoading = false;
      });
    }
  }

  /// Xóa các mục đã chọn — hiện dialog xác nhận trước khi xóa vĩnh viễn.
  Future<void> _deleteSelected() async {
    if (_sel.selectedIds.isEmpty) return;
    final count = _sel.selectedIds.length;
    final isAll = _sel.isAllSelected(_historyList.length);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isAll ? 'Xóa tất cả lịch sử' : 'Xóa mục đã chọn'),
        content: Text(isAll
            ? 'Bạn có chắc chắn muốn xóa toàn bộ ${_historyList.length} lịch sử đã quét?'
            : 'Bạn có chắc chắn muốn xóa $count mục đã chọn?'),
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
        await StorageService.deleteScannedItem(id);
      }
      _sel.exit();
      _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAllSel = _sel.isAllSelected(_historyList.length);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        // Nút close hiển thị khi đang trong chế độ chọn nhiều
        leading: _sel.isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: _sel.exit,
              )
            : null,
        title: Text(
          _sel.isSelectionMode ? 'Đã chọn ${_sel.count}' : AppStrings.historyTitle,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          // Toolbar selection: chọn/bỏ chọn tất cả + xóa
          if (_sel.isSelectionMode) ...[
            IconButton(
              icon: Icon(isAllSel ? Icons.select_all_rounded : Icons.deselect_rounded, color: Colors.white),
              tooltip: isAllSel ? 'Bỏ chọn tất cả' : 'Chọn tất cả',
              onPressed: () => _sel.toggleAll(_historyList.map((e) => e.id).toList()),
            ),
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: Colors.white),
              onPressed: _deleteSelected,
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _historyList.isEmpty
              // Empty state khi chưa có lịch sử
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history_rounded, size: 64, color: AppColors.textMuted),
                      SizedBox(height: 12),
                      Text('Chưa có lịch sử quét nào', style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _historyList.length,
                  separatorBuilder: (_, _) => const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
                  itemBuilder: (context, index) {
                    final item = _historyList[index];
                    return QrListItem(
                      item: item,
                      isSelected: _sel.isSelected(item.id),
                      isSelectionMode: _sel.isSelectionMode,
                      onSelectionChanged: (_) => _sel.toggle(item.id, listLength: _historyList.length),
                      onLongPress: () {
                        // Long-press lần đầu: vào selection mode
                        // Long-press lần sau: toggle selection
                        if (!_sel.isSelectionMode) {
                          _sel.enter(item.id);
                        } else {
                          _sel.toggle(item.id, listLength: _historyList.length);
                        }
                      },
                      onTap: () {
                        if (_sel.isSelectionMode) {
                          _sel.toggle(item.id, listLength: _historyList.length);
                        } else {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => ScanResultScreen(qrData: item)));
                        }
                      },
                    );
                  },
                ),
    );
  }
}
