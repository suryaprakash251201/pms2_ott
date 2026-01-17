import 'package:flutter/foundation.dart';
import '../../../data/models/models.dart';
import '../../../data/services/services.dart';

/// Provider for home screen state management
class HomeProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final OfflineService _offlineService = OfflineService();

  List<Movie> _movies = [];
  List<Movie> _featuredMovies = [];
  Map<String, List<Movie>> _categorizedMovies = {};
  List<Map<String, dynamic>> _continueWatching = [];
  bool _isLoading = true;
  String? _error;

  // Getters
  List<Movie> get movies => _movies;
  List<Movie> get featuredMovies => _featuredMovies;
  Map<String, List<Movie>> get categorizedMovies => _categorizedMovies;
  List<Map<String, dynamic>> get continueWatching => _continueWatching;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize and load all data
  Future<void> initialize({String? userId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('HomeProvider: Fetching movies from Supabase...');
      
      // Load movies from Supabase
      _movies = await _supabaseService.getMovies();
      
      debugPrint('HomeProvider: Fetched ${_movies.length} movies');

      // If no movies from server, try offline cache
      if (_movies.isEmpty) {
        debugPrint('HomeProvider: No movies from server, trying cache...');
        _movies = _offlineService.getCachedMovies();
        debugPrint('HomeProvider: Got ${_movies.length} movies from cache');
      } else {
        // Cache movies for offline use
        await _offlineService.cacheMovies(_movies);
      }

      // Set featured movies (first 5)
      _featuredMovies = _movies.take(5).toList();
      debugPrint('HomeProvider: Featured movies: ${_featuredMovies.map((m) => m.title).toList()}');

      // Categorize movies by genre
      _categorizeMovies();

      // Load continue watching if user is logged in
      if (userId != null) {
        _continueWatching = await _supabaseService.getContinueWatching(userId);
      }

      _isLoading = false;
      _error = null;
    } catch (e, stackTrace) {
      debugPrint('HomeProvider: Error loading movies: $e');
      debugPrint('HomeProvider: Stack trace: $stackTrace');
      _error = 'Failed to load movies: $e';
      _isLoading = false;

      // Try to load from cache on error
      _movies = _offlineService.getCachedMovies();
      _featuredMovies = _movies.take(5).toList();
      _categorizeMovies();
    }

    notifyListeners();
  }

  /// Categorize movies by genre
  void _categorizeMovies() {
    _categorizedMovies = {};

    for (final movie in _movies) {
      for (final genre in movie.genres) {
        if (!_categorizedMovies.containsKey(genre)) {
          _categorizedMovies[genre] = [];
        }
        _categorizedMovies[genre]!.add(movie);
      }
    }
    
    debugPrint('HomeProvider: Categorized into ${_categorizedMovies.length} genres');
  }

  /// Refresh data
  Future<void> refresh({String? userId}) async {
    debugPrint('HomeProvider: Refreshing data...');
    await initialize(userId: userId);
  }

  /// Get movies by genre
  List<Movie> getMoviesByGenre(String genre) {
    return _categorizedMovies[genre] ?? [];
  }

  /// Get available genres
  List<String> getGenres() {
    return _categorizedMovies.keys.toList();
  }
}
