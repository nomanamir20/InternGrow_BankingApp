import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// A lightweight JSON-in-SharedPreferences store, mirroring the same
/// table-like structure as the SQLite version. Used only on Flutter Web,
/// where sqflite has no stable native implementation without bundling
/// custom WASM assets — this keeps the web build simple and reliable
/// while the exact same LocalDataService interface stays unchanged above it.
class WebStorageHelper {
  WebStorageHelper._();

  static Future<List<Map<String, dynamic>>> getAll(String table) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(table);
    if (stored == null) return [];
    final List<dynamic> decoded = jsonDecode(stored);
    return decoded.cast<Map<String, dynamic>>();
  }

  static Future<void> _saveAll(String table, List<Map<String, dynamic>> rows) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(table, jsonEncode(rows));
  }

  static Future<void> insert(String table, Map<String, dynamic> row) async {
    final rows = await getAll(table);
    rows.add(row);
    await _saveAll(table, rows);
  }

  static Future<void> update(String table, String id, Map<String, dynamic> row) async {
    final rows = await getAll(table);
    final index = rows.indexWhere((r) => r['id'] == id);
    if (index >= 0) {
      rows[index] = row;
      await _saveAll(table, rows);
    }
  }

  static Future<void> delete(String table, String id) async {
    final rows = await getAll(table);
    rows.removeWhere((r) => r['id'] == id);
    await _saveAll(table, rows);
  }
}