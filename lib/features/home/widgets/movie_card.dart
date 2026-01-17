import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/movie.dart';
import '../../../shared/widgets/cached_image.dart';

/// Individual movie card widget
class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onTap;
  final double width;
  final double height;
  final bool showTitle;
  final bool showRating;

  const MovieCard({
    super.key,
    required this.movie,
    this.onTap,
    this.width = 120,
    this.height = 180,
    this.showTitle = true,
    this.showRating = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Poster image
            Stack(
              children: [
                Hero(
                  tag: 'movie_${movie.id}',
                  child: CachedImage(
                    imageUrl: movie.posterUrl,
                    width: width,
                    height: height,
                    borderRadius: 8,
                  ),
                ),
                // Rating badge
                if (showRating && movie.rating != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            movie.rating!.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            // Title - constrained to prevent overflow
            if (showTitle) ...[
              const SizedBox(height: 6),
              SizedBox(
                height: 32, // Fixed height for title
                child: Text(
                  movie.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontSize: 11,
                        height: 1.2,
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Gradient overlay widget
class GradientOverlay extends StatelessWidget {
  final Widget child;
  
  const GradientOverlay({super.key, required this.child});
  
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
          stops: const [0.5, 1.0],
        ).createShader(rect);
      },
      blendMode: BlendMode.darken,
      child: child,
    );
  }
}

/// Large movie card for featured/highlighted content
class LargeMovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onTap;
  final VoidCallback? onPlayTap;

  const LargeMovieCard({
    super.key,
    required this.movie,
    this.onTap,
    this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Stack(
          children: [
            // Backdrop image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GradientOverlay(
                child: CachedImage(
                  imageUrl: movie.backdropUrl ?? movie.posterUrl,
                  width: double.infinity,
                  height: 200,
                ),
              ),
            ),
            // Content overlay
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (movie.rating != null) ...[
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          movie.rating!.toStringAsFixed(1),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (movie.releaseYear.isNotEmpty) ...[
                        Text(
                          movie.releaseYear,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (movie.formattedDuration.isNotEmpty)
                        Text(
                          movie.formattedDuration,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Play button
                  ElevatedButton.icon(
                    onPressed: onPlayTap ?? onTap,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Play'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
