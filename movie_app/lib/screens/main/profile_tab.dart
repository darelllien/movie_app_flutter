import 'package:flutter/material.dart';
import 'package:movie_app/constants/app_color.dart';
import 'package:movie_app/models/transaction.dart';
import 'package:movie_app/constants/app_text_styles.dart';
import 'package:movie_app/screens/main/widgets/profile_header.dart';
import 'package:movie_app/screens/main/widgets/tiket_saya_tab.dart';
import 'package:movie_app/screens/main/widgets/daftar_transaksi_tab.dart';
import 'package:movie_app/screens/main/widgets/edit_profile_page.dart';

import '../../data/account_data.dart';
import '../../routes/app_routes.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String userName = 'Memuat...';
  String userEmail = 'Memuat...';
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    TransactionState().addListener(_onTransactionChanged);
  }

  @override
  void dispose() {
    TransactionState().removeListener(_onTransactionChanged);
    super.dispose();
  }

  void _onTransactionChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadUserData() async {
    final userData = await AccountData.getCurrentUser();
    if (userData != null && mounted) {
      setState(() {
        userName = userData['name'] ?? 'User';
        userEmail = userData['email'] ?? '-';
        _profileImagePath =
        (userData['image'] != null && userData['image']!.isNotEmpty)
            ? userData['image']
            : null;
      });
    }
  }

  void _logout() async {
    await AccountData.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
          (route) => false,
    );
  }
  
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Konfirmasi Logout',
            style: AppTextStyles.headingSmall.copyWith(color: AppColors.textPrimary),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari akun ini?',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: AppTextStyles.button.copyWith(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                _logout();
              },
              child: Text(
                'Keluar',
                style: AppTextStyles.button.copyWith(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allHistory = TransactionState().history;
    final activeTickets = allHistory.where((tx) => !tx.isScanned).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleSpacing: 20,
          title: Text(
            'Profil',
            style: AppTextStyles.headingMedium.copyWith(color: AppColors.textPrimary),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(Icons.logout, color: Colors.redAccent, size: 22),
                onPressed: _showLogoutConfirmation,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            ProfileHeader(
              userName: userName,
              userEmail: userEmail,
              imagePath: _profileImagePath,
              onEditPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(
                      currentName: userName,
                      currentEmail: userEmail,
                      currentImagePath: _profileImagePath,
                      onSave: (newName, newImagePath) async {
                        await AccountData.updateUser(newName, newImagePath);

                        setState(() {
                          userName = newName;
                          _profileImagePath = newImagePath;
                        });
                      },
                    ),
                  ),
                );
              },
            ),

            Container(
              color: Colors.white,
              child: const TabBar(
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                tabs: [
                  Tab(text: 'Tiket Saya'),
                  Tab(text: 'Daftar Transaksi'),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                children: [
                  TiketSayaTab(
                    tickets: activeTickets,
                    onRefresh: () {
                      setState(() {});
                    },
                  ),
                  DaftarTransaksiTab(history: allHistory),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}