import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../core/theme/app_colors.dart';

class BubbleData {
  final int id;
  final Offset position;
  bool isPopped;
  double scale;

  BubbleData({
    required this.id,
    required this.position,
    this.isPopped = false,
    this.scale = 1.0,
  });
}

class BubblesExerciseView extends StatefulWidget {
  const BubblesExerciseView({super.key});

  @override
  State<BubblesExerciseView> createState() => _BubblesExerciseViewState();
}

class _BubblesExerciseViewState extends State<BubblesExerciseView> {
  final List<BubbleData> _bubbles = [];

  final double _bubbleSize = 54.0;
  final double _bubbleSpacing = 9.0;
  final int _cols = 5;
  final int _rows = 6;

  final AudioPlayer _audioPlayer = AudioPlayer();

  // ── Controles de experiencia ──────────────────────────────────────────
  bool _soundEnabled = true;
  bool _classicSoundEnabled = false; // Audio WAV como secundario
  bool _regenerativeMode = false;

  @override
  void initState() {
    super.initState();
    _generateBubbles();

    // Precarga el sonido para evitar delay en la primera explosión
    _audioPlayer.setSource(AssetSource('sounds/burbuja.wav'));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _generateBubbles() {
    _bubbles.clear();
    int id = 0;
    for (int r = 0; r < _rows; r++) {
      for (int c = 0; c < _cols; c++) {
        _bubbles.add(
          BubbleData(
            id: id++,
            position: Offset(
              c * (_bubbleSize + _bubbleSpacing),
              r * (_bubbleSize + _bubbleSpacing),
            ),
          ),
        );
      }
    }
  }

  // ── Generador de sonido sintético rápido ──────────────────────────────
  String _generatePopSound() {
    const sampleRate = 44100;
    const duration = 0.08; // Muy corto (80ms) para respuesta ultra rápida
    const numSamples = (sampleRate * duration);
    // Para el "pop", iniciamos con una frecuencia media que sube bruscamente (efecto burbuja rápida)
    const startFrequency = 400.0;
    const endFrequency = 800.0;

    final dataSize = (numSamples * 2).toInt();
    final bytes = BytesBuilder();

    // RIFF header
    bytes.add(utf8.encode('RIFF'));
    bytes.add(_int32ToBytes(36 + dataSize));
    bytes.add(utf8.encode('WAVE'));

    // fmt subchunk
    bytes.add(utf8.encode('fmt '));
    bytes.add(_int32ToBytes(16));
    bytes.add(_int16ToBytes(1));
    bytes.add(_int16ToBytes(1)); // Mono
    bytes.add(_int32ToBytes(sampleRate));
    bytes.add(_int32ToBytes(sampleRate * 2));
    bytes.add(_int16ToBytes(2));
    bytes.add(_int16ToBytes(16));

    // data subchunk
    bytes.add(utf8.encode('data'));
    bytes.add(_int32ToBytes(dataSize));

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      // Barrido de frecuencia ascendente
      final freq =
          startFrequency + ((endFrequency - startFrequency) * (t / duration));
      // Envolvente rápida para el "click"
      final envelope = math.exp(-30.0 * t);

      final wave = math.sin(2 * math.pi * freq * t);

      final sample = (wave * envelope * 0.8 * 32767).toInt().clamp(
        -32768,
        32767,
      );
      bytes.add(_int16ToBytes(sample));
    }

    final base64String = base64Encode(bytes.toBytes());
    return 'data:audio/wav;base64,$base64String';
  }

  List<int> _int32ToBytes(int value) => [
    value & 0xFF,
    (value >> 8) & 0xFF,
    (value >> 16) & 0xFF,
    (value >> 24) & 0xFF,
  ];

  List<int> _int16ToBytes(int value) => [value & 0xFF, (value >> 8) & 0xFF];

  // ── Sonido (respeta el toggle) ────────────────────────────────────────
  Future<void> _playPopSound() async {
    if (!_soundEnabled) return;

    try {
      await _audioPlayer.stop();
      if (!_classicSoundEnabled) {
        // En Android/iOS AudioPlayer de audioplayers a veces tarda con data URIs grandes.
        // Pero para muestras muy cortas funciona bien, o se puede alternar la fuente.
        // Si el usuario exije velocidad pura, la generación en tiempo real puede introducir un lag mínimo por la decodificación.
        // Lo generamos:
        final uri = _generatePopSound();
        await _audioPlayer.setSource(UrlSource(uri));
      } else {
        await _audioPlayer.setSource(AssetSource('sounds/burbuja.wav'));
      }
      // Pequeña variación de pitch aleatoria para que no suenen todas idénticas
      final pitch = 0.9 + (math.Random().nextDouble() * 0.3); // 0.9 a 1.2
      await _audioPlayer.setPlaybackRate(pitch);
      await _audioPlayer.resume();
    } catch (_) {}
  }

