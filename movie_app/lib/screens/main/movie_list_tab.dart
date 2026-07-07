import 'package:flutter/material.dart';
import '../../repositories/movie_repository.dart';
import '../../models/movie.dart';
import '../../constants/app_color.dart';
import '../../constants/app_text_styles.dart';
import '../../utils/formatters.dart';

enum MovieListType { nowPlaying, upcoming }

class MovieListTab extends StatefulWidget {
  final MovieListType type;

  const MovieListTab({
    super.key,
    this.type = MovieListType.nowPlaying,
  });

  @override
  State<MovieListTab> createState() => _MovieListTabState();
}

class _MovieListTabState extends State<MovieListTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MovieRepository _movieRepository = MovieRepository();

  late Future<List<Movie>> _nowPlayingFuture;
  late Future<List<Movie>> _upcomingFuture;

  @override
  void initState() {
    super.initState();

    int initialIndex = widget.type == MovieListType.nowPlaying ? 0 : 1;
    _tabController = TabController(length: 2, vsync: this, initialIndex: initialIndex);
    _nowPlayingFuture = _movieRepository.getNowPlayingMovies();
    _upcomingFuture = _movieRepository.getUpcomingMovies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: canPop ? 0 : 20,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),

        leading: canPop
            ? IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        )
            : null,

        title: Text(
          'Daftar Film',
          style: AppTextStyles.headingMedium.copyWith(color: AppColors.textPrimary),
        ),

        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 3,
          dividerColor: Colors.transparent,
          labelColor: AppColors.primary,
          indicatorColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Sedang Tayang'),
            Tab(text: 'Akan Tayang'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMovieGrid(_nowPlayingFuture, isUpcoming: false),
          _buildMovieGrid(_upcomingFuture, isUpcoming: true),
        ],
      ),
    );
  }

  Widget _buildMovieGrid(Future<List<Movie>> futureData, {required bool isUpcoming}) {
    return FutureBuilder<List<Movie>>(
      future: futureData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Gagal memuat film.\n${snapshot.error}',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          );
        }

        final movies = snapshot.data ?? [];

        if (movies.isEmpty) {
          return Center(
            child: Text(
              'Belum ada film untuk ditampilkan.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.55,
            crossAxisSpacing: 16,
            mainAxisSpacing: 20,
          ),
          itemCount: movies.length,
          itemBuilder: (context, index) {
            return _MovieGridCard(
              movie: movies[index],
              isUpcoming: isUpcoming,
            );
          },
        );
      },
    );
  }
}

class _MovieGridCard extends StatelessWidget {
  final Movie movie;
  final bool isUpcoming;

  const _MovieGridCard({
    required this.movie,
    required this.isUpcoming,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                movie.fullPosterUrl,
                width: double.infinity,
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
            ),
          ),
          const SizedBox(height: 10),

          Text(
            Formatters.truncateTitle(movie.title, maxLength: 25, truncateLength: 22),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),

          isUpcoming
              ? Text(
            'Rilis: ${Formatters.formatDate(movie.releaseDate)}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          )
              : Row(
            children: [
              const Icon(Icons.star, size: 14, color: AppColors.cta),
              const SizedBox(width: 4),
              Text(
                movie.voteAverage.toStringAsFixed(1),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}