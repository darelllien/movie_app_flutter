import 'dart:math';
import 'package:flutter/material.dart';
import 'package:movie_app/constants/app_color.dart';
import 'package:movie_app/constants/app_text_styles.dart';
import 'package:movie_app/models/cinema.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/services/api_services.dart';

class CinemaDetailPage extends StatefulWidget {
  final Cinema cinema;

  const CinemaDetailPage({
    super.key,
    required this.cinema,
  });

  @override
  State<CinemaDetailPage> createState() => _CinemaDetailPageState();
}

class _CinemaDetailPageState extends State<CinemaDetailPage> {
  late Future<List<Movie>> _moviesFuture;

  @override
  void initState() {
    super.initState();
    // Memanggil API sekali di initState agar tidak berulang kali me-request
    // saat terjadi rebuild UI.
    _moviesFuture = _fetchAndRandomizeMovies();
  }

  Future<List<Movie>> _fetchAndRandomizeMovies() async {
    final apiService = ApiService();
    final movies = await apiService.getNowPlayingMovies();
    
    final random = Random();
    movies.shuffle(random);
    final count = random.nextInt(3) + 3; // Menghasilkan angka 3, 4, atau 5
    
    return movies.take(count).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.cinema.name),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCinemaHeader(),
                  const SizedBox(height: 24),
                  const Divider(color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  Text(
                    'Sedang Tayang di Sini',
                    style: AppTextStyles.headingMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMoviesFutureBuilder(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCinemaHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            widget.cinema.logoUrl,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 100,
                height: 100,
                color: AppColors.base,
                child: const Icon(Icons.movie, color: AppColors.primary),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.cinema.name,
                style: AppTextStyles.headingLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, color: AppColors.cta, size: 18),
                  const SizedBox(width: 4),
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
                children: [
                  const Icon(Icons.access_time, color: AppColors.textSecondary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    widget.cinema.operatingHours,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, color: AppColors.textSecondary, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.cinema.address,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMoviesFutureBuilder() {
    return FutureBuilder<List<Movie>>(
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
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'Belum ada jadwal tayang.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          );
        }

        final movies = snapshot.data!;
        return ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return _buildMovieItem(context, movie);
          },
        );
      },
    );
  }

  Widget _buildMovieItem(BuildContext context, Movie movie) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            movie.fullPosterUrl,
            width: 50,
            height: 75,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 50,
                height: 75,
                color: AppColors.base,
                child: const Icon(Icons.broken_image, color: AppColors.primary),
              );
            },
          ),
        ),
        title: Text(
          movie.title,
          style: AppTextStyles.headingSmall.copyWith(color: AppColors.textPrimary),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              movie.genreNames,
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cta,
            foregroundColor: AppColors.textOnCta,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            _showTicketBottomSheet(context, movie);
          },
          child: Text(
            'Beli',
            style: AppTextStyles.button,
          ),
        ),
      ),
    );
  }

  void _showTicketBottomSheet(BuildContext context, Movie movie) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Beli Tiket',
                style: AppTextStyles.headingMedium.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              Text(
                '${movie.title} di ${widget.cinema.name}',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.base,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Isi oleh orang 4 (Spesialis Data & Transaksi)',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Tutup',
                    style: AppTextStyles.button.copyWith(color: AppColors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
