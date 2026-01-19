import 'package:flutter/foundation.dart';
import '../../../data/models/models.dart';
import '../../../data/services/services.dart';
import 'dart:async'; // Added for Timer

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

    // STRATEGY: Instant Load
    // 1. Try to load from cache immediately
    debugPrint('HomeProvider: Attempting instant load from cache...');
    try {
      _movies = _offlineService.getCachedMovies();
    } catch (e) {
      debugPrint('HomeProvider: Cache error: $e');
    }

    // 2. If cache empty, use DUMMY DATA immediately so UI shows something
    if (_movies.isEmpty) {
      debugPrint('HomeProvider: Cache empty, using DUMMY DATA for instant load');
      _movies = _generateDummyMovies();
    }

    // 3. Process the initial data (cache or dummy)
    if (_movies.isNotEmpty) {
      _featuredMovies = _movies.take(5).toList();
      _categorizeMovies();
      // Important: Stop loading state HERE because we have data to show
      _isLoading = false; 
      notifyListeners(); 
    }

    // 4. Fetch fresh data from network in BACKGROUND
    // We don't await this blocking the UI, but we do await it to update state eventually
    debugPrint('HomeProvider: Starting background network fetch...');
    
    try {
      // Use a safety timeout for the network call
      final freshMovies = await _supabaseService.getMovies().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('HomeProvider: Background fetch timed out');
          return []; // Return empty to indicate failure/timeout
        },
      );
      
      if (freshMovies.isNotEmpty) {
        debugPrint('HomeProvider: Background fetch successful (${freshMovies.length} movies)');
        _movies = freshMovies;
        
        // Cache the fresh data
        await _offlineService.cacheMovies(_movies);
        
        // Update UI with fresh data
        _featuredMovies = _movies.take(5).toList();
        _categorizeMovies();
        
        // Ensure loading is false (if it wasn't already)
        _isLoading = false;
        _error = null;
        notifyListeners();
      } else {
         debugPrint('HomeProvider: Background fetch returned empty or timed out. Keeping existing data.');
      }
      
      // Load continue watching
      if (userId != null) {
        try {
           final watching = await _supabaseService.getContinueWatching(userId);
           if (watching.isNotEmpty) {
             _continueWatching = watching;
             notifyListeners();
           }
        } catch (e) {
           debugPrint('HomeProvider: Failed to load continue watching: $e');
        }
      }

    } catch (e) {
      debugPrint('HomeProvider: Background fetch error: $e');
      // No need to show error since we have data shown
    }
    
    // Final safety check: if we are still loading for some reason, stop it
    if (_isLoading) {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _handleError(String message) {
     if (!_isLoading) return; // Already handled

     _error = message;
     _isLoading = false;
     
     // Try to load from cache
     _movies = _offlineService.getCachedMovies();

     // If cache empty, use DUMMY DATA
     if (_movies.isEmpty) {
        _movies = _generateDummyMovies();
     }

     _featuredMovies = _movies.take(5).toList();
     _categorizeMovies();
     
     notifyListeners();
  }

  List<Movie> _generateDummyMovies() {
    return List.generate(10, (index) {
      return Movie(
        id: 'dummy_$index',
        tmdbId: 123 + index,
        title: 'Demo Movie ${index + 1}',
        description: 'This is a demo movie description to show the UI when the backend is unreachable.',
        posterUrl: 'https://placehold.co/500x750/1a1a1a/ffffff.png?text=Movie+${index+1}',
        backdropUrl: 'https://placehold.co/1280x720/1a1a1a/ffffff.png?text=Backdrop+${index+1}',
        s3VideoUrl: 'https://www.w3schools.com/html/mov_bbb.mp4', // Safe sample video
        duration: 7200,
        releaseDate: DateTime.now(), // Use DateTime instead of String
        rating: 8.5,
        genres: ['Action', 'Drama', if (index % 2 == 0) 'Sci-Fi'],
      );
    });
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
