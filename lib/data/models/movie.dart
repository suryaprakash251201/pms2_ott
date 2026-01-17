import 'package:hive/hive.dart';

part 'movie.g.dart';

/// Movie model representing a video in the streaming app
@HiveType(typeId: 0)
class Movie extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int tmdbId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String? description;

  @HiveField(4)
  final String? posterUrl;

  @HiveField(5)
  final String? backdropUrl;

  @HiveField(6)
  final String s3VideoUrl;

  @HiveField(7)
  final int? duration; // in seconds

  @HiveField(8)
  final DateTime? releaseDate;

  @HiveField(9)
  final double? rating;

  @HiveField(10)
  final List<String> genres;

  @HiveField(11)
  final DateTime? createdAt;

  Movie({
    required this.id,
    required this.tmdbId,
    required this.title,
    this.description,
    this.posterUrl,
    this.backdropUrl,
    required this.s3VideoUrl,
    this.duration,
    this.releaseDate,
    this.rating,
    this.genres = const [],
    this.createdAt,
  });

  /// Create Movie from Supabase JSON response
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as String,
      tmdbId: json['tmdb_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      posterUrl: json['poster_url'] as String?,
      backdropUrl: json['backdrop_url'] as String?,
      s3VideoUrl: json['s3_video_url'] as String,
      duration: json['duration'] as int?,
      releaseDate: json['release_date'] != null
          ? DateTime.tryParse(json['release_date'] as String)
          : null,
      rating: (json['rating'] as num?)?.toDouble(),
      genres: json['genres'] != null
          ? List<String>.from(json['genres'] as List)
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  /// Convert Movie to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tmdb_id': tmdbId,
      'title': title,
      'description': description,
      'poster_url': posterUrl,
      'backdrop_url': backdropUrl,
      's3_video_url': s3VideoUrl,
      'duration': duration,
      'release_date': releaseDate?.toIso8601String().split('T').first,
      'rating': rating,
      'genres': genres,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Get formatted duration string (e.g., "2h 15m")
  String get formattedDuration {
    if (duration == null) return '';
    final hours = duration! ~/ 3600;
    final minutes = (duration! % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Get release year
  String get releaseYear {
    return releaseDate?.year.toString() ?? '';
  }

  /// Copy with new values
  Movie copyWith({
    String? id,
    int? tmdbId,
    String? title,
    String? description,
    String? posterUrl,
    String? backdropUrl,
    String? s3VideoUrl,
    int? duration,
    DateTime? releaseDate,
    double? rating,
    List<String>? genres,
    DateTime? createdAt,
  }) {
    return Movie(
      id: id ?? this.id,
      tmdbId: tmdbId ?? this.tmdbId,
      title: title ?? this.title,
      description: description ?? this.description,
      posterUrl: posterUrl ?? this.posterUrl,
      backdropUrl: backdropUrl ?? this.backdropUrl,
      s3VideoUrl: s3VideoUrl ?? this.s3VideoUrl,
      duration: duration ?? this.duration,
      releaseDate: releaseDate ?? this.releaseDate,
      rating: rating ?? this.rating,
      genres: genres ?? this.genres,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'Movie(id: $id, title: $title)';
}
