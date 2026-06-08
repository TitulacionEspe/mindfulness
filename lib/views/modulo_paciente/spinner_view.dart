import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/theme/app_colors.dart';

class SpinnerView extends StatefulWidget {
  const SpinnerView({super.key});

  @override
  State<SpinnerView> createState() => _SpinnerViewState();
}

class _SpinnerViewState extends State<SpinnerView>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _angle = 0.0;
  double _angularVelocity = 0.0;
  final GlobalKey _spinnerKey = GlobalKey();

  bool _audioEnabled = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    _initAudio();

    _ticker = createTicker((_) {
      if (_angularVelocity.abs() > 0.001) {
        setState(() {
          _angle += _angularVelocity;
          _angularVelocity *= 0.982; // fricción suave
        });
        _updateAudio();
      } else if (_angularVelocity != 0.0) {
        setState(() => _angularVelocity = 0.0);
        _updateAudio();
      }
    });
    _ticker.start();
  }

  Future<void> _initAudio() async {
    // Generar el zumbido dinámico en base64
    final audioUri = _generateSpinnerSound();
    await _audioPlayer.setUrl(audioUri);
    await _audioPlayer.setLoopMode(LoopMode.one);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // ── Generador de Onda Sintética (Hz) ──────────────────────────────────────
  String _generateSpinnerSound() {
    const sampleRate = 44100;
    const duration = 1.0;
    const numSamples = (sampleRate * duration);
    const frequency = 120.0; // Frecuencia base del zumbido (Hz)

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

    final random = math.Random();

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      // Mezcla de ondas para sonido de rodamiento hueco
      final wave1 = math.sin(2 * math.pi * frequency * t);
      final wave2 = math.sin(2 * math.pi * frequency * 2 * t) * 0.3;
      // Ruido para la fricción metálica
      final noise = (random.nextDouble() * 2 - 1) * 0.15;

      final sample = ((wave1 + wave2 + noise) * 0.4 * 32767).toInt().clamp(
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

  // ── Audio helpers dinámicos ───────────────────────────────────────────────
  void _updateAudio() {
    final speed = _angularVelocity.abs();

    if (_audioEnabled && speed > 0.02) {
      // Modificamos dinámicamente los Hz (pitch) según la velocidad
      final pitch = (speed * 1.5).clamp(0.5, 2.0);
      // El volumen también responde a la inercia
      final volume = (speed / 1.2).clamp(0.0, 1.0);

      _audioPlayer.setPitch(pitch);
      _audioPlayer.setVolume(volume);

      if (!_audioPlayer.playing) {
        _audioPlayer.play();
      }
    } else {
      if (_audioPlayer.playing) {
        _audioPlayer.pause();
      }
    }
  }

  void _toggleAudio() {
    HapticFeedback.selectionClick();
    setState(() => _audioEnabled = !_audioEnabled);
    _updateAudio();
  }

  // ── Física de giro ────────────────────────────────────────────────────────
  void _onPanUpdate(DragUpdateDetails details) {
    final renderBox =
        _spinnerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final center = Offset(size.width / 2, size.height / 2);
    final dx = details.localPosition.dx - center.dx;
    final dy = details.localPosition.dy - center.dy;
    final tangentialForce = (dx * details.delta.dy) - (dy * details.delta.dx);

    setState(() {
      _angularVelocity += tangentialForce / 9000.0;
      _angularVelocity = _angularVelocity.clamp(-1.2, 1.2);
    });
  }

  void _impulso() {
    HapticFeedback.heavyImpact();
    setState(() {
      // Agrega velocidad en la dirección actual de giro (o clockwise si está parado)
      final boost = _angularVelocity >= 0 ? 0.6 : -0.6;
      _angularVelocity = (_angularVelocity + boost).clamp(-1.2, 1.2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh, color: AppColors.mint, size: 22),
            const SizedBox(width: 8),
            Text(
              'Fidget spinner',
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
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Instrucción
            Text(
              'Desliza los bordes rápido para girar',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),

            const Spacer(),

            // Spinner
            Center(
              child: GestureDetector(
                onPanUpdate: _onPanUpdate,
                child: Container(
                  key: _spinnerKey,
                  width: 300,
                  height: 300,
                  color: Colors.transparent,
                  child: Transform.rotate(
                    angle: _angle,
                    child: const _SpinnerWidget(size: 300),
                  ),
                ),
              ),
            ),

            const Spacer(),

            // ── Botones ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Row(
                children: [
                  // Audio Off / On
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _toggleAudio,
                      icon: Icon(
                        _audioEnabled
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                      label: Text(
                        _audioEnabled ? 'Sonido' : 'Mudo',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: AppColors.outlineVariant,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        backgroundColor: AppColors.surface,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Impulso rápido
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _impulso,
                      icon: Icon(
                        Icons.bolt_rounded,
                        color: AppColors.buttonPrimaryText,
                        size: 20,
                      ),
                      label: Text(
                        'Impulso rápido',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.buttonPrimaryText,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget visual del Spinner con gradientes 3D
// ─────────────────────────────────────────────────────────────────────────────
class _SpinnerWidget extends StatelessWidget {
  final double size;
  const _SpinnerWidget({required this.size});

  static const double _wingOffset = 82.0;
  static const double _wingSize = 108.0;
  static const double _centerSize = 88.0;
  static const double _bearingSize = 36.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // ── Sombra global del conjunto ────────────────────────────────────
        Container(
          width: size * 0.55,
          height: size * 0.55,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.mint.withValues(alpha: 0.18),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
        ),

        // ── Ala 1 (arriba) ────────────────────────────────────────────────
        Transform.translate(
          offset: const Offset(0, -_wingOffset),
          child: _buildWing(),
        ),

        // ── Ala 2 (abajo izquierda, 120°) ─────────────────────────────────
        Transform.rotate(
          angle: 2 * math.pi / 3,
          child: Transform.translate(
            offset: const Offset(0, -_wingOffset),
            child: _buildWing(),
          ),
        ),

        // ── Ala 3 (abajo derecha, 240°) ───────────────────────────────────
        Transform.rotate(
          angle: 4 * math.pi / 3,
          child: Transform.translate(
            offset: const Offset(0, -_wingOffset),
            child: _buildWing(),
          ),
        ),

        // ── Centro (rodamiento principal) ─────────────────────────────────
        Container(
          width: _centerSize,
          height: _centerSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.secondaryContainer,
                AppColors.mint,
                AppColors.buttonPrimaryText,
              ],
              stops: [0.0, 0.5, 1.0],
              center: Alignment(-0.3, -0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.surfaceLowest.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(3, 5),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: _bearingSize,
              height: _bearingSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.surfaceBright, AppColors.mint],
                  center: Alignment(-0.3, -0.4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWing() {
    return Container(
      width: _wingSize,
      height: _wingSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.secondaryContainer,
            AppColors.mint,
            AppColors.buttonPrimaryText,
          ],
          stops: [0.0, 0.5, 1.0],
          center: Alignment(-0.25, -0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.surfaceLowest.withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(3, 6),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: _wingSize * 0.38,
          height: _wingSize * 0.38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [AppColors.surfaceBright, AppColors.mint],
              center: Alignment(-0.3, -0.4),
            ),
          ),
        ),
      ),
    );
  }
}
