import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../repositories/movie_repository.dart';
import '../../models/movie.dart';
import '../../constants/app_color.dart';
import '../../constants/app_text_styles.dart';
import '../../utils/formatters.dart';
import '../details/movie_detail_page.dart';
import 'search_page.dart';
import 'movie_list_tab.dart';
import '../../data/account_data.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => HomeTabState();
}

class HomeTabState extends State<HomeTab> {
  static const double _pagePadding = 20;
  static const double _upcomingListHeight = 240;
  static const double _posterAspectRatio = 2 / 3;

  static const double _highlightViewportFraction = 0.5;
  static const double _carouselEnlargeFactor = 0.18;

  static const double _plainImageWidth = 130;
  static const double _plainImageHeight = 170;

  final MovieRepository _movieRepository = MovieRepository();

  String _currentUserName = 'User';

  late final Future<List<Movie>> _nowPlayingFuture;
  late final Future<List<Movie>> _upcomingFuture;

  void loadUserNameExternal() {
    _loadUserName();
  }

  @override
  void initState() {
    super.initState();
    _nowPlayingFuture = _movieRepository.getNowPlayingMovies();
    _upcomingFuture = _movieRepository.getUpcomingMovies();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final userData = await AccountData.getCurrentUser();

    if (userData != null && mounted) {
      setState(() {
        _currentUserName =
            (userData['name'] != null && userData['name']!.isNotEmpty)
            ? userData['name']!
            : 'User';
      });
    }
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
                  _buildMovieStateWrapper(
                    future: _nowPlayingFuture,
                    height: _nowPlayingCardHeight(context),
                    onSuccess: (movies) => _buildNowPlayingCarousel(
                      movies,
                      _nowPlayingCardHeight(context),
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildSectionTitle(
                    title: 'Akan Tayang',
                    onSeeAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const MovieListTab(type: MovieListType.upcoming),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                  _buildMovieStateWrapper(
                    future: _upcomingFuture,
                    height: _upcomingListHeight,
                    onSuccess: (movies) => _buildUpcomingList(movies),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieStateWrapper({
    required Future<List<Movie>> future,
    required double height,
    required Widget Function(List<Movie> movies) onSuccess,
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
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
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
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }

        return onSuccess(movies);
      },
    );
  }

  Widget _buildNowPlayingCarousel(List<Movie> movies, double height) {
    return CarouselSlider.builder(
      itemCount: movies.length,
      options: CarouselOptions(
        height: height,
        viewportFraction: _highlightViewportFraction,
        enlargeCenterPage: true,
        enlargeFactor: _carouselEnlargeFactor,
        enlargeStrategy: CenterPageEnlargeStrategy.scale,
        autoPlay: true,
        padEnds: true,
      ),
      itemBuilder: (context, index, realIndex) {
        return _NowPlayingCard(movie: movies[index], height: height);
      },
    );
  }

  Widget _buildUpcomingList(List<Movie> movies) {
    return SizedBox(
      height: _upcomingListHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: _pagePadding),
        itemCount: movies.length,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return _MovieCarouselCard(
            movie: movies[index],
            imageWidth: _plainImageWidth,
            imageHeight: _plainImageHeight,
            showReleaseDate: true,
          );
        },
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
                    'Halo, $_currentUserName!',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.base,
                    ),
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
                        content: Text(
                          'Fitur ini masih belum tersedia saat ini',
                        ),
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
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
              ),
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
            style: AppTextStyles.headingMedium.copyWith(
              color: AppColors.textPrimary,
            ),
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
}

class _NowPlayingCard extends StatelessWidget {
  final Movie movie;
  final double height;

  const _NowPlayingCard({required this.movie, required this.height});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailPage(movie: movie),
          ),
        );
      },
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
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.surface,
                    child: const Icon(
                      Icons.broken_image,
                      color: AppColors.textSecondary,
                    ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: AppColors.cta,
                          ),
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
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailPage(movie: movie),
          ),
        );
      },
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
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: imageWidth,
                  height: imageHeight,
                  color: AppColors.surface,
                  child: const Icon(
                    Icons.broken_image,
                    color: AppColors.textSecondary,
                  ),
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
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
