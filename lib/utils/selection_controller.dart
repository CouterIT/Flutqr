import 'package:flutter/foundation.dart';

/// Reusable multi-select controller for list screens
class SelectionController extends ChangeNotifier {
  bool isSelectionMode = false;
  final Set<String> _selectedIds = {};

  Set<String> get selectedIds => _selectedIds;
  int get count => _selectedIds.length;

  bool isSelected(String id) => _selectedIds.contains(id);

  bool isAllSelected(int listLength) =>
      listLength > 0 && _selectedIds.length == listLength;

  void toggle(String id, {required int listLength}) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
      if (_selectedIds.isEmpty) isSelectionMode = false;
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  void enter(String id) {
    isSelectionMode = true;
    _selectedIds.clear();
    _selectedIds.add(id);
    notifyListeners();
  }

  void exit() {
    isSelectionMode = false;
    _selectedIds.clear();
    notifyListeners();
  }

  void toggleAll(List<String> allIds) {
    if (_selectedIds.length == allIds.length) {
      _selectedIds.clear();
      isSelectionMode = false;
    } else {
      _selectedIds.addAll(allIds);
    }
    notifyListeners();
  }

  /// Remove IDs that no longer exist in the list
  void cleanUp(List<String> validIds) {
    _selectedIds.removeWhere((id) => !validIds.contains(id));
    if (_selectedIds.isEmpty) isSelectionMode = false;
  }
}
