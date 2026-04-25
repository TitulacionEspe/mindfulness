import 'package:flutter/material.dart';
import 'package:mindfulness_app/core/theme/app_colors.dart';
import 'package:provider/provider.dart';

import '../model_ps/favorite_model.dart';
import '../viewmodels_ps/favorites_viewmodel.dart';

class FavoriteSoundCard extends StatelessWidget {
  final ProfessionalFavorite favorite;

  const FavoriteSoundCard({super.key, required this.favorite});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FavoritesViewModel>();
    bool isPlaying =
        viewModel.currentlyPlayingUrl == favorite.previewUrl &&
        viewModel.audioPlayer.playing;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Stack(
        children: [
          // Fondo con Waveform (viene de Supabase ahora)
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.network(
                favorite.waveformUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(Icons.music_note),
              ),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.mint,
              child: IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: AppColors.surfaceLowest,
                ),
                onPressed: () => viewModel.togglePlay(favorite.previewUrl),
              ),
            ),
            title: Text(
              favorite.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text("Categoría: ${favorite.category}"),
            // EL CAMBIO: Botón para eliminar
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => viewModel.removeFavorite(favorite.externalId),
            ),
          ),
        ],
      ),
    );
  }
}