  // ── Explotar burbuja ──────────────────────────────────────────────────
  void _popBubble(int index) {
    if (_bubbles[index].isPopped) return;

    HapticFeedback.heavyImpact();
    _playPopSound();

    setState(() {
      _bubbles[index].isPopped = true;
      _bubbles[index].scale = 1.3;
    });

    Future.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      setState(() {
        _bubbles[index].scale = 0.86;
      });
    });

    // Modo regenerativo: la burbuja reaparece sola
    if (_regenerativeMode) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        setState(() {
          _bubbles[index].isPopped = false;
          _bubbles[index].scale = 1.0;
        });
      });
    }
  }

  // ── Reiniciar todas las burbujas ──────────────────────────────────────
  void _resetBubbles() {
    HapticFeedback.mediumImpact();
    setState(() {
      for (final b in _bubbles) {
        b.isPopped = false;
        b.scale = 1.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double gridWidth = _cols * _bubbleSize + (_cols - 1) * _bubbleSpacing;
    final double gridHeight =
        _rows * _bubbleSize + (_rows - 1) * _bubbleSpacing;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bubble_chart, color: AppColors.mint, size: 22),
            const SizedBox(width: 8),
            Text(
              'Burbujas antiestrés',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: BackButton(color: AppColors.textPrimary),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(Icons.info_outline, color: AppColors.textPrimary),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // Subtítulo
              Text(
                'Toca para explotar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.mint,
                ),
              ),

              const SizedBox(height: 14),

              // Tarjeta blanca con cuadrícula centrada
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: SizedBox(
                    width: gridWidth,
                    height: gridHeight,
                    child: Stack(
                      children: _bubbles.asMap().entries.map((entry) {
                        final index = entry.key;
                        final bubble = entry.value;
                        return Positioned(
                          left: bubble.position.dx,
                          top: bubble.position.dy,
                          child: GestureDetector(
                            onTap: () => _popBubble(index),
                            child: AnimatedScale(
                              scale: bubble.scale,
                              duration: const Duration(milliseconds: 120),
                              curve: Curves.easeOutBack,
                              child: _BubbleWidget(
                                size: _bubbleSize,
                                isPopped: bubble.isPopped,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Botón Reiniciar — justo debajo de la tarjeta
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _resetBubbles,
                  icon: Icon(Icons.refresh, color: AppColors.buttonPrimaryText),
                  label: Text(
                    'Reiniciar burbujas',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: AppColors.buttonPrimaryText,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Toggles: Sonido y Regenerativo ───────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Column(
                  children: [
                    // Toggle Sonido
                    SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      dense: true,
                      title: Row(
                        children: [
                          Icon(
                            _soundEnabled ? Icons.volume_up : Icons.volume_off,
                            size: 20,
                            color: _soundEnabled
                                ? AppColors.mint
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Sonido de explosión',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: _soundEnabled
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      value: _soundEnabled,
                      activeThumbColor: AppColors.mint,
                      onChanged: (val) {
                        setState(() {
                          _soundEnabled = val;
                        });
                      },
                    ),
                    // Toggle Regenerativo
                    SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      dense: true,
                      title: Row(
                        children: [
                          Icon(
                            Icons.autorenew,
                            size: 20,
                            color: _regenerativeMode
                                ? AppColors.mint
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Burbujas infinitas',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: _regenerativeMode
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      value: _regenerativeMode,
                      activeThumbColor: AppColors.mint,
                      onChanged: (val) {
                        setState(() {
                          _regenerativeMode = val;
                        });
                      },
                    ),
                    // Toggle Sonido Clásico (Solo si el sonido general está activo)
                    if (_soundEnabled)
                      SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        dense: true,
                        title: Row(
                          children: [
                            Icon(
                              Icons.slow_motion_video_rounded,
                              size: 20,
                              color: _classicSoundEnabled
                                  ? AppColors.mint
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Usar audio clásico (lento)',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: _classicSoundEnabled
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        value: _classicSoundEnabled,
                        activeThumbColor: AppColors.mint,
                        onChanged: (val) {
                          setState(() {
                            _classicSoundEnabled = val;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget de burbuja individual
// ─────────────────────────────────────────────────────────────────────────────
class _BubbleWidget extends StatelessWidget {
  final double size;
  final bool isPopped;

  const _BubbleWidget({required this.size, required this.isPopped});

  @override
  Widget build(BuildContext context) {
    if (isPopped) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surfaceHigh,
          border: Border.all(color: AppColors.outlineVariant, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.surfaceLowest.withValues(alpha: 0.10),
              blurRadius: 4,
              offset: const Offset(1, 1),
            ),
          ],
        ),
      );
    }

    // Burbuja activa con gradiente y brillo
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [AppColors.secondaryContainer, AppColors.mint],
          center: Alignment(-0.3, -0.3),
        ),
        border: Border.all(color: AppColors.mint, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.surfaceBright.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(-2, -2),
          ),
          BoxShadow(
            color: AppColors.surfaceLowest.withValues(alpha: 0.20),
            blurRadius: 8,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Align(
        alignment: const Alignment(-0.25, -0.4),
        child: Container(
          width: size * 0.3,
          height: size * 0.18,
          decoration: BoxDecoration(
            color: AppColors.surfaceBright.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
