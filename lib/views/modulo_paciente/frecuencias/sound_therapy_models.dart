// ═══════════════════════════════════════════════════════════════════════════
//  MODELOS DE DATOS — Terapia de Sonido
//
//  Este archivo SOLO contiene datos (catálogos). No genera audio.
//  El motor de audio real lo conecta el agente (ver TODOs en sound_therapy_player_screen.dart)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

/// Una frecuencia Solfeggio/curativa seleccionable.
class SoundFrequency {
  final int hz;
  final String title; // "528Hz"
  final String description; // "Frecuencia del amor y reparación del ADN"
  final IconData icon;

  const SoundFrequency({
    required this.hz,
    required this.title,
    required this.description,
    required this.icon,
  });
}

/// Un ritmo binaural opcional (diferencia de frecuencia entre oído izq/der).
class BinauralBeat {
  final String label; // "Delta 2Hz"
  final double hz; // 2.0
  final Color accentColor;

  const BinauralBeat({
    required this.label,
    required this.hz,
    required this.accentColor,
  });
}

/// Nivel de modulación de amplitud (qué tan "pulsante" suena el tono).
enum ModulationLevel { muySutil, suave, moderado, fuerte }

extension ModulationLevelX on ModulationLevel {
  String get label {
    switch (this) {
      case ModulationLevel.muySutil:
        return 'Muy Sutil';
      case ModulationLevel.suave:
        return 'Suave';
      case ModulationLevel.moderado:
        return 'Moderado';
      case ModulationLevel.fuerte:
        return 'Fuerte';
    }
  }

  /// Profundidad de modulación 0.0–1.0 que el motor de audio puede usar
  /// para decidir cuánto varía la amplitud del tono en el tiempo.
  /// TODO(agente): ajustar estos valores según se escuchen en pruebas reales.
  double get depth {
    switch (this) {
      case ModulationLevel.muySutil:
        return 0.05;
      case ModulationLevel.suave:
        return 0.15;
      case ModulationLevel.moderado:
        return 0.30;
      case ModulationLevel.fuerte:
        return 0.50;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  CATÁLOGO — Frecuencias Solfeggio (edita aquí para agregar/quitar)
// ═══════════════════════════════════════════════════════════════════════════

const List<SoundFrequency> kSoundFrequencies = [
  SoundFrequency(
    hz: 174,
    title: '174Hz',
    description: 'Anestésico natural',
    icon: Icons.healing,
  ),
  SoundFrequency(
    hz: 396,
    title: '396Hz',
    description: 'Liberación del miedo y la culpa',
    icon: Icons.shield_outlined,
  ),
  SoundFrequency(
    hz: 417,
    title: '417Hz',
    description: 'Facilitando el cambio',
    icon: Icons.autorenew,
  ),
  SoundFrequency(
    hz: 528,
    title: '528Hz',
    description: 'Frecuencia del amor y reparación del ADN',
    icon: Icons.favorite_outline,
  ),
  SoundFrequency(
    hz: 639,
    title: '639Hz',
    description: 'Relaciones armoniosas',
    icon: Icons.people_outline,
  ),
  SoundFrequency(
    hz: 741,
    title: '741Hz',
    description: 'Despertar de la intuición',
    icon: Icons.lightbulb_outline,
  ),
  SoundFrequency(
    hz: 852,
    title: '852Hz',
    description: 'Regreso al orden espiritual',
    icon: Icons.self_improvement,
  ),
  SoundFrequency(
    hz: 963,
    title: '963Hz',
    description: 'Conciencia universal',
    icon: Icons.spa_outlined,
  ),
];

// ═══════════════════════════════════════════════════════════════════════════
//  CATÁLOGO — Ritmos Binaurales (opcional)
// ═══════════════════════════════════════════════════════════════════════════

const List<BinauralBeat> kBinauralBeats = [
  BinauralBeat(label: 'Delta 2Hz', hz: 2.0, accentColor: Color(0xFF26A69A)),
  BinauralBeat(label: 'Theta 4Hz', hz: 4.0, accentColor: Color(0xFF7B61FF)),
  BinauralBeat(label: 'Alpha 8Hz', hz: 8.0, accentColor: Color(0xFF2196F3)),
  BinauralBeat(label: 'Beta 15Hz', hz: 15.0, accentColor: Color(0xFFFF9800)),
];

// ═══════════════════════════════════════════════════════════════════════════
//  DURACIONES disponibles (en minutos)
// ═══════════════════════════════════════════════════════════════════════════

const List<int> kDurationsMinutes = [1, 3, 5, 7, 10];

// ═══════════════════════════════════════════════════════════════════════════
//  CONFIGURACIÓN DE SESIÓN — lo que el usuario eligió en la pantalla 1
//  y se pasa íntegro a la pantalla 2 (reproductor) y de ahí al motor de audio.
// ═══════════════════════════════════════════════════════════════════════════

class SoundTherapySessionConfig {
  final SoundFrequency frequency;
  final BinauralBeat? binauralBeat; // null = sin ritmo binaural
  final ModulationLevel modulation;
  final int durationMinutes;
  final double volume; // 0.0–1.0

  const SoundTherapySessionConfig({
    required this.frequency,
    required this.binauralBeat,
    required this.modulation,
    required this.durationMinutes,
    required this.volume,
  });

  Duration get duration => Duration(minutes: durationMinutes);

  @override
  String toString() =>
      'SoundTherapySessionConfig(freq: ${frequency.hz}Hz, binaural: ${binauralBeat?.label ?? "ninguno"}, '
      'mod: ${modulation.label}, duración: ${durationMinutes}min, vol: ${(volume * 100).round()}%)';
}
