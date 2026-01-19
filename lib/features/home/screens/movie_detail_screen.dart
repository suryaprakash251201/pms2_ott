import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/movie.dart';
import '../../../data/models/actor.dart';
import '../../../data/services/tmdb_service.dart';
import '../../../shared/widgets/cached_image.dart';
import '../../player/screens/player_screen.dart';

/// Hotstar-style Movie Detail Screen
class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({
    super.key,
    required this.movie,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool _isDescriptionExpanded = false;
  List<Actor> _cast = [];
  List<Map<String, dynamic>> _similarMovies = [];
  bool _isLoadingCast = true;
  bool _isLoadingSimilar = true;
  final TMDBService _tmdbService = TMDBService();

  @override
  void initState() {
    super.initState();
    _fetchCastAndCrew();
    _fetchSimilarMovies();
  }

  Future<void> _fetchCastAndCrew() async {
    int tmdbId = widget.movie.tmdbId;
    
    // If no TMDB ID, try searching by title
    if (tmdbId == 0) {
      debugPrint('No TMDB ID, searching by title: ${widget.movie.title}');
      try {
        final searchResults = await _tmdbService.searchMovies(widget.movie.title);
        if (searchResults.isNotEmpty) {
          tmdbId = searchResults.first['id'] as int;
          debugPrint('Found TMDB ID from search: $tmdbId');
        } else {
          debugPrint('No TMDB results found for: ${widget.movie.title}');
          if (mounted) setState(() => _isLoadingCast = false);
          return;
        }
      } catch (e) {
        debugPrint('Error searching TMDB: $e');
        if (mounted) setState(() => _isLoadingCast = false);
        return;
      }
    }

    try {
      debugPrint('Fetching cast for TMDB ID: $tmdbId');
      final credits = await _tmdbService.getMovieCredits(tmdbId);
      
      if (credits != null && credits['cast'] != null) {
        final castList = (credits['cast'] as List).take(10).map((c) {
          return Actor(
            id: c['id'].toString(),
            name: c['name'] ?? 'Unknown',
            profileUrl: c['profile_path'] != null 
                ? 'https://image.tmdb.org/t/p/w185${c['profile_path']}' 
                : null,
            characterName: c['character'],
            role: 'Actor',
          );
        }).toList();
        
        // Also add director from crew
        final crew = credits['crew'] as List?;
        if (crew != null) {
          final director = crew.firstWhere(
            (c) => c['job'] == 'Director',
            orElse: () => null,
          );
          if (director != null) {
            castList.insert(0, Actor(
              id: director['id'].toString(),
              name: director['name'] ?? 'Unknown',
              profileUrl: director['profile_path'] != null 
                  ? 'https://image.tmdb.org/t/p/w185${director['profile_path']}' 
                  : null,
              role: 'Director',
            ));
          }
        }
        
        if (mounted) {
          setState(() {
            _cast = castList;
            _isLoadingCast = false;
          });
        }
      } else {
        debugPrint('No cast data returned from TMDB');
        if (mounted) setState(() => _isLoadingCast = false);
      }
    } catch (e) {
      debugPrint('Error fetching cast: $e');
      if (mounted) setState(() => _isLoadingCast = false);
    }
  }

  Future<void> _fetchSimilarMovies() async {
    int tmdbId = widget.movie.tmdbId;
    
    // If no TMDB ID, try searching by title
    if (tmdbId == 0) {
      debugPrint('No TMDB ID for similar, searching by title: ${widget.movie.title}');
      try {
        final searchResults = await _tmdbService.searchMovies(widget.movie.title);
        if (searchResults.isNotEmpty) {
          tmdbId = searchResults.first['id'] as int;
          debugPrint('Found TMDB ID from search for similar: $tmdbId');
        } else {
          debugPrint('No TMDB results found for similar: ${widget.movie.title}');
          if (mounted) setState(() => _isLoadingSimilar = false);
          return;
        }
      } catch (e) {
        debugPrint('Error searching TMDB for similar: $e');
        if (mounted) setState(() => _isLoadingSimilar = false);
        return;
      }
    }

    try {
      debugPrint('Fetching similar movies for TMDB ID: $tmdbId');
      final similar = await _tmdbService.getSimilarMovies(tmdbId);
      
      if (mounted) {
        setState(() {
          _similarMovies = similar.take(10).toList();
          _isLoadingSimilar = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching similar movies: $e');
      if (mounted) setState(() => _isLoadingSimilar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeroSection(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildTitleAndMetadata(context),
                  const SizedBox(height: 24),
                  _buildActionButtons(context),
                  const SizedBox(height: 24),
                  _buildSynopsis(context),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Cast & Crew'),
                  const SizedBox(height: 16),
                  _buildCastList(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('More Like This'),
                  const SizedBox(height: 16),
                  _buildSimilarList(),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 450,
      pinned: true,
      backgroundColor: AppColors.backgroundDark,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white, shadows: [
           Shadow(blurRadius: 10, color: Colors.black),
        ]),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
         IconButton(
          icon: const Icon(Icons.cast, color: Colors.white, shadows: [
             Shadow(blurRadius: 10, color: Colors.black),
          ]),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'movie_${widget.movie.id}',
              child: CachedImage(
                imageUrl: widget.movie.backdropUrl ?? widget.movie.posterUrl,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    AppColors.backgroundDark.withOpacity(0.8),
                    AppColors.backgroundDark,
                  ],
                  stops: const [0.0, 0.4, 0.85, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleAndMetadata(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          widget.movie.title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMetadataBadge(widget.movie.releaseYear),
            const SizedBox(width: 8),
            const Text('•', style: TextStyle(color: Colors.white54)),
            const SizedBox(width: 8),
            _buildGenresText(),
            const SizedBox(width: 8),
            const Text('•', style: TextStyle(color: Colors.white54)),
            const SizedBox(width: 8),
            _buildMetadataBadge('U/A 13+'),
          ],
        ),
        const SizedBox(height: 8),
         if (widget.movie.formattedDuration.isNotEmpty)
          Text(
            widget.movie.formattedDuration,
             style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
      ],
    );
  }
  
  Widget _buildGenresText() {
     if (widget.movie.genres.isEmpty) return const SizedBox();
     final genres = widget.movie.genres.take(3).join(' • ');
     return Text(
       genres,
       style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
     );
  }

  Widget _buildMetadataBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
         SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlayerScreen(movie: widget.movie),
                ),
              );
            },
            icon: const Icon(Icons.play_arrow_rounded, size: 28),
            label: const Text(
              'Watch Now',
               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download_rounded),
            label: const Text('Download'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.15),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSynopsis(BuildContext context) {
    final description = widget.movie.description ?? 'No description available.';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          description,
          maxLines: _isDescriptionExpanded ? null : 3,
          overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textSecondaryDark,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        if (description.length > 100)
          GestureDetector(
            onTap: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _isDescriptionExpanded ? 'Less' : 'More',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCastList() {
    if (_isLoadingCast) {
      return SizedBox(
        height: 120,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (context, index) => _buildCastShimmer(),
        ),
      );
    }

    if (_cast.isEmpty) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: Text(
            'Cast information not available',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _cast.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final actor = _cast[index];
          return Column(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.cardDark,
                  image: actor.profileUrl != null
                      ? DecorationImage(
                          image: NetworkImage(actor.profileUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: actor.profileUrl == null
                    ? const Icon(Icons.person, color: Colors.white54)
                    : null,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 80,
                child: Column(
                  children: [
                    Text(
                      actor.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    if (actor.role != null && actor.role != 'Actor')
                      Text(
                        actor.role!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCastShimmer() {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.cardDark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 12,
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildSimilarList() {
    if (_isLoadingSimilar) {
      return SizedBox(
        height: 180,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) => Container(
            width: 120,
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    }

    if (_similarMovies.isEmpty) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: Text(
            'No similar movies found',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _similarMovies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final movie = _similarMovies[index];
          final posterPath = movie['poster_path'];
          final posterUrl = posterPath != null 
              ? 'https://image.tmdb.org/t/p/w500$posterPath'
              : '';
          
          return GestureDetector(
            onTap: () {
              // Create a temporary Movie object for navigation
              final similarMovie = Movie(
                id: 'tmdb_${movie['id']}',
                tmdbId: movie['id'] ?? 0,
                title: movie['title'] ?? 'Unknown',
                description: movie['overview'],
                posterUrl: posterUrl,
                backdropUrl: movie['backdrop_path'] != null
                    ? 'https://image.tmdb.org/t/p/w1280${movie['backdrop_path']}'
                    : posterUrl,
                s3VideoUrl: '', // No video URL for similar movies
                rating: (movie['vote_average'] as num?)?.toDouble(),
              );
              
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: similarMovie)),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 120,
                height: 160,
                child: posterUrl.isNotEmpty
                    ? CachedImage(imageUrl: posterUrl, fit: BoxFit.cover)
                    : Container(
                        color: AppColors.cardDark,
                        child: const Icon(Icons.movie, color: Colors.white54),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
