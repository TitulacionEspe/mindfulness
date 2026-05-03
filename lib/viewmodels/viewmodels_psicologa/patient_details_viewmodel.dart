import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/patient_history_model.dart';

class PatientDetailsViewModel extends ChangeNotifier {
  final _client = Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<HistorySessionItem> _sessions = [];
  List<HistorySessionItem> get sessions => _sessions;

  List<HistoryEmotionItem> _emotions = [];
  List<HistoryEmotionItem> get emotions => _emotions;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadPatientHistory(String patientId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final profId = _client.auth.currentUser?.id;
      if (profId == null) return;

      // 1. Obtener ASIGNACIONES hechas por esta psicóloga
      // Esto nos da la lista base de lo que "ella envió"
      final assignmentsRes = await _client
          .from('assignments')
          .select('*, routines(title)')
          .eq('patient_id', patientId)
          .eq('professional_id', profId)
          .order('assigned_at', ascending: false);

      final assignmentsList = assignmentsRes as List;

      // 2. Obtener TODAS las sesiones del paciente
      final sessionsRes = await _client
          .from('activity_sessions')
          .select('*')
          .eq('patient_id', patientId)
          .order('started_at', ascending: false);

      final sessionsList = sessionsRes as List;

      // 3. Obtener TODAS las evaluaciones emocionales del paciente
      final emotionsRes = await _client
          .from('self_assessments')
          .select('*')
          .eq('patient_id', patientId);

      final emotionsList = emotionsRes as List;

      // 4. Mapear asignaciones a HistorySessionItem
      _sessions = assignmentsList.map((a) {
        final routineId = a['routine_id'];
        final statusStr = a['status'];

        // Buscamos la sesión más reciente que coincida con esta rutina
        // para extraer detalles como el impacto emocional real si está completada.
        final matchingSession = sessionsList
            .cast<Map<String, dynamic>?>()
            .firstWhere(
              (s) => s?['routine_id'] == routineId,
              orElse: () => null,
            );

        return HistorySessionItem(
          // Usamos el ID de la sesión para vincular las emociones en la vista
          id: matchingSession != null ? matchingSession['id'] : a['id'],
          routineTitle: a['routines']?['title'] ?? 'Rutina eliminada',
          startedAt: matchingSession != null
              ? DateTime.parse(matchingSession['started_at'])
              : DateTime.parse(a['assigned_at']),
          completedAt:
              (matchingSession != null &&
                  matchingSession['completed_at'] != null)
              ? DateTime.parse(matchingSession['completed_at'])
              : null,
          status: _parseStatus(statusStr),
          assignmentContext: 'assigned',
        );
      }).toList();

      // 5. Mapear evaluaciones emocionales
      _emotions = emotionsList.map((e) {
        return HistoryEmotionItem(
          id: e['id'],
          sessionId: e['session_id'],
          recordedAt: DateTime.parse(e['recorded_at']),
          preEmotion: e['context'] == 'pre' ? e['emotion_id'] : '',
          preIntensity: e['context'] == 'pre' ? e['intensity'] : 0,
          postEmotion: e['context'] == 'post' ? e['emotion_id'] : null,
          postIntensity: e['context'] == 'post' ? e['intensity'] : null,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error en loadPatientHistory: $e');
      _errorMessage = 'Error al cargar el historial: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  HistorySessionStatus _parseStatus(String? status) {
    switch (status) {
      case 'completed':
        return HistorySessionStatus.completed;
      case 'pending':
        return HistorySessionStatus.unknown;
      case 'interrupted':
        return HistorySessionStatus.interrupted;
      default:
        return HistorySessionStatus.interrupted;
    }
  }
}
