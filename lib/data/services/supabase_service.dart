import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../models/models.dart';
import 'tmdb_service.dart';

/// Supabase database service for all CRUD operations
class SupabaseService {
  final SupabaseClient _client = SupabaseConfig.client;
  final TMDBService _tmdbService = TMDBService();

  // ============ MOVIES ============

  /// Fetch all movies
  Future<List<Movie>> getMovies() async {
    try {
      final response = await _client
          .from('movies')
          .select()
          .order('created_at', ascending: false);
      return (response as List)
          .map((json) => Movie.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching movies: $e');
      return [];
    }
  }

  /// Fetch single movie by ID
  Future<Movie?> getMovieById(String id) async {
    try {
      final response =
          await _client.from('movies').select().eq('id', id).single();
      return Movie.fromJson(response);
    } catch (e) {
      print('Error fetching movie: $e');
      return null;
    }
  }

  /// Fetch movies by genre
  Future<List<Movie>> getMoviesByGenre(String genre) async {
    try {
      final response = await _client
          .from('movies')
          .select()
          .contains('genres', [genre]).order('created_at', ascending: false);
      return (response as List)
          .map((json) => Movie.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching movies by genre: $e');
      return [];
    }
  }

  /// Search movies by title
  Future<List<Movie>> searchMovies(String query) async {
    try {
      final response = await _client
          .from('movies')
          .select()
          .ilike('title', '%$query%')
          .order('title');
      return (response as List)
          .map((json) => Movie.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error searching movies: $e');
      return [];
    }
  }

  /// Add a new movie with TMDB data
  Future<Movie> addMovie({
    required int tmdbId,
    required String s3VideoUrl,
    int? duration,
  }) async {
    try {
      // Fetch TMDB data
      final tmdbData = await _tmdbService.getMovieDetails(tmdbId);
      if (tmdbData == null) {
        throw Exception('Failed to fetch TMDB data for ID: $tmdbId');
      }

      // Extract genres
      final genres = (tmdbData['genres'] as List?)
              ?.map((g) => g['name'] as String)
              .toList() ??
          [];

      // Prepare movie data
      final movieData = {
        'tmdb_id': tmdbId,
        'title': tmdbData['title'],
        'description': tmdbData['overview'],
        'poster_url': TMDBService.getPosterUrl(tmdbData['poster_path']),
        'backdrop_url': TMDBService.getBackdropUrl(tmdbData['backdrop_path']),
        's3_video_url': s3VideoUrl,
        'duration': duration ?? (tmdbData['runtime'] as int? ?? 0) * 60,
        'release_date': tmdbData['release_date'],
        'rating': tmdbData['vote_average'],
        'genres': genres,
      };

      // Insert into Supabase
      final response =
          await _client.from('movies').insert(movieData).select().single();
      return Movie.fromJson(response);
    } catch (e) {
      print('Error adding movie: $e');
      rethrow;
    }
  }

  /// Update movie
  Future<bool> updateMovie(Movie movie) async {
    try {
      await _client.from('movies').update(movie.toJson()).eq('id', movie.id);
      return true;
    } catch (e) {
      print('Error updating movie: $e');
      return false;
    }
  }

  /// Delete movie
  Future<bool> deleteMovie(String id) async {
    try {
      await _client.from('movies').delete().eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting movie: $e');
      return false;
    }
  }

  // ============ PLAYLISTS ============

  /// Fetch all playlists
  Future<List<Playlist>> getPlaylists() async {
    try {
      final response = await _client
          .from('playlists')
          .select()
          .order('created_at', ascending: false);
      return (response as List)
          .map((json) => Playlist.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching playlists: $e');
      return [];
    }
  }

  /// Fetch playlist with movies
  Future<Playlist?> getPlaylistWithMovies(String playlistId) async {
    try {
      // Get playlist
      final playlistResponse = await _client
          .from('playlists')
          .select()
          .eq('id', playlistId)
          .single();

      // Get playlist movies
      final moviesResponse = await _client
          .from('playlist_movies')
          .select('movie_id, position, movies(*)')
          .eq('playlist_id', playlistId)
          .order('position');

      final movies = (moviesResponse as List).map((pm) {
        return Movie.fromJson(pm['movies'] as Map<String, dynamic>);
      }).toList();

      return Playlist.fromJson(playlistResponse).copyWith(movies: movies);
    } catch (e) {
      print('Error fetching playlist with movies: $e');
      return null;
    }
  }

  /// Create new playlist
  Future<Playlist?> createPlaylist({
    required String name,
    String? description,
    String? thumbnailUrl,
  }) async {
    try {
      final response = await _client.from('playlists').insert({
        'name': name,
        'description': description,
        'thumbnail_url': thumbnailUrl,
        'is_public': true,
      }).select().single();
      return Playlist.fromJson(response);
    } catch (e) {
      print('Error creating playlist: $e');
      return null;
    }
  }

  /// Add movie to playlist
  Future<bool> addMovieToPlaylist(String playlistId, String movieId) async {
    try {
      // Get current max position
      final positionResponse = await _client
          .from('playlist_movies')
          .select('position')
          .eq('playlist_id', playlistId)
          .order('position', ascending: false)
          .limit(1);

      final nextPosition = positionResponse.isEmpty
          ? 0
          : (positionResponse[0]['position'] as int) + 1;

      await _client.from('playlist_movies').insert({
        'playlist_id': playlistId,
        'movie_id': movieId,
        'position': nextPosition,
      });
      return true;
    } catch (e) {
      print('Error adding movie to playlist: $e');
      return false;
    }
  }

  /// Remove movie from playlist
  Future<bool> removeMovieFromPlaylist(
      String playlistId, String movieId) async {
    try {
      await _client
          .from('playlist_movies')
          .delete()
          .eq('playlist_id', playlistId)
          .eq('movie_id', movieId);
      return true;
    } catch (e) {
      print('Error removing movie from playlist: $e');
      return false;
    }
  }

  /// Delete playlist
  Future<bool> deletePlaylist(String id) async {
    try {
      await _client.from('playlists').delete().eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting playlist: $e');
      return false;
    }
  }

  // ============ USER PROGRESS ============

  /// Get user's watch progress for all movies
  Future<List<UserProgress>> getUserProgress(String userId) async {
    try {
      final response = await _client
          .from('user_progress')
          .select()
          .eq('user_id', userId)
          .order('last_watched', ascending: false);
      return (response as List)
          .map((json) => UserProgress.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching user progress: $e');
      return [];
    }
  }

  /// Get progress for a specific movie
  Future<UserProgress?> getMovieProgress(String userId, String movieId) async {
    try {
      final response = await _client
          .from('user_progress')
          .select()
          .eq('user_id', userId)
          .eq('movie_id', movieId)
          .maybeSingle();
      return response != null ? UserProgress.fromJson(response) : null;
    } catch (e) {
      print('Error fetching movie progress: $e');
      return null;
    }
  }

  /// Update watch progress
  Future<bool> updateProgress({
    required String userId,
    required String movieId,
    required int watchPosition,
    bool? isCompleted,
  }) async {
    try {
      await _client.from('user_progress').upsert({
        'user_id': userId,
        'movie_id': movieId,
        'watch_position': watchPosition,
        'is_completed': isCompleted ?? false,
        'last_watched': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,movie_id');
      return true;
    } catch (e) {
      print('Error updating progress: $e');
      return false;
    }
  }

  /// Get continue watching list (in progress, not completed)
  Future<List<Map<String, dynamic>>> getContinueWatching(String userId) async {
    try {
      final response = await _client
          .from('user_progress')
          .select('*, movies(*)')
          .eq('user_id', userId)
          .eq('is_completed', false)
          .gt('watch_position', 0)
          .order('last_watched', ascending: false)
          .limit(10);
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching continue watching: $e');
      return [];
    }
  }

  // ============ MY LIST ============

  /// Get user's saved movies list
  Future<List<Movie>> getMyList(String userId) async {
    try {
      final response = await _client
          .from('user_my_list')
          .select('*, movies(*)')
          .eq('user_id', userId)
          .order('added_at', ascending: false);

      return (response as List)
          .map((item) =>
              Movie.fromJson(item['movies'] as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching my list: $e');
      return [];
    }
  }

  /// Check if movie is in user's list
  Future<bool> isInMyList(String userId, String movieId) async {
    try {
      final response = await _client
          .from('user_my_list')
          .select('id')
          .eq('user_id', userId)
          .eq('movie_id', movieId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      print('Error checking my list: $e');
      return false;
    }
  }

  /// Add movie to my list
  Future<bool> addToMyList(String userId, String movieId) async {
    try {
      await _client.from('user_my_list').insert({
        'user_id': userId,
        'movie_id': movieId,
      });
      return true;
    } catch (e) {
      print('Error adding to my list: $e');
      return false;
    }
  }

  /// Remove movie from my list
  Future<bool> removeFromMyList(String userId, String movieId) async {
    try {
      await _client
          .from('user_my_list')
          .delete()
          .eq('user_id', userId)
          .eq('movie_id', movieId);
      return true;
    } catch (e) {
      print('Error removing from my list: $e');
      return false;
    }
  }

  /// Toggle movie in my list
  Future<bool> toggleMyList(String userId, String movieId) async {
    final inList = await isInMyList(userId, movieId);
    if (inList) {
      return removeFromMyList(userId, movieId);
    } else {
      return addToMyList(userId, movieId);
    }
  }
}
