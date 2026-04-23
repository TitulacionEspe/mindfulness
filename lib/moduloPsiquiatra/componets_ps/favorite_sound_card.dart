import 'package:flutter/material.dart';
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
                errorBuilder: (_, __, ___) => const Icon(Icons.music_note),
              ),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal,
              child: IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
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
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => viewModel.removeFavorite(favorite.externalId),
            ),
          ),
        ],
      ),
    );
  }
}
