// Archivo: lib/core/config/supabase_config.dart
// Lee las credenciales de Supabase desde el archivo .env (vía flutter_dotenv).
// IMPORTANTE: No commitear credenciales reales. El archivo .env está ignorado en git.

import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static bool get isConfigured =>
      url.isNotEmpty && anonKey.isNotEmpty && !url.contains('<');
}
