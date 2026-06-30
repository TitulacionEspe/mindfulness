// ═══════════════════════════════════════════════════════════════════════════
//  MOTOR DE AUDIO — Síntesis PCM en tiempo real
//
//  Este archivo contiene:
//  1. SoundTherapyEngine (contrato abstracto)
//  2. RealSoundEngine (implementación real con flutter_pcm_sound)
//  3. PlaceholderSoundEngine (fallback para plataformas sin soporte PCM)
//  4. Factory createSoundTherapyEngine()
//
//  El motor genera ondas seno puras con soporte para:
//  - Ritmos binaurales (frecuencia distinta por canal L/R)
//  - Modulación de amplitud (AM) configurable
//  - Control de volumen en vivo
//  - Pause/Resume sin perder fase
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_pcm_sound/flutter_pcm_sound.dart';

import 'sound_therapy_models.dart';

/// Contrato que cualquier motor de audio debe cumplir.
abstract class SoundTherapyEngine {
  /// Inicia la generación/reproducción del tono según [config].
  Future<void> start(SoundTherapySessionConfig config);

  /// Pausa la reproducción (mantiene el progreso).
  Future<void> pause();

  /// Reanuda después de pause().
  Future<void> resume();

  /// Detiene completamente y libera recursos.
  Future<void> stop();

  /// Cambia el volumen en vivo sin reiniciar la sesión (0.0–1.0).
  Future<void> setVolumeLive(double volume);

  /// Stream que emite el tiempo restante cada segundo mientras suena.
  /// La UI lo escucha para actualizar el contador "4:59", la barra, etc.
  Stream<Duration> get remainingTimeStream;

  /// Se completa cuando la sesión termina naturalmente (tiempo agotado).
  Future<void> get onCompleted;

  /// Libera recursos (llamar en dispose() de la pantalla).
  void dispose();
}

// ═══════════════════════════════════════════════════════════════════════════
//  IMPLEMENTACIÓN REAL — Síntesis de audio con flutter_pcm_sound
//
//  Genera ondas seno PCM 16-bit estéreo interleaved (L, R, L, R...).
//  Cada canal puede tener una frecuencia distinta para ritmos binaurales.
//  La modulación de amplitud se aplica a nivel de sample individual.
// ═══════════════════════════════════════════════════════════════════════════

class RealSoundEngine implements SoundTherapyEngine {
  // ─── Constantes de audio ───────────────────────────────────────────
  static const int _sampleRate = 44100;
  static const int _channelCount = 2; // estéreo
  static const int _chunkFrames = 4096; // frames por feed
  static const double _modRate = 0.2; // Hz — pulso AM lento y suave

  // ─── Estado de síntesis ────────────────────────────────────────────
  SoundTherapySessionConfig? _config;
  double _volume = 1.0;
  bool _paused = false;
  bool _running = false;

  /// Fase acumulada en samples — mantiene continuidad de la onda
  /// incluso entre feeds para evitar clicks/pops.
  int _sampleOffset = 0;

  // ─── Timer de duración ─────────────────────────────────────────────
  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;
  final _remainingController = StreamController<Duration>.broadcast();
  Completer<void> _completer = Completer<void>();

  // ─── Flag de inicialización del plugin ─────────────────────────────
  bool _pcmInitialized = false;

  @override
  Stream<Duration> get remainingTimeStream => _remainingController.stream;

  @override
  Future<void> get onCompleted => _completer.future;

  @override
  Future<void> start(SoundTherapySessionConfig config) async {
    _config = config;
    _volume = config.volume;
    _sampleOffset = 0;
    _paused = false;
    _running = true;

    // Reiniciar el completer si ya se usó previamente
    if (_completer.isCompleted) {
      _completer = Completer<void>();
    }

    // ─── Inicializar flutter_pcm_sound en estéreo ────────────────
    try {
      await FlutterPcmSound.setup(
        sampleRate: _sampleRate,
        channelCount: _channelCount,
      );
      _pcmInitialized = true;

      // Umbral de buffer: cuando quedan menos de 8000 frames,
      // el callback se dispara para alimentar más datos.
      await FlutterPcmSound.setFeedThreshold(8000);

      // Registrar callback de alimentación
      FlutterPcmSound.setFeedCallback(_onFeedRequested);

      // Alimentar buffer inicial antes de dar play
      _generateAndFeed();
      _generateAndFeed(); // doble seed para evitar underruns al inicio
    } catch (e) {
      debugPrint('[RealSoundEngine] Error al inicializar PCM: $e');
      // En caso de error, caer en modo silencioso (solo timer)
      _pcmInitialized = false;
    }

    // ─── Timer de conteo regresivo ───────────────────────────────
    _remaining = config.duration;
    _remainingController.add(_remaining);

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_paused) return;

      if (_remaining.inSeconds <= 1) {
        _remaining = Duration.zero;
        _remainingController.add(_remaining);
        _stopAudio();
        _countdownTimer?.cancel();
        if (!_completer.isCompleted) _completer.complete();
        return;
      }

