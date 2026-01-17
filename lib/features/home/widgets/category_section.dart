import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/movie.dart';
import 'movie_card.dart';

/// Horizontal scrollable category section
class CategorySection extends StatelessWidget {
  final String title;
  final List<Movie> movies;
  final Function(Movie)? onMovieTap;
  final VoidCallback? onSeeAllTap;
  final EdgeInsets? padding;

  const CategorySection({
    super.key,
    required this.title,
    required this.movies,
    this.onMovieTap,
    this.onSeeAllTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (onSeeAllTap != null)
                TextButton(
                  onPressed: onSeeAllTap,
                  child: Row(
                    children: [
                      Text(
                        'See All',
                        style: TextStyle(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: AppColors.textSecondaryDark,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Movies list
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: MovieCard(
                  movie: movie,
                  onTap: () => onMovieTap?.call(movie),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Continue watching section with progress indicator
class ContinueWatchingSection extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final Function(Movie, int)? onMovieTap;

  const ContinueWatchingSection({
    super.key,
    required this.items,
    this.onMovieTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Continue Watching',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final movie = Movie.fromJson(item['movies']);
              final progress = item['watch_position'] as int? ?? 0;
              final duration = movie.duration ?? 1;
              final progressPercent = (progress / duration).clamp(0.0, 1.0);

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _ContinueWatchingCard(
                  movie: movie,
                  progressPercent: progressPercent,
                  onTap: () => onMovieTap?.call(movie, progress),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ContinueWatchingCard extends StatelessWidget {
  final Movie movie;
  final double progressPercent;
  final VoidCallback? onTap;

  const _ContinueWatchingCard({
    required this.movie,
    required this.progressPercent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.cardDark,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with play button
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    movie.backdropUrl ?? movie.posterUrl ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.surfaceDark,
                      child: const Icon(Icons.movie, size: 48),
                    ),
                  ),
                  // Dark overlay
                  Container(
                    color: Colors.black.withOpacity(0.3),
                  ),
                  // Play icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Progress bar
            LinearProgressIndicator(
              value: progressPercent,
              backgroundColor: AppColors.surfaceDark,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 3,
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                movie.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textPrimaryDark,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
