import 'package:hive/hive.dart';

part 'actor.g.dart';

@HiveType(typeId: 1)
class Actor extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? profileUrl;

  @HiveField(3)
  final String? characterName;

  @HiveField(4)
  final String? role; // 'Actor', 'Director', etc.

  Actor({
    required this.id,
    required this.name,
    this.profileUrl,
    this.characterName,
    this.role = 'Actor',
  });

  factory Actor.fromJson(Map<String, dynamic> json) {
    return Actor(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      profileUrl: json['profile_path'] != null 
          ? 'https://image.tmdb.org/t/p/w185${json['profile_path']}' 
          : null,
      characterName: json['character'],
      role: json['known_for_department'] ?? 'Actor',
    );
  }
}
