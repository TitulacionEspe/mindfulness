import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../componets_ps/sound_card.dart';
import '../viewmodels_ps/freesound_viewmodel.dart';

class RecursosView extends StatelessWidget {
  const RecursosView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FreesoundViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Buscador de Sonidos")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Lluvia, pájaros...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onSubmitted: (val) => viewModel.search(val),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: viewModel.sounds.length,
              itemBuilder: (ctx, i) => SoundCard(sound: viewModel.sounds[i]),
            ),
          ),
        ],
      ),
    );
  }
}
