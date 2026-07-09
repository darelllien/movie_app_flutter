import '../models/movie.dart';
import '../services/api_services.dart';

class MovieRepository {
  final ApiService _apiService = ApiService();
  final RegExp _containsNonAscii = RegExp(r'[^\x00-\x7F]');

  Future<List<Movie>> getNowPlayingMovies() async {
    final movies = await _apiService.getNowPlayingMovies();
    final now = DateTime.now();
    final oneMonthAgo = now.subtract(const Duration(days: 30));

    return movies.where((movie) {
      try {
        if (_containsNonAscii.hasMatch(movie.title)) {
          return false;
        }

        final releaseDate = DateTime.parse(movie.releaseDate);
        final isPastOrToday = releaseDate.isBefore(now) || releaseDate.isAtSameMomentAs(now);
        final isNotTooOld = releaseDate.isAfter(oneMonthAgo);

        return isPastOrToday && isNotTooOld;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  Future<List<Movie>> getUpcomingMovies() async {
    final movies = await _apiService.getUpcomingMovies();
    final now = DateTime.now();

    return movies.where((movie) {
      try {
        if (_containsNonAscii.hasMatch(movie.title)) return false;

        final releaseDate = DateTime.parse(movie.releaseDate);
        return releaseDate.isAfter(now);
      } catch (_) {
        return false;
      }
    }).toList();
  }

  Future<List<Movie>> searchMovies(String query) async {
    if (query.trim().isEmpty) return [];

    final movies = await _apiService.searchMovies(query);

    return movies.where((movie) {
      try {
        if (_containsNonAscii.hasMatch(movie.title)) return false;

        return true;
      } catch (_) {
        return false;
      }
    }).toList();
  }
}