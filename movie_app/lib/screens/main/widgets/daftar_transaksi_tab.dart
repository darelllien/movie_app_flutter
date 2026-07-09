import 'package:flutter/material.dart';
import 'package:movie_app/constants/app_color.dart';
import 'package:movie_app/constants/app_text_styles.dart';
import 'package:movie_app/models/transaction.dart';

class DaftarTransaksiTab extends StatelessWidget {
  final List<TransactionModel> history;

  const DaftarTransaksiTab({super.key, required this.history});

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[month - 1];
  }

  IconData _getPaymentIcon(String method) {
    final lowerMethod = method.toLowerCase();
    if (lowerMethod.contains('gopay') || lowerMethod.contains('gojek')) {
      return Icons.account_balance_wallet_outlined;
    } else if (lowerMethod.contains('dana')) {
      return Icons.phone_android_outlined;
    } else if (lowerMethod.contains('shopeepay')) {
      return Icons.shopping_bag_outlined;
    } else if (lowerMethod.contains('bca') ||
        lowerMethod.contains('mandiri') ||
        lowerMethod.contains('bni')) {
      return Icons.account_balance_outlined;
    }
    return Icons.payments_outlined;
  }

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Center(child: Text('Belum Ada Riwayat Transaksi'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final tx = history[index];
        final String dateStr =
            "${tx.transactionDate.day} ${_getMonthName(tx.transactionDate.month)}";
        final String timeStr =
            "${tx.transactionDate.hour.toString().padLeft(2, '0')}:${tx.transactionDate.minute.toString().padLeft(2, '0')}";

        final bool isExpired = DateTime.now().isAfter(tx.transactionDate);
        final String label = isExpired ? "Expired" : "Pembayaran Berhasil";
        final Color color = isExpired
            ? Colors.grey.shade500
            : Colors.blue.shade600;

        return _buildTransactionCard(tx, dateStr, timeStr, label, color);
      },
    );
  }

  Widget _buildTransactionCard(
    TransactionModel tx,
    String dateStr,
    String timeStr,
    String label,
    Color color,
  ) {
    final int total = (tx.ticketCount * tx.pricePerTicket) + 3000;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    tx.movie.fullPosterUrl,
                    width: 55,
                    height: 78,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 55,
                      height: 78,
                      color: Colors.grey[300],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              tx.movie.title,
                              style: AppTextStyles.headingMedium.copyWith(
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tx.cinema.name.toUpperCase(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _badge(Icons.calendar_month, dateStr),
                          const SizedBox(width: 6),
                          _badge(Icons.access_time, timeStr),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: List.generate(
              32,
              (i) => Expanded(
                child: Container(
                  color: i % 2 == 0 ? Colors.transparent : Colors.grey[200],
                  height: 1.2,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _rowDetail(
                  Icons.chair_outlined,
                  'Kursi',
                  tx.seatNumbers,
                  valueColor: AppColors.cta,
                ),
                const SizedBox(height: 6),
                _rowDetail(
                  _getPaymentIcon(tx.paymentMethod),
                  'Metode Pembayaran',
                  tx.paymentMethod,
                ),
                const SizedBox(height: 6),
                _rowDetail(
                  Icons.payments_outlined,
                  'Total Pembayaran',
                  'Rp ${total.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]}.")}',
                  isBold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: AppColors.base.withOpacity(0.12),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 10, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowDetail(
    IconData icon,
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
