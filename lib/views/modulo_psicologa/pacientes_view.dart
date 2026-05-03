import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../viewmodels/viewmodels_psicologa/patients_viewmodel.dart';
import 'pacientes/components/day_registry.dart';
import 'pacientes/components/patient_card_white.dart';
import 'pacientes/components/patient_search_row.dart';
import 'pacientes/components/status_filters.dart';

class PacientesView extends StatefulWidget {
  const PacientesView({super.key});

  @override
  State<PacientesView> createState() => _PacientesViewState();
}

class _PacientesViewState extends State<PacientesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientsViewModel>().loadPatients();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PatientsViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => viewModel.refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const PatientSearchRow(),
                    const SizedBox(height: 20),
                    const StatusFilters(),
                    const SizedBox(height: 25),
                    Text(
                      "Lista de pacientes",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),

                    if (viewModel.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (viewModel.errorMessage != null)
                      Center(
                        child: Text(
                          viewModel.errorMessage!,
                          style: TextStyle(color: AppColors.error),
                        ),
                      )
                    else if (viewModel.patients.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text("No se encontraron pacientes"),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: viewModel.patients.length,
                        itemBuilder: (context, index) {
                          final patient = viewModel.patients[index];
                          return PatientCardWhite(
                            patient: patient,
                          );
                        },
                      ),

                    const SizedBox(height: 20),
                    const DayRegistry(),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
