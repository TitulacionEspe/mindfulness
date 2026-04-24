class RoutineModel {
  const RoutineModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.durationSeconds,
    this.breathingPattern,
  });

  final String id;
  final String title;
  final String description;
  final RoutineCategory category;
  final int durationSeconds;
  final BreathingPatternModel? breathingPattern;

  factory RoutineModel.fromMap(
    Map<String, dynamic> map, {
    BreathingPatternModel? breathingPattern,
  }) {
    return RoutineModel(
      id: map['id'] as String,
      title: map['title'] as String? ?? 'Rutina sin titulo',
      description: map['description'] as String? ?? '',
      category: RoutineCategoryX.fromValue(map['category'] as String?),
      durationSeconds: map['duration_seconds'] as int? ?? 180,
      breathingPattern: breathingPattern,
    );
  }

  String get durationLabel {
    final minutes = (durationSeconds / 60).ceil();
    return '$minutes min';
  }
}

class BreathingPatternModel {
  const BreathingPatternModel({
    required this.routineId,
    required this.inhaleSec,
    required this.holdInSec,
    required this.exhaleSec,
    required this.holdOutSec,
    required this.cyclesRecommended,
  });

  final String routineId;
  final int inhaleSec;
  final int holdInSec;
  final int exhaleSec;
  final int holdOutSec;
  final int cyclesRecommended;

  factory BreathingPatternModel.fromMap(Map<String, dynamic> map) {
    return BreathingPatternModel(
      routineId: map['routine_id'] as String,
      inhaleSec: map['inhale_sec'] as int? ?? 4,
      holdInSec: map['hold_in_sec'] as int? ?? 0,
      exhaleSec: map['exhale_sec'] as int? ?? 6,
      holdOutSec: map['hold_out_sec'] as int? ?? 0,
      cyclesRecommended: map['cycles_recommended'] as int? ?? 5,
    );
  }
}

enum RoutineCategory { all, breathing, relaxation, sleepInduction, soundscape }

extension RoutineCategoryX on RoutineCategory {
  static RoutineCategory fromValue(String? value) {
    return switch (value) {
      'breathing' => RoutineCategory.breathing,
      'relaxation' => RoutineCategory.relaxation,
      'sleep_induction' => RoutineCategory.sleepInduction,
      'soundscape' => RoutineCategory.soundscape,
      _ => RoutineCategory.relaxation,
    };
  }

  String get value {
    return switch (this) {
      RoutineCategory.all => 'all',
      RoutineCategory.breathing => 'breathing',
      RoutineCategory.relaxation => 'relaxation',
      RoutineCategory.sleepInduction => 'sleep_induction',
      RoutineCategory.soundscape => 'soundscape',
    };
  }

  String get label {
    return switch (this) {
      RoutineCategory.all => 'Todas',
      RoutineCategory.breathing => 'Respiracion',
      RoutineCategory.relaxation => 'Relajacion',
      RoutineCategory.sleepInduction => 'Descanso',
      RoutineCategory.soundscape => 'Ambiente',
    };
  }
}
