import 'dart:math';
import 'package:flutter/material.dart';
import 'package:movie_app/constants/app_color.dart';
import 'package:movie_app/constants/app_text_styles.dart';
import 'package:movie_app/models/cinema.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/services/api_services.dart';
import 'package:movie_app/widgets/movie_card.dart';
import 'package:movie_app/widgets/ticket_buttom_sheet.dart';

class CinemaDetailPage extends StatefulWidget {
  final Cinema cinema;

  const CinemaDetailPage({super.key, required this.cinema});

  @override
  State<CinemaDetailPage> createState() => _CinemaDetailPageState();
}

class _CinemaDetailPageState extends State<CinemaDetailPage> {
  late Future<List<Movie>> _moviesFuture;

  @override
  void initState() {
    super.initState();
    _moviesFuture = _fetchAndRandomizeMovies();
  }

  Future<List<Movie>> _fetchAndRandomizeMovies() async {
    final apiService = ApiService();
    final movies = await apiService.getNowPlayingMovies();

    final random = Random();
    movies.shuffle(random);
    // Requirement assignment: menampilkan 3-5 film secara acak (random).
    final count = random.nextInt(3) + 3;

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
          child: widget.cinema.logoUrl.startsWith('http')
              ? Image.network(
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
                )
              : Image.asset(
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
                  const Icon(
                    Icons.access_time,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
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
                  const Icon(
                    Icons.location_on,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
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

        final movies = snapshot.data!;
        return ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return MovieCard(
              movie: movie,
              onBuyPressed: () {
                TicketBottomSheet.show(
                  context,
                  movieTitle: movie.title,
                  cinemaName: widget.cinema.name,
                );
              },
            );
          },
        );
      },
    );
  }
}
