import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../../core/theme/app_colors.dart';

/// Custom video player controls overlay with premium Netflix-style UI
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

class _CustomPlayerControlsState extends State<CustomPlayerControls>
    with TickerProviderStateMixin {
  bool _isVisible = true;
  bool _isBuffering = false;
  bool _isLocked = false;
  Timer? _hideTimer;
  double _volume = 100.0;
  double _playbackSpeed = 1.0;
  
  // Gesture tracking
  bool _isDraggingProgress = false;
  
  // Skip animation controllers
  late AnimationController _skipBackController;
  late AnimationController _skipForwardController;
  bool _showSkipBack = false;
  bool _showSkipForward = false;
  int _skipBackSeconds = 0;
  int _skipForwardSeconds = 0;
  
  // Quality options
  final List<String> _qualityOptions = ['Auto', '1080p', '720p', '480p', '360p'];
  String _selectedQuality = 'Auto';

  @override
  void initState() {
    super.initState();
    _startHideTimer();
    _volume = widget.player.state.volume;
    
    _skipBackController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _skipForwardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Listen to buffering state
    widget.player.stream.buffering.listen((buffering) {
      if (mounted) setState(() => _isBuffering = buffering);
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _skipBackController.dispose();
    _skipForwardController.dispose();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && widget.player.state.playing && !_isLocked) {
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
    
    setState(() {
      _isVisible = !_isVisible;
    });
    if (_isVisible) {
      _startHideTimer();
    } else {
      _hideTimer?.cancel();
    }
  }

  void _onUserInteraction() {
    if (!_isLocked) {
      setState(() => _isVisible = true);
      _startHideTimer();
    }
  }

  void _handleDoubleTapSeek(bool isForward) {
    final seconds = isForward ? 10 : -10;
    widget.player.seek(widget.player.state.position + Duration(seconds: seconds));
    
    setState(() {
      if (isForward) {
        _skipForwardSeconds += 10;
        _showSkipForward = true;
        _skipForwardController.forward(from: 0);
      } else {
        _skipBackSeconds += 10;
        _showSkipBack = true;
        _skipBackController.forward(from: 0);
      }
    });
    
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          if (isForward) {
            _showSkipForward = false;
            _skipForwardSeconds = 0;
          } else {
            _showSkipBack = false;
            _skipBackSeconds = 0;
          }
        });
      }
    });
    
    _onUserInteraction();
  }

  void _toggleLock() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isLocked = !_isLocked;
      _isVisible = true;
    });
    _startHideTimer();
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
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          // Double-tap zones with ripple effect
          Row(
            children: [
              // Left zone - rewind
              Expanded(
                child: GestureDetector(
                  onDoubleTap: () => _handleDoubleTapSeek(false),
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    color: Colors.transparent,
                    child: _showSkipBack ? _buildSkipAnimation(false) : null,
                  ),
                ),
              ),
              // Center zone - play/pause
              Expanded(
                child: GestureDetector(
                  onDoubleTap: () {
                    if (widget.player.state.playing) {
                      widget.player.pause();
                    } else {
                      widget.player.play();
                    }
                    _onUserInteraction();
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Container(color: Colors.transparent),
                ),
              ),
              // Right zone - forward
              Expanded(
                child: GestureDetector(
                  onDoubleTap: () => _handleDoubleTapSeek(true),
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    color: Colors.transparent,
                    child: _showSkipForward ? _buildSkipAnimation(true) : null,
                  ),
                ),
              ),
            ],
          ),

          // Buffering indicator
          if (_isBuffering)
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3,
                ),
              ),
            ),

          // Lock screen overlay
          if (_isLocked && _isVisible)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 0,
              right: 0,
              child: Center(
                child: _buildLockButton(),
              ),
            ),

          // Main Controls UI
          if (!_isLocked)
            AnimatedOpacity(
              opacity: _isVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: IgnorePointer(
                ignoring: !_isVisible,
                child: Container(
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
                      stops: [0.0, 0.15, 0.85, 1.0],
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
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSkipAnimation(bool isForward) {
    final controller = isForward ? _skipForwardController : _skipBackController;
    final seconds = isForward ? _skipForwardSeconds : _skipBackSeconds;
    
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2 * (1 - controller.value)),
            borderRadius: isForward
                ? const BorderRadius.only(
                    topLeft: Radius.circular(200),
                    bottomLeft: Radius.circular(200),
                  )
                : const BorderRadius.only(
                    topRight: Radius.circular(200),
                    bottomRight: Radius.circular(200),
                  ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isForward ? Icons.fast_forward : Icons.fast_rewind,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  '$seconds seconds',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLockButton() {
    return GestureDetector(
      onTap: _toggleLock,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isLocked ? Icons.lock : Icons.lock_open,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _isLocked ? 'Tap to Unlock' : 'Lock',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back button with glow
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
              onPressed: widget.onBack,
            ),
          ),
          const SizedBox(width: 12),
          
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NOW PLAYING',
                  style: TextStyle(
                    color: AppColors.primary.withOpacity(0.9),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Lock button
          IconButton(
            icon: Icon(
              _isLocked ? Icons.lock : Icons.lock_open,
              color: Colors.white70,
            ),
            onPressed: _toggleLock,
            tooltip: 'Lock Screen',
          ),
          
          // Quality selector
          _buildPopupButton(
            icon: Icons.hd,
            label: _selectedQuality,
            items: _qualityOptions,
            onSelected: (value) {
              setState(() => _selectedQuality = value);
              _onUserInteraction();
            },
          ),
          
          // Speed selector
          _buildPopupButton(
            icon: Icons.speed,
            label: '${_playbackSpeed}x',
            items: ['0.5x', '0.75x', '1.0x', '1.25x', '1.5x', '2.0x'],
            onSelected: (value) {
              final speed = double.parse(value.replaceAll('x', ''));
              setState(() => _playbackSpeed = speed);
              widget.player.setRate(speed);
              _onUserInteraction();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPopupButton({
    required IconData icon,
    required String label,
    required List<String> items,
    required Function(String) onSelected,
  }) {
    return PopupMenuButton<String>(
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      offset: const Offset(0, 48),
      onOpened: _onUserInteraction,
      itemBuilder: (context) => items.map((item) {
        final isSelected = item == label || item == '${label}x' || label.contains(item.replaceAll('x', ''));
        return PopupMenuItem(
          value: item,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                if (isSelected)
                  const Icon(Icons.check_circle, color: AppColors.primary, size: 18)
                else
                  const SizedBox(width: 18),
                const SizedBox(width: 12),
                Text(
                  item,
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
      onSelected: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 18),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Skip backward
        _buildControlButton(
          icon: Icons.replay_10_rounded,
          size: 48,
          onTap: () {
            widget.player.seek(widget.player.state.position - const Duration(seconds: 10));
            _onUserInteraction();
          },
        ),
        const SizedBox(width: 40),
        
        // Play/Pause with animated button
        StreamBuilder<bool>(
          stream: widget.player.stream.playing,
          builder: (context, snapshot) {
            final isPlaying = snapshot.data ?? false;
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                if (isPlaying) {
                  widget.player.pause();
                } else {
                  widget.player.play();
                }
                _onUserInteraction();
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    key: ValueKey(isPlaying),
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            );
          },
        ),
        
        const SizedBox(width: 40),
        
        // Skip forward
        _buildControlButton(
          icon: Icons.forward_10_rounded,
          size: 48,
          onTap: () {
            widget.player.seek(widget.player.state.position + const Duration(seconds: 10));
            _onUserInteraction();
          },
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required double size,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
        ),
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          // Progress bar with preview
          StreamBuilder<Duration>(
            stream: widget.player.stream.position,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final duration = widget.player.state.duration;
              final buffered = widget.player.state.buffer;
              final progress = duration.inMilliseconds > 0
                  ? position.inMilliseconds / duration.inMilliseconds
                  : 0.0;
              final bufferProgress = duration.inMilliseconds > 0
                  ? buffered.inMilliseconds / duration.inMilliseconds
                  : 0.0;
              
              return Column(
                children: [
                  // Time labels
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(position),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '-${_formatDuration(duration - position)}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Custom progress bar
                  GestureDetector(
                    onHorizontalDragStart: (details) {
                      setState(() => _isDraggingProgress = true);
                      _onUserInteraction();
                    },
                    onHorizontalDragUpdate: (details) {
                      final box = context.findRenderObject() as RenderBox;
                      final width = box.size.width - 40;
                      final pos = (details.localPosition.dx / width).clamp(0.0, 1.0);
                      final newPosition = Duration(
                        milliseconds: (pos * duration.inMilliseconds).toInt(),
                      );
                      widget.player.seek(newPosition);
                    },
                    onHorizontalDragEnd: (details) {
                      setState(() => _isDraggingProgress = false);
                    },
                    onTapUp: (details) {
                      final box = context.findRenderObject() as RenderBox;
                      final width = box.size.width - 40;
                      final pos = (details.localPosition.dx / width).clamp(0.0, 1.0);
                      final newPosition = Duration(
                        milliseconds: (pos * duration.inMilliseconds).toInt(),
                      );
                      widget.player.seek(newPosition);
                      _onUserInteraction();
                    },
                    child: Container(
                      height: 32,
                      alignment: Alignment.center,
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          // Background track
                          Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          // Buffered track
                          FractionallySizedBox(
                            widthFactor: bufferProgress.clamp(0.0, 1.0),
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white38,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          // Progress track
                          FractionallySizedBox(
                            widthFactor: progress.clamp(0.0, 1.0),
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.primary, AppColors.primaryLight],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          // Thumb
                          Positioned(
                            left: (MediaQuery.of(context).size.width - 40) * progress.clamp(0.0, 1.0) - 8,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: _isDraggingProgress ? 20 : 16,
                              height: _isDraggingProgress ? 20 : 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.5),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Bottom row with volume
          Row(
            children: [
              // Volume control
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_volume > 0) {
                      _volume = 0;
                    } else {
                      _volume = 100;
                    }
                    widget.player.setVolume(_volume);
                  });
                },
                child: Icon(
                  _volume == 0
                      ? Icons.volume_off_rounded
                      : _volume < 50
                          ? Icons.volume_down_rounded
                          : Icons.volume_up_rounded,
                  color: Colors.white70,
                  size: 24,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 100,
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: Colors.white,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: _volume,
                    min: 0,
                    max: 100,
                    onChanged: (value) {
                      setState(() => _volume = value);
                      widget.player.setVolume(value);
                      _onUserInteraction();
                    },
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Fullscreen button (placeholder for future)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.subtitles_outlined, color: Colors.white70, size: 18),
                    const SizedBox(width: 6),
                    const Text(
                      'Subtitles',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
