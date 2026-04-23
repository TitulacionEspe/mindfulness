class ProfessionalFavorite {
  final String? id; // UUID de la tabla
  final String professionalId;
  final int externalId;
  final String name;
  final String previewUrl;
  final String waveformUrl;
  final String category;

  ProfessionalFavorite({
    this.id,
    required this.professionalId,
    required this.externalId,
    required this.name,
    required this.previewUrl,
    required this.waveformUrl,
    required this.category,
  });

  // Para enviar a Supabase
  Map<String, dynamic> toJson() => {
    'professional_id': professionalId,
    'external_id': externalId,
    'name': name,
    'preview_url': previewUrl,
    'waveform_url': waveformUrl,
    'category': category,
  };

  // Para leer de Supabase
  factory ProfessionalFavorite.fromJson(Map<String, dynamic> json) =>
      ProfessionalFavorite(
        id: json['id'],
        professionalId: json['professional_id'],
        externalId: json['external_id'],
        name: json['name'],
        previewUrl: json['preview_url'],
        waveformUrl: json['waveform_url'],
        category: json['category'],
      );
}
