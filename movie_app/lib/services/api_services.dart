import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import '../models/movie.dart';

class ApiService {
  final String baseUrl = 'https://api.themoviedb.org/3';

  final String _token = dotenv.maybeGet('TMDB_TOKEN') ?? '';

  Future<List<Movie>> getNowPlayingMovies() async {
    final url = Uri.parse(
      '$baseUrl/movie/now_playing?language=id-ID&page=1&with_original_language=en|id',
    );
    return _fetchMovieList(url);
  }

  Future<List<Movie>> getUpcomingMovies() async {
    final url = Uri.parse(
      '$baseUrl/movie/upcoming?language=id-ID&page=1&with_original_language=en|id',
    );
    return _fetchMovieList(url);
  }

  Future<List<Movie>> searchMovies(String query) async {
    if (query.isEmpty) return [];
    final url = Uri.parse(
      '$baseUrl/search/movie?query=$query&language=id-ID&page=1',
    );
    return _fetchMovieList(url);
  }

  Future<List<Movie>> getPopularMovies() async {
    final url = Uri.parse('$baseUrl/movie/popular?language=id-ID&page=1');
    return _fetchMovieList(url);
  }

  Future<Map<String, dynamic>> getMovieCredits(int movieId) async {
    if (_token.isEmpty) {
      throw Exception(
        'API Token tidak ditemukan! Periksa kembali file .env Anda.',
      );
    }
    final url = Uri.parse('$baseUrl/movie/$movieId/credits');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat data credits dari TMDB');
    }
  }

  Future<String?> getMovieTrailer(int movieId) async {
    if (_token.isEmpty) return null;

    final url = Uri.parse('$baseUrl/movie/$movieId/videos?language=en-US');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        return null;
      }

      final data = json.decode(response.body);
      final List videos = data['results'] ?? [];

      if (videos.isEmpty) return null;

      debugPrint("===== VIDEO LIST =====");
      for (final v in videos) {
        debugPrint(
          "${v['name']} | ${v['type']} | ${v['official']} | ${v['site']} | ${v['key']}",
        );
      }

      final officialTrailer = videos.cast<Map<String, dynamic>?>().firstWhere(
        (v) =>
            v?['site'] == 'YouTube' &&
            v?['type'] == 'Trailer' &&
            v?['official'] == true,
        orElse: () => null,
      );

      if (officialTrailer != null) {
        return officialTrailer['key'];
      }

      final trailer = videos.cast<Map<String, dynamic>?>().firstWhere(
        (v) => v?['site'] == 'YouTube' && v?['type'] == 'Trailer',
        orElse: () => null,
      );

      if (trailer != null) {
        return trailer['key'];
      }

      final teaser = videos.cast<Map<String, dynamic>?>().firstWhere(
        (v) => v?['site'] == 'YouTube' && v?['type'] == 'Teaser',
        orElse: () => null,
      );

      if (teaser != null) {
        return teaser['key'];
      }

      return null;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<List<Movie>> _fetchMovieList(Uri url) async {
    if (_token.isEmpty) {
      throw Exception(
        'API Token tidak ditemukan! Periksa kembali file .env Anda.',
      );
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];

        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception(
          'Gagal memuat data dari TMDB. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan atau parse data: $e');
    }
  }
}
