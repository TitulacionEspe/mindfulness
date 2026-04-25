import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ThemePreferencesRepository {
  ThemePreferencesRepository({
    SupabaseClient? supabaseClient,
    Future<SharedPreferences> Function()? preferencesFactory,
  }) : _supabaseClient = supabaseClient,
       _preferencesFactory =
           preferencesFactory ?? SharedPreferences.getInstance;

  static const String themeModeKey = 'theme_mode';
  static const String lightValue = 'light';
  static const String darkValue = 'dark';

  final SupabaseClient? _supabaseClient;
  final Future<SharedPreferences> Function() _preferencesFactory;

  SupabaseClient get _client => _supabaseClient ?? Supabase.instance.client;

  Future<ThemeMode> loadThemeMode() async {
    final localTheme = await loadLocalThemeMode();
    if (localTheme != null) return localTheme;

    final remoteTheme = await loadRemoteThemeMode();
    if (remoteTheme != null) {
      await saveLocalThemeMode(remoteTheme);
      return remoteTheme;
    }

    return ThemeMode.light;
  }

  Future<ThemeMode?> loadLocalThemeMode() async {
    final preferences = await _preferencesFactory();
    return parseThemeMode(preferences.getString(themeModeKey));
  }

  Future<void> saveLocalThemeMode(ThemeMode mode) async {
    final preferences = await _preferencesFactory();
    await preferences.setString(themeModeKey, serializeThemeMode(mode));
  }

  Future<ThemeMode?> loadRemoteThemeMode() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final response = await _client
          .from('profiles')
          .select('theme_mode')
          .eq('id', user.id)
          .maybeSingle();

      return parseThemeMode(response?['theme_mode'] as String?);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveRemoteThemeMode(ThemeMode mode) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return;

      await _client
          .from('profiles')
          .update({'theme_mode': serializeThemeMode(mode)})
          .eq('id', user.id);
    } catch (_) {
      // La preferencia local ya quedó guardada; la sincronización remota es best-effort.
    }
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    await saveLocalThemeMode(mode);
    await saveRemoteThemeMode(mode);
  }

  static ThemeMode? parseThemeMode(String? value) {
    switch (value) {
      case lightValue:
        return ThemeMode.light;
      case darkValue:
        return ThemeMode.dark;
      default:
        return null;
    }
  }

  static String serializeThemeMode(ThemeMode mode) {
    return mode == ThemeMode.dark ? darkValue : lightValue;
  }
}
