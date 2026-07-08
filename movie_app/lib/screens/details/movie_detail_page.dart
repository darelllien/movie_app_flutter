import 'package:flutter/material.dart';
import 'package:movie_app/constants/app_color.dart';
import 'package:movie_app/constants/app_text_styles.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/widgets/ticket_buttom_sheet.dart';
import 'package:movie_app/data/dummy_data.dart';
import 'package:movie_app/services/api_services.dart';
import 'package:movie_app/widgets/cinema_schedule_card.dart';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;

  const MovieDetailPage({super.key, required this.movie});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  bool _isSynopsisTab = true;
  final DateTime _baseDate = DateTime(2026, 7, 10);
  late DateTime _selectedDate = _baseDate;
  String? _selectedCinemaName;
  String? _selectedShowtime;

  List<Map<String, String>> _cast = [];
  String _director = 'Memuat...';
  String _producer = 'Memuat...';
  bool _isLoadingCredits = true;

  @override
  void initState() {
    super.initState();
    _fetchCredits();
  }

  Future<void> _fetchCredits() async {
    try {
      final api = ApiService();
      final credits = await api.getMovieCredits(widget.movie.id);
      
      final castData = credits['cast'] as List;
      final parsedCast = castData.take(10).map((c) {
        return {
          'image': c['profile_path'] != null ? 'https://image.tmdb.org/t/p/w200${c['profile_path']}' : '',
          'name': c['name'].toString(),
          'role': c['character'].toString(),
        };
      }).toList();

      final crewData = credits['crew'] as List;
      final directorNode = crewData.firstWhere((c) => c['job'] == 'Director', orElse: () => {'name': '-'});
      final producers = crewData.where((c) => c['job'] == 'Producer').map((c) => c['name']).toList();

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
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month - 1];
  }

  String _getDayName(int weekday) {
    const days = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];
    return days[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    // Membatasi maksimal 2 genre
    final genres = widget.movie.genreNames.split(', ').take(2).toList();
    
    // Mengecek apakah tombol beli tiket aktif
    final isTicketActive = !_isSynopsisTab && _selectedShowtime != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER (Backdrop + Poster + Title)
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
                            colors: [
                              Colors.black54,
                              Colors.transparent,
                              Colors.black87,
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 40,
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
                          width: 110,
                          height: 160,
                          color: AppColors.primary,
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
                            widget.movie.voteAverage.toStringAsFixed(1),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.textSecondary),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              genre,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Jarak untuk ruang poster yang menjulur (130) + 16 padding
            const SizedBox(height: 146),

            // TABS
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
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

            // CONTENT
            // CONTENT
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            onPressed: isTicketActive
                ? () {
                    TicketBottomSheet.show(
                      context,
                      movieTitle: widget.movie.title,
                      cinemaName: _selectedCinemaName ?? 'Bioskop',
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

  Widget _buildSynopsisContent() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
        // OVERVIEW
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            (widget.movie.overview.isEmpty || widget.movie.overview.toLowerCase().contains('belum tersedia'))
                ? 'Film fiksi fana yang mengisahkan sebuah petualangan seru penuh dengan drama, aksi, dan intrik yang memukau. Para karakter akan dibawa ke dalam petualangan emosional dalam menghadapi berbagai konflik batin serta tantangan hidup yang tak terduga untuk mencapai tujuan akhir mereka. Karya sinematik ini menyajikan visual yang indah dan alur cerita yang sangat tidak bisa ditebak.' 
                : widget.movie.overview,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
        const SizedBox(height: 24),
        
        // CREW (Producer & Director)
        const Divider(height: 1),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Produser', style: AppTextStyles.headingSmall),
              const SizedBox(height: 4),
              Text(
                _producer,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Text('Sutradara', style: AppTextStyles.headingSmall),
              const SizedBox(height: 4),
              Text(
                _director,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 24),

        // TOP CAST
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Pemeran',
            style: AppTextStyles.headingMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
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
                        width: 90,
                        height: 110,
                        fit: BoxFit.cover,
                        errorBuilder: (context, err, stack) => Container(
                          width: 90,
                          height: 110,
                          color: Colors.grey[300],
                          child: const Icon(Icons.person, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cast['name']!,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cast['role']!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // DATE PICKER
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
              final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;
              
              String dayLabel = (index == 0) ? 'HARI INI' : _getDayName(date.weekday);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                    // Reset selected showtime when date changes
                    _selectedShowtime = null;
                  });
                },
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey[300]!,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dayLabel,
                        style: AppTextStyles.caption.copyWith(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
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
        const SizedBox(height: 24),

        // SEARCH & FILTER
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey[400]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari bioskop',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (String result) {
                // Implement city filter logic
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'Semua Kota',
                  child: Text('Semua Kota'),
                ),
                const PopupMenuItem<String>(
                  value: 'Jakarta',
                  child: Text('Jakarta'),
                ),
                const PopupMenuItem<String>(
                  value: 'Bogor',
                  child: Text('Bogor'),
                ),
                const PopupMenuItem<String>(
                  value: 'Depok',
                  child: Text('Depok'),
                ),
                const PopupMenuItem<String>(
                  value: 'Tangerang',
                  child: Text('Tangerang'),
                ),
                const PopupMenuItem<String>(
                  value: 'Bekasi',
                  child: Text('Bekasi'),
                ),
              ],
              child: Container(
                height: 45,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.tune, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Filter',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
        const SizedBox(height: 24),

        // CINEMA SCHEDULES (Max 5)
        ...DummyData.cinemaSchedules.take(5).toList().asMap().entries.map((entry) {
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
            onViewMore: () {
              // Handle view more schedules action
            },
          );
        }),
      ],
    );
  }
}
