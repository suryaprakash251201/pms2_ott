import 'package:flutter/foundation.dart';
import '../../../data/models/models.dart';
import '../../../data/services/services.dart';

/// Provider for playlist management
class PlaylistProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<Playlist> _playlists = [];
  Playlist? _selectedPlaylist;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Playlist> get playlists => _playlists;
  Playlist? get selectedPlaylist => _selectedPlaylist;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all playlists
  Future<void> loadPlaylists() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _playlists = await _supabaseService.getPlaylists();
      _isLoading = false;
    } catch (e) {
      _error = 'Failed to load playlists: $e';
      _isLoading = false;
    }

    notifyListeners();
  }

  /// Load playlist with movies
  Future<void> loadPlaylistDetails(String playlistId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedPlaylist =
          await _supabaseService.getPlaylistWithMovies(playlistId);
      _isLoading = false;
    } catch (e) {
      _error = 'Failed to load playlist: $e';
      _isLoading = false;
    }

    notifyListeners();
  }

  /// Create new playlist
  Future<bool> createPlaylist({
    required String name,
    String? description,
    String? thumbnailUrl,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final playlist = await _supabaseService.createPlaylist(
        name: name,
        description: description,
        thumbnailUrl: thumbnailUrl,
      );

      if (playlist != null) {
        _playlists.insert(0, playlist);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = 'Failed to create playlist';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to create playlist: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Add movie to playlist
  Future<bool> addMovieToPlaylist(String playlistId, String movieId) async {
    try {
      final success =
          await _supabaseService.addMovieToPlaylist(playlistId, movieId);
      if (success && _selectedPlaylist?.id == playlistId) {
        await loadPlaylistDetails(playlistId);
      }
      return success;
    } catch (e) {
      _error = 'Failed to add movie: $e';
      notifyListeners();
      return false;
    }
  }

  /// Remove movie from playlist
  Future<bool> removeMovieFromPlaylist(
      String playlistId, String movieId) async {
    try {
      final success =
          await _supabaseService.removeMovieFromPlaylist(playlistId, movieId);
      if (success && _selectedPlaylist != null) {
        _selectedPlaylist = _selectedPlaylist!.copyWith(
          movies: _selectedPlaylist!.movies
              .where((m) => m.id != movieId)
              .toList(),
        );
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Failed to remove movie: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete playlist
  Future<bool> deletePlaylist(String playlistId) async {
    try {
      final success = await _supabaseService.deletePlaylist(playlistId);
      if (success) {
        _playlists.removeWhere((p) => p.id == playlistId);
        if (_selectedPlaylist?.id == playlistId) {
          _selectedPlaylist = null;
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Failed to delete playlist: $e';
      notifyListeners();
      return false;
    }
  }

  /// Clear selected playlist
  void clearSelection() {
    _selectedPlaylist = null;
    notifyListeners();
  }
}
