import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/qr_data_model.dart';

/// Persistence storage manager for scan & generation history
class StorageService {
  static const String _keyHistory = 'flutqr_history_v1';
  static SharedPreferences? _prefs;

  /// Initialize SharedPreferences instance
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get stored QR history list
  static Future<List<QRDataModel>> getHistory() async {
    _prefs ??= await SharedPreferences.getInstance();
    final String? jsonString = _prefs?.getString(_keyHistory);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((item) => QRDataModel.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Save new QR item to history (avoids immediate duplicates)
  static Future<void> saveItem(QRDataModel item) async {
    final history = await getHistory();

    // Remove duplicates if same raw value exists
    history.removeWhere((element) => element.rawValue == item.rawValue);

    // Insert at the beginning of the list
    history.insert(0, item);

    await _saveList(history);
  }

  /// Delete single item from history by ID
  static Future<void> deleteItem(String id) async {
    final history = await getHistory();
    history.removeWhere((element) => element.id == id);
    await _saveList(history);
  }

  /// Clear entire history
  static Future<void> clearHistory() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.remove(_keyHistory);
  }

  static Future<void> _saveList(List<QRDataModel> list) async {
    _prefs ??= await SharedPreferences.getInstance();
    final String jsonString =
        jsonEncode(list.map((item) => item.toMap()).toList());
    await _prefs?.setString(_keyHistory, jsonString);
  }
}
