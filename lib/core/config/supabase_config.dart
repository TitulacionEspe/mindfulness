import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration class for Supabase credentials.
/// Reads values from .env file via flutter_dotenv.
class SupabaseConfig {
  /// Gets the Supabase URL from environment variables.
  /// Access via subscript operator to avoid NotInitializedError.
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';

  /// Gets the Supabase Anon Key from environment variables.
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Checks if Supabase is properly configured with valid credentials.
  static bool get isConfigured =>
      url.isNotEmpty &&
      anonKey.isNotEmpty &&
      !url.contains('<') &&
      !url.contains('dummy');
}
