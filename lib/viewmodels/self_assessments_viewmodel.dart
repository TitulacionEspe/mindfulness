import 'package:flutter/material.dart';

import '../models/self_assessment_model.dart';
import '../services/self_assessments_repository.dart';

class SelfAssessmentsViewModel extends ChangeNotifier {
  SelfAssessmentsViewModel({SelfAssessmentsRepository? repository})
    : _repository = repository ?? SupabaseSelfAssessmentsRepository();

  static const List<String> emotionCatalog = [
    'calma',
    'alegria',
    'gratitud',
    'esperanza',
    'concentracion',
    'cansancio',
    'ansiedad',
    'estres',
    'tristeza',
    'enojo',
    'frustracion',
    'preocupacion',
  ];

  final SelfAssessmentsRepository _repository;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  Future<bool> createAssessment({
    required String sessionId,
    required AssessmentContext context,
    required String emotionId,
    required int intensity,
  }) async {
    final normalizedEmotion = emotionId.trim();
    if (sessionId.trim().isEmpty) {
      _errorMessage = 'No se pudo asociar la autoevaluacion a la sesion.';
      notifyListeners();
      return false;
    }
    if (normalizedEmotion.isEmpty) {
      _errorMessage = 'Selecciona una emocion para continuar.';
      notifyListeners();
      return false;
    }
    if (intensity < 1 || intensity > 10) {
      _errorMessage = 'Selecciona una intensidad valida entre 1 y 10.';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repository.createAssessment(
        sessionId: sessionId,
        context: context,
        emotionId: normalizedEmotion,
        intensity: intensity,
      );
      _successMessage = context == AssessmentContext.preSession
          ? 'Registro previo guardado.'
          : 'Registro posterior guardado.';
      return true;
    } catch (_) {
      _errorMessage =
          'No se pudo guardar la autoevaluacion. Revisa tu conexion e intenta nuevamente.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void reset() {
    _isSaving = false;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
