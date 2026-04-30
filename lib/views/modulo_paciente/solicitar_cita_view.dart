import 'package:flutter/material.dart';
import 'package:mindfulness_app/core/theme/app_colors.dart';
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

  Future<void> _loadProfessionals() async {
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('id, full_name')
          .eq('role', 'professional');

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
            SnackBar(
              content: const Text("✅ Solicitud enviada con éxito"),
              backgroundColor: AppColors.mint,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("❌ Error: $e"),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Solicitar Cita"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
      ),
      body: _fetchingPros
          ? Center(child: CircularProgressIndicator(color: AppColors.mint))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 12.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderSection(),
                    const SizedBox(height: 32),
                    _buildSectionTitle("¿Con quién deseas la cita?"),
                    const SizedBox(height: 12),
                    _buildProfessionalSelector(),
                    const SizedBox(height: 32),
                    _buildSectionTitle("Tipo de consulta"),
                    const SizedBox(height: 12),
                    _buildTypeSelector(),
                    const SizedBox(height: 32),
                    _buildSectionTitle("Cuéntanos el motivo"),
                    const SizedBox(height: 12),
                    _buildMotiveField(),
                    const SizedBox(height: 48),
                    _buildSubmitButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Agenda tu espacio",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Selecciona un profesional y cuéntanos cómo podemos ayudarte hoy.",
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildProfessionalSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(Icons.person_outline, color: AppColors.lavender),
        ),
        dropdownColor: AppColors.surfaceHigh,
        iconEnabledColor: AppColors.lavender,
        hint: Text(
          "Selecciona un profesional",
          style: TextStyle(color: AppColors.textSecondary),
        ),
        items: _professionals.map((pro) {
          return DropdownMenuItem(
            value: pro['id'].toString(),
            child: Text(
              pro['full_name'] ?? "Profesional",
              style: TextStyle(color: AppColors.textPrimary),
            ),
          );
        }).toList(),
        onChanged: (val) => setState(() => _selectedProId = val),
        validator: (val) =>
            val == null ? "Por favor selecciona un profesional" : null,
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: ['Primera vez', 'Seguimiento', 'Urgencia'].map((type) {
        final isSelected = _selectedType == type;
        return ChoiceChip(
          label: Text(type),
          selected: isSelected,
          onSelected: (val) => setState(() => _selectedType = type),
          backgroundColor: AppColors.surface,
          selectedColor: AppColors.mint.withValues(alpha: 0.2),
          labelStyle: TextStyle(
            color: isSelected ? AppColors.mint : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? AppColors.mint : AppColors.outlineVariant,
            ),
          ),
          showCheckmark: false,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        );
      }).toList(),
    );
  }

  Widget _buildMotiveField() {
    return TextFormField(
      controller: _motiveController,
      maxLines: 4,
      style: TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: "Ej: Me he sentido muy ansioso esta semana...",
        hintStyle: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.5),
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.all(20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.mint, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
      validator: (val) => val!.isEmpty ? "Por favor escribe el motivo" : null,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mint,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: const Text(
          "Enviar Solicitud",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
