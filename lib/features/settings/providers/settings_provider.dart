import 'package:flutter/material.dart';
import '../../../data/services/services.dart';

/// Provider for app settings and preferences
class SettingsProvider extends ChangeNotifier {
  final OfflineService _offlineService = OfflineService();

  ThemeMode _themeMode = ThemeMode.dark;
  String _videoQuality = 'auto';
  bool _autoplay = true;
  String _cacheSize = '0 MB';

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  String get videoQuality => _videoQuality;
  bool get autoplay => _autoplay;
  String get cacheSize => _cacheSize;

  /// Initialize settings from storage
  Future<void> initialize() async {
    _themeMode =
        _offlineService.getThemeMode() ? ThemeMode.dark : ThemeMode.light;
    _videoQuality = _offlineService.getVideoQuality();
    _autoplay = _offlineService.getAutoplay();
    _cacheSize = _offlineService.getFormattedCacheSize();
    notifyListeners();
  }

  /// Toggle theme mode
  Future<void> toggleTheme() async {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await _offlineService.saveThemeMode(_themeMode == ThemeMode.dark);
    notifyListeners();
  }

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _offlineService.saveThemeMode(mode == ThemeMode.dark);
    notifyListeners();
  }

  /// Set video quality
  Future<void> setVideoQuality(String quality) async {
    _videoQuality = quality;
    await _offlineService.saveVideoQuality(quality);
    notifyListeners();
  }

  /// Toggle autoplay
  Future<void> toggleAutoplay() async {
    _autoplay = !_autoplay;
    await _offlineService.saveAutoplay(_autoplay);
    notifyListeners();
  }

  /// Set autoplay
  Future<void> setAutoplay(bool value) async {
    _autoplay = value;
    await _offlineService.saveAutoplay(value);
    notifyListeners();
  }

  /// Refresh cache size
  void refreshCacheSize() {
    _cacheSize = _offlineService.getFormattedCacheSize();
    notifyListeners();
  }

  /// Clear cache
  Future<void> clearCache() async {
    await _offlineService.clearMoviesCache();
    refreshCacheSize();
  }

  /// Clear all app data
  Future<void> clearAllData() async {
    await _offlineService.clearAllData();
    // Reset to defaults
    _themeMode = ThemeMode.dark;
    _videoQuality = 'auto';
    _autoplay = true;
    _cacheSize = '0 MB';
    notifyListeners();
  }

  /// Get available quality options
  List<String> get qualityOptions => [
        'auto',
        '1080p',
        '720p',
        '480p',
        '360p',
      ];
}
