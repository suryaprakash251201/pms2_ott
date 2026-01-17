/// Model for user's saved movies list (My List)
class MyListItem {
  final String id;
  final String userId;
  final String movieId;
  final DateTime addedAt;

  MyListItem({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.addedAt,
  });

  factory MyListItem.fromJson(Map<String, dynamic> json) {
    return MyListItem(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      movieId: json['movie_id'] as String,
      addedAt: json['added_at'] != null
          ? DateTime.parse(json['added_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'movie_id': movieId,
      'added_at': addedAt.toIso8601String(),
    };
  }
}
