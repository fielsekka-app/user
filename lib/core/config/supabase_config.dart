import 'package:supabase_flutter/supabase_flutter.dart';
import 'env.dart';
import '../services/secure_storage_service.dart';

/// Supabase configuration and initialization
class SupabaseConfig {
  static SupabaseClient? _client;

  /// Initialize Supabase client
  static Future<void> initialize() async {
    final url = Env.supabaseUrl.isNotEmpty ? Env.supabaseUrl : 'https://dummy.supabase.co';
    final anonKey = Env.supabaseAnonKey.isNotEmpty ? Env.supabaseAnonKey : 'dummyKey';

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authOptions: FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        autoRefreshToken: true,
        localStorage: SecureStorageService(),
      ),
    );

    _client = Supabase.instance.client;
  }

  /// Get the Supabase client instance
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception(
        'Supabase client not initialized. Call SupabaseConfig.initialize() first.',
      );
    }
    return _client!;
  }

  /// Check if Supabase is initialized
  static bool get isInitialized => _client != null;
}
