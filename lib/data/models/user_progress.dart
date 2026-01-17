/// User progress model for tracking watch history
class UserProgress {
  final String id;
  final String userId;
  final String movieId;
  final int watchPosition; // in seconds
  final bool isCompleted;
  final DateTime lastWatched;

  UserProgress({
    required this.id,
    required this.userId,
    required this.movieId,
    this.watchPosition = 0,
    this.isCompleted = false,
    required this.lastWatched,
  });

  /// Create UserProgress from Supabase JSON response
  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      movieId: json['movie_id'] as String,
      watchPosition: json['watch_position'] as int? ?? 0,
      isCompleted: json['is_completed'] as bool? ?? false,
      lastWatched: json['last_watched'] != null
          ? DateTime.parse(json['last_watched'] as String)
          : DateTime.now(),
    );
  }

  /// Convert UserProgress to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'movie_id': movieId,
      'watch_position': watchPosition,
      'is_completed': isCompleted,
      'last_watched': lastWatched.toIso8601String(),
    };
  }

  /// Get formatted watch position (e.g., "45:30")
  String get formattedPosition {
    final hours = watchPosition ~/ 3600;
    final minutes = (watchPosition % 3600) ~/ 60;
    final seconds = watchPosition % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Calculate progress percentage (requires movie duration)
  double getProgressPercentage(int? movieDuration) {
    if (movieDuration == null || movieDuration == 0) return 0;
    return (watchPosition / movieDuration).clamp(0.0, 1.0);
  }

  /// Copy with new values
  UserProgress copyWith({
    String? id,
    String? userId,
    String? movieId,
    int? watchPosition,
    bool? isCompleted,
    DateTime? lastWatched,
  }) {
    return UserProgress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      movieId: movieId ?? this.movieId,
      watchPosition: watchPosition ?? this.watchPosition,
      isCompleted: isCompleted ?? this.isCompleted,
      lastWatched: lastWatched ?? this.lastWatched,
    );
  }

  @override
  String toString() =>
      'UserProgress(movieId: $movieId, position: $watchPosition, completed: $isCompleted)';
}
