import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../repositories/movie_repository.dart';
import '../../models/movie.dart';
import '../../constants/app_color.dart';
import '../../constants/app_text_styles.dart';
import '../../utils/formatters.dart';
import 'search_page.dart';
import 'movie_list_tab.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  static const double _pagePadding = 20;
  static const double _upcomingCarouselHeight = 240;
  static const double _posterAspectRatio = 2 / 3;

  static const double _highlightViewportFraction = 0.5;
  static const double _plainViewportFraction = 0.35;
  static const double _carouselEnlargeFactor = 0.18;

  static const double _plainImageWidth = 130;
  static const double _plainImageHeight = 170;

  // Cukup panggil Repository, tidak perlu panggil ApiService lagi
  final MovieRepository _movieRepository = MovieRepository();

  late final Future<List<Movie>> _nowPlayingFuture;
  late final Future<List<Movie>> _upcomingFuture;

  @override
  void initState() {
    super.initState();
    // Sangat bersih! Logika filter waktu sudah diurus oleh Repository
    _nowPlayingFuture = _movieRepository.getNowPlayingMovies();
    _upcomingFuture = _movieRepository.getUpcomingMovies();
  }

  double _nowPlayingCardHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth * _highlightViewportFraction;
    return itemWidth / _posterAspectRatio;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  _buildSectionTitle(
                    title: 'Sedang Tayang',
                    onSeeAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MovieListTab(
                            type: MovieListType.nowPlaying,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                  _buildMovieCarousel(
                    future: _nowPlayingFuture,
                    height: _nowPlayingCardHeight(context),
                    highlightCenter: true,
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle(
                    title: 'Akan Tayang',
                    onSeeAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MovieListTab(
                            type: MovieListType.upcoming,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                  _buildMovieCarousel(
                    future: _upcomingFuture,
                    height: _upcomingCarouselHeight,
                    highlightCenter: false,
                    showReleaseDate: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: _pagePadding,
        right: _pagePadding,
        bottom: 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, Irfan!',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.base),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mau nonton apa hari ini?',
                    style: AppTextStyles.headingMedium.copyWith(
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications_none),
                  color: AppColors.primary,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fitur ini masih belum tersedia saat ini'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            readOnly: true,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchPage()),
            ),
            decoration: InputDecoration(
              hintText: 'Cari judul film atau bioskop...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required VoidCallback onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _pagePadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.headingMedium.copyWith(color: AppColors.textPrimary),
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              'Semua >',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieCarousel({
    required Future<List<Movie>> future,
    required double height,
    bool highlightCenter = true,
    bool showReleaseDate = false,
  }) {
    return FutureBuilder<List<Movie>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: height,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (snapshot.hasError) {
          return SizedBox(
            height: height,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Gagal memuat film.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ),
          );
        }

        final movies = snapshot.data ?? [];

        if (movies.isEmpty) {
          return SizedBox(
            height: height,
            child: Center(
              child: Text(
                'Belum ada film untuk ditampilkan.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ),
          );
        }

        final options = highlightCenter
            ? CarouselOptions(
          height: height,
          viewportFraction: _highlightViewportFraction,
          enlargeCenterPage: true,
          enlargeFactor: _carouselEnlargeFactor,
          enlargeStrategy: CenterPageEnlargeStrategy.scale,
          autoPlay: true,
          padEnds: true,
        )
            : CarouselOptions(
          height: height,
          viewportFraction: _plainViewportFraction,
          enlargeCenterPage: false,
          autoPlay: true,
          padEnds: false,
        );

        return CarouselSlider.builder(
          itemCount: movies.length,
          options: options,
          itemBuilder: (context, index, realIndex) {
            if (highlightCenter) {
              return _NowPlayingCard(
                movie: movies[index],
                height: height,
              );
            }

            final card = _MovieCarouselCard(
              movie: movies[index],
              imageWidth: _plainImageWidth,
              imageHeight: _plainImageHeight,
              showReleaseDate: showReleaseDate,
            );

            return Container(
              margin: EdgeInsets.only(left: index == 0 ? _pagePadding : 6, right: 6),
              child: card,
            );
          },
        );
      },
    );
  }
}

class _NowPlayingCard extends StatelessWidget {
  final Movie movie;
  final double height;

  const _NowPlayingCard({
    required this.movie,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                movie.fullPosterUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: AppColors.surface,
                    child: const Center(
                      child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.surface,
                    child: const Icon(Icons.broken_image, color: AppColors.textSecondary),
                  );
                },
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.black.withValues(alpha: 0),
                      AppColors.black.withValues(alpha: 0.85),
                    ],
                    stops: const [0.45, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 14,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 14, color: AppColors.cta),
                          const SizedBox(width: 4),
                          Text(
                            movie.voteAverage.toStringAsFixed(1),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.headingSmall.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MovieCarouselCard extends StatelessWidget {
  final Movie movie;
  final double imageWidth;
  final double imageHeight;
  final bool showReleaseDate;

  const _MovieCarouselCard({
    required this.movie,
    required this.imageWidth,
    required this.imageHeight,
    this.showReleaseDate = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              movie.fullPosterUrl,
              width: imageWidth,
              height: imageHeight,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return SizedBox(
                  width: imageWidth,
                  height: imageHeight,
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: imageWidth,
                  height: imageHeight,
                  color: AppColors.surface,
                  child: const Icon(Icons.broken_image, color: AppColors.textSecondary),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Text(
            Formatters.truncateTitle(movie.title),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (showReleaseDate) ...[
            const SizedBox(height: 2),
            Text(
              'Rilis: ${Formatters.formatDate(movie.releaseDate)}',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}