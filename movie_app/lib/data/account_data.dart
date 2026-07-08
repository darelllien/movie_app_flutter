import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AccountData {
  static const String _usersKey = 'users_list';
  static const String _currentUserKey = 'current_user';

  // --- TAMBAHKAN FUNGSI INI ---
  /// Menginisialisasi akun admin jika belum ada di database lokal
  static Future<void> initializeAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> usersStr = prefs.getStringList(_usersKey) ?? [];

    // Cek apakah akun admin sudah terdaftar
    bool adminExists = false;
    for (String userStr in usersStr) {
      Map<String, dynamic> user = jsonDecode(userStr);
      if (user['email'] == 'admin123@gmail.com') {
        adminExists = true;
        break;
      }
    }

    // Jika admin belum ada, masukkan ke dalam daftar akun
    if (!adminExists) {
      Map<String, dynamic> adminUser = {
        'name': 'admin',
        'email': 'admin123@gmail.com',
        'password': '123456',
      };
      usersStr.add(jsonEncode(adminUser));
      await prefs.setStringList(_usersKey, usersStr);
      print('Akun admin default berhasil dibuat!'); // Hanya untuk pengecekan di terminal
    }
  }

  /// Mendaftarkan pengguna baru.
  /// Mengembalikan [true] jika berhasil, [false] jika email sudah terdaftar.
  static Future<bool> registerUser(String name, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> usersStr = prefs.getStringList(_usersKey) ?? [];

    // Cek apakah email sudah terdaftar (Verifikasi Akun)
    for (String userStr in usersStr) {
      Map<String, dynamic> user = jsonDecode(userStr);
      if (user['email'] == email) {
        return false; // Email sudah digunakan
      }
    }

    // Simpan data pengguna baru
    Map<String, dynamic> newUser = {
      'name': name,
      'email': email,
      'password': password,
    };

    usersStr.add(jsonEncode(newUser));
    await prefs.setStringList(_usersKey, usersStr);
    return true;
  }

  /// Memverifikasi login.
  /// Mengembalikan data user jika valid, atau [null] jika email/password salah.
  static Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> usersStr = prefs.getStringList(_usersKey) ?? [];

    for (String userStr in usersStr) {
      Map<String, dynamic> user = jsonDecode(userStr);
      if (user['email'] == email && user['password'] == password) {
        // Simpan sesi login aktif
        await prefs.setString(_currentUserKey, jsonEncode(user));
        await prefs.setBool('isLoggedIn', true);
        return user;
      }
    }
    return null; // Kredensial tidak valid
  }

  /// Mengambil data pengguna yang sedang login saat ini (berguna untuk halaman Profil)
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userStr = prefs.getString(_currentUserKey);
    if (userStr != null) {
      return jsonDecode(userStr);
    }
    return null;
  }

  /// Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    await prefs.setBool('isLoggedIn', false);
  }
}