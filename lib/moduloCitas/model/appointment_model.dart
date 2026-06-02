class Appointment {
  final String? id;
  final String patientId;
  final String professionalId;
  final String type;
  final String motive;
  final String status;
  final DateTime? scheduledDate; // La Pro lo define
  final int? durationMinutes; // La Pro lo define
  final String? professionalNotes;
  final String?
  patientName; // Agregado para mostrar en la vista del profesional
  final String?
  professionalName; // Nombre de la profesional para mostrar al paciente

  Appointment({
    this.id,
    required this.patientId,
    required this.professionalId,
    required this.type,
    required this.motive,
    this.status = 'SOLICITADA',
    this.scheduledDate,
    this.durationMinutes,
    this.professionalNotes,
    this.patientName,
    this.professionalName,
  });

  Map<String, dynamic> toJson() => {
    'patient_id': patientId,
    'professional_id': professionalId,
    'appointment_type': type,
    'motive': motive,
    'status': status,
    'scheduled_date': scheduledDate?.toIso8601String(),
    'duration_minutes': durationMinutes,
    'professional_notes': professionalNotes,
  };

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
    id: json['id'],
    patientId: json['patient_id'],
    professionalId: json['professional_id'],
    type: json['appointment_type'],
    motive: json['motive'],
    status: json['status'],
    scheduledDate: json['scheduled_date'] != null
        ? DateTime.parse(json['scheduled_date'])
        : null,
    durationMinutes: json['duration_minutes'],
    professionalNotes: json['professional_notes'],
    // Extraemos el nombre si viene en el join de Supabase (profiles(full_name))
    patientName: json['profiles'] != null
        ? json['profiles']['full_name']
        : null,
    professionalName: json['professional'] != null
        ? json['professional']['full_name']
        : null,
  );
}
