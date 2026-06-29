import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/theme/app_colors.dart';

class StressBallView extends StatefulWidget {
  const StressBallView({super.key});

  @override
  State<StressBallView> createState() => _StressBallViewState();
}

class _StressBallViewState extends State<StressBallView>
    with TickerProviderStateMixin {
  // ── Física ────────────────────────────────────────────────────────────────
  static const double _ballRadius = 70.0;
  static const double _gravity = 980.0;
  static const double _restitution = 0.72;
  static const double _friction = 0.985;
  static const double _minBounceVelocity = 80;

  // Espacio reservado abajo: contador + botón + paddings
  static const double _bottomUiHeight = 160.0;

  Offset _position = const Offset(200, 400);
  Offset _velocity = Offset.zero;

  bool _isDragging = false;
  bool _hasDragged = false; // Para ocultar la instrucción de onboarding
  bool _audioEnabled = true; // Sonido activado por defecto
  late Ticker _ticker;
  late AnimationController _onboardingController;
  DateTime _lastTickTime = DateTime.now();
  int _bounceCount = 0;
  Size _screenSize = Size.zero;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    _initAudio();

    // Animación del onboarding flotante (mano que indica arrastrar)
    _onboardingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _ticker = createTicker(_onTick)..start();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      setState(() {
        _position = Offset(size.width / 2, size.height / 2);
      });
    });
  }

  void _toggleAudio() {
    HapticFeedback.selectionClick();
    setState(() => _audioEnabled = !_audioEnabled);
  }

  Future<void> _initAudio() async {
    final audioUri = _generateBounceSound();
    await _audioPlayer.setUrl(audioUri);
  }

  // ── Generador Sintético de Sonido de Rebote (Goma/Percusión) ─────────────
  String _generateBounceSound() {
    const sampleRate = 44100;
    const duration = 0.2; // 200ms
    const numSamples = (sampleRate * duration);
    const startFrequency = 200.0;
    const endFrequency = 40.0;

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
      // Frecuencia que decae rápidamente (efecto de percusión / golpe)
      final freq =
          startFrequency *
          math.pow(endFrequency / startFrequency, t / duration);
      // Envolvente de decaimiento rápido
      final envelope = math.exp(-15.0 * t);
      // Mezcla con un poco de ruido para simular la textura de goma impactando
      final noise = (math.Random().nextDouble() * 2 - 1) * 0.2;

      final wave = math.sin(2 * math.pi * freq * t) + noise;

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

  @override
  void dispose() {
    _ticker.dispose();
    _onboardingController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // Límite inferior real: pantalla menos UI inferior
  double get _floorY => _screenSize.height - _bottomUiHeight - _ballRadius;

  void _onTick(Duration elapsed) {
    if (_isDragging) return;

    final now = DateTime.now();
    final dt = now.difference(_lastTickTime).inMicroseconds / 1_000_000.0;
    _lastTickTime = now;

    if (dt <= 0 || dt > 0.1) return;

    _velocity = Offset(_velocity.dx, _velocity.dy + _gravity * dt);
    _velocity = _velocity * _friction;

    Offset newPos = _position + _velocity * dt;

    bool bounced = false;

    // Pared izquierda / derecha
    if (newPos.dx - _ballRadius < 0) {
      newPos = Offset(_ballRadius, newPos.dy);
      _velocity = Offset(-_velocity.dx * _restitution, _velocity.dy);
      bounced = true;
    } else if (newPos.dx + _ballRadius > _screenSize.width) {
      newPos = Offset(_screenSize.width - _ballRadius, newPos.dy);
      _velocity = Offset(-_velocity.dx * _restitution, _velocity.dy);
      bounced = true;
    }

    // Techo
    if (newPos.dy - _ballRadius < 0) {
      newPos = Offset(newPos.dx, _ballRadius);
      _velocity = Offset(_velocity.dx, -_velocity.dy * _restitution);
      bounced = true;
    }

    // Suelo virtual: justo encima del contador
    if (newPos.dy > _floorY) {
      newPos = Offset(newPos.dx, _floorY);
      _velocity = Offset(_velocity.dx, -_velocity.dy * _restitution);
      bounced = true;
    }

    if (bounced && _velocity.distance > _minBounceVelocity) {
      _onBounce();
    }

    setState(() {
      _position = newPos;
    });
  }

  Future<void> _onBounce() async {
    HapticFeedback.mediumImpact();
    setState(() => _bounceCount++);

    if (!_audioEnabled) return;

    // Dinamismo del sonido basado en la velocidad de impacto
    final speed = _velocity.distance;
    final volume = (speed / 1200.0).clamp(0.2, 1.0);
    final pitch = (speed / 800.0).clamp(0.8, 1.5);

    try {
      await _audioPlayer.setVolume(volume);
      await _audioPlayer.setPitch(pitch);
      await _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();
    } catch (_) {}
  }

  void _onDragStart(DragStartDetails d) {
    if (!_hasDragged) {
      setState(() => _hasDragged = true);
    }
    _isDragging = true;
    _velocity = Offset.zero;
    _lastTickTime = DateTime.now();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    setState(() {
      _position = Offset(
        (_position.dx + d.delta.dx).clamp(
          _ballRadius,
          _screenSize.width - _ballRadius,
        ),
        (_position.dy + d.delta.dy).clamp(_ballRadius, _floorY),
      );
    });
  }

  void _onDragEnd(DragEndDetails d) {
    _isDragging = false;
    _lastTickTime = DateTime.now();

    final vx = d.velocity.pixelsPerSecond.dx;
    final vy = d.velocity.pixelsPerSecond.dy;
    const maxV = 3000.0;
    final speed = Offset(vx, vy).distance;
    _velocity = speed > maxV ? Offset(vx, vy) * (maxV / speed) : Offset(vx, vy);
  }

  void _resetCounter() {
    HapticFeedback.mediumImpact();
    setState(() => _bounceCount = 0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _screenSize = Size(constraints.maxWidth, constraints.maxHeight);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 9, backgroundColor: AppColors.tertiary),
                const SizedBox(width: 8),
                Text(
                  'Pelota antiestrés',
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
          ),
          body: Stack(
            children: [
              // Área de gestos (toda la zona de juego)
              GestureDetector(
                onPanStart: _onDragStart,
                onPanUpdate: _onDragUpdate,
                onPanEnd: _onDragEnd,
                behavior: HitTestBehavior.opaque,
                child: const SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),

              // Animación de Instrucción Flotante (Onboarding)
              if (!_hasDragged)
                Positioned(
                  top: _screenSize.height * 0.15,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _onboardingController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _onboardingController.value * 25),
                          child: Opacity(
                            opacity: 1.0 - (_onboardingController.value * 0.3),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.touch_app_rounded,
                                  size: 56,
                                  color: AppColors.tertiary,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Arrastra la pelota hacia abajo\ny suelta para lanzar',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.tertiary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // Sombra proyectada
              Positioned(
                left: _position.dx - _ballRadius * 0.7,
                top: _position.dy + _ballRadius * 0.65,
                child: Container(
                  width: _ballRadius * 1.4,
                  height: _ballRadius * 0.3,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLowest.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),

              // La bola
              Positioned(
                left: _position.dx - _ballRadius,
                top: _position.dy - _ballRadius,
                child: GestureDetector(
                  onPanStart: _onDragStart,
                  onPanUpdate: _onDragUpdate,
                  onPanEnd: _onDragEnd,
                  child: _StressBall(
                    radius: _ballRadius,
                    isDragging: _isDragging,
                  ),
                ),
              ),

              // ── UI inferior: contador + botón ────────────────────────────
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Contador
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Rebotes:',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            '$_bounceCount',
                            style: TextStyle(
                              color: AppColors.tertiary,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Botones: Audio y Reiniciar
                    Row(
                      children: [
                        // Audio Toggle
                        Expanded(
                          flex: 1,
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
                              padding: const EdgeInsets.symmetric(vertical: 15),
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
                        // Botón reiniciar
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: _resetCounter,
                            icon: Icon(
                              Icons.refresh,
                              color: AppColors.buttonPrimaryText,
                            ),
                            label: Text(
                              'Reiniciar contador',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.buttonPrimaryText,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.buttonPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget visual de la bola
// ─────────────────────────────────────────────────────────────────────────────
class _StressBall extends StatelessWidget {
  final double radius;
  final bool isDragging;

  const _StressBall({required this.radius, required this.isDragging});

  @override
  Widget build(BuildContext context) {
    final double size = radius * 2;
    return AnimatedScale(
      scale: isDragging ? 1.08 : 1.0,
      duration: const Duration(milliseconds: 120),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.tertiaryContainer,
              AppColors.tertiary,
              AppColors.tertiaryOnContainer,
            ],
            stops: [0.0, 0.55, 1.0],
            center: Alignment(-0.3, -0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.tertiary.withValues(alpha: 0.45),
              blurRadius: isDragging ? 22 : 16,
              offset: const Offset(4, 8),
            ),
            BoxShadow(
              color: AppColors.surfaceBright.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(-4, -4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: size * 0.12,
              left: size * 0.2,
              child: Container(
                width: size * 0.28,
                height: size * 0.16,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBright.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
            Positioned(
              top: size * 0.22,
              left: size * 0.28,
              child: Container(
                width: size * 0.1,
                height: size * 0.06,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBright.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
