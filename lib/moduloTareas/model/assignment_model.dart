import '../../models/routine_model.dart';

class Assignment {
  final String id;
  final String routineId;
  final String title;
  final String description;
  final String category;
  final String status; // 'pending', 'completed', 'expired'
  final Map<String, dynamic> breathingPattern;

  Assignment({
    required this.id,
    required this.routineId,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.breathingPattern,
  });

  /// Convierte esta asignación al modelo base de Rutinas para reusar vistas
  RoutineModel toRoutineModel() {
    final cat = RoutineCategoryX.fromValue(category);

    // Solo asignar patrón de respiración si la categoría lo requiere
    // O si los datos del patrón tienen sentido (ciclos > 0)
    final hasPattern =
        cat == RoutineCategory.breathing ||
        (breathingPattern['cycles_recommended'] ?? 0) > 0;

    return RoutineModel(
      id: routineId,
      title: title,
      description: description,
      category: cat,
      durationSeconds: totalDuration,
      breathingPattern: hasPattern
          ? BreathingPatternModel(
              routineId: routineId,
              inhaleSec: breathingPattern['inhale_sec'] ?? 4,
              holdInSec: breathingPattern['hold_in_sec'] ?? 0,
              exhaleSec: breathingPattern['exhale_sec'] ?? 6,
              holdOutSec: breathingPattern['hold_out_sec'] ?? 0,
              cyclesRecommended: breathingPattern['cycles_recommended'] ?? 5,
            )
          : null,
    );
  }

  factory Assignment.fromJson(Map<String, dynamic> json) {
    // Supabase Join: 'routines' puede venir como objeto o lista
    final dynamic routineRaw = json['routines'];
    final Map<String, dynamic> routine = (routineRaw is List)
        ? (routineRaw.isNotEmpty ? routineRaw[0] : {})
        : (routineRaw ?? {});

    // Extraer patrón de respiración (breathing_patterns es 1:1 con routines)
    final dynamic patternRaw = routine['breathing_patterns'];
    final Map<String, dynamic>? pattern = (patternRaw is List)
        ? (patternRaw.isNotEmpty ? patternRaw[0] : null)
        : (patternRaw as Map<String, dynamic>?);

    return Assignment(
      id: json['id']?.toString() ?? '',
      routineId: json['routine_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      title: routine['title'] ?? 'Sin título',
      description: routine['description'] ?? '',
      category: routine['category'] ?? 'relaxation',
      breathingPattern: pattern ?? {},
    );
  }

  /// Calcula la duración total teórica en segundos
  int get totalDuration {
    final int inhale = breathingPattern['inhale_sec'] ?? 4;
    final int holdIn = breathingPattern['hold_in_sec'] ?? 2;
    final int exhale = breathingPattern['exhale_sec'] ?? 6;
    final int holdOut = breathingPattern['hold_out_sec'] ?? 0;
    final int cycles = breathingPattern['cycles_recommended'] ?? 5;
    return (inhale + holdIn + exhale + holdOut) * cycles;
  }
}
