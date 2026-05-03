import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/model_psicologa/patient_model.dart';
import '../../../../moduloPsiquiatra/viewmodels_ps/routines_viewmodel2.dart';
import '../../../../viewmodels/auth_viewmodel.dart';

class AsignarPacienteView extends StatefulWidget {
  final PatientModel patient;

  const AsignarPacienteView({super.key, required this.patient});

  @override
  State<AsignarPacienteView> createState() => _AsignarPacienteViewState();
}

class _AsignarPacienteViewState extends State<AsignarPacienteView> {
  String? _selectedRoutineId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoutinesViewModel2>().loadRoutines();
    });
  }

  void _assign() async {
    if (_selectedRoutineId != null) {
      final profId = context.read<AuthViewModel>().currentUser?.id;
      if (profId == null) return;

      await context.read<RoutinesViewModel2>().assignToPatient(
        widget.patient.id,
        _selectedRoutineId!,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ Actividad asignada a ${widget.patient.fullName}"),
            backgroundColor: AppColors.mint,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final routinesVM = context.watch<RoutinesViewModel2>();
    final routines = routinesVM.routines;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Asignar a ${widget.patient.fullName}",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: routinesVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: routines.length,
                    itemBuilder: (context, index) {
                      final routine = routines[index];
                      final isSelected = _selectedRoutineId == routine.id;

                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedRoutineId = routine.id),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accent.withValues(alpha: 0.1)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.accent
                                  : AppColors.outlineVariant.withValues(
                                      alpha: 0.5,
                                    ),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getIconForCategory(routine.category),
                                  color: AppColors.accent,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      routine.title,
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      _getLabelForCategory(routine.category),
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.accent,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: _selectedRoutineId != null ? _assign : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mint,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Confirmar Asignación",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'breathing':
        return Icons.air_rounded;
      case 'relaxation':
        return Icons.self_improvement_rounded;
      case 'sleep_induction':
        return Icons.bedtime_rounded;
      default:
        return Icons.spa_rounded;
    }
  }

  String _getLabelForCategory(String category) {
    switch (category) {
      case 'breathing':
        return "Respiración";
      case 'relaxation':
        return "Relajación";
      case 'sleep_induction':
        return "Sueño";
      default:
        return "Mindfulness";
    }
  }
}
