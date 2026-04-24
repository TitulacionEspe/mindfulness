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

  // ACCIÓN DEL PACIENTE: Solicitar
  Future<void> createNewRequest(
    String proId,
    String type,
    String motive,
  ) async {
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
  // En lib/moduloCitas/viewmodels/appointments_viewmodel.dart

  Future<void> updateStatusFromPatient(String id, String newStatus) async {
    await _service.updateByPatient(appointmentId: id, newStatus: newStatus);
    await loadAll(); // Refrescar lista local
  }

  // --- ACCIÓN: FINALIZAR CITA ---
  Future<void> markAsDone(String appointmentId, String notes) async {
    isLoading = true;
    notifyListeners();

    try {
      await _service.completeAppointment(appointmentId, notes);
      await loadAll(); // Recargamos la lista para que desaparezca de la agenda activa
    } catch (e) {
      debugPrint("Error al finalizar cita: $e");
      rethrow; // Para que la vista sepa que hubo un error si lo necesita
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
