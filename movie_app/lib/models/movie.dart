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
      overview: (json['overview'] == null || json['overview'].toString().trim().isEmpty)
          ? 'Sinopsis belum tersedia.'
          : json['overview'],
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      releaseDate: json['release_date'] ?? '-',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      genreIds: List<int>.from(json['genre_ids'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'posterPath': posterPath,
      'backdropPath': backdropPath,
      'releaseDate': releaseDate,
      'voteAverage': voteAverage,
      'genreIds': genreIds,
    };
  }

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'] ?? 0,
      title: map['title'] ?? '',
      overview: map['overview'] ?? '',
      posterPath: map['posterPath'] ?? '',
      backdropPath: map['backdropPath'] ?? '',
      releaseDate: map['releaseDate'] ?? '',
      voteAverage: (map['voteAverage'] as num?)?.toDouble() ?? 0.0,
      genreIds: List<int>.from(map['genreIds'] ?? []),
    );
  }

  String get fullPosterUrl => posterPath.isNotEmpty ? 'https://image.tmdb.org/t/p/w500$posterPath' : 'https://via.placeholder.com/500x750?text=No+Image';
  String get fullBackdropUrl => backdropPath.isNotEmpty ? 'https://image.tmdb.org/t/p/w780$backdropPath' : 'https://via.placeholder.com/780x439?text=No+Image';
  String get genreNames { /* ... */ return 'General'; }
}