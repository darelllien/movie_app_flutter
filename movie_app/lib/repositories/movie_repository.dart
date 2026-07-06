import '../models/movie.dart';
import '../services/api_services.dart';

class MovieRepository {
  final ApiService _apiService = ApiService();

  Future<List<Movie>> getNowPlayingMovies() async {
    final movies = await _apiService.getNowPlayingMovies();
    final now = DateTime.now();
    final oneMonthAgo = now.subtract(const Duration(days: 30));

    return movies.where((movie) {
      try {
        final releaseDate = DateTime.parse(movie.releaseDate);
        final isPastOrToday = releaseDate.isBefore(now) || releaseDate.isAtSameMomentAs(now);
        final isNotTooOld = releaseDate.isAfter(oneMonthAgo);

        return isPastOrToday && isNotTooOld;
      } catch (_) {
        return true;
      }
    }).toList();
  }

  Future<List<Movie>> getUpcomingMovies() async {
    final movies = await _apiService.getUpcomingMovies();
    final now = DateTime.now();

    return movies.where((movie) {
      try {
        final releaseDate = DateTime.parse(movie.releaseDate);
        return releaseDate.isAfter(now);
      } catch (_) {
        return true;
      }
    }).toList();
  }
}