      _remaining -= const Duration(seconds: 1);
      _remainingController.add(_remaining);
    });
  }

  /// Callback invocado por flutter_pcm_sound cuando el buffer baja
  /// del umbral. Genera y alimenta un nuevo chunk de PCM.
  void _onFeedRequested(int remainingFrames) {
    if (!_running || _paused) return;
    _generateAndFeed();
  }

  /// Genera un chunk de samples estéreo (interleaved L/R) y lo envía
  /// al plugin PCM para reproducción inmediata.
  void _generateAndFeed() {
    if (!_running || _paused || _config == null || !_pcmInitialized) return;

    final cfg = _config!;
    final freqL = cfg.frequency.hz.toDouble();
    final freqR = cfg.binauralBeat != null
        ? freqL + cfg.binauralBeat!.hz
        : freqL;
    final modDepth = cfg.modulation.depth;

    // Buffer interleaved: [L0, R0, L1, R1, ...]
    final samples = List<int>.filled(_chunkFrames * _channelCount, 0);

    for (int i = 0; i < _chunkFrames; i++) {
      // Tiempo absoluto en segundos para este sample
      final t = (_sampleOffset + i) / _sampleRate;

      // ─── Modulación de amplitud (AM) ───────────────────────
      // amplitud(t) = 1.0 - depth + depth * sin(2π * modRate * t)
      // Produce un pulso suave y lento.
      final am = 1.0 - modDepth + modDepth * sin(2 * pi * _modRate * t);

      // Amplitud final: volumen × modulación × rango Int16
      final amp = _volume * am * 32767.0;

      // ─── Canal izquierdo: frecuencia base ──────────────────
      final sampleL = (sin(2 * pi * freqL * t) * amp).round().clamp(
        -32767,
        32767,
      );

      // ─── Canal derecho: frecuencia base + offset binaural ──
      final sampleR = (sin(2 * pi * freqR * t) * amp).round().clamp(
        -32767,
        32767,
      );

      samples[i * 2] = sampleL;
      samples[i * 2 + 1] = sampleR;
    }

    _sampleOffset += _chunkFrames;

    // Enviar al hardware de audio
    try {
      FlutterPcmSound.feed(PcmArrayInt16.fromList(samples));
    } catch (e) {
      debugPrint('[RealSoundEngine] Error al enviar PCM: $e');
    }
  }

  @override
  Future<void> pause() async {
    _paused = true;
    // El buffer existente se drena naturalmente → silencio.
    // No hacemos FlutterPcmSound.stop() para evitar re-setup.
  }

  @override
  Future<void> resume() async {
    if (!_running) return;
    _paused = false;
    // Reanudar la alimentación de samples
    if (_pcmInitialized) {
      _generateAndFeed();
    }
  }

  @override
  Future<void> stop() async {
    _countdownTimer?.cancel();
    _stopAudio();
  }

  /// Detiene la generación de audio y limpia el estado del plugin.
  void _stopAudio() {
    _running = false;
    _paused = false;

    if (_pcmInitialized) {
      try {
        FlutterPcmSound.setFeedCallback(null);
        FlutterPcmSound.release();
      } catch (e) {
        debugPrint('[RealSoundEngine] Error al liberar PCM: $e');
      }
      _pcmInitialized = false;
    }
  }

  @override
  Future<void> setVolumeLive(double volume) async {
    // El cambio de volumen toma efecto inmediato en el siguiente
    // chunk generado — sin reiniciar la síntesis.
    _volume = volume.clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _stopAudio();
    _remainingController.close();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  IMPLEMENTACIÓN PLACEHOLDER (fallback para plataformas sin PCM)
//
//  Esta clase NO genera audio real. Solo simula el paso del tiempo con un
//  Timer, para que la pantalla 2 (reproductor) funcione visualmente.
//  Se usa automáticamente en web/windows donde flutter_pcm_sound no opera.
// ═══════════════════════════════════════════════════════════════════════════

class PlaceholderSoundEngine implements SoundTherapyEngine {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _paused = false;

  final _remainingController = StreamController<Duration>.broadcast();
  Completer<void> _completer = Completer<void>();

  @override
  Stream<Duration> get remainingTimeStream => _remainingController.stream;

  @override
  Future<void> get onCompleted => _completer.future;

  @override
  Future<void> start(SoundTherapySessionConfig config) async {
    _remaining = config.duration;
    _remainingController.add(_remaining);

    if (_completer.isCompleted) {
      _completer = Completer<void>();
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_paused) return;
      if (_remaining.inSeconds <= 1) {
        _remaining = Duration.zero;
        _remainingController.add(_remaining);
        _timer?.cancel();
        if (!_completer.isCompleted) _completer.complete();
        return;
      }
      _remaining -= const Duration(seconds: 1);
      _remainingController.add(_remaining);
    });
  }

  @override
  Future<void> pause() async {
    _paused = true;
  }

  @override
  Future<void> resume() async {
    _paused = false;
  }

  @override
  Future<void> stop() async {
    _timer?.cancel();
  }

  @override
  Future<void> setVolumeLive(double volume) async {}

  @override
  void dispose() {
    _timer?.cancel();
    _remainingController.close();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  FACTORY — punto único para intercambiar el motor.
//
//  Usa RealSoundEngine en plataformas con soporte PCM (Android, iOS, macOS).
//  En web o Windows cae al PlaceholderSoundEngine.
// ═══════════════════════════════════════════════════════════════════════════

SoundTherapyEngine createSoundTherapyEngine() {
  // flutter_pcm_sound soporta Android, iOS, macOS.
  // En web u otras plataformas sin soporte, usar placeholder.
  if (kIsWeb) {
    return PlaceholderSoundEngine();
  }
  return RealSoundEngine();
}
