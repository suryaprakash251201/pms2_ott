import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/widgets.dart';
import '../../home/widgets/movie_card.dart';
import '../../player/screens/player_screen.dart';
import '../providers/playlist_provider.dart';

/// Playlist detail screen showing all movies in a playlist
class PlaylistDetailScreen extends StatefulWidget {
  final String playlistId;

  const PlaylistDetailScreen({
    super.key,
    required this.playlistId,
  });

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlaylistProvider>().loadPlaylistDetails(widget.playlistId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, provider, child) {
        final playlist = provider.selectedPlaylist;

        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: CustomScrollView(
            slivers: [
              // App bar with playlist info
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppColors.backgroundDark,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    playlist?.name ?? 'Loading...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withOpacity(0.8),
                          AppColors.backgroundDark,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.playlist_play,
                        size: 80,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
                actions: [
                  if (playlist != null)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) async {
                        if (value == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: AppColors.cardDark,
                              title: const Text(
                                'Delete Playlist?',
                                style: TextStyle(color: Colors.white),
                              ),
                              content: const Text(
                                'This action cannot be undone.',
                                style: TextStyle(
                                    color: AppColors.textSecondaryDark),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true && mounted) {
                            await provider.deletePlaylist(widget.playlistId);
                            Navigator.pop(context);
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: AppColors.error),
                              SizedBox(width: 8),
                              Text('Delete Playlist'),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              // Content
              if (provider.isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (provider.error != null)
                SliverFillRemaining(
                  child: AppErrorWidget(
                    message: provider.error!,
                    onRetry: () =>
                        provider.loadPlaylistDetails(widget.playlistId),
                  ),
                )
              else if (playlist == null || playlist.movies.isEmpty)
                const SliverFillRemaining(
                  child: EmptyStateWidget(
                    message: 'No movies in this playlist yet.',
                    icon: Icons.movie_outlined,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final movie = playlist.movies[index];
                        return Dismissible(
                          key: Key(movie.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: AppColors.error,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) {
                            provider.removeMovieFromPlaylist(
                              widget.playlistId,
                              movie.id,
                            );
                          },
                          child: Card(
                            color: AppColors.cardDark,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(8),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  movie.posterUrl ?? '',
                                  width: 50,
                                  height: 75,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 50,
                                    height: 75,
                                    color: AppColors.surfaceDark,
                                    child: const Icon(Icons.movie),
                                  ),
                                ),
                              ),
                              title: Text(
                                movie.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (movie.releaseYear.isNotEmpty)
                                    Text(
                                      movie.releaseYear,
                                      style: const TextStyle(
                                        color: AppColors.textSecondaryDark,
                                      ),
                                    ),
                                  if (movie.formattedDuration.isNotEmpty)
                                    Text(
                                      movie.formattedDuration,
                                      style: const TextStyle(
                                        color: AppColors.textSecondaryDark,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.play_circle_fill,
                                  color: AppColors.primary,
                                  size: 40,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          PlayerScreen(movie: movie),
                                    ),
                                  );
                                },
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PlayerScreen(movie: movie),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                      childCount: playlist.movies.length,
                    ),
                  ),
                ),
            ],
          ),
          // Play all button
          floatingActionButton: playlist != null && playlist.movies.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: () {
                    // Play first movie
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PlayerScreen(movie: playlist.movies.first),
                      ),
                    );
                  },
                  backgroundColor: AppColors.primary,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play All'),
                )
              : null,
        );
      },
    );
  }
}
