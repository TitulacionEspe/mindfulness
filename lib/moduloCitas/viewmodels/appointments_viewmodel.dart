import 'package:flutter/material.dart';

import '../model/appointment_model.dart';
import '../services/appointments_service.dart';

class AppointmentsViewModel extends ChangeNotifier {
  final AppointmentsService _service = AppointmentsService();

  List<Appointment> allAppointments = [];
  bool isLoading = false;

  // Listas filtradas para la UI
  List<Appointment> get pendingRequests =>
      allAppointments.where((a) => a.status == 'SOLICITADA').toList();
  List<Appointment> get confirmedAgenda =>
      allAppointments.where((a) => a.status == 'CONFIRMADA').toList();

  Future<void> loadAll() async {
    isLoading = true;
    notifyListeners();
    try {
      allAppointments = await _service.getAppointments();
    } catch (e) {
      debugPrint("Error: $e");
    }
    isLoading = false;
    notifyListeners();
  }

  void reset() {
    allAppointments = [];
    isLoading = false;
    notifyListeners();
  }

  // ACCIÓN DEL PACIENTE: Solicitar
  Future<void> createNewRequest(
    String proId,
    String type,
    String motive,
  ) async {
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
      motive: motive,
    );
    await _service.requestAppointment(appointment);
    await loadAll();
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
    await loadAll();
  }

  // ACCIÓN DE LA PROFESIONAL: Rechazar Solicitud
  Future<void> rejectFromPro(String id) async {
    await _service.updateByProfessional(
      appointmentId: id,
      data: {'status': 'RECHAZADA'},
    );
    await loadAll();
  }
  // En lib/moduloCitas/viewmodels/appointments_viewmodel.dart

  Future<void> updateStatusFromPatient(String id, String newStatus) async {
    try {
      await _service.updateByPatient(appointmentId: id, newStatus: newStatus);
      await loadAll(); // Refrescar lista local
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
