import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../model_ps/favorite_model.dart';
import '../services_ps/favorites_service.dart';

class FavoritesViewModel extends ChangeNotifier {
  final FavoritesService _service = FavoritesService();
  final AudioPlayer audioPlayer = AudioPlayer();

  List<ProfessionalFavorite> allFavorites = []; // Lista maestra
  List<ProfessionalFavorite> filteredFavorites = []; // Lista que se muestra

  bool isLoading = false;
  String? selectedCategory; // Para el filtro
  String? currentlyPlayingUrl;

  // Cargar datos de Supabase
  Future<void> loadFavorites() async {
    isLoading = true;
    notifyListeners();

    try {
      allFavorites = await _service.getFavorites();
      filteredFavorites = allFavorites;
      selectedCategory = null; // Reset de filtro
    } catch (e) {
      debugPrint("Error cargando favoritos: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Filtrar localmente (sin ir a la DB de nuevo)
  void filterByCategory(String? category) {
    selectedCategory = category;
    if (category == null) {
      filteredFavorites = allFavorites;
    } else {
      filteredFavorites = allFavorites
          .where((f) => f.category == category)
          .toList();
    }
    notifyListeners();
  }

  // Obtener lista de categorías únicas para los botones de filtro
  List<String> get categories =>
      allFavorites.map((e) => e.category).toSet().toList();

  // Eliminar un favorito
  Future<void> removeFavorite(int externalId) async {
    try {
      await _service.deleteFavorite(externalId);
      allFavorites.removeWhere((f) => f.externalId == externalId);
      filterByCategory(selectedCategory); // Refrescar vista actual
    } catch (e) {
      debugPrint("Error eliminando: $e");
    }
  }

  // Control de Audio (Play/Pause)
  Future<void> togglePlay(String url) async {
    if (currentlyPlayingUrl == url && audioPlayer.playing) {
      await audioPlayer.pause();
    } else {
      currentlyPlayingUrl = url;
      await audioPlayer.setUrl(url);
      audioPlayer.play();
    }
    notifyListeners();
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
