import 'package:flutter/material.dart';

class BankModel {
  final String id;
  final String name;
  final List<String> instructions;

  const BankModel({
    required this.id,
    required this.name,
    required this.instructions,
  });
}

class PaymentMethodModel {
  final String id;
  final String name;
  final IconData icon;
  final List<String>? mainInstructions;
  final List<BankModel>? subBanks;

  const PaymentMethodModel({
    required this.id,
    required this.name,
    required this.icon,
    this.mainInstructions,
    this.subBanks,
  });
}

class PaymentData {
  static const List<PaymentMethodModel> methods = [
    PaymentMethodModel(
      id: 'qris',
      name: 'QRIS',
      icon: Icons.qr_code_scanner,
      mainInstructions: [
        '1. Simpan atau screenshot kode QRIS yang muncul.',
        '2. Buka aplikasi e-wallet (Gojek, DANA, OVO) atau mobile banking Anda.',
        '3. Pilih menu scan/pindai lalu unggah screenshot QRIS.',
        '4. Periksa nominal transaksi dan konfirmasi pembayaran.',
      ],
    ),
    PaymentMethodModel(
      id: 'va_folder',
      name: 'Transfer Virtual Account',
      icon: Icons.account_balance,
      subBanks: [
        BankModel(
          id: 'va_bca',
          name: 'Virtual Account BCA',
          instructions: [
            '1. Salin nomor Virtual Account BCA yang tertera.',
            '2. Buka aplikasi m-BCA atau masuk ke ATM BCA.',
            '3. Pilih menu m-Transfer > BCA Virtual Account.',
            '4. Masukkan nomor VA dan konfirmasi PIN Anda.',
          ],
        ),
        BankModel(
          id: 'va_mandiri',
          name: 'Virtual Account Mandiri',
          instructions: [
            '1. Salin nomor Virtual Account Mandiri.',
            '2. Buka aplikasi Livin\' by Mandiri atau ATM Mandiri.',
            '3. Pilih menu Bayar > Multipayment.',
            '4. Masukkan kode perusahaan dan nomor VA lalu bayar.',
          ],
        ),
        BankModel(
          id: 'va_bni',
          name: 'Virtual Account BNI',
          instructions: [
            '1. Buka BNI Mobile Banking atau ATM BNI.',
            '2. Pilih menu Transfer > Virtual Account Billing.',
            '3. Masukkan nomor VA dan pilih rekening debet.',
            '4. Periksa informasi tagihan lalu masukkan password transaksi.',
          ],
        ),
        BankModel(
          id: 'va_bri',
          name: 'Virtual Account BRI (BRIVA)',
          instructions: [
            '1. Login ke aplikasi BRImo Anda.',
            '2. Pilih menu BRIVA > Tambah Transaksi Baru.',
            '3. Masukkan nomor Virtual Account BRIVA.',
            '4. Konfirmasi data detail bokingan dan masukkan PIN.',
          ],
        ),
        BankModel(
          id: 'va_bsi',
          name: 'Virtual Account BSI',
          instructions: [
            '1. Buka BSI Mobile > menu Bayar.',
            '2. Pilih Institusi/Akademik > Masukkan Nama Bioskop.',
            '3. Tempel kode VA tagihan boking Anda.',
            '4. Validasi nominal tagihan lalu masukkan PIN BSI.',
          ],
        ),
      ],
    ),
    PaymentMethodModel(
      id: 'gopay',
      name: 'GoPay',
      icon: Icons.account_balance_wallet,
      mainInstructions: [
        '1. Anda akan langsung dialihkan ke aplikasi Gojek.',
        '2. Pastikan saldo GoPay Anda mencukupi rincian harga.',
        '3. Klik "Bayar Sekarang" dan masukkan PIN GoPay Anda.',
      ],
    ),
    PaymentMethodModel(
      id: 'dana',
      name: 'DANA',
      icon: Icons.wallet,
      mainInstructions: [
        '1. Masukkan nomor ponsel yang terdaftar di akun DANA Anda.',
        '2. Masukkan PIN DANA dan kode OTP yang dikirimkan via SMS.',
        '3. Konfirmasi pembayaran pada halaman rincian.',
      ],
    ),
  ];
}
