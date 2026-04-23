import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../componets_ps/favorite_sound_card.dart';
import '../viewmodels_ps/favorites_viewmodel.dart';

class FavoritosView extends StatefulWidget {
  const FavoritosView({super.key});

  @override
  State<FavoritosView> createState() => _FavoritosViewState();
}

class _FavoritosViewState extends State<FavoritosView> {
  @override
  void initState() {
    super.initState();
    // Cargamos los datos de Supabase al entrar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesViewModel>().loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FavoritesViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Fondo gris azulado muy suave
      appBar: AppBar(
        // FLECHA DE RETROCESO PERSONALIZADA
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Mi Biblioteca",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          // BOTÓN DE REFRESCAR
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.indigo),
            onPressed: () => viewModel.loadFavorites(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryFilters(viewModel),
          Expanded(
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.filteredFavorites.isEmpty
                ? _buildEmptyState()
                : _buildFavoritesList(viewModel),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: Filtros de Categoría (Chips) ---
  Widget _buildCategoryFilters(FavoritesViewModel viewModel) {
    if (viewModel.allFavorites.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Opción "Todos"
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: const Text("Todos"),
              selected: viewModel.selectedCategory == null,
              onSelected: (_) => viewModel.filterByCategory(null),
              selectedColor: Colors.indigo.withValues(alpha: 0.2),
              checkmarkColor: Colors.indigo,
            ),
          ),
          // Categorías dinámicas (las que tú inventaste al guardar)
          ...viewModel.categories.map((cat) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: Text(cat),
                selected: viewModel.selectedCategory == cat,
                onSelected: (_) => viewModel.filterByCategory(cat),
                selectedColor: Colors.teal.withValues(alpha: 0.2),
                checkmarkColor: Colors.teal,
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- WIDGET: Lista de Favoritos ---
  Widget _buildFavoritesList(FavoritesViewModel viewModel) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: viewModel.filteredFavorites.length,
      itemBuilder: (context, index) {
        final favorite = viewModel.filteredFavorites[index];
        return FavoriteSoundCard(favorite: favorite);
      },
    );
  }

  // --- WIDGET: Estado Vacío (UX Premium) ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_music_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            "No hay recursos en esta categoría",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Guarda sonidos desde el buscador para verlos aquí",
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      ),
    );
  }
}
