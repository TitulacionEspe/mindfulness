import 'package:flutter/material.dart';
import 'package:mindfulness_app/core/theme/app_colors.dart';
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
  final TextEditingController _searchController = TextEditingController();
  late FreesoundViewModel _viewModel;

  final List<Map<String, String>> _categories = [
    {'label': 'Sanación', 'query': 'healing frequencies'},
    {'label': '432 Hz', 'query': '432hz'},
    {'label': '528 Hz', 'query': '528hz'},
    {'label': 'Solfeggio', 'query': 'solfeggio healing'},
    {'label': 'Binaural', 'query': 'binaural relaxation'},
    {'label': 'Ondas Delta', 'query': 'delta waves sleep'},
    {'label': 'Lluvia', 'query': 'rain relaxation'},
    {'label': 'Dormir', 'query': 'deep sleep music'},
    {'label': 'Cuencos', 'query': 'tibetan bowls'},
  ];

  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    // Listener para el scroll infinito
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _viewModel.fetchNextPage();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Guardamos la referencia del ViewModel aquí de forma segura
    _viewModel = context.read<FreesoundViewModel>();
  }

  @override
  void dispose() {
    _viewModel.stopAudio(silent: true);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    _searchController.text = query;
    _viewModel.search(query);
    setState(() {
      _selectedCategory = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FreesoundViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Buscador de sonidos')),
      body: Column(
        children: [
          // BARRA DE CATEGORÍAS
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category['query'];

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(category['label']!),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      if (selected) {
                        _handleSearch(category['query']!);
                      } else {
                        setState(() => _selectedCategory = '');
                      }
                    },
                    selectedColor: AppColors.successBg,
                    checkmarkColor: AppColors.mint,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.mint
                          : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Buscar: rain, forest, etc...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _selectedCategory = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onSubmitted: (val) {
                _viewModel.search(val);
                setState(() => _selectedCategory = val);
              },
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
