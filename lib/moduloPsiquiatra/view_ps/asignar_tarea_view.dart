import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../viewmodels_ps/routines_viewmodel2.dart';

class AsignarTareaView extends StatefulWidget {
  const AsignarTareaView({super.key});

  @override
  State<AsignarTareaView> createState() => _AsignarTareaViewState();
}

class _AsignarTareaViewState extends State<AsignarTareaView> {
  String? _selectedPatientId;
  String? _selectedRoutineId;
  List<Map<String, dynamic>> _patients = [];
  bool _loadingPatients = true;

  @override
  void initState() {
    super.initState();
    // 1. Carga los pacientes desde Supabase
    _loadPatients();
    // 2. Fuerza la carga de rutinas del ViewModel al abrir la pantalla
    //    Evita el bug de tener que navegar atrás y volver para ver datos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<RoutinesViewModel2>().loadRoutines();
      }
    });
  }

  Future<void> _loadPatients() async {
    final res = await Supabase.instance.client
        .from('profiles')
        .select('id, full_name')
        .eq('role', 'patient');
    setState(() {
      _patients = List<Map<String, dynamic>>.from(res);
      _loadingPatients = false;
    });
  }

  void _assign() async {
    if (_selectedPatientId != null && _selectedRoutineId != null) {
      await context.read<RoutinesViewModel2>().assignToPatient(
        _selectedPatientId!,
        _selectedRoutineId!,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Tarea asignada al paciente")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 3. Escuchamos el ViewModel para reaccionar a cambios de estado
    final routinesVM = context.watch<RoutinesViewModel2>();
    final routines = routinesVM.routines;

    return Scaffold(
      appBar: AppBar(title: const Text("Asignar Rutina")),
      // 4. Muestra spinner si el ViewModel O los pacientes aún están cargando
      body: (routinesVM.isLoading || _loadingPatients)
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Dropdown Pacientes con null safety
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    hint: const Text("Seleccionar Paciente"),
                    items: _patients.map((p) {
                      return DropdownMenuItem(
                        value: p['id']?.toString(),
                        child: Text(p['full_name'] ?? "Paciente sin nombre"),
                      );
                    }).toList(),
                    onChanged: (val) =>
                        setState(() => _selectedPatientId = val),
                  ),
                  const SizedBox(height: 20),
                  // Dropdown Rutinas: muestra aviso si la lista está vacía
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    hint: const Text("Seleccionar Rutina"),
                    items: routines.isEmpty
                        ? [
                            const DropdownMenuItem(
                              value: null,
                              child: Text("No hay rutinas creadas"),
                            ),
                          ]
                        : routines.map((r) {
                            return DropdownMenuItem(
                              value: r.id,
                              child: Text(r.title),
                            );
                          }).toList(),
                    onChanged: (val) =>
                        setState(() => _selectedRoutineId = val),
                  ),
                  const Spacer(),
                  // 5. Botón deshabilitado hasta que ambos campos estén seleccionados
                  ElevatedButton(
                    onPressed:
                        (_selectedPatientId != null &&
                            _selectedRoutineId != null)
                        ? _assign
                        : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.indigo,
                    ),
                    child: const Text(
                      "Confirmar Asignación",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
