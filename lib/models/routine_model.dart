class RoutineModel {
  const RoutineModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.durationSeconds,
    this.breathingPattern,
    this.audioUrl,
    this.createdBy,
  });

  final String id;
  final String title;
  final String description;
  final RoutineCategory category;
  final int durationSeconds;
  final BreathingPatternModel? breathingPattern;
  final String? audioUrl;
  final String? createdBy;

  factory RoutineModel.fromMap(
    Map<String, dynamic> map, {
    BreathingPatternModel? breathingPattern,
    String? audioUrl,
  }) {
    return RoutineModel(
      id: map['id'] as String,
      title: map['title'] as String? ?? 'Rutina sin título',
      description: map['description'] as String? ?? '',
      category: RoutineCategoryX.fromValue(map['category'] as String?),
      durationSeconds: map['duration_seconds'] as int? ?? 180,
      breathingPattern: breathingPattern,
      audioUrl: audioUrl,
      createdBy: map['created_by'] as String?,
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
    this.inhaleSound = 'sounds/bell.wav',
    this.holdInSound = 'sounds/burbuja.wav',
    this.exhaleSound = 'sounds/platillo.wav',
    this.holdOutSound = 'sounds/burbuja.wav',
  });

  final String routineId;
  final int inhaleSec;
  final int holdInSec;
  final int exhaleSec;
  final int holdOutSec;
  final int cyclesRecommended;
  final String inhaleSound;
  final String holdInSound;
  final String exhaleSound;
  final String holdOutSound;

  factory BreathingPatternModel.fromMap(Map<String, dynamic> map) {
    return BreathingPatternModel(
      routineId: map['routine_id'] as String,
      inhaleSec: map['inhale_sec'] as int? ?? 4,
      holdInSec: map['hold_in_sec'] as int? ?? 0,
      exhaleSec: map['exhale_sec'] as int? ?? 6,
      holdOutSec: map['hold_out_sec'] as int? ?? 0,
      cyclesRecommended: map['cycles_recommended'] as int? ?? 5,
      inhaleSound: map['inhale_sound'] as String? ?? 'sounds/bell.wav',
      holdInSound: map['hold_in_sound'] as String? ?? 'sounds/burbuja.wav',
      exhaleSound: map['exhale_sound'] as String? ?? 'sounds/platillo.wav',
      holdOutSound: map['hold_out_sound'] as String? ?? 'sounds/burbuja.wav',
    );
  }
}

enum RoutineCategory {
  all,
  breathing,
  relaxation,
  sleepInduction,
  soundscape,
  terapiaSonido,
}

extension RoutineCategoryX on RoutineCategory {
  static RoutineCategory fromValue(String? value) {
    return switch (value) {
      'breathing' => RoutineCategory.breathing,
      'relaxation' => RoutineCategory.relaxation,
      'sleep_induction' => RoutineCategory.sleepInduction,
      'soundscape' => RoutineCategory.soundscape,
      'terapia_sonido' => RoutineCategory.terapiaSonido,
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
      RoutineCategory.terapiaSonido => 'terapia_sonido',
    };
  }

  String get label {
    return switch (this) {
      RoutineCategory.all => 'Todas',
      RoutineCategory.breathing => 'Respiración',
      RoutineCategory.relaxation => 'Relajación',
      RoutineCategory.sleepInduction => 'Descanso',
      RoutineCategory.soundscape => 'Ambiente',
      RoutineCategory.terapiaSonido => 'Sonidos guiados',
    };
  }
}
