import 'dart:math';
import 'package:flutter/material.dart';
import 'package:movie_app/constants/app_color.dart';
import 'package:movie_app/constants/app_text_styles.dart';
import 'package:movie_app/models/cinema.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/services/api_services.dart';
import 'package:movie_app/widgets/ticket_buttom_sheet.dart';

class CinemaDetailPage extends StatefulWidget {
  final Cinema cinema;

  const CinemaDetailPage({super.key, required this.cinema});

  @override
  State<CinemaDetailPage> createState() => _CinemaDetailPageState();
}

class _CinemaDetailPageState extends State<CinemaDetailPage> {
  late Future<List<Map<String, dynamic>>> _moviesFuture;

  final DateTime _baseDate = DateTime(2026, 7, 10);
  late DateTime _selectedDate = _baseDate;

  Movie? _selectedMovie;
  String? _selectedShowtime;

  @override
  void initState() {
    super.initState();
    _moviesFuture = _fetchAndRandomizeMovies();
  }

  Future<List<Map<String, dynamic>>> _fetchAndRandomizeMovies() async {
    final apiService = ApiService();
    final movies = await apiService.getNowPlayingMovies();

    final random = Random();
    movies.shuffle(random);
    final count = random.nextInt(3) + 3;
    final selectedMovies = movies.take(count).toList();

    final allPossibleShowtimes = [
      '10:00',
      '11:15',
      '12:30',
      '13:45',
      '14:30',
      '15:15',
      '16:45',
      '18:00',
      '19:15',
      '20:30',
      '21:45',
    ];

    return selectedMovies.map((m) {
      allPossibleShowtimes.shuffle(random);
      final showtimeCount = random.nextInt(4) + 3;
      var times = allPossibleShowtimes.take(showtimeCount).toList();
      times.sort();
      return {'movie': m, 'showtimes': times};
    }).toList();
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

  String _getDayName(int weekday) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return days[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final isTicketActive = _selectedMovie != null && _selectedShowtime != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Bioskop Detail',
          style: AppTextStyles.headingMedium.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCinemaHeader(),
            Container(height: 2, color: Colors.grey[200]),
            _buildDatePicker(),
            Container(height: 4, color: Colors.grey[200]),
            _buildMoviesFutureBuilder(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: SafeArea(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isTicketActive
                  ? AppColors.cta
                  : Colors.grey[400],
              foregroundColor: isTicketActive
                  ? AppColors.textOnCta
                  : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            onPressed: isTicketActive
                ? () {
                    String formattedDateStr =
                        "${_selectedDate.day} ${_getMonthName(_selectedDate.month)}";
                    TicketBottomSheet.show(
                      context,
                      movieTitle: _selectedMovie!.title,
                      cinemaName: widget.cinema.name,
                      selectedDate: formattedDateStr,
                      selectedTime: _selectedShowtime!,
                    );
                  }
                : null,
            child: Text(
              'BELI TIKET',
              style: AppTextStyles.button.copyWith(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCinemaHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: widget.cinema.logoUrl.startsWith('http')
                ? Image.network(
                    widget.cinema.logoUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildErrorLogo(),
                  )
                : Image.asset(
                    widget.cinema.logoUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildErrorLogo(),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.cinema.name,
                  style: AppTextStyles.cinemaTitle.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 2.0),
                      child: Icon(Icons.star, color: AppColors.cta, size: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.cinema.rating.toStringAsFixed(1),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 2.0),
                      child: Icon(Icons.schedule, color: Colors.grey, size: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.cinema.operatingHours,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2.0),
                      child: Icon(Icons.location_on, color: Colors.grey, size: 16),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.cinema.address,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildErrorLogo() {
    return Container(width: 100, height: 100, color: Colors.grey[300]);
  }

  Widget _buildDatePicker() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: SizedBox(
        height: 60,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 7,
          itemBuilder: (context, index) {
            final date = _baseDate.add(Duration(days: index));
            final isToday = index == 0;
            final isSelected =
                date.day == _selectedDate.day &&
                date.month == _selectedDate.month;
            String dayLabel = isToday ? 'HARI INI' : _getDayName(date.weekday);

            return GestureDetector(
              onTap: isToday
                  ? () {
                      setState(() {
                        _selectedDate = date;
                        _selectedMovie = null;
                        _selectedShowtime = null;
                      });
                    }
                  : null,
              child: Container(
                width: 60,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1B2C4F)
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dayLabel,
                      style: AppTextStyles.caption.copyWith(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMoviesFutureBuilder() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _moviesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Gagal memuat film.\n${snapshot.error}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'Belum ada jadwal tayang.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          );
        }

        final moviesData = snapshot.data!;
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: moviesData.length,
          separatorBuilder: (context, index) => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(height: 1, color: Color(0xFFE0E0E0)),
          ),
          itemBuilder: (context, index) {
            final data = moviesData[index];
            final Movie movie = data['movie'];
            final List<String> showtimes = data['showtimes'];

            return _buildCinemaMovieCard(movie, showtimes);
          },
        );
      },
    );
  }

  Widget _buildCinemaMovieCard(Movie movie, List<String> showtimes) {
    final genres = movie.genreNames.split(', ').take(2).toList();

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  movie.fullPosterUrl,
                  width: 64,
                  height: 96,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(width: 64, height: 96, color: Colors.grey[300]),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: AppTextStyles.movieListTitle.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Genre: ',
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(width: 4),
                        ...genres.map(
                          (g) => Container(
                            margin: const EdgeInsets.only(right: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              g,
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Rating: ',
                          style: AppTextStyles.bodyMedium,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 2.0),
                          child: Icon(Icons.star, color: AppColors.cta, size: 16),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          movie.voteAverage.toStringAsFixed(1),
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Regular 2D',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Rp 45.000',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.2,
            ),
            itemCount: showtimes.length,
            itemBuilder: (context, index) {
              final time = showtimes[index];
              final isSelected =
                  _selectedMovie?.id == movie.id && _selectedShowtime == time;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedMovie = null;
                      _selectedShowtime = null;
                    } else {
                      _selectedMovie = movie;
                      _selectedShowtime = time;
                    }
                  });
                },
                child: Container(
                  width: (MediaQuery.of(context).size.width - 32 - 36) / 4,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF2A30F) : Colors.white,
                    border: Border.all(
                      color: isSelected ? const Color(0xFFF2A30F) : Colors.grey[300]!,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    time,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
