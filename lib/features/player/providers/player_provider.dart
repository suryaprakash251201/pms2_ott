import 'package:flutter/foundation.dart';
import '../../../data/models/models.dart';
import '../../../data/services/services.dart';

/// Provider for video player state management
class PlayerProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  Movie? _currentMovie;
  UserProgress? _progress;
  bool _isPlaying = false;
  String? _error;

  // Getters
  Movie? get currentMovie => _currentMovie;
  UserProgress? get progress => _progress;
  bool get isPlaying => _isPlaying;
  String? get error => _error;

  /// Initialize player data with movie
  Future<void> initialize(Movie movie, {String? userId}) async {
    _currentMovie = movie;
    _error = null;
    notifyListeners();

    try {
      // Load saved progress
      if (userId != null) {
        _progress =
            await _supabaseService.getMovieProgress(userId, movie.id);
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load player data: $e';
      notifyListeners();
    }
  }

  /// Update playback status
  void setPlaying(bool playing) {
    _isPlaying = playing;
    notifyListeners();
  }

  /// Save current progress
  Future<void> saveProgress(String userId, int position, int duration) async {
    if (_currentMovie == null) return;

    final isCompleted =
        duration > 0 && position >= duration - 30;

    await _supabaseService.updateProgress(
      userId: userId,
      movieId: _currentMovie!.id,
      watchPosition: position,
      isCompleted: isCompleted,
    );
  }
}
