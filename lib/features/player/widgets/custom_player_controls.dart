import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../../core/theme/app_colors.dart';

/// Custom video player controls overlay with Hotstar-style UI
class CustomPlayerControls extends StatefulWidget {
  final Player player;
  final VideoController controller;
  final String title;
  final VoidCallback onBack;

  const CustomPlayerControls({
    super.key,
    required this.player,
    required this.controller,
    required this.title,
    required this.onBack,
  });

  @override
  State<CustomPlayerControls> createState() => _CustomPlayerControlsState();
}

class _CustomPlayerControlsState extends State<CustomPlayerControls> {
  bool _isVisible = true;
  bool _isBuffering = false;
  bool _isLocked = false;
  double _currentVolume = 100.0;
  bool _showVolumeSlider = false;
  Timer? _hideTimer;
  Timer? _volumeSliderTimer;
  bool _isLandscape = true;
  
  // Playback speed options
  final List<double> _speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  double _currentSpeed = 1.0;
  
  // Quality options
  final List<String> _qualityOptions = ['Auto', '1080p', '720p', '480p'];
  String _selectedQuality = 'Auto';

  @override
  void initState() {
    super.initState();
    _startHideTimer();
    
    // Listen to buffering state
    widget.player.stream.buffering.listen((buffering) {
      if (mounted) setState(() => _isBuffering = buffering);
    });
    
    // Listen to volume changes
    widget.player.stream.volume.listen((volume) {
      if (mounted) setState(() => _currentVolume = volume);
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _volumeSliderTimer?.cancel();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && widget.player.state.playing) {
        setState(() => _isVisible = false);
      }
    });
  }

  void _toggleControls() {
    if (_isLocked) {
      setState(() => _isVisible = !_isVisible);
      if (_isVisible) _startHideTimer();
      return;
    }
    setState(() => _isVisible = !_isVisible);
    if (_isVisible) {
      _startHideTimer();
    } else {
      _hideTimer?.cancel();
    }
  }

  void _onUserInteraction() {
    setState(() => _isVisible = true);
    _startHideTimer();
  }

  void _toggleLock() {
    setState(() => _isLocked = !_isLocked);
    _onUserInteraction();
  }

  void _setVolume(double volume) {
    setState(() => _currentVolume = volume);
    widget.player.setVolume(volume);
    _onUserInteraction();
    _resetVolumeSliderTimer();
  }

  void _toggleVolumeSlider() {
    setState(() => _showVolumeSlider = !_showVolumeSlider);
    if (_showVolumeSlider) {
      _resetVolumeSliderTimer();
    }
    _onUserInteraction();
  }

  void _resetVolumeSliderTimer() {
    _volumeSliderTimer?.cancel();
    _volumeSliderTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showVolumeSlider = false);
    });
  }

  void _setSpeed(double speed) {
    setState(() => _currentSpeed = speed);
    widget.player.setRate(speed);
    _onUserInteraction();
  }

  void _toggleOrientation() {
    setState(() => _isLandscape = !_isLandscape);
    if (_isLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    _onUserInteraction();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleControls,
      onDoubleTapDown: (details) {
        if (_isLocked) return;
        final screenWidth = MediaQuery.of(context).size.width;
        final tapX = details.globalPosition.dx;
        
        if (tapX < screenWidth / 3) {
          widget.player.seek(widget.player.state.position - const Duration(seconds: 10));
          _showSeekAnimation(context, false);
        } else if (tapX > screenWidth * 2 / 3) {
          widget.player.seek(widget.player.state.position + const Duration(seconds: 10));
          _showSeekAnimation(context, true);
        }
        _onUserInteraction();
      },
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          // Buffering indicator
          if (_isBuffering)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),

          // Volume Slider Overlay (left side)
          if (_showVolumeSlider)
            Positioned(
              left: 24,
              top: 0,
              bottom: 0,
              child: Center(
                child: _buildVolumeSlider(),
              ),
            ),

          // Main Controls Overlay
          AnimatedOpacity(
            opacity: _isVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: IgnorePointer(
              ignoring: !_isVisible,
              child: _isLocked 
                ? _buildLockedOverlay()
                : _buildFullControls(),
            ),
          ),
        ],
      ),
    );
  }

  void _showSeekAnimation(BuildContext context, bool forward) {
    final overlay = OverlayEntry(
      builder: (context) => Positioned(
        left: forward ? null : 50,
        right: forward ? 50 : null,
        top: 0,
        bottom: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              forward ? Icons.forward_10 : Icons.replay_10,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
      ),
    );
    
    Overlay.of(context).insert(overlay);
    Future.delayed(const Duration(milliseconds: 500), () => overlay.remove());
  }

  Widget _buildVolumeSlider() {
    return Container(
      width: 40,
      height: 200,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            _currentVolume == 0 ? Icons.volume_off : Icons.volume_up,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RotatedBox(
              quarterTurns: 3,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: Colors.white24,
                  thumbColor: AppColors.primary,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: _currentVolume,
                  min: 0,
                  max: 100,
                  onChanged: _setVolume,
                ),
              ),
            ),
          ),
          Text(
            '${_currentVolume.toInt()}%',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedOverlay() {
    return Container(
      color: Colors.black26,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: IconButton(
            icon: const Icon(Icons.lock_open, color: Colors.white, size: 32),
            onPressed: _toggleLock,
            tooltip: 'Unlock',
          ),
        ),
      ),
    );
  }

  Widget _buildFullControls() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black87,
            Colors.transparent,
            Colors.transparent,
            Colors.black87,
          ],
          stops: [0.0, 0.2, 0.8, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            const Spacer(),
            _buildCenterControls(),
            const Spacer(),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: widget.onBack,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Cast button
          IconButton(
            icon: const Icon(Icons.cast, color: Colors.white),
            onPressed: _showCastDialog,
            tooltip: 'Cast',
          ),
          // Subtitles button
          IconButton(
            icon: const Icon(Icons.subtitles_outlined, color: Colors.white),
            onPressed: _showSubtitlesDialog,
            tooltip: 'Subtitles',
          ),
          _buildSettingsMenu(),
        ],
      ),
    );
  }

  void _showCastDialog() {
    _onUserInteraction();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cast to Device',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.tv, color: Colors.white),
              title: const Text('Searching for devices...', style: TextStyle(color: Colors.white70)),
              subtitle: const Text('Make sure your device is on the same network', style: TextStyle(color: Colors.white54, fontSize: 12)),
            ),
            const SizedBox(height: 16),
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSubtitlesDialog() {
    _onUserInteraction();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Subtitles',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.check, color: AppColors.primary),
              title: const Text('Off', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const SizedBox(width: 24),
              title: const Text('English', style: TextStyle(color: Colors.white70)),
              subtitle: const Text('Coming soon', style: TextStyle(color: Colors.white54, fontSize: 12)),
              onTap: () {},
            ),
            ListTile(
              leading: const SizedBox(width: 24),
              title: const Text('Hindi', style: TextStyle(color: Colors.white70)),
              subtitle: const Text('Coming soon', style: TextStyle(color: Colors.white54, fontSize: 12)),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsMenu() {
    return PopupMenuButton<String>(
      color: const Color(0xFF1E1E1E),
      icon: const Icon(Icons.settings_outlined, color: Colors.white),
      onOpened: _onUserInteraction,
      itemBuilder: (context) => [
        const PopupMenuItem(
          enabled: false,
          height: 30,
          child: Text('Quality', style: TextStyle(color: Colors.white54, fontSize: 12)),
        ),
        ..._qualityOptions.map((q) => PopupMenuItem(
          value: 'quality_$q',
          height: 40,
          child: Row(
            children: [
              if (_selectedQuality == q) 
                const Icon(Icons.check, color: AppColors.primary, size: 16)
              else
                const SizedBox(width: 16),
              const SizedBox(width: 8),
              Text(q, style: TextStyle(color: _selectedQuality == q ? AppColors.primary : Colors.white)),
            ],
          ),
        )),
        const PopupMenuDivider(),
        const PopupMenuItem(
          enabled: false,
          height: 30,
          child: Text('Playback Speed', style: TextStyle(color: Colors.white54, fontSize: 12)),
        ),
        ..._speedOptions.map((s) => PopupMenuItem(
          value: 'speed_$s',
          height: 40,
          child: Row(
            children: [
              if (_currentSpeed == s) 
                const Icon(Icons.check, color: AppColors.primary, size: 16)
              else
                const SizedBox(width: 16),
              const SizedBox(width: 8),
              Text('${s}x', style: TextStyle(color: _currentSpeed == s ? AppColors.primary : Colors.white)),
            ],
          ),
        )),
      ],
      onSelected: (value) {
        if (value.startsWith('quality_')) {
          setState(() => _selectedQuality = value.replaceFirst('quality_', ''));
        } else if (value.startsWith('speed_')) {
          final speed = double.parse(value.replaceFirst('speed_', ''));
          _setSpeed(speed);
        }
        _onUserInteraction();
      },
    );
  }

  Widget _buildCenterControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          iconSize: 48,
          icon: const Icon(Icons.replay_10_rounded, color: Colors.white),
          onPressed: () {
            widget.player.seek(widget.player.state.position - const Duration(seconds: 10));
            _onUserInteraction();
          },
        ),
        const SizedBox(width: 48),
        
        StreamBuilder<bool>(
          stream: widget.player.stream.playing,
          builder: (context, snapshot) {
            final isPlaying = snapshot.data ?? false;
            return GestureDetector(
              onTap: () {
                if (isPlaying) {
                  widget.player.pause();
                } else {
                  widget.player.play();
                }
                _onUserInteraction();
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 64,
                ),
              ),
            );
          },
        ),
        
        const SizedBox(width: 48),
        
        IconButton(
          iconSize: 48,
          icon: const Icon(Icons.forward_10_rounded, color: Colors.white),
          onPressed: () {
            widget.player.seek(widget.player.state.position + const Duration(seconds: 10));
            _onUserInteraction();
          },
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: StreamBuilder<Duration>(
            stream: widget.player.stream.position,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final duration = widget.player.state.duration;
              
              return Row(
                children: [
                  Text(
                    _formatDuration(position),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: Colors.white24,
                        thumbColor: AppColors.primary,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        trackHeight: 3,
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                      ),
                      child: Slider(
                        value: position.inSeconds.toDouble().clamp(0.0, duration.inSeconds.toDouble()),
                        min: 0.0,
                        max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0,
                        onChanged: (value) {
                          widget.player.seek(Duration(seconds: value.toInt()));
                          _onUserInteraction();
                        },
                      ),
                    ),
                  ),
                  Text(
                    _formatDuration(duration),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              );
            },
          ),
        ),
        // Bottom action row
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Row(
            children: [
              // Lock button
              IconButton(
                icon: const Icon(Icons.lock_outline, color: Colors.white),
                onPressed: _toggleLock,
                tooltip: 'Lock Screen',
              ),
              // Volume button with slider
              IconButton(
                icon: Icon(
                  _currentVolume == 0 ? Icons.volume_off : 
                  _currentVolume < 50 ? Icons.volume_down : Icons.volume_up,
                  color: Colors.white,
                ),
                onPressed: _toggleVolumeSlider,
                tooltip: 'Volume',
              ),
              // Speed indicator
              if (_currentSpeed != 1.0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${_currentSpeed}x',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              const Spacer(),
              // Rotate screen button
              IconButton(
                icon: Icon(
                  _isLandscape ? Icons.stay_current_portrait : Icons.stay_current_landscape,
                  color: Colors.white,
                ),
                onPressed: _toggleOrientation,
                tooltip: _isLandscape ? 'Portrait' : 'Landscape',
              ),
              // Picture in Picture button
              IconButton(
                icon: const Icon(Icons.picture_in_picture_alt, color: Colors.white),
                onPressed: _showPipDialog,
                tooltip: 'PiP',
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPipDialog() {
    _onUserInteraction();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Picture-in-Picture', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.picture_in_picture_alt, color: Colors.white54, size: 64),
            const SizedBox(height: 16),
            Text(
              Platform.isAndroid 
                ? 'PiP is available on Android. The feature will be enabled in a future update.'
                : 'Picture-in-Picture is currently only available on Android devices.',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
