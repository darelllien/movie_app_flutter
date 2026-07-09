import 'package:flutter/material.dart';
import 'package:movie_app/constants/app_color.dart';
import 'package:movie_app/constants/app_text_styles.dart';
import 'package:movie_app/data/dummy_data.dart';
import 'package:movie_app/data/seat_data.dart';
import 'package:movie_app/models/cinema.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/services/api_services.dart';
import 'package:movie_app/screens/history/checkout_page.dart';
import 'package:movie_app/models/transaction.dart';

class TicketBottomSheet extends StatefulWidget {
  final String movieTitle;
  final String cinemaName;
  final String selectedDate;
  final String selectedTime;

  const TicketBottomSheet({
    super.key,
    required this.movieTitle,
    required this.cinemaName,
    required this.selectedDate,
    required this.selectedTime,
  });

  static void show(
    BuildContext context, {
    required String movieTitle,
    required String cinemaName,
    required String selectedDate,
    required String selectedTime,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketBottomSheet(
          movieTitle: movieTitle,
          cinemaName: cinemaName,
          selectedDate: selectedDate,
          selectedTime: selectedTime,
        ),
      ),
    );
  }

  @override
  State<TicketBottomSheet> createState() => _TicketBottomSheetState();
}

class _TicketBottomSheetState extends State<TicketBottomSheet> {
  Movie? _movieObj;
  Cinema? _cinemaDetail;
  int _ticketPrice = 0;
  String _showtype = "REGULAR 2D";
  bool _isLoading = true;

  final List<String> _selectedSeats = [];

  @override
  void initState() {
    super.initState();
    _loadAsyncMetadata();
  }

