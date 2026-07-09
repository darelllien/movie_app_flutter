import 'package:flutter/material.dart';
import 'package:movie_app/constants/app_color.dart';
import 'package:movie_app/constants/app_text_styles.dart';
import 'package:movie_app/models/transaction.dart';

class TiketSayaTab extends StatefulWidget {
  final List<TransactionModel> tickets;
  final Function() onRefresh;

  const TiketSayaTab({
    super.key,
    required this.tickets,
    required this.onRefresh,
  });

  @override
  State<TiketSayaTab> createState() => _TiketSayaTabState();
}

class _TiketSayaTabState extends State<TiketSayaTab> {
  String _getTicketStatus(TransactionModel tx) {
    if (tx.isScanned) return "Sudah Digunakan";
    if (DateTime.now().isAfter(tx.transactionDate)) return "Expired";
    return "Aktif";
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Aktif":
        return Colors.green;
      case "Sudah Digunakan":
        return Colors.blue.shade600;
      case "Expired":
        return Colors.grey.shade500;
      default:
        return Colors.grey;
    }
  }

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

  void _showBarcodePopup(
      BuildContext context,
      TransactionModel tx,
      String dateStr,
      String timeStr,
      ) {
    final String currentStatus = _getTicketStatus(tx);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'BarcodePopup',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: Colors.white,
              elevation: 16,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'E-Tiket Digital',
                          style: AppTextStyles.headingLarge.copyWith(
                            fontSize: 18,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              currentStatus,
                            ).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            currentStatus,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(currentStatus),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Pindai kode ini di mesin cetak bioskop',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Opacity(
                      opacity: currentStatus == "Aktif" ? 1.0 : 0.35,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(28, (index) {
                                double lineWidth = (index % 3 == 0)
                                    ? 4.0
                                    : (index % 2 == 0)
                                    ? 2.0
                                    : 1.0;
                                return Container(
                                  width: lineWidth,
                                  height: 80,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 1.5,
                                  ),
                                  color: Colors.black87,
                                );
                              }),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              tx.id.toUpperCase(),
                              style: const TextStyle(
                                letterSpacing: 3.0,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),
                    _buildPopupRow(
                      Icons.movie_outlined,
                      'Film',
                      tx.movie.title,
                    ),
                    const SizedBox(height: 10),
                    _buildPopupRow(
                      Icons.theaters_outlined,
                      'Bioskop',
                      tx.cinema.name,
                    ),
                    const SizedBox(height: 10),
                    _buildPopupRow(
                      Icons.calendar_month_outlined,
                      'Jadwal',
                      '$dateStr — $timeStr',
                    ),
                    const SizedBox(height: 10),
                    _buildPopupRow(
                      Icons.chair_outlined,
                      'Nomor Kursi',
                      tx.seatNumbers,
                      isHighlight: true,
                    ),
                    const SizedBox(height: 24),
                    Column(
                      children: [
                        if (currentStatus == "Aktif") ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.qr_code_scanner,
                                size: 18,
                                color: Colors.white,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                TransactionState().markAsScanned(tx.id);
                                Navigator.pop(context);
                                widget.onRefresh();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Simulasi Berhasil! Tiket fisik Anda telah dicetak.',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              label: Text(
                                'Simulasi Cetak Tiket (Scan)',
                                style: AppTextStyles.button.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Tutup',
                              style: AppTextStyles.button.copyWith(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopupRow(
      IconData icon,
      String label,
      String value, {
        bool isHighlight = false,
      }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: isHighlight ? AppColors.cta : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tickets.isEmpty) {
      return const Center(child: Text('Maaf, Anda tidak sedang memiliki tiket'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.tickets.length,
      itemBuilder: (context, index) {
        final tx = widget.tickets[index];
        final String dateStr =
            "${tx.transactionDate.day} ${_getMonthName(tx.transactionDate.month)}";
        final String timeStr =
            "${tx.transactionDate.hour.toString().padLeft(2, '0')}:${tx.transactionDate.minute.toString().padLeft(2, '0')}";
        final String status = _getTicketStatus(tx);

        return GestureDetector(
          onTap: () => _showBarcodePopup(context, tx, dateStr, timeStr),
          child: _buildTicketCard(
            tx,
            dateStr,
            timeStr,
            status,
            _getStatusColor(status),
          ),
        );
      },
    );
  }

  Widget _buildTicketCard(
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