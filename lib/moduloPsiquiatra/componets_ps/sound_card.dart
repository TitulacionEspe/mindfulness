import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model_ps/freesound_model.dart';
import '../viewmodels_ps/freesound_viewmodel.dart';

class SoundCard extends StatelessWidget {
  final FreesoundSound sound;
  const SoundCard({super.key, required this.sound});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FreesoundViewModel>();
    bool isPlaying =
        viewModel.currentlyPlayingUrl == sound.previewUrl &&
        viewModel.audioPlayer.playing;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: Image.network(sound.waveformUrl, fit: BoxFit.cover),
            ),
          ),
          ListTile(
            title: Text(
              sound.name,
              maxLines: 1,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("${sound.duration.toStringAsFixed(1)} seg"),
            leading: CircleAvatar(
              backgroundColor: Colors.indigo,
              child: IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () => viewModel.togglePlay(sound.previewUrl),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
