import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/qr_data_model.dart';

/// Storage manager separating Scanned History and Created Codes
class StorageService {
  static const String _keyScannedHistory = 'flutqr_scanned_history_v2';
  static const String _keyCreatedCodes = 'flutqr_created_codes_v2';

  static SharedPreferences? _prefs;

  /// Initialize SharedPreferences instance
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ================= SCANNED HISTORY =================

  /// Get stored scanned history list
  static Future<List<QRDataModel>> getScannedHistory() async {
    _prefs ??= await SharedPreferences.getInstance();
    final String? jsonString = _prefs?.getString(_keyScannedHistory);
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

  /// Save scanned QR item to history (scanned items ONLY)
  static Future<void> saveScannedItem(QRDataModel item) async {
    final history = await getScannedHistory();

    // Remove duplicates if same raw value exists
    history.removeWhere((element) => element.rawValue == item.rawValue);

    // Insert at the beginning of the list
    history.insert(0, item);

    await _saveList(_keyScannedHistory, history);
  }

  /// Delete single scanned item from history by ID
  static Future<void> deleteScannedItem(String id) async {
    final history = await getScannedHistory();
    history.removeWhere((element) => element.id == id);
    await _saveList(_keyScannedHistory, history);
  }

  /// Clear entire scanned history
  static Future<void> clearScannedHistory() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.remove(_keyScannedHistory);
  }

  // ================= CREATED CODES =================

  /// Get stored created codes list
  static Future<List<QRDataModel>> getCreatedCodes() async {
    _prefs ??= await SharedPreferences.getInstance();
    final String? jsonString = _prefs?.getString(_keyCreatedCodes);
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

  /// Save created QR item to created list
  static Future<void> saveCreatedItem(QRDataModel item) async {
    final list = await getCreatedCodes();

    list.removeWhere((element) => element.rawValue == item.rawValue);
    list.insert(0, item);

    await _saveList(_keyCreatedCodes, list);
  }

  /// Delete single created item by ID
  static Future<void> deleteCreatedItem(String id) async {
    final list = await getCreatedCodes();
    list.removeWhere((element) => element.id == id);
    await _saveList(_keyCreatedCodes, list);
  }

  /// Clear all created codes
  static Future<void> clearCreatedCodes() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.remove(_keyCreatedCodes);
  }

  // ================= HELPER =================

  static Future<void> _saveList(String key, List<QRDataModel> list) async {
    _prefs ??= await SharedPreferences.getInstance();
    final String jsonString =
        jsonEncode(list.map((item) => item.toMap()).toList());
    await _prefs?.setString(key, jsonString);
  }
}
