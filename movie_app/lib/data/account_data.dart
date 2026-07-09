import 'package:shared_preferences/shared_preferences.dart';

class AccountData {
  // ==========================================
  // FUNGSI AUTENTIKASI BAWAAN KELOMPOK (DIKEMBALIKAN)
  // ==========================================

  // Membantu menginisialisasi akun admin default di main.dart saat aplikasi pertama start
  static Future<void> initializeAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    // Jika data lokal masih kosong, pasang kredensial admin bawaan awal
    if (!prefs.containsKey('user_name')) {
      await prefs.setString('user_name', 'admin');
      await prefs.setString('user_email', 'admin123@gmail.com');
      await prefs.setString(
        'user_password',
        'admin123',
      ); // Jika ada sistem validasi pass lokal
      await prefs.setString('user_image', '');
    }
  }

  // Fungsi pengecekan login untuk login_page.dart
  static Future<bool> loginUser(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final localEmail = prefs.getString('user_email') ?? 'admin123@gmail.com';
    final localPassword = prefs.getString('user_password') ?? 'admin123';

    if (email == localEmail && password == localPassword) {
      await prefs.setBool('is_logged_in', true);
      return true;
    }
    return false;
  }

  // Fungsi pendaftaran akun baru untuk register_page.dart
  static Future<bool> registerUser(
    String name,
    String email,
    String password,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setString('user_name', name);
      await prefs.setString('user_email', email);
      await prefs.setString('user_password', password);
      await prefs.setString('user_image', '');
      return true;
    } catch (_) {
      return false;
    }
  }

  // ==========================================
  // FUNGSI TULIS & BACA DATA UNTUK PROFILE
  // ==========================================

  // Mengambil user aktif secara dinamis dari storage lokal
  static Future<Map<String, String>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();

    final String? localName = prefs.getString('user_name');
    final String? localEmail = prefs.getString('user_email');
    final String? localImagePath = prefs.getString('user_image');

    if (localName != null && localEmail != null) {
      return {
        'name': localName,
        'email': localEmail,
        'image': localImagePath ?? '',
      };
    }

    return {'name': 'admin', 'email': 'admin123@gmail.com', 'image': ''};
  }

  // Menyimpan perubahan modifikasi nama & foto dari halaman edit profile
  static Future<void> updateUser(String newName, String? newImagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', newName);
    if (newImagePath != null) {
      await prefs.setString('user_image', newImagePath);
    }
  }

  // Fungsi logout total sekalian membersihkan session state login
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Hapus status login saja agar data profil buatan user tidak ikut ke-reset saat logout
    await prefs.setBool('is_logged_in', false);
  }
}
