import 'package:flutter/material.dart';
import 'package:movie_app/constants/app_color.dart';
import 'package:movie_app/constants/app_text_styles.dart';
import 'package:movie_app/data/payment_data.dart';
import 'package:movie_app/models/cinema.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/models/transaction.dart';

class CheckoutPage extends StatefulWidget {
  final Movie movie;
  final Cinema cinema;
  final String date;
  final String time;
  final List<String> seats;
  final int ticketPrice;

  const CheckoutPage({
    super.key,
    required this.movie,
    required this.cinema,
    required this.date,
    required this.time,
    required this.seats,
    required this.ticketPrice,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String? _selectedMethodId;
  String? _selectedSubBankId;
  final int _serviceFee = 3000;

  int _getMonthNumber(String dateStr) {
    try {
      String monthName = dateStr.trim().split(' ')[1].toLowerCase();
      if (monthName.startsWith('jan')) return 1;
      if (monthName.startsWith('feb')) return 2;
      if (monthName.startsWith('mar')) return 3;
      if (monthName.startsWith('apr')) return 4;
      if (monthName.startsWith('mei') || monthName.startsWith('may')) return 5;
      if (monthName.startsWith('jun')) return 6;
      if (monthName.startsWith('jul')) return 7;
      if (monthName.startsWith('agu') || monthName.startsWith('aug')) return 8;
      if (monthName.startsWith('sep')) return 9;
      if (monthName.startsWith('okt') || monthName.startsWith('oct')) return 10;
      if (monthName.startsWith('nov')) return 11;
      if (monthName.startsWith('des') || monthName.startsWith('dec')) return 12;
    } catch (_) {}
    return DateTime.now().month;
  }

  void _showSuccessPopup(String paymentName, int grandTotal) {
    int day = 1;
    try {
      day = int.parse(widget.date.trim().split(' ')[0]);
    } catch (_) {
      day = DateTime.now().day;
    }

    int hour = 12;
    int minute = 0;
    try {
      hour = int.parse(widget.time.split(':')[0]);
      minute = int.parse(widget.time.split(':')[1]);
    } catch (_) {}

    final newTx = TransactionModel(
      id: 'TX-${DateTime.now().millisecondsSinceEpoch}',
      movie: widget.movie,
      cinema: widget.cinema,
      ticketCount: widget.seats.length,
      pricePerTicket: widget.ticketPrice,
      transactionDate: DateTime(
        DateTime.now().year,
        _getMonthNumber(widget.date),
        day,
        hour,
        minute,
      ),
      seatNumbers: widget.seats.join(', '),
      paymentMethod: paymentName,
    );

    TransactionState().addTransaction(newTx);

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 350),
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
              elevation: 14,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 54,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Pembayaran Berhasil!',
                      style: AppTextStyles.headingLarge.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'E-Ticket Anda bisa ditemukan di Profile',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildPopupRow('Metode Bayar', paymentName),
                          const SizedBox(height: 10),
                          _buildPopupRow(
                            'Total Harga',
                            'Rp ${grandTotal.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                            isPrice: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        child: Text(
                          'Selesai',
                          style: AppTextStyles.button.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
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

  Widget _buildPopupRow(String label, String value, {bool isPrice = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: isPrice ? AppColors.cta : AppColors.textPrimary,
            ),
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseTicketTotal = widget.seats.length * widget.ticketPrice;
    final grandTotal = baseTicketTotal + _serviceFee;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Konfirmasi Pembayaran',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 24),
                  Text(
                    'Pilih Metode Pembayaran',
                    style: AppTextStyles.headingSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentMethodsList(),
                ],
              ),
            ),
          ),
          _buildBottomActionBar(grandTotal),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final baseTicketTotal = widget.seats.length * widget.ticketPrice;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.movie.fullPosterUrl,
                  width: 65,
                  height: 95,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      Container(width: 65, height: 95, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.movie.title,
                      style: AppTextStyles.headingMedium.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.cinema.name.toUpperCase(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          _buildInfoRowWithIcon(
            Icons.calendar_month_outlined,
            'Jadwal Nonton',
            '${widget.date} | ${widget.time}',
          ),
          const SizedBox(height: 10),
          _buildInfoRowWithIcon(
            Icons.chair_outlined,
            'Nomor Kursi',
            widget.seats.join(', '),
            valueColor: AppColors.cta,
          ),
          const SizedBox(height: 10),
          _buildInfoRowWithIcon(
            Icons.local_activity_outlined,
            'Harga Satuan',
            'Rp ${widget.ticketPrice.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
          ),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),

          _buildInfoRowWithIcon(
            Icons.payments_outlined,
            'Total Harga Tiket (${widget.seats.length}x)',
            'Rp ${baseTicketTotal.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
            isBold: true,
          ),
          const SizedBox(height: 10),
          _buildInfoRowWithIcon(
            Icons.room_service_outlined,
            'Biaya Penanganan',
            'Rp ${_serviceFee.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
            isBold: false,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowWithIcon(
    IconData icon,
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
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
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodsList() {
    return Column(
      children: PaymentData.methods.map((method) {
        final isSelected = _selectedMethodId == method.id;
        final isFolder = method.subBanks != null;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              backgroundColor: AppColors.primary,
              collapsedBackgroundColor: AppColors.primary,
              onExpansionChanged: (expanded) {
                setState(() {
                  _selectedMethodId = method.id;
                  if (!isFolder) _selectedSubBankId = null;
                });
              },
              leading: Icon(
                method.icon,
                color: Colors.white,
                size: 22,
              ),
              title: Text(
                method.name,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              trailing: const Icon(
                Icons.keyboard_arrow_down,
                size: 22,
                color: Colors.white,
              ),
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: Column(
                    children: [
                      if (isFolder)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Column(
                            children: method.subBanks!.map((bank) {
                              final isBankSelected = _selectedSubBankId == bank.id;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: isBankSelected
                                      ? Colors.white
                                      : const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isBankSelected
                                        ? AppColors.primary
                                        : Colors.grey[300]!,
                                    width: isBankSelected ? 2.0 : 1.0,
                                  ),
                                ),
                                child: Theme(
                                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                  child: ExpansionTile(
                                    onExpansionChanged: (expanded) {
                                      if (expanded) {
                                        setState(() => _selectedSubBankId = bank.id);
                                      }
                                    },
                                    title: Text(
                                      bank.name,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isBankSelected
                                            ? AppColors.primary
                                            : Colors.black,
                                      ),
                                    ),
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: bank.instructions.map((step) {
                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: 4),
                                              child: Text(
                                                step,
                                                style: AppTextStyles.caption.copyWith(
                                                  color: Colors.black87,
                                                  height: 1.4,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        )
                      else if (method.mainInstructions != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: method.mainInstructions!.map((step) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  step,
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.black,
                                    height: 1.4,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomActionBar(int grandTotal) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[100]!)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Bayar',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Rp ${grandTotal.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                  style: AppTextStyles.headingLarge.copyWith(
                    color: AppColors.cta,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  if (_selectedMethodId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Silakan pilih salah satu metode pembayaran!',
                        ),
                      ),
                    );
                    return;
                  }

                  if (_selectedMethodId == 'va_folder' &&
                      _selectedSubBankId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Silakan klik dan pilih salah satu Bank Virtual Account Anda!',
                        ),
                      ),
                    );
                    return;
                  }

                  String finalPaymentName = "";
                  if (_selectedMethodId == 'va_folder') {
                    final currentFolder = PaymentData.methods.firstWhere(
                      (m) => m.id == 'va_folder',
                    );
                    final selectedBank = currentFolder.subBanks!.firstWhere(
                      (b) => b.id == _selectedSubBankId,
                    );
                    finalPaymentName = selectedBank.name;
                  } else {
                    final selectedMethod = PaymentData.methods.firstWhere(
                      (m) => m.id == _selectedMethodId,
                    );
                    finalPaymentName = selectedMethod.name;
                  }

                  _showSuccessPopup(finalPaymentName, grandTotal);
                },
                child: Text(
                  'Konfirmasi Bayar',
                  style: AppTextStyles.button.copyWith(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
