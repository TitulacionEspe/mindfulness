import 'package:flutter/material.dart';
import 'package:mindfulness_app/core/theme/app_colors.dart';
import 'package:provider/provider.dart';

import '../model_ps/freesound_model.dart';
import '../viewmodels_ps/freesound_viewmodel.dart';

class SoundCard extends StatelessWidget {
  final FreesoundSound sound;

  const SoundCard({super.key, required this.sound});

  // --- DIÁLOGO PARA ELEGIR O ESCRIBIR CATEGORÍA ---
  void _showCategoryDialog(BuildContext context, FreesoundViewModel vm) {
    final TextEditingController customController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Guardar Recurso"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Elige una categoría o escribe una nueva:"),
            SizedBox(height: 15),
            TextField(
              controller: customController,
              decoration: InputDecoration(
                hintText: "Ej: Insomnio, Ansiedad...",
                filled: true,
                fillColor: AppColors.surfaceLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Chips de categorías rápidas
            Wrap(
              spacing: 8,
              children: ["Relajación", "Naturaleza", "Focalización"].map((cat) {
                return ActionChip(
                  label: Text(cat),
                  onPressed: () => _handleSave(context, vm, cat),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar", style: TextStyle(color: AppColors.error)),
          ),
          ElevatedButton(
            onPressed: () {
              final text = customController.text.trim();
              if (text.isNotEmpty) _handleSave(context, vm, text);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  // --- LÓGICA DE PERSISTENCIA CON CONFIRMACIONES ---
  void _handleSave(
    BuildContext context,
    FreesoundViewModel vm,
    String category,
  ) async {
    Navigator.pop(context); // Cerramos el diálogo

    try {
      await vm.markAsFavorite(sound, category);

      // SNACKBAR DE ÉXITO
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ Agregado a favoritos en '$category'"),
            backgroundColor: AppColors.mint,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // SNACKBAR DE ERROR (Lo que faltaba)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Ya existe en tus favoritos o hubo un error"),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FreesoundViewModel>();
    bool isPlaying =
        viewModel.currentlyPlayingUrl == sound.previewUrl &&
        viewModel.audioPlayer.playing;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Stack(
        children: [
          // Fondo con la Onda Sonora
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.network(
                sound.waveformUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(Icons.waves),
              ),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.lavender,
              child: IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: AppColors.surfaceLowest,
                ),
                onPressed: () => viewModel.togglePlay(sound.previewUrl),
              ),
            ),
            title: Text(
              sound.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text("${sound.duration.toStringAsFixed(1)} seg"),
            trailing: IconButton(
              icon: Icon(Icons.settings, color: AppColors.outline),
              onPressed: () => _showCategoryDialog(context, viewModel),
            ),
          ),
        ],
      ),
    );
  }
}
