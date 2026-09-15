import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/qr_data_model.dart';
import '../../../models/qr_type.dart';
import '../../../services/storage_service.dart';
import '../scan/scan_result_screen.dart';

/// History Screen displaying scanned items with Long-Press Selection & Batch Delete
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<QRDataModel> _historyList = [];
  bool _isLoading = true;

  // Selection Mode State
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });
    final list = await StorageService.getScannedHistory();
    if (mounted) {
      setState(() {
        _historyList = list;
        _isLoading = false;
        // Clean up any deleted selection IDs
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
      if (_selectedIds.length == _historyList.length) {
        _selectedIds.clear();
        _isSelectionMode = false;
      } else {
        _selectedIds.addAll(_historyList.map((e) => e.id));
      }
    });
  }

  Future<void> _deleteSelectedItems() async {
    if (_selectedIds.isEmpty) return;

    final int count = _selectedIds.length;
    final bool isAll = count == _historyList.length;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAll ? 'Xóa tất cả lịch sử' : 'Xóa mục đã chọn'),
        content: Text(
          isAll
              ? 'Bạn có chắc chắn muốn xóa toàn bộ $_historyList.length lịch sử đã quét?'
              : 'Bạn có chắc chắn muốn xóa $count mục đã chọn?',
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
        await StorageService.deleteScannedItem(id);
      }
      _exitSelectionMode();
      _loadHistory();
    }
  }

  String _formatTimestamp(DateTime dt) {
    return DateFormat('dd-MM-yyyy hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final bool isAllSelected =
        _historyList.isNotEmpty && _selectedIds.length == _historyList.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                tooltip: 'Hủy chọn',
                onPressed: _exitSelectionMode,
              )
            : null,
        title: Text(
          _isSelectionMode ? 'Đã chọn ${_selectedIds.length}' : 'History',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isSelectionMode) ...[
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _historyList.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history_rounded,
                          size: 64, color: AppColors.textMuted),
                      SizedBox(height: 12),
                      Text(
                        'Chưa có lịch sử quét nào',
                        style:
                            TextStyle(color: AppColors.textMuted, fontSize: 15),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _historyList.length,
                  separatorBuilder: (_, _) => const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF0F0F0),
                  ),
                  itemBuilder: (context, index) {
                    final item = _historyList[index];
                    final bool isSelected = _selectedIds.contains(item.id);

                    return Container(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : Colors.transparent,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
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
                                builder: (context) =>
                                    ScanResultScreen(qrData: item),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
