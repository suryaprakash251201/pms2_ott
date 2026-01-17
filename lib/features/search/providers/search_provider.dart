import 'package:flutter/foundation.dart';
import '../../../data/models/models.dart';
import '../../../data/services/services.dart';

/// Provider for search functionality
class SearchProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final TMDBService _tmdbService = TMDBService();

  List<Movie> _results = [];
  List<Map<String, dynamic>> _tmdbResults = [];
  String _query = '';
  bool _isLoading = false;
  String? _error;
  bool _searchTMDB = false;

  // Getters
  List<Movie> get results => _results;
  List<Map<String, dynamic>> get tmdbResults => _tmdbResults;
  String get query => _query;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get searchTMDB => _searchTMDB;
  bool get hasResults => _results.isNotEmpty || _tmdbResults.isNotEmpty;

  /// Toggle TMDB search
  void setSearchTMDB(bool value) {
    _searchTMDB = value;
    if (_query.isNotEmpty) {
      search(_query);
    }
    notifyListeners();
  }

  /// Search movies
  Future<void> search(String query) async {
    if (query.isEmpty) {
      _results = [];
      _tmdbResults = [];
      _query = '';
      notifyListeners();
      return;
    }

    _query = query;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_searchTMDB) {
        // Search TMDB directly
        _tmdbResults = await _tmdbService.searchMovies(query);
        _results = [];
      } else {
        // Search local database
        _results = await _supabaseService.searchMovies(query);
        _tmdbResults = [];
      }
      _isLoading = false;
    } catch (e) {
      _error = 'Search failed: $e';
      _isLoading = false;
    }

    notifyListeners();
  }

  /// Clear search
  void clear() {
    _results = [];
    _tmdbResults = [];
    _query = '';
    _error = null;
    notifyListeners();
  }

  /// Get genres for filtering
  Future<List<Map<String, dynamic>>> getGenres() async {
    try {
      return await _tmdbService.getGenres();
    } catch (e) {
      return [];
    }
  }
}
