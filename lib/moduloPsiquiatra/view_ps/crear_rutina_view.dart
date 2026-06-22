import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../viewmodels_ps/routines_viewmodel2.dart';
import 'componets/breathing_cycles_info.dart';
import 'componets/custom_slider.dart';
import 'componets/multimedia_selector.dart';

class CrearRutinaView extends StatefulWidget {
  const CrearRutinaView({super.key});

  @override
  State<CrearRutinaView> createState() => _CrearRutinaViewState();
}

class _CrearRutinaViewState extends State<CrearRutinaView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String? _selectedCategory;
  int _durationMinutes = 5;

  // Parámetros de respiración
  int _inhale = 4;
  int _holdIn = 4;
  int _exhale = 4;
  int _holdOut = 0;

  // Parámetros de audio
  File? _selectedAudioFile;
  String? _selectedExternalUrl;
  String? _selectedAudioName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<RoutinesViewModel2>();
      if (vm.categories.isEmpty) {
        vm.loadCategories().then((_) {
          if (mounted && vm.categories.isNotEmpty) {
            setState(() => _selectedCategory = vm.categories.first);
          }
        });
      } else {
        setState(() => _selectedCategory = vm.categories.first);
      }
    });
  }

  Future<void> _pickAudio() async {
    try {
      final FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedAudioFile = File(result.files.single.path!);
          _selectedExternalUrl = null;
          _selectedAudioName = null;
        });
      }
    } catch (e) {
      debugPrint("Error al seleccionar archivo: $e");
    }
  }

  void _showFavoritesPicker(RoutinesViewModel2 vm) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Mis Sonidos Favoritos",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (vm.favorites.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("No tienes sonidos guardados como favoritos."),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: vm.favorites.length,
                    itemBuilder: (context, i) {
                      final fav = vm.favorites[i];
                      return ListTile(
                        leading: const Icon(
                          Icons.music_note,
                          color: Colors.blue,
                        ),
                        title: Text(fav['name'] ?? "Sin nombre"),
                        subtitle: Text(fav['category'] ?? ""),
                        onTap: () {
                          setState(() {
                            _selectedExternalUrl = fav['preview_url'];
                            _selectedAudioName = fav['name'];
                            _selectedAudioFile = null;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) return;

    final vm = context.read<RoutinesViewModel2>();

    final success = await vm.saveFullRoutine(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      category: _selectedCategory!,
      durationSeconds: _durationMinutes * 60,
      inhale: _selectedCategory == 'breathing' ? _inhale : null,
      holdIn: _selectedCategory == 'breathing' ? _holdIn : null,
      exhale: _selectedCategory == 'breathing' ? _exhale : null,
      holdOut: _selectedCategory == 'breathing' ? _holdOut : null,
      audioFile: (_selectedCategory != 'breathing') ? _selectedAudioFile : null,
      externalAudioUrl: (_selectedCategory != 'breathing')
          ? _selectedExternalUrl
          : null,
      audioName: (_selectedCategory != 'breathing') ? _selectedAudioName : null,
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Rutina creada y guardada correctamente"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Error: ${vm.errorMessage}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RoutinesViewModel2>();
    final isLoading = viewModel.isLoading;
    final categories = viewModel.categories;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Crear Nueva Rutina"),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: isLoading && categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildSectionTitle("Información básica"),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: _inputDecoration(
                      "Título de la rutina",
                      Icons.title,
                    ),
                    validator: (v) => v!.isEmpty ? "Campo requerido" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descController,
                    decoration: _inputDecoration(
                      "Descripción o beneficios",
                      Icons.description,
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Categoría y duración"),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: _inputDecoration("Categoría", Icons.category),
                    items: categories.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text(c.replaceAll('_', ' ').toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (val) =>
                        setState(() => _selectedCategory = val!),
                    validator: (v) =>
                        v == null ? "Selecciona una categoría" : null,
                  ),
                  const SizedBox(height: 16),
                  CustomSlider(
                    label: "Duración total",
                    value: _durationMinutes,
                    min: 1,
                    max: 10,
                    unit: "min",
                    onChanged: (val) =>
                        setState(() => _durationMinutes = val.toInt()),
                  ),
                  const Divider(height: 48),

                  if (_selectedCategory == 'breathing') ...[
                    _buildSectionTitle("Patrón de respiración"),
                    const SizedBox(height: 16),
                    CustomSlider(
                      label: "Inhalar",
                      value: _inhale,
                      min: 1,
                      max: 12,
                      unit: "seg",
                      onChanged: (v) => setState(() => _inhale = v.toInt()),
                    ),
                    CustomSlider(
                      label: "Sostener (lleno)",
                      value: _holdIn,
                      min: 0,
                      max: 12,
                      unit: "seg",
                      onChanged: (v) => setState(() => _holdIn = v.toInt()),
                    ),
                    CustomSlider(
                      label: "Exhalar",
                      value: _exhale,
                      min: 1,
                      max: 12,
                      unit: "seg",
                      onChanged: (v) => setState(() => _exhale = v.toInt()),
                    ),
                    CustomSlider(
                      label: "Sostener (vacio)",
                      value: _holdOut,
                      min: 0,
                      max: 12,
                      unit: "seg",
                      onChanged: (v) => setState(() => _holdOut = v.toInt()),
                    ),
                    const SizedBox(height: 16),
                    BreathingCyclesInfo(
                      inhale: _inhale,
                      holdIn: _holdIn,
                      exhale: _exhale,
                      holdOut: _holdOut,
                      durationMinutes: _durationMinutes,
                    ),
                  ] else if (_selectedCategory != null) ...[
                    _buildSectionTitle("Contenido Multimedia"),
                    const SizedBox(height: 16),
                    MultimediaSelector(
                      selectedAudioFile: _selectedAudioFile,
                      selectedExternalUrl: _selectedExternalUrl,
                      selectedAudioName: _selectedAudioName,
                      onPickLocal: _pickAudio,
                      onShowFavorites: _showFavoritesPicker,
                      viewModel: viewModel,
                      onClear: () => setState(() {
                        _selectedAudioFile = null;
                        _selectedExternalUrl = null;
                        _selectedAudioName = null;
                      }),
                    ),
                  ],

                  const SizedBox(height: 40),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mint,
                        foregroundColor: AppColors.buttonPrimaryText,
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Guardar rutina",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.lavender,
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.mint),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.outlineVariant),
      ),
    );
  }
}
