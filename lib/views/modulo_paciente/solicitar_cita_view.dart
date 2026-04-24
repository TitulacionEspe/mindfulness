import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../moduloCitas/viewmodels/appointments_viewmodel.dart';

class SolicitarCitaView extends StatefulWidget {
  const SolicitarCitaView({super.key});

  @override
  State<SolicitarCitaView> createState() => _SolicitarCitaViewState();
}

class _SolicitarCitaViewState extends State<SolicitarCitaView> {
  final _formKey = GlobalKey<FormState>();
  final _motiveController = TextEditingController();

  String? _selectedProId;
  String _selectedType = 'Primera vez';
  List<Map<String, dynamic>> _professionals = [];
  bool _fetchingPros = true;

  @override
  void initState() {
    super.initState();
    _loadProfessionals();
  }

  // Obtenemos la lista de profesionales reales de tu tabla profiles
  Future<void> _loadProfessionals() async {
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('id, full_name')
          .eq('role', 'professional'); // Filtramos por rol

      setState(() {
        _professionals = List<Map<String, dynamic>>.from(data);
        _fetchingPros = false;
      });
    } catch (e) {
      debugPrint("Error cargando profesionales: $e");
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && _selectedProId != null) {
      final vm = context.read<AppointmentsViewModel>();

      try {
        await vm.createNewRequest(
          _selectedProId!,
          _selectedType,
          _motiveController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Solicitud enviada con éxito"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Regresamos al home
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("❌ Error: $e"),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nueva Cita"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: _fetchingPros
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "¿Con quién deseas la cita?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color.fromARGB(255, 82, 78, 78),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      hint: const Text("Selecciona un profesional"),
                      items: _professionals.map((pro) {
                        return DropdownMenuItem(
                          value: pro['id'].toString(),
                          child: Text(pro['full_name'] ?? "Profesional"),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedProId = val),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      "Tipo de consulta",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: ['Primera vez', 'Seguimiento', 'Urgencia'].map((
                        type,
                      ) {
                        return ChoiceChip(
                          label: Text(type),
                          selected: _selectedType == type,
                          onSelected: (val) =>
                              setState(() => _selectedType = type),
                          selectedColor: Colors.indigo.withValues(alpha: 0.2),
                          checkmarkColor: Colors.indigo,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      "Cuéntanos el motivo",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _motiveController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText:
                            "Ej: Me he sentido muy ansioso esta semana...",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (val) =>
                          val!.isEmpty ? "Por favor escribe algo" : null,
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Enviar Solicitud",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
