import 'package:flutter/material.dart';

// PENTING: Anda mungkin perlu mengubah 2 baris path import di bawah ini
// agar sesuai dengan letak folder account_data.dart dan login_screen.dart di proyek Anda.
import '../../data/account_data.dart';
import '../auth/login_page.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String userName = 'Memuat...';
  String userEmail = 'Memuat...';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Mengambil data dari lokal storage (shared_preferences)
  Future<void> _loadUserData() async {
    final userData = await AccountData.getCurrentUser();
    if (userData != null && mounted) {
      setState(() {
        userName = userData['name'] ?? 'User';
        userEmail = userData['email'] ?? '-';
      });
    }
  }

  // Fungsi untuk Logout
  void _logout() async {
    await AccountData.logout();

    if (!mounted) return;

    // Kembali ke LoginScreen dan hapus semua tumpukan navigasi sebelumnya
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Kita tetap menggunakan Theme dari main.dart agar warna menyesuaikan AppColors kelompok Anda
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.surface,
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              // Avatar
              CircleAvatar(
                radius: 50,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              // Nama User
              Text(
                userName,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              // Email User
              Text(
                userEmail,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              // Tombol Logout
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Keluar (Logout)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}