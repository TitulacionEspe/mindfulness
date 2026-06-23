import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../../../core/theme/app_colors.dart';
import '../../viewmodels_ps/routines_viewmodel2.dart';

class MultimediaSelector extends StatelessWidget {
  final File? selectedAudioFile;
  final String? selectedExternalUrl;
  final String? selectedAudioName;
  final VoidCallback onPickLocal;
  final Function(RoutinesViewModel2) onShowFavorites;
  final RoutinesViewModel2 viewModel;
  final VoidCallback onClear;

  const MultimediaSelector({
    super.key,
    required this.selectedAudioFile,
    required this.selectedExternalUrl,
    required this.selectedAudioName,
    required this.onPickLocal,
    required this.onShowFavorites,
    required this.viewModel,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasSelection =
        selectedAudioFile != null || selectedExternalUrl != null;

    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (hasSelection) ...[
              Row(
                children: [
                  Icon(
                    selectedExternalUrl != null ? Icons.star : Icons.audio_file,
                    color: AppColors.mint,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selectedAudioName ??
                          (selectedAudioFile != null
                              ? p.basename(selectedAudioFile!.path)
                              : "Audio seleccionado"),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: onClear,
                    icon: Icon(Icons.close, color: AppColors.error),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Botón de favoritos.
            ElevatedButton.icon(
              onPressed: () => onShowFavorites(viewModel),
              icon: const Icon(Icons.favorite_border),
              label: const Text('Elegir de mis favoritos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lavender,
                foregroundColor: AppColors.buttonPrimaryText,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 12),
            Text(
              'o también puedes',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),

            // Botón para subir archivo.
            OutlinedButton.icon(
              onPressed: onPickLocal,
              icon: const Icon(Icons.cloud_upload_outlined),
              label: const Text('Subir archivo local'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.lavender,
                side: BorderSide(color: AppColors.lavender),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
