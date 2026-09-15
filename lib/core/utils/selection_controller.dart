import 'package:flutter/foundation.dart';

/// Controller quản lý trạng thái chọn nhiều (multi-select) cho các list screen.
///
/// Tái sử dụng cho cả HistoryScreen và GenerateScreen —
/// tránh viết lại logic chọn/bỏ chọn/chọn tất cả/xóa ở mỗi screen.
///
/// Kế thừa `ChangeNotifier` để widget có thể lắng nghe thay đổi
/// qua `addListener()` — mỗi lần trạng thái selection thay đổi,
/// widget sẽ gọi `setState()` để rebuild UI (hiển thị checkbox, nút xóa...).
class SelectionController extends ChangeNotifier {
  /// `true` khi đang trong chế độ chọn nhiều (hiển thị checkbox, nút toolbar).
  bool isSelectionMode = false;

  /// Set chứa ID các item đang được chọn — dùng Set để check O(1).
  final Set<String> _selectedIds = {};

  Set<String> get selectedIds => _selectedIds;
  int get count => _selectedIds.length;

  /// Kiểm tra 1 item có đang được chọn không.
  bool isSelected(String id) => _selectedIds.contains(id);

  /// Kiểm tra đã chọn tất cả item chưa — cần biết tổng số item để so sánh.
  bool isAllSelected(int listLength) =>
      listLength > 0 && _selectedIds.length == listLength;

  /// Chọn/bỏ chọn 1 item.
  ///
  /// Nếu đang bỏ chọn item cuối cùng → tự động thoát selection mode.
  /// `listLength` truyền từ bên ngoài để `isAllSelected` cập nhật đúng.
  void toggle(String id, {required int listLength}) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
      // Không còn item nào chọn → thoát selection mode
      if (_selectedIds.isEmpty) isSelectionMode = false;
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  /// Bắt đầu selection mode — chọn item đầu tiên (thường qua long-press).
  void enter(String id) {
    isSelectionMode = true;
    _selectedIds.clear();
    _selectedIds.add(id);
    notifyListeners();
  }

  /// Thoát selection mode — xóa sạch tất cả selection.
  void exit() {
    isSelectionMode = false;
    _selectedIds.clear();
    notifyListeners();
  }

  /// Chọn tất cả hoặc bỏ chọn tất cả.
  ///
  /// Nếu đã chọn hết → clear và thoát mode.
  /// Nếu chưa chọn hết → chọn tất cả.
  void toggleAll(List<String> allIds) {
    if (_selectedIds.length == allIds.length) {
      _selectedIds.clear();
      isSelectionMode = false;
    } else {
      _selectedIds.addAll(allIds);
    }
    notifyListeners();
  }

  /// Dọn dẹp các ID không còn tồn tại trong list.
  ///
  /// Khi list reload sau khi xóa item, các ID cũ trong `_selectedIds`
  /// có thể không còn hợp lệ — cần remove để tránh lỗi logic.
  void cleanUp(List<String> validIds) {
    _selectedIds.removeWhere((id) => !validIds.contains(id));
    if (_selectedIds.isEmpty) isSelectionMode = false;
  }
}
