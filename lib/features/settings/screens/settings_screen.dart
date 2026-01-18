import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/services.dart';
import '../../home/providers/home_provider.dart';
import '../providers/settings_provider.dart';

/// Settings screen for app preferences
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use theme colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Content Management section
              _buildSectionHeader(context, 'Content Management'),
              _buildSettingsTile(
                context,
                icon: Icons.add_circle_outline,
                iconColor: AppColors.success,
                title: 'Add Movie',
                subtitle: 'Add a new movie from S3 and TMDB',
                onTap: () => _showAddMovieDialog(context),
              ),
              _buildSettingsTile(
                context,
                icon: Icons.refresh,
                title: 'Refresh Movies',
                subtitle: 'Reload movies from server',
                onTap: () => _refreshMovies(context),
              ),
              const Divider(),

              // Appearance section
              _buildSectionHeader(context, 'Appearance'),
              _buildSettingsTile(
                context,
                icon: isDark ? Icons.dark_mode : Icons.light_mode,
                title: 'Dark Mode',
                subtitle: provider.isDarkMode ? 'Dark theme enabled' : 'Light theme enabled',
                trailing: Switch(
                  value: provider.isDarkMode,
                  onChanged: (_) => provider.toggleTheme(),
                  activeColor: AppColors.primary,
                ),
              ),
              const Divider(),

              // Playback section
              _buildSectionHeader(context, 'Playback'),
              _buildSettingsTile(
                context,
                icon: Icons.high_quality,
                title: 'Video Quality',
                subtitle: provider.videoQuality.toUpperCase(),
                onTap: () => _showQualityDialog(context, provider),
              ),
              _buildSettingsTile(
                context,
                icon: Icons.play_arrow,
                title: 'Autoplay',
                subtitle: 'Play next video automatically',
                trailing: Switch(
                  value: provider.autoplay,
                  onChanged: (_) => provider.toggleAutoplay(),
                  activeColor: AppColors.primary,
                ),
              ),
              const Divider(),

              // Storage section
              _buildSectionHeader(context, 'Storage'),
              _buildSettingsTile(
                context,
                icon: Icons.storage,
                title: 'Cache Size',
                subtitle: provider.cacheSize,
              ),
              _buildSettingsTile(
                context,
                icon: Icons.delete_outline,
                title: 'Clear Cache',
                subtitle: 'Free up storage space',
                onTap: () => _showClearCacheDialog(context, provider),
              ),
              const Divider(),

              // About section
              _buildSectionHeader(context, 'About'),
              _buildSettingsTile(
                context,
                icon: Icons.info_outline,
                title: 'App Version',
                subtitle: '1.0.0',
              ),
              _buildSettingsTile(
                context,
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                onTap: () {},
              ),
              _buildSettingsTile(
                context,
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () {},
              ),
              const Divider(),

              // Danger zone
              _buildSectionHeader(context, 'Data'),
              _buildSettingsTile(
                context,
                icon: Icons.warning_outlined,
                iconColor: AppColors.error,
                title: 'Clear All Data',
                subtitle: 'Remove all cached data and settings',
                onTap: () => _showClearAllDataDialog(context, provider),
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppColors.primary,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: theme.textTheme.bodySmall,
            )
          : null,
      trailing: trailing ??
          (onTap != null
              ? Icon(
                  Icons.chevron_right,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                )
              : null),
      onTap: onTap,
    );
  }

  Future<void> _refreshMovies(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Text('Refreshing movies...'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 1),
      ),
    );

    final homeProvider = context.read<HomeProvider>();
    await homeProvider.refresh();

    if (homeProvider.error != null) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to refresh: ${homeProvider.error}'),
          backgroundColor: AppColors.error,
        ),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Movies refreshed! Found ${homeProvider.movies.length} movies.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _showAddMovieDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AddMovieDialog(
        onMovieAdded: () {
          // Refresh home screen after adding a movie
          context.read<HomeProvider>().refresh();
        },
      ),
    );
  }

  void _showQualityDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Video Quality'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: provider.qualityOptions.map((quality) {
            return RadioListTile<String>(
              value: quality,
              groupValue: provider.videoQuality,
              title: Text(quality.toUpperCase()),
              activeColor: AppColors.primary,
              onChanged: (value) {
                if (value != null) {
                  provider.setVideoQuality(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache?'),
        content: const Text(
          'This will remove all cached movie data. You will need to re-download content for offline use.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.clearCache();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDataDialog(
      BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will remove all app data including cache, settings, and preferences. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.clearAllData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All data cleared'),
                  backgroundColor: AppColors.warning,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

/// Dialog for adding a new movie
class AddMovieDialog extends StatefulWidget {
  final VoidCallback? onMovieAdded;

  const AddMovieDialog({super.key, this.onMovieAdded});

  @override
  State<AddMovieDialog> createState() => _AddMovieDialogState();
}

class _AddMovieDialogState extends State<AddMovieDialog> {
  final _formKey = GlobalKey<FormState>();
  final _movieNameController = TextEditingController();
  final _s3UrlController = TextEditingController();
  final _tmdbService = TMDBService();
  final _supabaseService = SupabaseService();

  bool _isSearching = false;
  bool _isSaving = false;
  List<Map<String, dynamic>> _searchResults = [];
  Map<String, dynamic>? _selectedMovie;

  @override
  void dispose() {
    _movieNameController.dispose();
    _s3UrlController.dispose();
    super.dispose();
  }

  Future<void> _searchMovie() async {
    if (_movieNameController.text.isEmpty) return;
    
    // Close keyboard via focus scope
    FocusScope.of(context).unfocus();

    setState(() {
      _isSearching = true;
      _searchResults = [];
      _selectedMovie = null;
    });

    try {
      final results = await _tmdbService.searchMovies(_movieNameController.text);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e')),
        );
      }
    }
  }

  Future<void> _saveMovie() async {
    if (_selectedMovie == null || _s3UrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a movie and enter S3 URL')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final tmdbId = _selectedMovie!['id'] as int;
      final s3Url = _s3UrlController.text.trim();

      final movie = await _supabaseService.addMovie(
        tmdbId: tmdbId,
        s3VideoUrl: s3Url,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onMovieAdded?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Movie "${movie.title}" added successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add movie: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.movie_creation, color: AppColors.success),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Add New Movie',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // S3 URL input
              TextFormField(
                controller: _s3UrlController,
                decoration: const InputDecoration(
                  labelText: 'S3 Video URL',
                  hintText: 'https://s3.in-west3.purestore.io/your-video.mp4',
                  prefixIcon: Icon(Icons.link),
                  filled: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter S3 video URL';
                  }
                  if (!value.startsWith('http')) {
                    return 'Please enter a valid URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Movie search
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _movieNameController,
                      decoration: const InputDecoration(
                        labelText: 'Search Movie Name',
                        hintText: 'Enter movie title...',
                        prefixIcon: Icon(Icons.search),
                        filled: true,
                      ),
                      onFieldSubmitted: (_) => _searchMovie(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSearching ? null : _searchMovie,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    child: _isSearching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Search'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Search results
              if (_isSearching)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_searchResults.isNotEmpty)
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final movie = _searchResults[index];
                        final isSelected = _selectedMovie == movie;
                        final posterPath = movie['poster_path'];
                        final releaseDate = movie['release_date'] as String?;
                        final year = releaseDate != null && releaseDate.length >= 4
                            ? releaseDate.substring(0, 4)
                            : '';

                        return ListTile(
                          selected: isSelected,
                          selectedTileColor: AppColors.primary.withOpacity(0.1),
                          leading: posterPath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    'https://image.tmdb.org/t/p/w92$posterPath',
                                    width: 40,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.movie, size: 40),
                                  ),
                                )
                              : const Icon(Icons.movie, size: 40),
                          title: Text(
                            movie['title'] ?? 'Unknown',
                            style: TextStyle(
                              color: isSelected ? AppColors.primary : theme.textTheme.bodyMedium?.color,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(year),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle, color: AppColors.success)
                              : null,
                          onTap: () {
                            setState(() => _selectedMovie = movie);
                          },
                        );
                      },
                    ),
                  ),
                )
              else if (_movieNameController.text.isNotEmpty && !_isSearching)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('No movies found. Try another search.'),
                  ),
                ),

              // Selected movie preview
              if (_selectedMovie != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.success.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selected: ${_selectedMovie!['title']}',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'TMDB ID: ${_selectedMovie!['id']}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isSaving || _selectedMovie == null
                        ? null
                        : _saveMovie,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(_isSaving ? 'Saving...' : 'Add Movie'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
