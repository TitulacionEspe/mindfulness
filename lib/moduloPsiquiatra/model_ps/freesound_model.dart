class FreesoundResponse {
  final int count;
  final String? next;
  final List<FreesoundSound> results;

  FreesoundResponse({required this.count, this.next, required this.results});

  factory FreesoundResponse.fromJson(Map<String, dynamic> json) {
    return FreesoundResponse(
      count: json['count'] ?? 0,
      next: json['next'],
      results:
          (json['results'] as List?)
              ?.map((i) => FreesoundSound.fromJson(i))
              .toList() ??
          [],
    );
  }
}

class FreesoundSound {
  final int id;
  final String name;
  final String description;
  final double duration;
  final String previewUrl;
  final String waveformUrl;

  FreesoundSound({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.previewUrl,
    required this.waveformUrl,
  });

  factory FreesoundSound.fromJson(Map<String, dynamic> json) {
    return FreesoundSound(
      id: json['id'],
      name: json['name'] ?? 'Sin nombre',
      description: (json['description'] ?? '').replaceAll(
        RegExp(r'<[^>]*>|&[^;]+;'),
        ' ',
      ),
      duration: (json['duration'] as num?)?.toDouble() ?? 0.0,
      previewUrl: json['previews']?['preview-hq-mp3'] ?? '',
      waveformUrl: json['images']?['waveform_m'] ?? '',
    );
  }
}
