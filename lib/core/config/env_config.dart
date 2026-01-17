import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration loaded from .env file
class EnvConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get tmdbApiKey => dotenv.env['TMDB_API_KEY'] ?? '';
  static String get tmdbBaseUrl =>
      dotenv.env['TMDB_BASE_URL'] ?? 'https://api.themoviedb.org/3';
  static String get tmdbImageBaseUrl =>
      dotenv.env['TMDB_IMAGE_BASE_URL'] ?? 'https://image.tmdb.org/t/p';
  static String get s3BucketUrl => dotenv.env['S3_BUCKET_URL'] ?? '';

  /// Validate that all required environment variables are set
  static bool validate() {
    final requiredVars = [
      supabaseUrl,
      supabaseAnonKey,
      tmdbApiKey,
    ];
    return requiredVars.every((v) => v.isNotEmpty);
  }

  /// Get full poster URL from TMDB path
  static String getPosterUrl(String? posterPath, {String size = 'w500'}) {
    if (posterPath == null || posterPath.isEmpty) {
      return '';
    }
    return '$tmdbImageBaseUrl/$size$posterPath';
  }

  /// Get full backdrop URL from TMDB path
  static String getBackdropUrl(String? backdropPath,
      {String size = 'w1280'}) {
    if (backdropPath == null || backdropPath.isEmpty) {
      return '';
    }
    return '$tmdbImageBaseUrl/$size$backdropPath';
  }
}
