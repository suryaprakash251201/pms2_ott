import 'movie.dart';

/// Playlist model representing a collection of movies
class Playlist {
  final String id;
  final String name;
  final String? description;
  final String? thumbnailUrl;
  final bool isPublic;
  final DateTime? createdAt;
  final List<Movie> movies;

  Playlist({
    required this.id,
    required this.name,
    this.description,
    this.thumbnailUrl,
    this.isPublic = true,
    this.createdAt,
    this.movies = const [],
  });

  /// Create Playlist from Supabase JSON response
  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      isPublic: json['is_public'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      movies: json['movies'] != null
          ? (json['movies'] as List)
              .map((m) => Movie.fromJson(m as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  /// Convert Playlist to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'is_public': isPublic,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Get movie count
  int get movieCount => movies.length;

  /// Get total duration
  String get totalDuration {
    final totalSeconds = movies.fold<int>(
      0,
      (sum, movie) => sum + (movie.duration ?? 0),
    );
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Copy with new values
  Playlist copyWith({
    String? id,
    String? name,
    String? description,
    String? thumbnailUrl,
    bool? isPublic,
    DateTime? createdAt,
    List<Movie>? movies,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      movies: movies ?? this.movies,
    );
  }

  @override
  String toString() => 'Playlist(id: $id, name: $name, movies: $movieCount)';
}

/// Junction model for playlist-movie relationship
class PlaylistMovie {
  final String id;
  final String playlistId;
  final String movieId;
  final int position;
  final DateTime? createdAt;

  PlaylistMovie({
    required this.id,
    required this.playlistId,
    required this.movieId,
    required this.position,
    this.createdAt,
  });

  factory PlaylistMovie.fromJson(Map<String, dynamic> json) {
    return PlaylistMovie(
      id: json['id'] as String,
      playlistId: json['playlist_id'] as String,
      movieId: json['movie_id'] as String,
      position: json['position'] as int,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'playlist_id': playlistId,
      'movie_id': movieId,
      'position': position,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
