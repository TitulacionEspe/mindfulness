import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/appointment_model.dart';

class AppointmentsService {
  final _supabase = Supabase.instance.client;

  // Obtener el ID del usuario logueado actualmente
  String? get currentUserId => _supabase.auth.currentUser?.id;

  // 1. CARGAR CITAS (El RLS filtrará automáticamente por el ID del usuario)
  Future<List<Appointment>> getAppointments() async {
    final response = await _supabase
        .from('appointments')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Appointment.fromJson(json))
        .toList();
  }

  // 2. EL PACIENTE SOLICITA (UC1)
  Future<void> requestAppointment(Appointment appointment) async {
    // Forzamos que el patient_id sea siempre el del usuario logueado
    await _supabase.from('appointments').insert({
      ...appointment.toJson(),
      'patient_id': currentUserId,
      'status': 'SOLICITADA',
    });
  }

  // 3. LA PROFESIONAL GESTIONA (UC2) - Solo si el logueado es el professional_id
  Future<void> updateByProfessional({
    required String appointmentId,
    required Map<String, dynamic> data,
  }) async {
    await _supabase
        .from('appointments')
        .update(data)
        .eq('id', appointmentId)
        .eq('professional_id', currentUserId!); // Seguridad extra
  }

  // 4. EL PACIENTE CONFIRMA/RECHAZA (UC3) - Solo si el logueado es el patient_id
  Future<void> updateByPatient({
    required String appointmentId,
    required String newStatus,
  }) async {
    await _supabase
        .from('appointments')
        .update({'status': newStatus})
        .eq('id', appointmentId)
        .eq('patient_id', currentUserId!); // Seguridad extra
  }

  // 5. FINALIZAR CITA (Solo Profesional)
  Future<void> completeAppointment(String appointmentId, String notes) async {
    await _supabase
        .from('appointments')
        .update({
          'status': 'COMPLETADA',
          'professional_notes': notes,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', appointmentId)
        .eq(
          'professional_id',
          currentUserId!,
        ); // Seguridad: solo el pro asignado
  }
}
