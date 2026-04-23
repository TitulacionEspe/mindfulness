import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../componets_ps/sound_card.dart';
import '../viewmodels_ps/freesound_viewmodel.dart';

class RecursosView extends StatefulWidget {
  const RecursosView({super.key});

  @override
  State<RecursosView> createState() => _RecursosViewState();
}

class _RecursosViewState extends State<RecursosView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Listener para el scroll infinito
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<FreesoundViewModel>().fetchNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
                hintText: "Buscar: rain, forest, etc...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onSubmitted: (val) => viewModel.search(val),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // Asignamos el controlador
              itemCount:
                  viewModel.sounds.length + (viewModel.isLoading ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (i < viewModel.sounds.length) {
                  return SoundCard(sound: viewModel.sounds[i]);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
