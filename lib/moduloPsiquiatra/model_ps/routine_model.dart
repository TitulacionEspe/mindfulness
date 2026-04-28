class RoutineTemplate {
  final String id; // Quitamos el '?' para obligar a que tenga ID
  final String title;
  final String description;
  final String category;

  RoutineTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
  });

  factory RoutineTemplate.fromJson(Map<String, dynamic> json) =>
      RoutineTemplate(
        id: json['id']?.toString() ?? '',
        title:
            json['title']?.toString() ?? 'Sin título', // 👈 Valor por defecto
        description: json['description']?.toString() ?? '',
        category: json['category']?.toString() ?? 'general',
      );
}
