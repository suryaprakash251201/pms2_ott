import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'data/services/offline_service.dart';
import 'features/home/providers/home_provider.dart';
import 'features/my_list/providers/my_list_provider.dart';
import 'features/player/providers/player_provider.dart';
import 'features/playlists/providers/playlist_provider.dart';
import 'features/search/providers/search_provider.dart';
import 'features/settings/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize MediaKit for video playback (Windows, Linux, macOS)
  try {
    MediaKit.ensureInitialized();
  } catch (e) {
    debugPrint('MediaKit initialization error: $e');
  }

  // Set preferred orientations
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } catch (e) {
    debugPrint('Orientation error: $e');
  }

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Error loading .env file: $e');
    // Continue without .env - app will use defaults
  }

  // Initialize offline storage
  try {
    await OfflineService.initialize();
  } catch (e) {
    debugPrint('Offline service error: $e');
  }

  // Initialize Supabase
  try {
    await SupabaseConfig.initialize();
  } catch (e) {
    debugPrint('Supabase initialization error: $e');
    // App can still run in offline mode
  }

  runApp(const PMS2OTTApp());
}

class PMS2OTTApp extends StatelessWidget {
  const PMS2OTTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => PlaylistProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => MyListProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'PMS2 OTT',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            home: const MainShell(),
          );
        },
      ),
    );
  }
}
