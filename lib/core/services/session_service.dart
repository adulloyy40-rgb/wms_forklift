import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyOperatorId = 'operator_id';
  static const String _keyOperatorNama = 'operator_nama';
  static const String _keyShift = 'shift';
  static const String _keyLoginTime = 'login_time';

  // Simpan Sesi Login
  static Future<void> saveSession({
    required String id,
    required String nama,
    required String shift,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyOperatorId, id);
    await prefs.setString(_keyOperatorNama, nama);
    await prefs.setString(_keyShift, shift);
    await prefs.setString(_keyLoginTime, DateTime.now().toIso8601String());
  }

  // Ambil Data Sesi Active
  static Future<Map<String, String?>> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getString(_keyOperatorId),
      'nama': prefs.getString(_keyOperatorNama),
      'shift': prefs.getString(_keyShift),
      'loginTime': prefs.getString(_keyLoginTime),
    };
  }

  // Cek Status Login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Logout & Hapus Sesi
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

