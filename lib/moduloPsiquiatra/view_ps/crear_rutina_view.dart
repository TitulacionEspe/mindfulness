import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  int inhale = 4;
  int hold = 4;
  int exhale = 4;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        await context.read<RoutinesViewModel2>().createBreathingRoutine(
          _titleController.text.trim(),
          _descController.text.trim(),
          {'inhale': inhale, 'hold': hold, 'exhale': exhale},
        );
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Rutina creada con éxito")),
          );
        }
      } catch (e) {
        debugPrint("Error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nueva Plantilla de Respiración")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Título de la rutina",
              ),
              validator: (v) => v!.isEmpty ? "Requerido" : null,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: "Descripción o beneficios",
              ),
              maxLines: 2,
            ),
            const Divider(height: 40),
            const Text(
              "Configuración del Patrón (segundos)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            _buildSlider(
              "Inhalar",
              inhale,
              (val) => setState(() => inhale = val.toInt()),
            ),
            _buildSlider(
              "Mantener",
              hold,
              (val) => setState(() => hold = val.toInt()),
            ),
            _buildSlider(
              "Exhalar",
              exhale,
              (val) => setState(() => exhale = val.toInt()),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Guardar Plantilla"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String label, int value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: $value seg"),
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
