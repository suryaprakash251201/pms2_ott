import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/movie.dart';
import '../../../shared/widgets/cached_image.dart';

/// Featured movies carousel for the home screen
class FeaturedCarousel extends StatefulWidget {
  final List<Movie> movies;
  final Function(Movie)? onMovieTap;
  final Function(Movie)? onPlayTap;

  const FeaturedCarousel({
    super.key,
    required this.movies,
    this.onMovieTap,
    this.onPlayTap,
  });

  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 450,
          child: Swiper(
            itemCount: widget.movies.length,
            autoplay: true,
            autoplayDelay: 5000,
            onIndexChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final movie = widget.movies[index];
              return _FeaturedItem(
                movie: movie,
                onTap: () => widget.onMovieTap?.call(movie),
                onPlayTap: () => widget.onPlayTap?.call(movie),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        AnimatedSmoothIndicator(
          activeIndex: _currentIndex,
          count: widget.movies.length,
          effect: const ExpandingDotsEffect(
            dotHeight: 8,
            dotWidth: 8,
            activeDotColor: AppColors.primary,
            dotColor: AppColors.textSecondaryDark,
          ),
        ),
      ],
    );
  }
}

class _FeaturedItem extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onTap;
  final VoidCallback? onPlayTap;

  const _FeaturedItem({
    required this.movie,
    this.onTap,
    this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Backdrop image with gradient
          ShaderMask(
            shaderCallback: (rect) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.8),
                  AppColors.backgroundDark,
                ],
                stops: const [0.0, 0.4, 0.75, 1.0],
              ).createShader(rect);
            },
            blendMode: BlendMode.darken,
            child: CachedImage(
              imageUrl: movie.backdropUrl ?? movie.posterUrl,
              fit: BoxFit.cover,
            ),
          ),
          // Content overlay
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  movie.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          const Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                ),
                const SizedBox(height: 8),
                // Metadata row
                Row(
                  children: [
                    if (movie.rating != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              movie.rating!.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (movie.releaseYear.isNotEmpty) ...[
                      Text(
                        movie.releaseYear,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (movie.formattedDuration.isNotEmpty) ...[
                      const Icon(
                        Icons.access_time,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        movie.formattedDuration,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                // Genres
                if (movie.genres.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children: movie.genres.take(3).map((genre) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          genre,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 16),
                // Description
                if (movie.description != null &&
                    movie.description!.isNotEmpty) ...[
                  Text(
                    movie.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onPlayTap,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Play'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        tooltip: 'Add to My List',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: IconButton(
                        onPressed: onTap,
                        icon: const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                        ),
                        tooltip: 'More Info',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
