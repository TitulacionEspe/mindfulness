import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'breathing_sphere.dart';
import 'session_progress_widgets.dart';

class AudioRunner extends StatefulWidget {
  final String audioUrl;
  final int durationSeconds;
  final VoidCallback onComplete;

  const AudioRunner({
    super.key,
    required this.audioUrl,
    required this.durationSeconds,
    required this.onComplete,
  });

  @override
  State<AudioRunner> createState() => _AudioRunnerState();
}

class _AudioRunnerState extends State<AudioRunner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  final AudioPlayer _player = AudioPlayer();

  Timer? _timer;
  int _elapsed = 0;
  bool _isPlaying = false;
  bool _isBuffering = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _player.setUrl(widget.audioUrl);
      if (mounted) {
        setState(() => _isBuffering = false);
        _player.play();
        _startTimer();
      }
    } catch (e) {
      debugPrint("Error cargando audio: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "No se pudo cargar el audio. Iniciando temporizador sin sonido.",
            ),
          ),
        );
        _startTimer(); // Fallback a temporizador solo
      }
    }

    _player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          _isBuffering = state.processingState == ProcessingState.buffering;

          if (state.processingState == ProcessingState.completed) {
            widget.onComplete();
          }
        });
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_isPlaying) return;
      setState(() {
        _elapsed++;
        if (_elapsed >= widget.durationSeconds) {
          _timer?.cancel();
          _player.stop();
          widget.onComplete();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.durationSeconds - _elapsed;
    final minutes = (remaining / 60).floor();
    final seconds = remaining % 60;
    final progress = (_elapsed / widget.durationSeconds).clamp(0.0, 1.0);

    return Column(
      children: [
        const Spacer(),
        if (_isBuffering)
          const CircularProgressIndicator(color: Colors.cyanAccent)
        else
          BreathingSphere(animation: _animationController, label: ''),
        const Spacer(),

        // Controles de audio
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                _isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
              ),
              iconSize: 64,
              color: Colors.white,
              onPressed: () {
                if (_isPlaying) {
                  _player.pause();
                } else {
                  _player.play();
                }
              },
            ),
          ],
        ),

        const Spacer(),
        PhaseProgressBar(
          label: _isBuffering ? 'Cargando audio...' : 'Escuchando rutina',
          time: '$minutes:${seconds.toString().padLeft(2, '0')}',
          progress: progress,
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
