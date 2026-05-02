import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../viewmodels_ps/routines_viewmodel2.dart';

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
        });
      }
    } catch (e) {
      debugPrint("Error al seleccionar archivo: $e");
    }
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
      audioFile:
          (_selectedCategory == 'soundscape' ||
              _selectedCategory == 'relaxation' ||
              _selectedCategory == 'sleep_induction')
          ? _selectedAudioFile
          : null,
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
                  _buildSectionTitle("Informacion Basica"),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: _inputDecoration(
                      "Titulo de la rutina",
                      Icons.title,
                    ),
                    validator: (v) => v!.isEmpty ? "Campo requerido" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descController,
                    decoration: _inputDecoration(
                      "Descripcion o beneficios",
                      Icons.description,
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Categoria y Duracion"),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: _inputDecoration("Categoria", Icons.category),
                    items: categories.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text(c.replaceAll('_', ' ').toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val!),
                    validator: (v) => v == null ? "Selecciona una categoria" : null,
                  ),
                  const SizedBox(height: 16),
                  _buildSlider(
                    "Duracion total",
                    _durationMinutes,
                    1,
                    45,
                    "min",
                    (val) => setState(() => _durationMinutes = val.toInt()),
                  ),
                  const Divider(height: 48),

                  // Lógica Dinámica según Categoría
                  if (_selectedCategory == 'breathing') ...[
                    _buildSectionTitle("Patron de Respiracion"),
                    const SizedBox(height: 16),
                    _buildSlider(
                      "Inhalar",
                      _inhale,
                      1,
                      12,
                      "seg",
                      (v) => setState(() => _inhale = v.toInt()),
                    ),
                    _buildSlider(
                      "Sostener (lleno)",
                      _holdIn,
                      0,
                      12,
                      "seg",
                      (v) => setState(() => _holdIn = v.toInt()),
                    ),
                    _buildSlider(
                      "Exhalar",
                      _exhale,
                      1,
                      12,
                      "seg",
                      (v) => setState(() => _exhale = v.toInt()),
                    ),
                    _buildSlider(
                      "Sostener (vacio)",
                      _holdOut,
                      0,
                      12,
                      "seg",
                      (v) => setState(() => _holdOut = v.toInt()),
                    ),
                  ] else if (_selectedCategory != null) ...[
                    _buildSectionTitle("Contenido Multimedia"),
                    const SizedBox(height: 16),
                    Card(
                      color: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: AppColors.outlineVariant),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            if (_selectedAudioFile != null) ...[
                              Row(
                                children: [
                                  const Icon(
                                    Icons.audio_file,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      p.basename(_selectedAudioFile!.path),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => setState(
                                      () => _selectedAudioFile = null,
                                    ),
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],
                            ElevatedButton.icon(
                              onPressed: _pickAudio,
                              icon: const Icon(Icons.cloud_upload_outlined),
                              label: Text(
                                _selectedAudioFile == null
                                    ? "Seleccionar Archivo de Audio"
                                    : "Cambiar Audio",
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.lavender,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "GUARDAR RUTINA",
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

  Widget _buildSlider(
    String label,
    int value,
    double min,
    double max,
    String unit,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              "$value $unit",
              style: TextStyle(
                color: AppColors.mint,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          activeColor: AppColors.mint,
          inactiveColor: AppColors.mint.withValues(alpha: 0.2),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