  Future<void> _loadAsyncMetadata() async {
    try {
      _cinemaDetail = DummyData.cinemas.firstWhere(
        (c) =>
            c.name.toLowerCase().contains(widget.cinemaName.toLowerCase()) ||
            widget.cinemaName.toLowerCase().contains(c.name.toLowerCase()),
        orElse: () => DummyData.cinemas.first,
      );

      final movies = await ApiService().getNowPlayingMovies();
      _movieObj = movies.firstWhere(
        (m) =>
            m.title.toLowerCase().trim() ==
            widget.movieTitle.toLowerCase().trim(),
        orElse: () => movies.first,
      );

      final schedule = DummyData.cinemaSchedules.firstWhere(
        (s) =>
            s['cinemaName'].toString().toLowerCase().contains(
              widget.cinemaName.toLowerCase(),
            ) ||
            widget.cinemaName.toLowerCase().contains(
              s['cinemaName'].toString().toLowerCase(),
            ),
      );

      _showtype = schedule['type'] ?? "REGULAR 2D";
      String rawPrice = schedule['price']
          .toString()
          .replaceAll('Rp', '')
          .replaceAll('.', '');
      _ticketPrice = int.parse(rawPrice);
    } catch (_) {
      _ticketPrice = 40000;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<String> _getCurrentReservedSeats() {
    final List<String> finalReserved = List.from(SeatData.defaultReservedSeats);
    final txHistory = TransactionState().history;

    for (var tx in txHistory) {
      if (tx.movie.title == widget.movieTitle &&
          tx.cinema.name == _cinemaDetail?.name) {
        final String txDateStr =
            "${tx.transactionDate.day} ${_getMonthName(tx.transactionDate.month)}";
        final String txTimeStr =
            "${tx.transactionDate.hour.toString().padLeft(2, '0')}:${tx.transactionDate.minute.toString().padLeft(2, '0')}";

        if (widget.selectedDate.trim() == txDateStr.trim() &&
            widget.selectedTime.trim() == txTimeStr.trim()) {
          final bookedList = tx.seatNumbers.split(', ').map((s) => s.trim());
          finalReserved.addAll(bookedList);
        }
      }
    }
    return finalReserved.toSet().toList();
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

  void _toggleSeatSelection(String seatCode, List<String> activeReserved) {
    if (activeReserved.contains(seatCode)) return;
    setState(() {
      if (_selectedSeats.contains(seatCode)) {
        _selectedSeats.remove(seatCode);
      } else {
        _selectedSeats.add(seatCode);
      }
    });
  }

  void _proceedToCheckout() {
    if (_selectedSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih posisi kursi nonton!')),
      );
      return;
    }
    if (_movieObj == null || _cinemaDetail == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          movie: _movieObj!,
          cinema: _cinemaDetail!,
          date: widget.selectedDate,
          time: widget.selectedTime,
          seats: _selectedSeats,
          ticketPrice: _ticketPrice,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final activeReservedSeats = _getCurrentReservedSeats();
    final totalPayment = _selectedSeats.length * _ticketPrice;

    return Scaffold(
      backgroundColor: Colors.white,
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
          'Pilih Kursi',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _buildPremiumScheduleHeaderPanel(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 36),
                  _buildScreenCurveIndicator(),
                  const SizedBox(height: 32),
                  _buildHorizontalSeatGrid(activeReservedSeats),
                  const SizedBox(height: 32),
                  _buildStatusLegends(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildBottomNavigationBar(totalPayment),
        ],
      ),
    );
  }

  Widget _buildPremiumScheduleHeaderPanel() {
    String formattedPrice =
        'Rp ${_ticketPrice.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      // ignore: deprecated_member_use
      color: AppColors.base.withOpacity(0.25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              _movieObj?.fullPosterUrl ?? '',
              width: 80,
              height: 115,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  Container(width: 80, height: 115, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.movieTitle,
                  style: AppTextStyles.headingLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  widget.cinemaName.toUpperCase(),
                  style: AppTextStyles.headingSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildBadgeInfoItem(
                      Icons.calendar_month,
                      widget.selectedDate,
                    ),
                    _buildBadgeInfoItem(Icons.access_time, widget.selectedTime),
                    _buildBadgeInfoItem(
                      Icons.payments_outlined,
                      formattedPrice,
                      iconColor: AppColors.cta,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeInfoItem(IconData icon, String label, {Color? iconColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: iconColor ?? AppColors.textSecondary),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenCurveIndicator() {
    return Column(
      children: [
        CustomPaint(
          size: const Size(double.infinity, 12),
          painter: ScreenCurvePainter(),
        ),
        const SizedBox(height: 8),
        Text(
          'LAYAR BIOSKOP ($_showtype)',
          style: AppTextStyles.caption.copyWith(
            color: Colors.grey[400],
            letterSpacing: 2.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalSeatGrid(List<String> activeReserved) {
    return SizedBox(
      height: 420,
      width: double.infinity,
      child: InteractiveViewer(
        maxScale: 2.5,
        minScale: 0.75,
        boundaryMargin: const EdgeInsets.all(20),
        constrained: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: SeatData.theaterRows.map((rowName) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(SeatData.totalColumns, (colIndex) {
                  final seatCode = '$rowName${colIndex + 1}';

                  Color seatBoxColor = const Color(0xFFE5E7EB);
                  Color textSeatColor = Colors.black54;

                  if (activeReserved.contains(seatCode)) {
                    seatBoxColor = AppColors.primary;
                    textSeatColor = Colors.white70;
                  } else if (_selectedSeats.contains(seatCode)) {
                    seatBoxColor = AppColors.cta;
                    textSeatColor = AppColors.textOnCta;
                  }

                  final double gapRight = SeatData.isTeaterGangWay(colIndex)
                      ? 20.0
                      : 4.0;

                  return GestureDetector(
                    onTap: () => _toggleSeatSelection(seatCode, activeReserved),
                    child: Container(
                      width: 34,
                      height: 34,
                      margin: EdgeInsets.only(
                        left: 4,
                        top: 4,
                        bottom: 4,
                        right: gapRight,
                      ),
                      decoration: BoxDecoration(
                        color: seatBoxColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          seatCode,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: textSeatColor,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusLegends() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(const Color(0xFFE5E7EB), 'Available'),
        const SizedBox(width: 24),
        _legendItem(AppColors.primary, 'Reserved'),
        const SizedBox(width: 24),
        _legendItem(AppColors.cta, 'Selected'),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(int totalPayment) {
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.confirmation_num_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedSeats.length}',
                    style: AppTextStyles.headingSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                onPressed: _proceedToCheckout,
                child: Text(
                  'Beli Tiket - Rp ${totalPayment.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
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

class ScreenCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      // ignore: deprecated_member_use
      ..color = AppColors.primary.withOpacity(0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, -2, size.width, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
