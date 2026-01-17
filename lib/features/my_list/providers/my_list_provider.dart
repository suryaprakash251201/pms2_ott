import 'package:flutter/foundation.dart';
import '../../../data/models/models.dart';
import '../../../data/services/services.dart';

/// Provider for My List functionality
class MyListProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<Movie> _myList = [];
  Set<String> _movieIds = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Movie> get myList => _myList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Check if movie is in list
  bool isInMyList(String movieId) => _movieIds.contains(movieId);

  /// Load user's list
  Future<void> loadMyList(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myList = await _supabaseService.getMyList(userId);
      _movieIds = _myList.map((m) => m.id).toSet();
      _isLoading = false;
    } catch (e) {
      _error = 'Failed to load list: $e';
      _isLoading = false;
    }

    notifyListeners();
  }

  /// Toggle movie in list
  Future<bool> toggleMovie(String userId, Movie movie) async {
    try {
      final wasInList = _movieIds.contains(movie.id);

      if (wasInList) {
        _myList.removeWhere((m) => m.id == movie.id);
        _movieIds.remove(movie.id);
        notifyListeners();

        final success =
            await _supabaseService.removeFromMyList(userId, movie.id);
        if (!success) {
          // Rollback
          _myList.add(movie);
          _movieIds.add(movie.id);
          notifyListeners();
          return false;
        }
      } else {
        _myList.insert(0, movie);
        _movieIds.add(movie.id);
        notifyListeners();

        final success = await _supabaseService.addToMyList(userId, movie.id);
        if (!success) {
          // Rollback
          _myList.removeWhere((m) => m.id == movie.id);
          _movieIds.remove(movie.id);
          notifyListeners();
          return false;
        }
      }

      return true;
    } catch (e) {
      _error = 'Failed to update list: $e';
      notifyListeners();
      return false;
    }
  }

  /// Clear list state
  void clear() {
    _myList = [];
    _movieIds = {};
    _error = null;
    notifyListeners();
  }
}
