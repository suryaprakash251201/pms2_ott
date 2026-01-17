import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../../core/theme/app_colors.dart';

/// Custom video player controls overlay with premium UI
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
  Timer? _hideTimer;
  double _volume = 100.0;
  double _playbackSpeed = 1.0;
  
  // Quality options
  final List<String> _qualityOptions = ['Auto', '1080p', '720p', '480p'];
  String _selectedQuality = 'Auto';
  bool _isSwitchingQuality = false;

  @override
  void initState() {
    super.initState();
    _startHideTimer();
    _volume = widget.player.state.volume;
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
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
    setState(() => _isVisible = true);
    _startHideTimer();
  }

  Future<void> _handleQualitySwitch(String quality) async {
    setState(() {
      _selectedQuality = quality;
      _isSwitchingQuality = true;
    });
    
    // Simulate network delay for quality switch
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() => _isSwitchingQuality = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('Quality set to $quality'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
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
          // Double-tap zones
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onDoubleTap: () {
                     widget.player.seek(widget.player.state.position - const Duration(seconds: 10));
                     _onUserInteraction();
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Container(),
                ),
              ),
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
                  child: Container(),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onDoubleTap: () {
                     widget.player.seek(widget.player.state.position + const Duration(seconds: 10));
                     _onUserInteraction();
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Container(),
                ),
              ),
            ],
          ),

          // Loading overlay for quality switch
          if (_isSwitchingQuality)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),

          // Controls UI
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
                    stops: [0.0, 0.2, 0.8, 1.0],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Top Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                                  shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            
                            // Quality Button
                            PopupMenuButton<String>(
                              initialValue: _selectedQuality,
                              color: const Color(0xFF1E1E1E),
                              icon: const Icon(Icons.high_quality, color: Colors.white),
                              onOpened: _onUserInteraction,
                              onCanceled: _startHideTimer,
                              itemBuilder: (context) => _qualityOptions.map((q) => 
                                PopupMenuItem(
                                  value: q,
                                  child: Row(
                                    children: [
                                      if (_selectedQuality == q)
                                        const Icon(Icons.check, color: AppColors.primary, size: 16)
                                      else
                                        const SizedBox(width: 16),
                                      const SizedBox(width: 8),
                                      Text(q, style: const TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                )
                              ).toList(),
                              onSelected: _handleQualitySwitch,
                            ),
                            
                            // Speed Button
                            PopupMenuButton<double>(
                              initialValue: _playbackSpeed,
                              color: const Color(0xFF1E1E1E),
                              icon: const Icon(Icons.speed, color: Colors.white),
                              onOpened: _onUserInteraction,
                              onCanceled: _startHideTimer,
                              itemBuilder: (context) => [0.5, 1.0, 1.25, 1.5, 2.0].map((s) => 
                                PopupMenuItem(
                                  value: s,
                                  child: Row(
                                    children: [
                                      if (_playbackSpeed == s)
                                        const Icon(Icons.check, color: AppColors.primary, size: 16)
                                      else
                                        const SizedBox(width: 16),
                                      const SizedBox(width: 8),
                                      Text('${s}x', style: const TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                )
                              ).toList(),
                              onSelected: (value) {
                                setState(() => _playbackSpeed = value);
                                widget.player.setRate(value);
                                _onUserInteraction();
                              },
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Playback Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            iconSize: 42,
                            icon: const Icon(Icons.replay_10, color: Colors.white),
                            onPressed: () {
                              widget.player.seek(widget.player.state.position - const Duration(seconds: 10));
                              _onUserInteraction();
                            },
                          ),
                          const SizedBox(width: 24),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withOpacity(0.2),
                            ),
                            child: IconButton(
                              iconSize: 64,
                              icon: StreamBuilder<bool>(
                                stream: widget.player.stream.playing,
                                builder: (context, snapshot) {
                                  final isPlaying = snapshot.data ?? false;
                                  return Icon(
                                    isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                                    color: AppColors.primary,
                                  );
                                },
                              ),
                              onPressed: () {
                                if (widget.player.state.playing) {
                                  widget.player.pause();
                                } else {
                                  widget.player.play();
                                }
                                _onUserInteraction();
                              },
                            ),
                          ),
                          const SizedBox(width: 24),
                          IconButton(
                            iconSize: 42,
                            icon: const Icon(Icons.forward_10, color: Colors.white),
                            onPressed: () {
                              widget.player.seek(widget.player.state.position + const Duration(seconds: 10));
                              _onUserInteraction();
                            },
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Bottom Controls
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            StreamBuilder<Duration>(
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
                                        data: SliderThemeData(
                                          activeTrackColor: AppColors.primary,
                                          inactiveTrackColor: Colors.white24,
                                          thumbColor: AppColors.primary,
                                          overlayColor: AppColors.primary.withOpacity(0.3),
                                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                                          trackHeight: 4,
                                        ),
                                        child: Slider(
                                          value: position.inSeconds.toDouble().clamp(0, duration.inSeconds.toDouble()),
                                          min: 0,
                                          max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0,
                                          onChanged: (value) {
                                            _onUserInteraction();
                                          },
                                          onChangeEnd: (value) {
                                            widget.player.seek(Duration(seconds: value.toInt()));
                                            _onUserInteraction();
                                          },
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _formatDuration(duration),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                );
                              },
                            ),
                            
                            // Volume Slider
                            Row(
                              children: [
                                Icon(
                                  _volume == 0 ? Icons.volume_off : Icons.volume_up,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 100,
                                  child: SliderTheme(
                                    data: SliderThemeData(
                                      activeTrackColor: Colors.white,
                                      inactiveTrackColor: Colors.white12,
                                      thumbColor: Colors.white,
                                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                      trackHeight: 2,
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
                              ],
                            ),
                          ],
                        ),
                      ),
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
}
