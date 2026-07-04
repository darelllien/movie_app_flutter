class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final String releaseDate;
  final double voteAverage;
  final List<int> genreIds;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.genreIds,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'No Title',
      overview: json['overview'] ?? 'No Overview Available',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      releaseDate: json['release_date'] ?? '-',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      genreIds: List<int>.from(json['genre_ids'] ?? []),
    );
  }

  String get fullPosterUrl => posterPath.isNotEmpty
      ? 'https://image.tmdb.org/t/p/w500$posterPath'
      : 'https://via.placeholder.com/500x750?text=No+Image';

  String get fullBackdropUrl => backdropPath.isNotEmpty
      ? 'https://image.tmdb.org/t/p/w780$backdropPath'
      : 'https://via.placeholder.com/780x439?text=No+Image';

  String get genreNames {
    if (genreIds.isEmpty) return 'General';

    const Map<int, String> tmdbGenres = {
      28: 'Action',
      12: 'Adventure',
      16: 'Animation',
      35: 'Comedy',
      80: 'Crime',
      99: 'Documentary',
      18: 'Drama',
      10751: 'Family',
      14: 'Fantasy',
      36: 'History',
      27: 'Horror',
      10402: 'Music',
      9648: 'Mystery',
      10749: 'Romance',
      878: 'Sci-Fi',
      10770: 'TV Movie',
      53: 'Thriller',
      10752: 'War',
      37: 'Western',
    };

    List<String> names = genreIds
        .map((id) => tmdbGenres[id])
        .where((name) => name != null)
        .cast<String>()
        .toList();

    return names.isNotEmpty ? names.join(', ') : 'General';
  }
}
