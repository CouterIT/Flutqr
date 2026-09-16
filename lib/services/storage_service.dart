import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/qr_data_model.dart';

/// Service quản lý lưu trữ dữ liệu QR bằng SharedPreferences.
///
/// Tách riêng 2 collection:
/// - **Scanned History**: mã QR quét từ camera/ảnh
/// - **Created Codes**: mã QR tự tạo trong app
///
/// Mỗi collection lưu dưới dạng JSON string trong SharedPreferences.
/// Các method generic (`_getItems`, `_upsertItem`...) được tái sử dụng
/// cho cả 2 collection, chỉ khác key lưu trữ.
class StorageService {
  // Key lưu trữ trong SharedPreferences — version v2 để backward-compatible
  static const String _keyScannedHistory = 'flutqr_scanned_history_v2';
  static const String _keyCreatedCodes = 'flutqr_created_codes_v2';
  static const String _keyVirusTotalApiKey = 'flutqr_virustotal_api_key';

  static SharedPreferences? _prefs;

  /// Khởi tạo SharedPreferences — phải gọi trong `main()` trước khi runApp.
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ================= Method generic private =================

  /// Đọc danh sách QRDataModel từ SharedPreferences theo key.
  ///
  /// Trả về list rỗng nếu key chưa tồn tại hoặc data bị corrupt (catch lỗi).
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

  /// Thêm mới hoặc cập nhật item — "upsert" (update or insert).
  ///
  /// Trước khi insert, xóa item có cùng `rawValue` (tránh trùng lặp).
  /// Item mới nhất luôn ở đầu danh sách (insert at index 0).
  static Future<void> _upsertItem(String key, QRDataModel item) async {
    final list = await _getItems(key);
    list.removeWhere((e) => e.rawValue == item.rawValue);
    list.insert(0, item);
    await _saveList(key, list);
  }

  /// Xóa 1 item theo ID.
  static Future<void> _deleteItem(String key, String id) async {
    final list = await _getItems(key);
    list.removeWhere((e) => e.id == id);
    await _saveList(key, list);
  }

  /// Xóa nhiều items theo list ID — batch delete (1 lần read, 1 lần write).
  static Future<void> _deleteItems(String key, List<String> ids) async {
    final list = await _getItems(key);
    list.removeWhere((e) => ids.contains(e.id));
    await _saveList(key, list);
  }

  /// Xóa toàn bộ collection theo key.
  static Future<void> _clearItems(String key) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.remove(key);
  }

  /// Serialize list QRDataModel thành JSON string rồi lưu vào SharedPreferences.
  static Future<void> _saveList(String key, List<QRDataModel> list) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setString(key, jsonEncode(list.map((e) => e.toMap()).toList()));
  }

  // ================= Scanned History =================

  /// Đọc danh sách mã QR đã quét.
  static Future<List<QRDataModel>> getScannedHistory() => _getItems(_keyScannedHistory);
  /// Lưu mã QR quét mới (hoặc cập nhật nếu đã tồn tại).
  static Future<void> saveScannedItem(QRDataModel item) => _upsertItem(_keyScannedHistory, item);
  /// Xóa 1 mã quét theo ID.
  static Future<void> deleteScannedItem(String id) => _deleteItem(_keyScannedHistory, id);
  /// Xóa nhiều mã quét theo list ID (batch).
  static Future<void> deleteScannedItems(List<String> ids) => _deleteItems(_keyScannedHistory, ids);
  /// Xóa toàn bộ lịch sử quét.
  static Future<void> clearScannedHistory() => _clearItems(_keyScannedHistory);

  // ================= Created Codes =================

  /// Đọc danh sách mã QR đã tạo.
  static Future<List<QRDataModel>> getCreatedCodes() => _getItems(_keyCreatedCodes);
  /// Lưu mã QR tạo mới (hoặc cập nhật nếu đã tồn tại).
  static Future<void> saveCreatedItem(QRDataModel item) => _upsertItem(_keyCreatedCodes, item);
  /// Xóa 1 mã tạo theo ID.
  static Future<void> deleteCreatedItem(String id) => _deleteItem(_keyCreatedCodes, id);
  /// Xóa nhiều mã tạo theo list ID (batch).
  static Future<void> deleteCreatedItems(List<String> ids) => _deleteItems(_keyCreatedCodes, ids);
  /// Xóa toàn bộ mã đã tạo.
  static Future<void> clearCreatedCodes() => _clearItems(_keyCreatedCodes);

  // ================= VirusTotal Settings =================

  /// Đọc VirusTotal API Key đã lưu.
  static Future<String> getVirusTotalApiKey() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs?.getString(_keyVirusTotalApiKey) ?? '';
  }

  /// Lưu VirusTotal API Key.
  static Future<void> saveVirusTotalApiKey(String apiKey) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setString(_keyVirusTotalApiKey, apiKey.trim());
  }
}
