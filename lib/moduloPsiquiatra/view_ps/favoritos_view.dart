import 'package:flutter/material.dart';
import 'package:mindfulness_app/core/theme/app_colors.dart';
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
      backgroundColor: AppColors.background, // Fondo gris azulado muy suave
      appBar: AppBar(
        // FLECHA DE RETROCESO PERSONALIZADA
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Mi Biblioteca",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.surfaceLowest,
        elevation: 0,
        centerTitle: true,
        actions: [
          // BOTÓN DE REFRESCAR
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.lavender),
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
            padding: EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text("Todos"),
              selected: viewModel.selectedCategory == null,
              onSelected: (_) => viewModel.filterByCategory(null),
              selectedColor: AppColors.lavender.withValues(alpha: 0.2),
              checkmarkColor: AppColors.lavender,
            ),
          ),
          // Categorías dinámicas (las que tú inventaste al guardar)
          ...viewModel.categories.map((cat) {
            return Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: Text(cat),
                selected: viewModel.selectedCategory == cat,
                onSelected: (_) => viewModel.filterByCategory(cat),
                selectedColor: AppColors.mint.withValues(alpha: 0.2),
                checkmarkColor: AppColors.mint,
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
          Icon(
            Icons.library_music_outlined,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.72),
          ),
          SizedBox(height: 20),
          Text(
            "No hay recursos en esta categoría",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Guarda sonidos desde el buscador para verlos aquí",
            style: TextStyle(color: AppColors.outline, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
