class PatientModel {
  final String id;
  final String fullName;
  final String? email;
  final double progress; // 0.0 to 1.0
  final String? currentTask;
  final DateTime? lastActivityAt;
  final int totalAssigned;
  final int totalCompleted;

  PatientModel({
    required this.id,
    required this.fullName,
    this.email,
    this.progress = 0.0,
    this.currentTask,
    this.lastActivityAt,
    this.totalAssigned = 0,
    this.totalCompleted = 0,
  });

  factory PatientModel.fromMap(
    Map<String, dynamic> map, {
    double progress = 0.0,
    String? currentTask,
    int totalAssigned = 0,
    int totalCompleted = 0,
  }) {
    return PatientModel(
      id: map['id'] as String,
      fullName: map['full_name'] as String? ?? 'Paciente sin nombre',
      email: map['email'] as String?,
      progress: progress,
      currentTask: currentTask,
      totalAssigned: totalAssigned,
      totalCompleted: totalCompleted,
    );
  }

  PatientModel copyWith({
    double? progress,
    String? currentTask,
    DateTime? lastActivityAt,
    int? totalAssigned,
    int? totalCompleted,
  }) {
    return PatientModel(
      id: id,
      fullName: fullName,
      email: email,
      progress: progress ?? this.progress,
      currentTask: currentTask ?? this.currentTask,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      totalAssigned: totalAssigned ?? this.totalAssigned,
      totalCompleted: totalCompleted ?? this.totalCompleted,
    );
  }
}
