class SleepLogModel {
  const SleepLogModel({
    required this.id,
    required this.patientId,
    required this.logDate,
    required this.bedTime,
    required this.wakeTime,
    this.sleepLatencyMin,
    this.wakeAfterSleepOnsetMin,
    this.sleepQualityRating,
    this.disturbances,
    required this.recordedAt,
  });

  final String id;
  final String patientId;
  final DateTime logDate;
  final DateTime bedTime;
  final DateTime wakeTime;
  final int? sleepLatencyMin;
  final int? wakeAfterSleepOnsetMin;
  final int? sleepQualityRating;
  final String? disturbances;
  final DateTime recordedAt;

  factory SleepLogModel.fromJson(Map<String, dynamic> json) {
    return SleepLogModel(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      logDate:
          DateTime.tryParse(json['log_date'] as String? ?? '') ??
          DateTime.now(),
      bedTime:
          DateTime.tryParse(json['bed_time'] as String? ?? '') ??
          DateTime.now(),
      wakeTime:
          DateTime.tryParse(json['wake_time'] as String? ?? '') ??
          DateTime.now(),
      sleepLatencyMin: _intOrNull(json['sleep_latency_min']),
      wakeAfterSleepOnsetMin: _intOrNull(json['wake_after_sleep_onset_min']),
      sleepQualityRating: _intOrNull(json['sleep_quality_rating']),
      disturbances: (json['disturbances'] as String?)?.trim(),
      recordedAt:
          DateTime.tryParse(json['recorded_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  static int? _intOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
