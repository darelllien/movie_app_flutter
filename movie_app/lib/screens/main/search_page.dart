import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_color.dart';
import '../../constants/app_text_styles.dart';
import '../../models/movie.dart';
import '../../models/cinema.dart';
import '../../repositories/movie_repository.dart';
import '../../data/dummy_data.dart';
import '../../utils/formatters.dart';
import '../details/movie_detail_page.dart';
import '../details/cinema_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  final MovieRepository _movieRepository = MovieRepository();
  Timer? _debounce;

  String _searchHint = 'Cari film...';
  String _currentQuery = '';

  Future<List<Movie>>? _movieSearchResults;
  List<Cinema> _cinemaSearchResults = [];

  List<String> _movieHistory = [];
  List<String> _cinemaHistory = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cinemaSearchResults = DummyData.cinemas;

    _loadSearchHistory();

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;

      setState(() {
        _searchHint = _tabController.index == 0 ? 'Cari film...' : 'Cari bioskop...';
        _searchController.clear();
        _currentQuery = '';
        FocusScope.of(context).unfocus();

        if (_tabController.index == 0) {
          _movieSearchResults = null;
        } else {
          _cinemaSearchResults = DummyData.cinemas;
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _movieHistory = prefs.getStringList('movie_history') ?? [];
      _cinemaHistory = prefs.getStringList('cinema_history') ?? [];
    });
  }

  Future<void> _saveSearchHistory(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();

    setState(() {
      if (_tabController.index == 0) {
        _movieHistory.remove(cleanQuery);
        _movieHistory.insert(0, cleanQuery);
        if (_movieHistory.length > 3) _movieHistory.removeLast();
        prefs.setStringList('movie_history', _movieHistory);
      } else {
        _cinemaHistory.remove(cleanQuery);
        _cinemaHistory.insert(0, cleanQuery);
        if (_cinemaHistory.length > 3) _cinemaHistory.removeLast();
        prefs.setStringList('cinema_history', _cinemaHistory);
      }
    });
  }

  void _onHistoryOrTrendTap(String query) {
    _searchController.text = query;
    _searchController.selection = TextSelection.fromPosition(TextPosition(offset: query.length));
    _onSearchChanged(query);
    _saveSearchHistory(query);
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _currentQuery = query;
      });
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    if (_tabController.index == 0) {
      if (query.trim().isEmpty) {
        setState(() => _movieSearchResults = null);
      } else {
        setState(() {
          _movieSearchResults = _movieRepository.searchMovies(query);
        });
      }
    } else {
      setState(() {
        if (query.trim().isEmpty) {
          _cinemaSearchResults = DummyData.cinemas;
        } else {
          _cinemaSearchResults = DummyData.cinemas.where((cinema) {
            return cinema.name.toLowerCase().contains(query.toLowerCase()) ||
                cinema.address.toLowerCase().contains(query.toLowerCase());
          }).toList();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          titleSpacing: 0,
          title: TextField(
            controller: _searchController,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: _onSearchChanged,
            onSubmitted: _saveSearchHistory,
            decoration: InputDecoration(
              hintText: _searchHint,
              hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
              border: InputBorder.none,
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                onPressed: () {
                  _searchController.clear();
                  _onSearchChanged('');
                },
              )
                  : null,
            ),
            style: AppTextStyles.bodyLarge,
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
              Tab(text: 'Film'),
              Tab(text: 'Bioskop'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildMovieSearchTab(),
            _buildCinemaSearchTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildIdleState(bool isMovie) {
    final history = isMovie ? _movieHistory : _cinemaHistory;

    final trends = isMovie
        ? ['OBSESSION', 'JANGAN BUANG IBU', 'MOANA', 'FOUFO', 'TOY STORY 5']
        : ['CGV', 'XXI', 'CINEPOLIS', 'BEKASI', 'JAKARTA'];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (history.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text(
                'Pencarian sebelumnya',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ),
            ...history.map((query) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: Icon(Icons.history, color: AppColors.textSecondary),
              title: Text(query, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
              onTap: () => _onHistoryOrTrendTap(query),
            )),
            Divider(height: 32, thickness: 1, color: AppColors.textSecondary.withValues(alpha: 0.1)),
          ] else ...[
            const SizedBox(height: 24),
          ],

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMovie ? 'Trend pencarian film' : 'Trend pencarian bioskop',
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: trends.map((trend) {
                    return GestureDetector(
                      onTap: () => _onHistoryOrTrendTap(trend),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          trend,
                          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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
    );
  }

  Widget _buildMovieSearchTab() {
    if (_currentQuery.isEmpty || _movieSearchResults == null) {
      return _buildIdleState(true);
    }

    return FutureBuilder<List<Movie>>(
      future: _movieSearchResults,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Terjadi kesalahan pencarian.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)));
        }
        final movies = snapshot.data ?? [];
        if (movies.isEmpty) {
          return Center(child: Text('Film "$_currentQuery" tidak ditemukan', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)));
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
            return _buildMovieCard(movies[index]);
          },
        );
      },
    );
  }

  Widget _buildCinemaSearchTab() {
    if (_currentQuery.isEmpty) {
      return _buildIdleState(false);
    }

    if (_cinemaSearchResults.isEmpty) {
      return Center(child: Text('Bioskop "$_currentQuery" tidak ditemukan', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _cinemaSearchResults.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildCinemaCard(_cinemaSearchResults[index]);
      },
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () {
        _saveSearchHistory(_currentQuery);
        Navigator.push(context, MaterialPageRoute(builder: (context) => MovieDetailPage(movie: movie)));
      },
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
                errorBuilder: (context, error, stackTrace) => Container(color: AppColors.surface, child: const Icon(Icons.broken_image, color: AppColors.textSecondary)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            Formatters.truncateTitle(movie.title, maxLength: 25, truncateLength: 22),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.star, size: 14, color: AppColors.cta),
              const SizedBox(width: 4),
              Text(movie.voteAverage.toStringAsFixed(1), style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCinemaCard(Cinema cinema) {
    return GestureDetector(
      onTap: () {
        _saveSearchHistory(_currentQuery);
        Navigator.push(context, MaterialPageRoute(builder: (context) => CinemaDetailPage(cinema: cinema)));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.1))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(cinema.logoUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.business, color: AppColors.textSecondary))),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cinema.name, style: AppTextStyles.headingSmall.copyWith(color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(cinema.address, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}