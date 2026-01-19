import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/movie.dart';
import '../widgets/custom_player_controls.dart';

/// Full-screen video player screen using media_kit with custom controls
class PlayerScreen extends StatefulWidget {
  final Movie movie;
  final int? startPosition;

  const PlayerScreen({
    super.key,
    required this.movie,
    this.startPosition,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final Player _player;
  late final VideoController _controller;
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    
    // Lock to landscape for video playback
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Hide system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      // Create player instance with configuration for faster startup
      _player = Player(
        configuration: const PlayerConfiguration(
          // Buffer settings for faster start
          bufferSize: 32 * 1024 * 1024, // 32MB buffer
        ),
      );
      _controller = VideoController(_player);

      // Show UI immediately - don't wait for video to fully load
      if (mounted) {
        setState(() => _isInitialized = true);
      }

      // Listen for errors
      _player.stream.error.listen((error) {
        debugPrint('Player error: $error');
        if (mounted) {
          setState(() => _error = error);
        }
      });

      // Open the video
      final videoUrl = widget.movie.s3VideoUrl;
      debugPrint('PlayerScreen: Opening video URL: $videoUrl');
      
      if (videoUrl.isEmpty) {
        throw Exception('Video URL is empty');
      }
      
      // Open and play immediately - don't await sequentially 
      await _player.open(
        Media(videoUrl),
        play: true, // Start playing immediately on open
      );

      // Seek to start position if provided (after playback starts)
      if (widget.startPosition != null && widget.startPosition! > 0) {
        await _player.seek(Duration(seconds: widget.startPosition!));
      }
    } catch (e) {
      debugPrint('Player init error: $e');
      if (mounted) {
        setState(() => _error = e.toString());
      }
    }
  }

  void _retryPlayback() {
    setState(() {
      _isInitialized = false;
      _error = null;
    });
    _player.dispose();
    _initializePlayer();
  }

  void _saveProgress() {
    if (!_isInitialized) return;
    // Save progress via provider
    final position = _player.state.position.inSeconds;
    debugPrint('Saving progress: $position seconds');
  }

  @override
  void dispose() {
    _saveProgress();
    
    // Reset orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Show system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video player
          if (_isInitialized)
            Center(
              child: Video(
                controller: _controller,
                controls: NoVideoControls, // Use our custom controls
              ),
            )
          else if (_error != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.error_outline, color: AppColors.error, size: 64),
                   const SizedBox(height: 16),
                   Text(
                     'Error loading video',
                     style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                   ),
                   const SizedBox(height: 8),
                   Text(
                     _error!,
                     style: const TextStyle(color: AppColors.textSecondaryDark),
                   ),
                   const SizedBox(height: 24),
                   ElevatedButton.icon(
                     onPressed: _retryPlayback,
                     icon: const Icon(Icons.refresh),
                     label: const Text('Retry'),
                   ),
                ],
              ),
            )
          else
            const Center(
               child: CircularProgressIndicator(color: AppColors.primary),
            ),
            
          // Custom Controls Overlay
          if (_isInitialized)
            CustomPlayerControls(
              player: _player,
              controller: _controller,
              title: widget.movie.title,
              onBack: () => Navigator.pop(context),
            ),
        ],
      ),
    );
  }
}
