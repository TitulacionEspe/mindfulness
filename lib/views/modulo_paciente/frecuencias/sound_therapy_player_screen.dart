// ═══════════════════════════════════════════════════════════════════════════
//  PANTALLA 2 — Reproductor de Terapia de Sonido
//
//  Recibe un SoundTherapySessionConfig ya armado desde la pantalla 1.
//  Usa SoundTherapyEngine (ver sound_therapy_engine.dart) para:
//    - iniciar/pausar/detener la generación de audio
//    - escuchar el tiempo restante y mostrarlo
//
//  🔴 Esta pantalla NO necesita cambios cuando el agente conecte el motor
//  real — solo debe implementar RealSoundEngine en sound_therapy_engine.dart.
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import 'sound_therapy_engine.dart';
import 'sound_therapy_models.dart';

class SoundTherapyPlayerScreen extends StatefulWidget {
  final SoundTherapySessionConfig config;

  const SoundTherapyPlayerScreen({super.key, required this.config});

  @override
  State<SoundTherapyPlayerScreen> createState() =>
      _SoundTherapyPlayerScreenState();
}

class _SoundTherapyPlayerScreenState extends State<SoundTherapyPlayerScreen>
    with SingleTickerProviderStateMixin {
  late SoundTherapyEngine _engine;
  Duration _remaining = Duration.zero;
  bool _isPaused = false;

  late AnimationController _pulseController;

  static const Color _bgTop = Color(0xFF2A1F6B);
  static const Color _bgBottom = Color(0xFF5B4FE5);

  @override
  void initState() {
    super.initState();
    _engine = createSoundTherapyEngine();
    _remaining = widget.config.duration;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _engine.remainingTimeStream.listen((d) {
      if (!mounted) return;
      setState(() => _remaining = d);
    });

    _engine.onCompleted.then((_) {
      if (!mounted) return;
      _showCompletedDialog();
    });

    _startSession();
  }

  @override
  void dispose() {
    _engine.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startSession() async {
    await _engine.start(widget.config);
  }

  Future<void> _togglePause() async {
    if (_isPaused) {
      await _engine.resume();
    } else {
      await _engine.pause();
    }
    setState(() => _isPaused = !_isPaused);
  }

  Future<void> _stopSession() async {
    await _engine.stop();
    if (mounted) Navigator.of(context).pop();
  }

  void _showCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sesión completada 🎧'),
        content: Text(
          'Terminaste tu sesión de ${widget.config.frequency.title} '
          '(${widget.config.durationMinutes} min).',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // cierra el dialog
              Navigator.of(context).pop(); // vuelve al selector
            },
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.toString().padLeft(1, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgTop, _bgBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              const Spacer(),
              _buildPulsingCircle(config),
              const SizedBox(height: 32),
              Text(
                config.frequency.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  config.frequency.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 15,
                  ),
                ),
              ),
              const Spacer(),
              _buildInfoCard(config),
              const SizedBox(height: 20),
              _buildBottomControls(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _stopSession,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  _formatDuration(_remaining),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildPulsingCircle(SoundTherapySessionConfig config) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, __) {
        final t = _pulseController.value; // 0..1
        return SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children:
                List.generate(4, (i) {
                  final ringScale = 0.55 + (i * 0.15) + (t * 0.05);
                  final opacity = (1.0 - i * 0.2) * (_isPaused ? 0.4 : 1.0);
                  return Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: Container(
                      width: 280 * ringScale,
                      height: 280 * ringScale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.10 + i * 0.03),
                      ),
                    ),
                  );
                })..add(
                  Container(
                    width: 110,
                    height: 110,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Icon(
                      config.frequency.icon,
                      size: 46,
                      color: _bgBottom,
                    ),
                  ),
                ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(SoundTherapySessionConfig config) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Text(
            'Encuentra una posición cómoda',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Respira naturalmente y deja que tu mente se asiente.'
            '${config.binauralBeat != null ? " Usa auriculares para el ritmo binaural." : ""}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer_outlined, color: Colors.white70, size: 14),
              const SizedBox(width: 6),
              Text(
                'Sesión de ${config.durationMinutes} min',
                style: const TextStyle(color: Colors.white70, fontSize: 12.5),
              ),
              if (config.binauralBeat != null) ...[
                const SizedBox(width: 14),
                const Icon(Icons.graphic_eq, color: Colors.white70, size: 14),
                const SizedBox(width: 6),
                Text(
                  config.binauralBeat!.label,
                  style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _togglePause,
              icon: Icon(
                _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                color: Colors.white,
              ),
              label: Text(
                _isPaused ? 'Reanudar' : 'Pausar',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white54),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _stopSession,
              icon: const Icon(Icons.stop_rounded),
              label: const Text(
                'Detener Sesión',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
