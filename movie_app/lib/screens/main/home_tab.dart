import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../services/api_services.dart';
import '../../models/movie.dart';
import '../../constants/app_color.dart';
import '../../constants/app_text_styles.dart';
import 'search_page.dart';
import 'movie_list_tab.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  static const double _nowPlayingCarouselHeight = 260;
  static const double _upcomingCarouselHeight = 240;

  static const double _carouselViewportFraction = 0.35;
  static const double _carouselEnlargeFactor = 0.18;

  static const double _plainImageWidth = 130;
  static const double _plainImageHeight = 170;

  static const double _highlightImageWidth = 130;
  static const double _highlightImageHeight = 180;

  static const int _titleMaxLength = 17;
  static const int _titleTruncateLength = 14;

  static const List<String> _monthLabels = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  final ApiService _apiService = ApiService();
  late final Future<List<Movie>> _nowPlayingFuture;
  late final Future<List<Movie>> _upcomingFuture;

  @override
  void initState() {
    super.initState();
    _nowPlayingFuture = _apiService.getNowPlayingMovies();
    _upcomingFuture = _apiService.getUpcomingMovies();
  }

  String _truncateTitle(String title) {
    if (title.length <= _titleMaxLength) return title;
    return '${title.substring(0, _titleTruncateLength)}...';
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day} ${_monthLabels[date.month - 1]} ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildSectionTitle(
              title: 'Sedang Tayang',
              onSeeAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MovieListTab()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildMovieCarousel(
              future: _nowPlayingFuture,
              height: _nowPlayingCarouselHeight,
              highlightCenter: true,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(
              title: 'Akan Tayang',
              onSeeAll: () {},
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
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
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
                  onPressed: () {},
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
            child: Center(
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
                viewportFraction: _carouselViewportFraction,
                enlargeCenterPage: true,
                enlargeFactor: _carouselEnlargeFactor,
                enlargeStrategy: CenterPageEnlargeStrategy.scale,
                autoPlay: true,
                padEnds: true,
              )
            : CarouselOptions(
                height: height,
                viewportFraction: _carouselViewportFraction,
                enlargeCenterPage: false,
                autoPlay: true,
                padEnds: false,
              );

        return CarouselSlider.builder(
          itemCount: movies.length,
          options: options,
          itemBuilder: (context, index, realIndex) {
            final card = _MovieCarouselCard(
              movie: movies[index],
              imageWidth: highlightCenter ? _highlightImageWidth : _plainImageWidth,
              imageHeight: highlightCenter ? _highlightImageHeight : _plainImageHeight,
              truncateTitle: _truncateTitle,
              formatDate: _formatDate,
              showReleaseDate: showReleaseDate,
            );

            if (highlightCenter) {
              return card;
            }

            return Container(
              margin: EdgeInsets.only(left: index == 0 ? 20 : 6, right: 6),
              child: card,
            );
          },
        );
      },
    );
  }
}

class _MovieCarouselCard extends StatelessWidget {
  final Movie movie;
  final double imageWidth;
  final double imageHeight;
  final String Function(String title) truncateTitle;
  final String Function(String date) formatDate;
  final bool showReleaseDate;

  const _MovieCarouselCard({
    required this.movie,
    required this.imageWidth,
    required this.imageHeight,
    required this.truncateTitle,
    required this.formatDate,
    this.showReleaseDate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: imageWidth,
                height: imageHeight,
                color: AppColors.surface,
                child: Icon(Icons.broken_image, color: AppColors.textSecondary),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Text(
          truncateTitle(movie.title),
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
            'Rilis: ${formatDate(movie.releaseDate)}',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }
}