import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/config/env_config.dart';

/// TMDB API Service for fetching movie metadata
class TMDBService {
  late final Dio _dio;

  TMDBService() {
    debugPrint('TMDBService: Initializing with API Key: ${EnvConfig.tmdbApiKey.isNotEmpty ? "SET" : "EMPTY"}');
    debugPrint('TMDBService: Base URL: ${EnvConfig.tmdbBaseUrl}');
    
    _dio = Dio(BaseOptions(
      baseUrl: EnvConfig.tmdbBaseUrl,
      queryParameters: {'api_key': EnvConfig.tmdbApiKey},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
    
    // Add logging interceptor for debugging
    _dio.interceptors.add(LogInterceptor(
      requestHeader: false,
      requestBody: false,
      responseHeader: false,
      responseBody: false,
      error: true,
      logPrint: (obj) => debugPrint('TMDB: $obj'),
    ));
  }

  /// Fetch movie details by TMDB ID
  Future<Map<String, dynamic>?> getMovieDetails(int tmdbId) async {
    try {
      debugPrint('TMDBService: Fetching movie details for ID: $tmdbId');
      final response = await _dio.get('/movie/$tmdbId');
      debugPrint('TMDBService: Got movie details: ${response.data['title']}');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('TMDB Error: ${e.message}');
      debugPrint('TMDB Error Response: ${e.response?.data}');
      debugPrint('TMDB Error Status: ${e.response?.statusCode}');
      return null;
    } catch (e) {
      debugPrint('TMDB Unexpected Error: $e');
      return null;
    }
  }

  /// Search movies by query
  Future<List<Map<String, dynamic>>> searchMovies(String query,
      {int page = 1}) async {
    try {
      debugPrint('TMDBService: Searching for: $query');
      final response = await _dio.get('/search/movie', queryParameters: {
        'query': query,
        'page': page,
      });
      final results = response.data['results'] as List;
      debugPrint('TMDBService: Found ${results.length} results');
      return results.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      debugPrint('TMDB Search Error: ${e.message}');
      debugPrint('TMDB Search Error Response: ${e.response?.data}');
      debugPrint('TMDB Search Error Status: ${e.response?.statusCode}');
      return [];
    } catch (e) {
      debugPrint('TMDB Search Unexpected Error: $e');
      return [];
    }
  }

  /// Get trending movies
  Future<List<Map<String, dynamic>>> getTrending(
      {String timeWindow = 'week'}) async {
    try {
      final response = await _dio.get('/trending/movie/$timeWindow');
      final results = response.data['results'] as List;
      return results.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      debugPrint('TMDB Trending Error: ${e.message}');
      return [];
    }
  }

  /// Get popular movies
  Future<List<Map<String, dynamic>>> getPopular({int page = 1}) async {
    try {
      final response =
          await _dio.get('/movie/popular', queryParameters: {'page': page});
      final results = response.data['results'] as List;
      return results.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      debugPrint('TMDB Popular Error: ${e.message}');
      return [];
    }
  }

  /// Get top rated movies
  Future<List<Map<String, dynamic>>> getTopRated({int page = 1}) async {
    try {
      final response =
          await _dio.get('/movie/top_rated', queryParameters: {'page': page});
      final results = response.data['results'] as List;
      return results.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      debugPrint('TMDB Top Rated Error: ${e.message}');
      return [];
    }
  }

  /// Get movies by genre
  Future<List<Map<String, dynamic>>> getByGenre(int genreId,
      {int page = 1}) async {
    try {
      final response = await _dio.get('/discover/movie', queryParameters: {
        'with_genres': genreId,
        'page': page,
        'sort_by': 'popularity.desc',
      });
      final results = response.data['results'] as List;
      return results.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      debugPrint('TMDB Genre Error: ${e.message}');
      return [];
    }
  }

  /// Get all genres list
  Future<List<Map<String, dynamic>>> getGenres() async {
    try {
      final response = await _dio.get('/genre/movie/list');
      final genres = response.data['genres'] as List;
      return genres.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      debugPrint('TMDB Genres Error: ${e.message}');
      return [];
    }
  }

  /// Get movie credits (cast & crew)
  Future<Map<String, dynamic>?> getMovieCredits(int tmdbId) async {
    try {
      final response = await _dio.get('/movie/$tmdbId/credits');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('TMDB Credits Error: ${e.message}');
      return null;
    }
  }

  /// Get similar movies
  Future<List<Map<String, dynamic>>> getSimilarMovies(int tmdbId) async {
    try {
      final response = await _dio.get('/movie/$tmdbId/similar');
      final results = response.data['results'] as List;
      return results.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      debugPrint('TMDB Similar Error: ${e.message}');
      return [];
    }
  }

  /// Get full poster URL
  static String getPosterUrl(String? posterPath, {String size = 'w500'}) {
    return EnvConfig.getPosterUrl(posterPath, size: size);
  }

  /// Get full backdrop URL
  static String getBackdropUrl(String? backdropPath, {String size = 'w1280'}) {
    return EnvConfig.getBackdropUrl(backdropPath, size: size);
  }
}

/// Genre IDs from TMDB
class TMDBGenres {
  static const int action = 28;
  static const int adventure = 12;
  static const int animation = 16;
  static const int comedy = 35;
  static const int crime = 80;
  static const int documentary = 99;
  static const int drama = 18;
  static const int family = 10751;
  static const int fantasy = 14;
  static const int history = 36;
  static const int horror = 27;
  static const int music = 10402;
  static const int mystery = 9648;
  static const int romance = 10749;
  static const int sciFi = 878;
  static const int tvMovie = 10770;
  static const int thriller = 53;
  static const int war = 10752;
  static const int western = 37;
}
