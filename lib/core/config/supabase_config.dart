import 'package:supabase_flutter/supabase_flutter.dart';
import 'env_config.dart';

/// Supabase client configuration and initialization
class SupabaseConfig {
  static SupabaseClient? _client;

  /// Initialize Supabase with environment variables
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  /// Get the Supabase client instance
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception(
          'Supabase not initialized. Call SupabaseConfig.initialize() first.');
    }
    return _client!;
  }

  /// Check if user is authenticated
  static bool get isAuthenticated => _client?.auth.currentUser != null;

  /// Get current user ID
  static String? get currentUserId => _client?.auth.currentUser?.id;
}
