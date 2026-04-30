import 'package:flutter/foundation.dart'; // Importante para debugPrint y kDebugMode
import 'package:just_audio/just_audio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model_ps/favorite_model.dart';
import '../model_ps/freesound_model.dart';
import '../services_ps/favorites_service.dart';
import '../services_ps/freesound_service.dart';

class FreesoundViewModel extends ChangeNotifier {
  final FreesoundService _freesoundService = FreesoundService();
  final FavoritesService _favoritesService = FavoritesService();
  final AudioPlayer audioPlayer = AudioPlayer();

  List<FreesoundSound> sounds = [];
  bool isLoading = false;
  int currentPage = 1;
  String currentQuery = '';
  String? currentlyPlayingUrl;

  // --- LÓGICA DE BÚSQUEDA ---
  Future<void> search(String query) async {
    currentQuery = query;
    currentPage = 1;
    sounds = [];
    await fetchNextPage();
  }

  Future<void> fetchNextPage() async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();
    try {
      final response = await _freesoundService.searchSounds(
        query: currentQuery,
        page: currentPage,
      );
      sounds.addAll(response.results);
      currentPage++;
    } catch (e) {
      debugPrint("Error cargando sonidos: $e");
    }
    isLoading = false;
    notifyListeners();
  }

  // --- LÓGICA DE GUARDADO CON DEBUG ---
  Future<void> markAsFavorite(FreesoundSound sound, String category) async {
    final session = Supabase.instance.client.auth.currentSession;
    final user = Supabase.instance.client.auth.currentUser;

    // Solo imprimimos si estamos en modo debug (desarrollo)
    if (kDebugMode) {
      debugPrint("--- 🛡️ DEBUG AUTH ---");
      if (session == null) {
        debugPrint(
          "❌ ERROR: No hay sesión activa. El token no existe o expiró.",
        );
      } else {
        debugPrint("✅ Sesión activa hasta: ${session.expiresAt}");
        debugPrint("🔑 Token: ${session.accessToken.substring(0, 10)}...");
      }
    }

    if (session == null) {
      throw Exception("Sesión expirada. Por favor, re-inicia sesión.");
    }

    if (user == null) {
      debugPrint("❌ ERROR: currentUser es NULL");
      throw Exception("Debes estar logueado para guardar favoritos");
    }

    debugPrint("👤 ID Usuario: ${user.id}");

    final favorite = ProfessionalFavorite(
      professionalId: user.id,
      externalId: sound.id,
      name: sound.name,
      previewUrl: sound.previewUrl,
      waveformUrl: sound.waveformUrl,
      category: category,
    );

    debugPrint("📝 Intentando insertar en Supabase: ${favorite.toJson()}");

    try {
      await _favoritesService.saveFavorite(favorite);
      debugPrint("🚀 EXITO: ¡Guardado en la tabla professional_favorites!");
    } catch (e) {
      debugPrint("🔥 ERROR AL GUARDAR: $e");

      if (e.toString().contains("403")) {
        debugPrint(
          "💡 TIP: El error 403 suele indicar que el RLS está bloqueando el INSERT.",
        );
      }
      throw Exception("Error al guardar: $e");
    }
  }

  // --- LÓGICA DE AUDIO ---
  Future<void> togglePlay(String url) async {
    try {
      if (currentlyPlayingUrl == url && audioPlayer.playing) {
        await audioPlayer.pause();
      } else {
        currentlyPlayingUrl = url;
        await audioPlayer.setUrl(url);
        audioPlayer.play();
      }
      notifyListeners();
    } catch (e) {
      debugPrint("🎵 Error de Audio: $e");
    }
  }

  void stopAudio({bool silent = false}) {
    if (audioPlayer.playing) {
      audioPlayer.stop();
      currentlyPlayingUrl = null;
      if (!silent) notifyListeners();
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}
