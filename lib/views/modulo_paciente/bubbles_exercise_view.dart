import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

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

  // ── Sonido (respeta el toggle) ────────────────────────────────────────
  Future<void> _playPopSound() async {
    if (!_soundEnabled) return;
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource('sounds/burbuja.wav'));
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
      backgroundColor: const Color(0xFFE8F4F8),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.bubble_chart, color: Color(0xFF1AAA7A), size: 22),
            SizedBox(width: 8),
            Text(
              'Burbujas Antiestrés',
              style: TextStyle(
                color: Color(0xFF1A1A2E),
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFE8F4F8),
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1A1A2E)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.info_outline, color: Color(0xFF1A1A2E)),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // Subtítulo
              const Text(
                'Toca para Explotar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0D9E6E),
                ),
              ),

              const SizedBox(height: 14),

              // Tarjeta blanca con cuadrícula centrada
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 14,
                      offset: const Offset(0, 3),
                    ),
                  ],
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
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    'Reiniciar Burbujas',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1AAA7A),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
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
                            _soundEnabled
                                ? Icons.volume_up
                                : Icons.volume_off,
                            size: 20,
                            color: _soundEnabled
                                ? const Color(0xFF1AAA7A)
                                : const Color(0xFF999999),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Sonido de explosión',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: _soundEnabled
                                  ? const Color(0xFF1A1A2E)
                                  : const Color(0xFF999999),
                            ),
                          ),
                        ],
                      ),
                      value: _soundEnabled,
                      activeThumbColor: const Color(0xFF1AAA7A),
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
                                ? const Color(0xFF1AAA7A)
                                : const Color(0xFF999999),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Burbujas infinitas',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: _regenerativeMode
                                  ? const Color(0xFF1A1A2E)
                                  : const Color(0xFF999999),
                            ),
                          ),
                        ],
                      ),
                      value: _regenerativeMode,
                      activeThumbColor: const Color(0xFF1AAA7A),
                      onChanged: (val) {
                        setState(() {
                          _regenerativeMode = val;
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
          color: const Color(0xFFD4EDE8),
          border: Border.all(color: const Color(0xFFA8D4CC), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
        gradient: const RadialGradient(
          colors: [Color(0xFF7EEEDD), Color(0xFF2ABCAA)],
          center: Alignment(-0.3, -0.3),
        ),
        border: Border.all(color: const Color(0xFF1AAA8A), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(-2, -2),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.13),
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
            color: Colors.white.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}