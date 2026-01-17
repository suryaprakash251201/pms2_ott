import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/movie.dart';
import '../../../shared/widgets/widgets.dart';
import '../../player/screens/player_screen.dart';
import '../providers/home_provider.dart';
import '../widgets/widgets.dart';
import 'movie_detail_screen.dart';

/// Home screen with featured content and category sections
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().initialize();
    });
  }

  void _onMovieTap(Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MovieDetailScreen(movie: movie),
      ),
    );
  }

  void _onPlayTap(Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerScreen(movie: movie),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Consumer<HomeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoading();
          }

          if (provider.error != null && provider.movies.isEmpty) {
            return AppErrorWidget(
              message: provider.error!,
              onRetry: () => provider.refresh(),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            color: AppColors.primary,
            child: CustomScrollView(
              slivers: [
                // App bar
                SliverAppBar(
                  floating: true,
                  snap: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(
                    'PMS2 OTT',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        // Navigate to search
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {},
                    ),
                  ],
                ),
                // Content
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Featured carousel
                      if (provider.featuredMovies.isNotEmpty)
                        FeaturedCarousel(
                          movies: provider.featuredMovies,
                          onMovieTap: _onMovieTap,
                          onPlayTap: _onPlayTap,
                        ),

                      const SizedBox(height: 24),

                      // Continue watching
                      if (provider.continueWatching.isNotEmpty) ...[
                        ContinueWatchingSection(
                          items: provider.continueWatching,
                          onMovieTap: (movie, position) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PlayerScreen(
                                  movie: movie,
                                  startPosition: position,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Categories by genre
                      ...provider.getGenres().take(5).map((genre) {
                        final movies = provider.getMoviesByGenre(genre);
                        if (movies.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: CategorySection(
                            title: genre,
                            movies: movies,
                            onMovieTap: _onMovieTap,
                          ),
                        );
                      }),

                      // All movies section
                      if (provider.movies.isNotEmpty)
                        CategorySection(
                          title: 'All Movies',
                          movies: provider.movies,
                          onMovieTap: _onMovieTap,
                        ),

                      const SizedBox(height: 100), // Bottom padding for nav bar
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoading() {
    return SingleChildScrollView(
      child: Column(
        children: const [
          SizedBox(height: 60),
          FeaturedShimmer(),
          SizedBox(height: 24),
          CategoryShimmer(),
          SizedBox(height: 24),
          CategoryShimmer(),
        ],
      ),
    );
  }
}
