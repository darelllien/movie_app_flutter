import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/movie.dart';

class ApiService {
  final String baseUrl = 'https://api.themoviedb.org/3';
  final String _token = dotenv.get('TMDB_TOKEN');

  Future<List<Movie>> getNowPlayingMovies() async {
    final url = Uri.parse('$baseUrl/movie/now_playing?language=id-ID&page=1');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(
          response.statusCode == 200 ? response.body : '',
        );
        final List<dynamic> results = data['results'];
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat data film: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan: $e');
    }
  }
}
