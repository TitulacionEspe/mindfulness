import 'package:supabase_flutter/supabase_flutter.dart';

import '../model_ps/favorite_model.dart';

class FavoritesService {
  final _supabase = Supabase.instance.client;

  // Obtener todos los favoritos del profesional actual
  Future<List<ProfessionalFavorite>> getFavorites() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('professional_favorites')
        .select()
        .eq('professional_id', userId);

    return (response as List)
        .map((json) => ProfessionalFavorite.fromJson(json))
        .toList();
  }

  // Guardar un nuevo favorito
  Future<void> saveFavorite(ProfessionalFavorite favorite) async {
    await _supabase.from('professional_favorites').insert(favorite.toJson());
  }

  // Eliminar un favorito
  Future<void> deleteFavorite(int externalId) async {
    final userId = _supabase.auth.currentUser?.id;
    await _supabase
        .from('professional_favorites')
        .delete()
        .eq('professional_id', userId!)
        .eq('external_id', externalId);
  }
}
