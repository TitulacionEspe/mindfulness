import 'package:flutter/material.dart';

import '../../core/utils/text_limit_utils.dart';
import '../model/appointment_model.dart';
import '../services/appointments_service.dart';

class AppointmentsViewModel extends ChangeNotifier {
  AppointmentsViewModel({AppointmentsService? service})
    : _service = service ?? AppointmentsService();

  static const int maxMotiveCharacters = 50;

  final AppointmentsService _service;

  List<Appointment> allAppointments = [];
  bool isLoading = false;
  String? statusUpdateMessage;
  final Map<String, String> _knownStatuses = {};

  // Listas filtradas para la UI
  List<Appointment> get pendingRequests =>
      allAppointments.where((a) => a.status == 'SOLICITADA').toList();
  List<Appointment> get confirmedAgenda =>
      allAppointments.where((a) => a.status == 'CONFIRMADA').toList();

  Future<void> loadAll({bool notifyStatusChanges = true}) async {
    isLoading = true;
    notifyListeners();
    try {
      final nextAppointments = await _service.getAppointments();
      if (notifyStatusChanges) {
        statusUpdateMessage = _detectStatusChange(nextAppointments);
      }
      allAppointments = nextAppointments;
      _knownStatuses
        ..clear()
        ..addEntries(
          allAppointments
              .where((appointment) => appointment.id != null)
              .map(
                (appointment) => MapEntry(appointment.id!, appointment.status),
              ),
        );
    } catch (e) {
      debugPrint("Error: $e");
    }
    isLoading = false;
    notifyListeners();
  }

  void reset() {
    allAppointments = [];
    isLoading = false;
    statusUpdateMessage = null;
    _knownStatuses.clear();
    notifyListeners();
  }

  void clearStatusUpdateMessage() {
    statusUpdateMessage = null;
    notifyListeners();
  }

  // ACCIÓN DEL PACIENTE: Solicitar
  Future<void> createNewRequest(
    String proId,
    String type,
    String motive, {
    String? extraNote,
  }) async {
    final normalizedMotive = motive.trim();
    final validationError = TextLimitUtils.requiredMaxCharactersError(
      normalizedMotive,
      maxCharacters: maxMotiveCharacters,
      emptyMessage: 'Ingresa el motivo de la cita.',
      fieldName: 'El motivo de la cita',
    );
    if (validationError != null) {
      throw Exception(validationError);
    }

    // Refrescar datos antes de validar para evitar solicitudes duplicadas
    allAppointments = await _service.getAppointments();

    // Validar límite de solicitudes (máximo 1 activa en proceso)
    final pendingCount = allAppointments
        .where((a) => a.status == 'SOLICITADA' || a.status == 'PROPUESTA')
        .length;
    if (pendingCount >= 1) {
      throw Exception(
        'Ya tienes una solicitud en proceso. Espera a que se resuelva o cancélala antes de enviar otra.',
      );
    }

    final appointment = Appointment(
      patientId: '', // El servicio lo llenará con el Auth.uid
      professionalId: proId,
      type: type,
      motive: extraNote == null || extraNote.trim().isEmpty
          ? normalizedMotive
          : '$normalizedMotive\n\n${extraNote.trim()}',
    );
    await _service.requestAppointment(appointment);
    await loadAll(notifyStatusChanges: false);
  }

  // ACCIÓN DE LA PROFESIONAL: Proponer Horario
  Future<void> proposeFromPro(String id, DateTime date, int minutes) async {
    // Refrescar datos antes de validar para evitar condiciones de carrera
    allAppointments = await _service.getAppointments();

    // Validación de conflictos (Double-booking)
    final limitDate = date.add(Duration(minutes: minutes));
    for (var app in allAppointments) {
      if ((app.status == 'CONFIRMADA' || app.status == 'PROPUESTA') &&
          app.scheduledDate != null &&
          app.durationMinutes != null &&
          app.id != id) {
        // Ignorar la cita actual que se está modificando
        final existingStart = app.scheduledDate!;
        final existingEnd = existingStart.add(
          Duration(minutes: app.durationMinutes!),
        );

        // Verifica si los intervalos de tiempo se solapan
        if (date.isBefore(existingEnd) && limitDate.isAfter(existingStart)) {
          throw Exception(
            'Ya tienes una cita agendada o propuesta en este horario.',
          );
        }
      }
    }

    await _service.updateByProfessional(
      appointmentId: id,
      data: {
        'scheduled_date': date.toIso8601String(),
        'duration_minutes': minutes,
        'status': 'PROPUESTA',
      },
    );
    await loadAll(notifyStatusChanges: false);
  }

  // ACCIÓN DE LA PROFESIONAL: Rechazar Solicitud
  Future<void> rejectFromPro(String id) async {
    await _service.updateByProfessional(
      appointmentId: id,
      data: {'status': 'RECHAZADA'},
    );
    await loadAll(notifyStatusChanges: false);
  }
  // En lib/moduloCitas/viewmodels/appointments_viewmodel.dart

  Future<void> updateStatusFromPatient(String id, String newStatus) async {
    try {
      await _service.updateByPatient(appointmentId: id, newStatus: newStatus);
      await loadAll(notifyStatusChanges: false); // Refrescar lista local
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Conflicto de horario')) {
        throw Exception(
          'Este horario ya fue confirmado por otro paciente. '
          'Por favor, contacta a tu profesional para reagendar.',
        );
      }
      rethrow;
    }
  }

  String? _detectStatusChange(List<Appointment> nextAppointments) {
    if (_knownStatuses.isEmpty) return null;

    for (final appointment in nextAppointments) {
      final id = appointment.id;
      if (id == null) continue;
      final previous = _knownStatuses[id];
      if (previous == null || previous == appointment.status) continue;

      final label = _statusLabel(appointment.status);
      final professional = appointment.professionalName?.trim();
      final source = professional == null || professional.isEmpty
          ? 'tu profesional'
          : professional;
      return 'Tu cita cambió a "$label" por $source.';
    }
    return null;
  }

  String _statusLabel(String status) {
    return switch (status) {
      'SOLICITADA' => 'solicitada',
      'PROPUESTA' => 'propuesta',
      'CONFIRMADA' => 'confirmada',
      'COMPLETADA' => 'finalizada',
      'RECHAZADA' => 'rechazada',
      'CANCELADA' => 'cancelada',
      _ => status.toLowerCase(),
    };
  }

  // --- ACCIÓN: FINALIZAR CITA ---
  Future<void> markAsDone(String appointmentId, String notes) async {
    isLoading = true;
    notifyListeners();

    try {
      debugPrint("Finalizando cita $appointmentId...");
      await _service.completeAppointment(appointmentId, notes);
      debugPrint("Cita finalizada en base de datos. Recargando...");

      // En lugar de llamar a loadAll que vuelve a poner isLoading=true,
      // podemos simplemente actualizar la lista local o llamar a _service directamente
      allAppointments = await _service.getAppointments();
      _knownStatuses
        ..clear()
        ..addEntries(
          allAppointments
              .where((appointment) => appointment.id != null)
              .map(
                (appointment) => MapEntry(appointment.id!, appointment.status),
              ),
        );
      debugPrint("Lista recargada.");
    } catch (e) {
      debugPrint("Error al finalizar cita: $e");
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
