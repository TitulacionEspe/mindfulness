import 'routine_model.dart';

class AssignedActivityModel {
  const AssignedActivityModel({
    required this.id,
    required this.routineId,
    required this.routine,
    required this.status,
    required this.assignedAt,
    this.targetCompletion,
  });

  final String id;
  final String routineId;
  final RoutineModel routine;
  final AssignmentStatus status;
  final DateTime assignedAt;
  final DateTime? targetCompletion;
}

enum AssignmentStatus { pending, completed, expired }

extension AssignmentStatusX on AssignmentStatus {
  static AssignmentStatus fromValue(String? value) {
    return switch (value) {
      'completed' => AssignmentStatus.completed,
      'expired' => AssignmentStatus.expired,
      _ => AssignmentStatus.pending,
    };
  }

  String get label {
    return switch (this) {
      AssignmentStatus.pending => 'Pendiente',
      AssignmentStatus.completed => 'Hecho',
      AssignmentStatus.expired => 'Vencida',
    };
  }
}
