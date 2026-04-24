import 'package:flutter/material.dart';

enum ReminderType {
  sleepInduction,
  routineStart,
  briefRelaxation;

  String get dbValue {
    switch (this) {
      case ReminderType.sleepInduction:
        return 'sleep_induction';
      case ReminderType.routineStart:
        return 'routine_start';
      case ReminderType.briefRelaxation:
        return 'brief_relaxation';
    }
  }

  static ReminderType fromDbValue(String value) {
    switch (value) {
      case 'sleep_induction':
        return ReminderType.sleepInduction;
      case 'routine_start':
        return ReminderType.routineStart;
      case 'brief_relaxation':
        return ReminderType.briefRelaxation;
      default:
        return ReminderType.routineStart;
    }
  }

  String get label {
    switch (this) {
      case ReminderType.sleepInduction:
        return 'Inducción al sueño';
      case ReminderType.routineStart:
        return 'Inicio de rutina';
      case ReminderType.briefRelaxation:
        return 'Relajación breve';
    }
  }
}

class ReminderModel {
  final String? id;
  final String patientId;
  final TimeOfDay triggerTime;
  final int
  daysOfWeek; // Máscara de bits: 1=Lun, 2=Mar, 4=Mié, 8=Jue, 16=Vie, 32=Sáb, 64=Dom
  final bool isActive;
  final ReminderType type;

  ReminderModel({
    this.id,
    required this.patientId,
    required this.triggerTime,
    required this.daysOfWeek,
    this.isActive = true,
    this.type = ReminderType.routineStart,
  });

  int? get notificationBaseId => id == null ? null : id.hashCode & 0x7fffffff;

  ReminderModel copyWith({
    String? id,
    String? patientId,
    TimeOfDay? triggerTime,
    int? daysOfWeek,
    bool? isActive,
    ReminderType? type,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      triggerTime: triggerTime ?? this.triggerTime,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      isActive: isActive ?? this.isActive,
      type: type ?? this.type,
    );
  }

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    final timeStr = json['trigger_time'] as String;
    final parts = timeStr.split(':');

    return ReminderModel(
      id: json['id'],
      patientId: json['patient_id'],
      triggerTime: TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      ),
      daysOfWeek: json['days_of_week'] ?? 0,
      isActive: json['is_active'] ?? true,
      type: ReminderType.fromDbValue(json['type'] ?? 'routine_start'),
    );
  }

  Map<String, dynamic> toJson() {
    final timeStr =
        '${triggerTime.hour.toString().padLeft(2, '0')}:${triggerTime.minute.toString().padLeft(2, '0')}:00';

    final map = {
      'patient_id': patientId,
      'trigger_time': timeStr,
      'days_of_week': daysOfWeek,
      'is_active': isActive,
      'type': type.dbValue,
    };

    if (id != null) {
      map['id'] = id!;
    }

    return map;
  }
}
