import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mindfulness_app/models/patient_history_model.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../models/model_psicologa/patient_model.dart';
import '../../../../viewmodels/viewmodels_psicologa/patient_details_viewmodel.dart';

class PacienteHistorialView extends StatefulWidget {
  final PatientModel patient;

  const PacienteHistorialView({super.key, required this.patient});

  @override
  State<PacienteHistorialView> createState() => _PacienteHistorialViewState();
}

class _PacienteHistorialViewState extends State<PacienteHistorialView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientDetailsViewModel>().loadPatientHistory(
        widget.patient.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PatientDetailsViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Historial de ${widget.patient.fullName}",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.sessions.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: viewModel.sessions.length,
              itemBuilder: (context, index) {
                final session = viewModel.sessions[index];
                // Buscar emociones asociadas a esta sesión
                final sessionEmotions = viewModel.emotions
                    .where((e) => e.sessionId == session.id)
                    .toList();

                return _buildHistoryCard(session, sessionEmotions);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "No hay actividades registradas aún.",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    HistorySessionItem session,
    List<HistoryEmotionItem> emotions,
  ) {
    final dateStr = DateFormat(
      'dd MMM, yyyy - HH:mm',
      'es',
    ).format(session.startedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  session.routineTitle,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildStatusBadge(session.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            dateStr,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const Divider(height: 24),
          if (emotions.isNotEmpty) ...[
            Text(
              "Impacto emocional:",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            _buildEmotionComparison(emotions),
          ] else
            Text(
              "Sin registro de emociones",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(HistorySessionStatus status) {
    final isCompleted = status == HistorySessionStatus.completed;
    final isPending = status == HistorySessionStatus.unknown;

    Color badgeColor = AppColors.error;
    String label = "Interrumpida";

    if (isCompleted) {
      badgeColor = AppColors.mint;
      label = "Completada";
    } else if (isPending) {
      badgeColor = AppColors.lavender;
      label = "Pendiente";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: badgeColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

Widget _buildEmotionComparison(List<HistoryEmotionItem> emotions) {
  // Intentamos encontrar pre y post
  final pre = emotions.firstWhere(
    (e) => e.preEmotion.isNotEmpty,
    orElse: () => emotions.first,
  );
  final post = emotions.firstWhere(
    (e) => e.postEmotion != null,
    orElse: () => emotions.first,
  );

  final hasPost = post.postEmotion != null;

  return Row(
    children: [
      _buildEmotionPill(
        "Antes: ${pre.preEmotion}",
        pre.preIntensity,
        AppColors.lavender,
      ),
      if (hasPost) ...[
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(
            Icons.arrow_forward_rounded,
            size: 16,
            color: Colors.grey,
          ),
        ),
        _buildEmotionPill(
          "Después: ${post.postEmotion}",
          post.postIntensity!,
          AppColors.mint,
        ),
      ],
    ],
  );
}

Widget _buildEmotionPill(String label, int intensity, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Text(
            intensity.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
