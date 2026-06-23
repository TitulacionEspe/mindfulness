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
    String selectedFromChips = "";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Guardar recurso'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Elige una categoría o escribe una nueva:'),
              const SizedBox(height: 15),
              TextField(
                controller: customController,
                onChanged: (val) {
                  // Si el usuario escribe manualmente, desmarcamos los chips si no coinciden
                  if (val != selectedFromChips) {
                    setState(() => selectedFromChips = "");
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Ej.: insomnio, ansiedad...',
                  filled: true,
                  fillColor: AppColors.surfaceLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Sugerencias:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: ['Relajación', 'Naturaleza', 'Focalización'].map((
                  cat,
                ) {
                  final isSelected = selectedFromChips == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedFromChips = cat;
                          customController.text = cat;
                        } else {
                          selectedFromChips = "";
                        }
                      });
                    },
                    selectedColor: AppColors.lavender.withValues(alpha: 0.3),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.lavender
                          : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar', style: TextStyle(color: AppColors.error)),
            ),
            ElevatedButton(
              onPressed: () {
                final text = customController.text.trim();
                if (text.isNotEmpty) {
                  // Capturamos el messenger antes de cerrar el diálogo.
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(context);
                  _handleSave(messenger, vm, text);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Escribe una categoría.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mint,
                foregroundColor: AppColors.buttonPrimaryText,
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  // --- Lógica de persistencia con confirmaciones ---
  void _handleSave(
    ScaffoldMessengerState messenger,
    FreesoundViewModel vm,
    String category,
  ) async {
    try {
      await vm.markAsFavorite(sound, category);

      // Usamos el messenger capturado previamente
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.buttonPrimaryText),
              const SizedBox(width: 10),
              Text("Guardado en '$category'."),
            ],
          ),
          backgroundColor: AppColors.mint,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text(
            'No se pudo guardar el recurso. Intenta nuevamente.',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
