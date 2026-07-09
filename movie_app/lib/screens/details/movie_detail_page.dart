import 'package:flutter/material.dart';
import 'package:movie_app/constants/app_color.dart';
import 'package:movie_app/constants/app_text_styles.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/widgets/ticket_buttom_sheet.dart';
import 'package:movie_app/data/dummy_data.dart';
import 'package:movie_app/services/api_services.dart';
import 'package:movie_app/widgets/cinema_schedule_card.dart';
import 'package:url_launcher/url_launcher.dart';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;

  const MovieDetailPage({super.key, required this.movie});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final ApiService _apiService = ApiService();
  bool _isSynopsisTab = true;
  final DateTime _baseDate = DateTime(2026, 7, 10);
  late DateTime _selectedDate = _baseDate;

  String? _selectedCinemaName;
  String? _selectedShowtime;

  String _selectedCity = 'SEMUA';
  bool _isDropdownOpen = false;

  List<Map<String, String>> _cast = [];
  String _director = 'Memuat...';
  String _producer = 'Memuat...';
  bool _isLoadingCredits = true;

  @override
  void initState() {
    super.initState();
    _fetchCredits();
  }

  Future<void> _playTrailer() async {
    final url = await _apiService.getMovieTrailer(widget.movie.id);
    if (url != null) {
      final uri = Uri.parse(url);
      try {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tidak dapat memutar trailer')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aplikasi browser tidak ditemukan')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trailer tidak tersedia')),
        );
      }
    }
  }

  Future<void> _fetchCredits() async {
    try {
      final api = ApiService();
      final credits = await api.getMovieCredits(widget.movie.id);

      final castData = credits['cast'] as List;
      final parsedCast = castData.take(10).map((c) {
        return {
          'image': c['profile_path'] != null
              ? 'https://image.tmdb.org/t/p/w200${c['profile_path']}'
              : '',
          'name': c['name'].toString(),
          'role': c['character'].toString(),
        };
      }).toList();

      final crewData = credits['crew'] as List;
      final directorNode = crewData.firstWhere(
            (c) => c['job'] == 'Director',
        orElse: () => {'name': '-'},
      );
      final producers = crewData
          .where((c) => c['job'] == 'Producer')
          .map((c) => c['name'])
          .toList();

      if (mounted) {
        setState(() {
          _cast = parsedCast;
          _director = directorNode['name'];
          _producer = producers.isNotEmpty ? producers.join(', ') : '-';
          _isLoadingCredits = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCredits = false;
          _director = '-';
          _producer = '-';
        });
      }
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return months[month - 1];
  }

  String _getDayName(int weekday) {
    const days = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];
    return days[weekday - 1];
  }

  bool _isUpcomingMovie() {
    if (widget.movie.releaseDate.isEmpty) return false;
    try {
      final releaseDate = DateTime.parse(widget.movie.releaseDate);
      return releaseDate.isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  bool _isMovieStillAiring() {
    if (widget.movie.releaseDate.isEmpty) return false;
    try {
      final releaseDate = DateTime.parse(widget.movie.releaseDate);
      final currentDate = DateTime.now();

      if (releaseDate.isAfter(currentDate)) return false;

      final differenceInDays = currentDate.difference(releaseDate).inDays;
      return differenceInDays <= 60;
    } catch (e) {
      return false;
    }
  }

  List<dynamic> get _filteredSchedules {
    if (_selectedCity == 'SEMUA') {
      return DummyData.cinemaSchedules;
    }
    return DummyData.cinemaSchedules.where((cinema) {
      return cinema['city'].toString().toUpperCase() == _selectedCity;
    }).toList();
  }

  List<String> get _availableCities {
    final cities = DummyData.cinemaSchedules
        .map((cinema) => cinema['city'].toString().toUpperCase())
        .toSet()
        .toList();
    cities.sort();
    return ['SEMUA', ...cities];
  }

  @override
  Widget build(BuildContext context) {
    final genres = widget.movie.genreNames.split(', ').take(2).toList();
    final isTicketActive = !_isSynopsisTab && _selectedShowtime != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        widget.movie.fullBackdropUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: AppColors.primary),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black54, Colors.transparent, Colors.black87],
                          ),
                        ),
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: _playTrailer,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 8,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  top: 190,
                  left: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.movie.fullPosterUrl,
                        width: 110,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 110, height: 160, color: AppColors.primary,
                          child: const Icon(Icons.broken_image, color: AppColors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 260,
                  left: 142,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.cta, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            _isUpcomingMovie() ? '-' : widget.movie.voteAverage.toStringAsFixed(1),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.movie.title,
                        style: AppTextStyles.headingLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: genres.map((genre) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.textSecondary),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(genre, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 120),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isSynopsisTab = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _isSynopsisTab ? AppColors.primary : Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'SINOPSIS',
                            style: AppTextStyles.headingSmall.copyWith(
                              color: _isSynopsisTab ? AppColors.primary : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isSynopsisTab = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: !_isSynopsisTab ? AppColors.primary : Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'JADWAL',
                            style: AppTextStyles.headingSmall.copyWith(
                              color: !_isSynopsisTab ? AppColors.primary : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _isSynopsisTab ? _buildSynopsisContent() : _buildJadwalContent(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isTicketActive ? AppColors.cta : Colors.grey[400],
              foregroundColor: isTicketActive ? AppColors.textOnCta : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            onPressed: isTicketActive
                ? () {
              String formattedDateStr = "${_selectedDate.day} ${_getMonthName(_selectedDate.month)}";
              TicketBottomSheet.show(
                context,
                movieTitle: widget.movie.title,
                cinemaName: _selectedCinemaName ?? 'Bioskop',
                selectedDate: formattedDateStr,
                selectedTime: _selectedShowtime!,
              );
            }
                : null,
            child: Text('BELI TIKET', style: AppTextStyles.button.copyWith(fontSize: 16)),
          ),
        ),
      ),
    );
  }

  Widget _buildSynopsisContent() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              (widget.movie.overview.isEmpty || widget.movie.overview.toLowerCase().contains('belum tersedia'))
                  ? 'Film fiksi fana yang mengisahkan sebuah petualangan seru penuh dengan drama, aksi, dan intrik yang memukau. Para karakter akan dibawa ke dalam petualangan emosional dalam menghadapi berbagai konflik batin serta tantangan hidup yang tak terduga untuk mencapai tujuan akhir mereka. Karya sinematik ini menyajikan visual yang indah dan alur cerita yang sangat tidak bisa ditebak.'
                  : widget.movie.overview,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, height: 1.5),
              textAlign: TextAlign.justify,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Produser', style: AppTextStyles.headingSmall),
                const SizedBox(height: 4),
                Text(_producer, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                Text('Sutradara', style: AppTextStyles.headingSmall),
                const SizedBox(height: 4),
                Text(_director, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Pemeran',
              style: AppTextStyles.headingMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              height: 180,
              child: _isLoadingCredits
                  ? const Center(child: CircularProgressIndicator())
                  : _cast.isEmpty
                  ? const Center(child: Text('Data pemeran belum tersedia.'))
                  : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _cast.length,
                itemBuilder: (context, index) {
                  final cast = _cast[index];
                  return Container(
                    width: 90,
                    margin: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            cast['image']!,
                            width: 90, height: 110, fit: BoxFit.cover,
                            errorBuilder: (context, err, stack) => Container(
                              width: 90, height: 110, color: Colors.grey[300],
                              child: const Icon(Icons.person, color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cast['name']!,
                          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          cast['role']!,
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildJadwalContent() {
    if (_isUpcomingMovie()) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 80.0, horizontal: 20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_month, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Maaf, film ini belum tayang di bioskop.',
                style: AppTextStyles.headingSmall.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (!_isMovieStillAiring()) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 80.0, horizontal: 20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.event_busy, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Maaf, film ini sudah tidak tayang di bioskop.',
                style: AppTextStyles.headingSmall.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final schedules = _filteredSchedules;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (context, index) {
                  final date = _baseDate.add(Duration(days: index));

                  final isToday = index == 0;
                  final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;
                  String dayLabel = isToday ? 'HARI INI' : _getDayName(date.weekday);

                  return GestureDetector(
                    onTap: isToday
                        ? () {
                      setState(() {
                        _selectedDate = date;
                        _selectedShowtime = null;
                      });
                    }
                        : null,
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : (isToday ? Colors.white : Colors.grey[100]),
                        border: Border.all(color: isSelected ? AppColors.primary : Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isSelected ? Colors.white : (isToday ? AppColors.textPrimary : Colors.grey[400]),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dayLabel,
                            style: AppTextStyles.caption.copyWith(
                              color: isSelected ? Colors.white : (isToday ? AppColors.textSecondary : Colors.grey[400]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        PopupMenuButton<String>(
          initialValue: _selectedCity,
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width,
            maxWidth: MediaQuery.of(context).size.width,
          ),
          offset: const Offset(0, 50),
          color: Colors.white,
          onOpened: () => setState(() => _isDropdownOpen = true),
          onCanceled: () => setState(() => _isDropdownOpen = false),
          onSelected: (String newValue) {
            setState(() {
              _selectedCity = newValue;
              _isDropdownOpen = false;
              _selectedCinemaName = null;
              _selectedShowtime = null;
            });
          },
          itemBuilder: (BuildContext context) {
            return _availableCities.map((String value) {
              return PopupMenuItem<String>(
                value: value,
                child: Text(value, style: AppTextStyles.bodyMedium),
              );
            }).toList();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.base,
              border: Border.symmetric(
                horizontal: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey[500]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedCity,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontSize: 16),
                  ),
                ),
                Icon(
                  _isDropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.grey[500],
                ),
              ],
            ),
          ),
        ),

        if (schedules.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Text(
                'Belum ada jadwal bioskop di $_selectedCity.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ...schedules.asMap().entries.map((entry) {
            final int index = entry.key;
            final cinema = entry.value;
            return CinemaScheduleCard(
              cinema: cinema,
              selectedCinemaName: _selectedCinemaName,
              selectedShowtime: _selectedShowtime,
              isFirst: index == 0,
              onShowtimeSelected: (cinemaName, showtime) {
                setState(() {
                  if (_selectedCinemaName == cinemaName && _selectedShowtime == showtime) {
                    _selectedCinemaName = null;
                    _selectedShowtime = null;
                  } else {
                    _selectedCinemaName = cinemaName;
                    _selectedShowtime = showtime;
                  }
                });
              },
              onViewMore: () {},
            );
          }),
      ],
    );
  }
}