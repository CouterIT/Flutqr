import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/qr_data_model.dart';

/// Storage manager separating Scanned History and Created Codes
class StorageService {
  static const String _keyScannedHistory = 'flutqr_scanned_history_v2';
  static const String _keyCreatedCodes = 'flutqr_created_codes_v2';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ================= Generic Private Helpers =================

  static Future<List<QRDataModel>> _getItems(String key) async {
    _prefs ??= await SharedPreferences.getInstance();
    final String? json = _prefs?.getString(key);
    if (json == null || json.isEmpty) return [];
    try {
      return (jsonDecode(json) as List)
          .map((e) => QRDataModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _upsertItem(String key, QRDataModel item) async {
    final list = await _getItems(key);
    list.removeWhere((e) => e.rawValue == item.rawValue);
    list.insert(0, item);
    await _saveList(key, list);
  }

  static Future<void> _deleteItem(String key, String id) async {
    final list = await _getItems(key);
    list.removeWhere((e) => e.id == id);
    await _saveList(key, list);
  }

  static Future<void> _clearItems(String key) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.remove(key);
  }

  static Future<void> _saveList(String key, List<QRDataModel> list) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setString(key, jsonEncode(list.map((e) => e.toMap()).toList()));
  }

  // ================= Scanned History =================

  static Future<List<QRDataModel>> getScannedHistory() => _getItems(_keyScannedHistory);
  static Future<void> saveScannedItem(QRDataModel item) => _upsertItem(_keyScannedHistory, item);
  static Future<void> deleteScannedItem(String id) => _deleteItem(_keyScannedHistory, id);
  static Future<void> clearScannedHistory() => _clearItems(_keyScannedHistory);

  // ================= Created Codes =================

  static Future<List<QRDataModel>> getCreatedCodes() => _getItems(_keyCreatedCodes);
  static Future<void> saveCreatedItem(QRDataModel item) => _upsertItem(_keyCreatedCodes, item);
  static Future<void> deleteCreatedItem(String id) => _deleteItem(_keyCreatedCodes, id);
  static Future<void> clearCreatedCodes() => _clearItems(_keyCreatedCodes);
}
