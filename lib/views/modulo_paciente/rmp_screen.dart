import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════
//
//  ╔══════════════════════════════════════════════╗
//  ║   SECCIÓN 1 — EMOJIS  (edita solo aquí)     ║
//  ╚══════════════════════════════════════════════╝
//
//  Cada grupo tiene DOS emojis:
//    • tensionEmoji     → se muestra durante la fase de TENSIÓN
//    • relaxationEmoji  → se muestra durante la fase de RELAJACIÓN
//
//  Cámbia cualquier emoji sin tocar el resto del código.
//
// ═══════════════════════════════════════════════════════════════════════════

class _RmpEmojis {
  // ── Manos ──────────────────────────────────────
  static const String manoDerTension = '✊'; // puño cerrado
  static const String manoDerRelax = '🖐️'; // mano abierta

  static const String manoIzqTension = '✊'; // puño cerrado
  static const String manoIzqRelax = '🖐️'; // mano abierta

  // ── Brazos ─────────────────────────────────────
  static const String bicepsDerTension = '💪'; // bíceps contraído
  static const String bicepsDerRelax = '🦾'; // brazo extendido

  static const String bicepsIzqTension = '💪'; // bíceps contraído
  static const String bicepsIzqRelax = '🦾'; // brazo extendido

  // ── Cara ───────────────────────────────────────
  static const String frenteTension = '😠'; // cejas fruncidas
  static const String frenteRelax = '😌'; // sereno

  static const String ojosNarizTension = '😣'; // ojos apretados
  static const String ojosNarizRelax = '😴'; // párpados suaves

  static const String mandibulaTension = '😬'; // dientes apretados
  static const String mandibulaRelax = '😮'; // boca suelta

  // ── Cuello y hombros ───────────────────────────
  static const String cuelloTension = '😤'; // cuello rígido
  static const String cuelloRelax = '🧘'; // postura serena

  static const String hombrosTension = '🙆'; // hombros encogidos
  static const String hombrosRelax = '🧎'; // hombros caídos

  // ── Torso ──────────────────────────────────────
  static const String espaldaTension = '🏋️'; // espalda en esfuerzo
  static const String espaldaRelax = '🛀'; // relajado

  static const String abdomenTension = '🫀'; // contracción
  static const String abdomenRelax = '🫁'; // expansión

  // ── Piernas ────────────────────────────────────
  static const String muslosTension = '🦵'; // muslo tenso
  static const String muslosRelax = '🪑'; // pierna suelta

  static const String caderasTension = '🧍'; // de pie tenso
  static const String caderasRelax = '🪷'; // suave / relajado

  static const String pantorrillaTension = '⚡'; // contracción brusca
  static const String pantorrillaRelax = '🦶'; // pie suelto

  static const String piesTension = '🦶'; // dedos apretados
  static const String piesRelax = '👣'; // completamente suelto
}

// ═══════════════════════════════════════════════════════════════════════════
//
//  ╔══════════════════════════════════════════════╗
//  ║   SECCIÓN 2 — GRUPOS ACTIVOS  (edita aquí)  ║
//  ╚══════════════════════════════════════════════╝
//
//  Controla qué grupos se incluyen en la sesión.
//  • Para DESACTIVAR un grupo: comenta su línea con //
//  • Para REORDENAR: mueve las líneas
//  • Para AGREGAR uno nuevo: crea un MuscleGroup y agrégalo aquí
//
//  El tiempo por fase se calcula automáticamente según cuántos
//  grupos estén activos y kTotalSessionSeconds.
//
// ═══════════════════════════════════════════════════════════════════════════

final List<MuscleGroup> kActiveGroups = [
  kAllGroups['manoDerecha']!,
  kAllGroups['manoIzquierda']!,
  kAllGroups['bicepsDerecho']!,
  kAllGroups['bicepsIzquierdo']!,
  kAllGroups['frente']!,
  kAllGroups['ojosNariz']!,
  kAllGroups['mandibula']!,
  kAllGroups['cuello']!,
  kAllGroups['hombros']!,
  kAllGroups['espalda']!,
  kAllGroups['abdomen']!,
  kAllGroups['muslos']!,
  kAllGroups['caderas']!,
  kAllGroups['pantorrillas']!,
  kAllGroups['pies']!,
];

// ═══════════════════════════════════════════════════════════════════════════
//
//  ╔══════════════════════════════════════════════╗
//  ║   SECCIÓN 3 — DURACIÓN TOTAL (segundos)     ║
//  ╚══════════════════════════════════════════════╝
//
//  kTotalSessionSeconds = 180  →  3 minutos
//  El tiempo por fase = total ÷ (grupos × 2)
//  Con 15 grupos → 6s/fase. Con 5 grupos → 18s/fase. Etc.
//
// ═══════════════════════════════════════════════════════════════════════════

const int kTotalSessionSeconds = 180;

// ═══════════════════════════════════════════════════════════════════════════
//  DATA MODEL
// ═══════════════════════════════════════════════════════════════════════════

class MuscleGroup {
  final String id;
  final String name;
  final String tensionEmoji;
  final String relaxationEmoji;
  final List<String> tensionSteps;
  final List<String> relaxationSteps;

  const MuscleGroup({
    required this.id,
    required this.name,
    required this.tensionEmoji,
    required this.relaxationEmoji,
    required this.tensionSteps,
    required this.relaxationSteps,
  });

  String emoji(bool isTension) => isTension ? tensionEmoji : relaxationEmoji;
}

// ═══════════════════════════════════════════════════════════════════════════
//  CATÁLOGO COMPLETO — todos los grupos disponibles
//  (No edites aquí; edita kActiveGroups arriba para activar/desactivar)
// ═══════════════════════════════════════════════════════════════════════════

final Map<String, MuscleGroup> kAllGroups = {
  'manoDerecha': const MuscleGroup(
    id: 'manoDerecha',
    name: 'Mano Derecha y Antebrazo',
    tensionEmoji: _RmpEmojis.manoDerTension,
    relaxationEmoji: _RmpEmojis.manoDerRelax,
    tensionSteps: [
      'Haz un puño apretado',
      'Aprieta fuerte',
      'Siente la tensión en tus dedos y antebrazo',
    ],
    relaxationSteps: [
      'Abre tu mano',
      'Déjala ir completamente floja',
      'Siente los dedos naturalmente curvados y relajados',
    ],
  ),
  'manoIzquierda': const MuscleGroup(
    id: 'manoIzquierda',
    name: 'Mano Izquierda y Antebrazo',
    tensionEmoji: _RmpEmojis.manoIzqTension,
    relaxationEmoji: _RmpEmojis.manoIzqRelax,
    tensionSteps: [
      'Haz un puño apretado con la mano izquierda',
      'Aprieta fuerte',
      'Siente la tensión en tus dedos y antebrazo',
    ],
    relaxationSteps: [
      'Abre tu mano izquierda',
      'Déjala ir completamente floja',
      'Siente los dedos naturalmente curvados y relajados',
    ],
  ),
  'bicepsDerecho': const MuscleGroup(
    id: 'bicepsDerecho',
    name: 'Bíceps Derecho',
    tensionEmoji: _RmpEmojis.bicepsDerTension,
    relaxationEmoji: _RmpEmojis.bicepsDerRelax,
    tensionSteps: [
      'Dobla el codo y tensa el bíceps',
      'Aprieta fuerte hacia el hombro',
      'Siente la tensión en la parte superior del brazo',
    ],
    relaxationSteps: [
      'Extiende el brazo lentamente',
      'Deja caer el brazo relajado',
      'Siente el peso del brazo completamente suelto',
    ],
  ),
  'bicepsIzquierdo': const MuscleGroup(
    id: 'bicepsIzquierdo',
    name: 'Bíceps Izquierdo',
    tensionEmoji: _RmpEmojis.bicepsIzqTension,
    relaxationEmoji: _RmpEmojis.bicepsIzqRelax,
    tensionSteps: [
      'Dobla el codo izquierdo y tensa el bíceps',
      'Aprieta fuerte hacia el hombro',
      'Siente la tensión en la parte superior del brazo',
    ],
    relaxationSteps: [
      'Extiende el brazo lentamente',
      'Deja caer el brazo relajado',
      'Siente el peso del brazo completamente suelto',
    ],
  ),
  'frente': const MuscleGroup(
    id: 'frente',
    name: 'Frente',
    tensionEmoji: _RmpEmojis.frenteTension,
    relaxationEmoji: _RmpEmojis.frenteRelax,
    tensionSteps: [
      'Levanta las cejas lo más alto posible',
      'Arruga la frente fuerte',
      'Siente la tensión en la frente',
    ],
    relaxationSteps: [
      'Deja caer las cejas suavemente',
      'Siente la frente lisa y suave',
      'Totalmente relajada y sin arrugas',
    ],
  ),
  'ojosNariz': const MuscleGroup(
    id: 'ojosNariz',
    name: 'Ojos y Nariz',
    tensionEmoji: _RmpEmojis.ojosNarizTension,
    relaxationEmoji: _RmpEmojis.ojosNarizRelax,
    tensionSteps: [
      'Cierra los ojos con fuerza',
      'Arruga la nariz',
      'Siente la tensión alrededor de los ojos',
    ],
    relaxationSteps: [
      'Suelta suavemente los párpados',
      'Deja la nariz sin arrugas',
      'Ojos cerrados suavemente, relajados',
    ],
  ),
  'mandibula': const MuscleGroup(
    id: 'mandibula',
    name: 'Mandíbula',
    tensionEmoji: _RmpEmojis.mandibulaTension,
    relaxationEmoji: _RmpEmojis.mandibulaRelax,
    tensionSteps: [
      'Aprieta los dientes fuerte',
      'Tensa la mandíbula',
      'Siente la tensión en la quijada',
    ],
    relaxationSteps: [
      'Deja que la mandíbula caiga',
      'Labios ligeramente separados',
      'Siente la mandíbula completamente suelta',
    ],
  ),
  'cuello': const MuscleGroup(
    id: 'cuello',
    name: 'Cuello y Garganta',
    tensionEmoji: _RmpEmojis.cuelloTension,
    relaxationEmoji: _RmpEmojis.cuelloRelax,
    tensionSteps: [
      'Empuja la barbilla hacia el pecho',
      'Tensa los músculos del cuello',
      'Siente la tensión en la garganta',
    ],
    relaxationSteps: [
      'Levanta la cabeza suavemente',
      'Deja el cuello suelto',
      'Siente el peso de la cabeza sostenido naturalmente',
    ],
  ),
  'hombros': const MuscleGroup(
    id: 'hombros',
    name: 'Hombros',
    tensionEmoji: _RmpEmojis.hombrosTension,
    relaxationEmoji: _RmpEmojis.hombrosRelax,
    tensionSteps: [
      'Levanta los hombros hacia las orejas',
      'Aprieta fuerte',
      'Siente la tensión en hombros y cuello',
    ],
    relaxationSteps: [
      'Deja caer los hombros',
      'Siente cómo se alejan de las orejas',
      'Pesados y completamente relajados',
    ],
  ),
  'espalda': const MuscleGroup(
    id: 'espalda',
    name: 'Espalda Alta',
    tensionEmoji: _RmpEmojis.espaldaTension,
    relaxationEmoji: _RmpEmojis.espaldaRelax,
    tensionSteps: [
      'Junta los omóplatos',
      'Empuja los codos hacia atrás',
      'Siente la tensión en la espalda alta',
    ],
    relaxationSteps: [
      'Suelta los omóplatos',
      'Deja los hombros hacia adelante suavemente',
      'Siente la espalda ancha y relajada',
    ],
  ),
  'abdomen': const MuscleGroup(
    id: 'abdomen',
    name: 'Abdomen',
    tensionEmoji: _RmpEmojis.abdomenTension,
    relaxationEmoji: _RmpEmojis.abdomenRelax,
    tensionSteps: [
      'Mete el estómago hacia adentro',
      'Tensa los músculos abdominales',
      'Siente la tensión en todo el abdomen',
    ],
    relaxationSteps: [
      'Suelta el abdomen',
      'Deja que el estómago se expanda',
      'Respira suave y profundamente',
    ],
  ),
  'muslos': const MuscleGroup(
    id: 'muslos',
    name: 'Muslos',
    tensionEmoji: _RmpEmojis.muslosTension,
    relaxationEmoji: _RmpEmojis.muslosRelax,
    tensionSteps: [
      'Aprieta los muslos fuerte',
      'Tensa los músculos de las piernas',
      'Siente la tensión en los muslos',
    ],
    relaxationSteps: [
      'Suelta los muslos',
      'Deja que las piernas caigan naturalmente',
      'Pesadas y completamente relajadas',
    ],
  ),
  'caderas': const MuscleGroup(
    id: 'caderas',
    name: 'Caderas y Glúteos',
    tensionEmoji: _RmpEmojis.caderasTension,
    relaxationEmoji: _RmpEmojis.caderasRelax,
    tensionSteps: [
      'Aprieta los glúteos juntos fuerte',
      'Tensa los músculos fuerte',
      'Siente tensión en las caderas',
    ],
    relaxationSteps: [
      'Deja que los glúteos se suavicen',
      'Siente cómo se esparcen naturalmente',
      'Pesados y relajados',
    ],
  ),
  'pantorrillas': const MuscleGroup(
    id: 'pantorrillas',
    name: 'Pantorrillas',
    tensionEmoji: _RmpEmojis.pantorrillaTension,
    relaxationEmoji: _RmpEmojis.pantorrillaRelax,
    tensionSteps: [
      'Apunta los pies hacia abajo',
      'Tensa las pantorrillas',
      'Siente la tensión en la parte trasera de la pierna',
    ],
    relaxationSteps: [
      'Suelta los pies',
      'Deja los tobillos flojos',
      'Siente las pantorrillas pesadas y relajadas',
    ],
  ),
  'pies': const MuscleGroup(
    id: 'pies',
    name: 'Pies',
    tensionEmoji: _RmpEmojis.piesTension,
    relaxationEmoji: _RmpEmojis.piesRelax,
    tensionSteps: [
      'Dobla los dedos de los pies hacia abajo',
      'Aprieta fuerte',
      'Siente la tensión en los pies',
    ],
    relaxationSteps: [
      'Suelta los dedos de los pies',
      'Deja los pies completamente flojos',
      'Siente los pies pesados y relajados',
    ],
  ),
};

// ═══════════════════════════════════════════════════════════════════════════
//  HELPERS DE TIEMPO
// ═══════════════════════════════════════════════════════════════════════════

int get kSecondsPerPhase =>
    (kTotalSessionSeconds / (kActiveGroups.length * 2)).round().clamp(4, 60);

// ═══════════════════════════════════════════════════════════════════════════
//  SONIDOS
//
//  • Tensión   → assets/sounds/platillo.wav
//  • Relajación → assets/sounds/platillo.wav
//  • Completa   → assets/sounds/burbuja.wav
//
// ═══════════════════════════════════════════════════════════════════════════

// Rutas de los archivos de audio (definidas aquí para cambiarlas fácil)
const String _kSoundTension = 'sounds/platillo.wav'; // fase tensión
const String _kSoundRelax = 'sounds/platillo.wav'; // fase relajación
const String _kSoundFinished = 'sounds/burbuja.wav'; // sesión completa

Future<void> _playSound(String assetPath) async {
  final player = AudioPlayer();
  await player.play(AssetSource(assetPath));
  // Libera el player cuando termina
  player.onPlayerComplete.listen((_) => player.dispose());
}

Future<void> _playTensionSound() async => _playSound(_kSoundTension);
Future<void> _playRelaxationSound() async => _playSound(_kSoundRelax);
Future<void> _playFinishedSound() async => _playSound(_kSoundFinished);

// ═══════════════════════════════════════════════════════════════════════════
//  PANTALLA PRINCIPAL
// ═══════════════════════════════════════════════════════════════════════════

class RmpScreen extends StatefulWidget {
  const RmpScreen({super.key});

  @override
  State<RmpScreen> createState() => _RmpScreenState();
}

class _RmpScreenState extends State<RmpScreen>
    with SingleTickerProviderStateMixin {
  // ── estado ──
  int _groupIndex = 0;
  bool _isTension = true;
  bool _isRunning = false;
  bool _isPaused = false;
  int _secondsLeft = kSecondsPerPhase;

  Timer? _timer;
  late AnimationController _pulseController;

  // ── lifecycle ──

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  // ── lógica del timer ──

  void _startSession() {
    setState(() {
      _groupIndex = 0;
      _isTension = true;
      _secondsLeft = kSecondsPerPhase;
      _isRunning = true;
      _isPaused = false;
    });
    _playTensionSound(); // sonido al iniciar primera fase
    _runTimer();
  }

  void _runTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 1) {
          _secondsLeft--;
        } else {
          _advance();
        }
      });
    });
  }

  void _advance() {
    if (_isTension) {
      // pasar a relajación
      _isTension = false;
      _secondsLeft = kSecondsPerPhase;
      _playRelaxationSound();
    } else if (_groupIndex < kActiveGroups.length - 1) {
      // siguiente grupo, vuelve a tensión
      _groupIndex++;
      _isTension = true;
      _secondsLeft = kSecondsPerPhase;
      _playTensionSound();
    } else {
      // sesión completa
      _playFinishedSound();
      _stopSession(finished: true);
    }
  }

  void _pauseResume() {
    setState(() => _isPaused = !_isPaused);
    if (_isPaused) {
      _timer?.cancel();
    } else {
      _runTimer();
    }
  }

  void _stopSession({bool finished = false}) {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
    });
    if (finished) _showFinishedDialog();
  }

  void _goTo(int index) {
    if (!_isRunning) return;
    setState(() {
      _groupIndex = index;
      _isTension = true;
      _secondsLeft = kSecondsPerPhase;
    });
    _playTensionSound();
  }

  // ── helpers ──

  MuscleGroup get _current => kActiveGroups[_groupIndex];

  Color get _phaseColor =>
      _isTension ? const Color(0xFFE53935) : const Color(0xFF26A69A);

  Color get _phaseBg =>
      _isTension ? const Color(0xFFFFF0F0) : const Color(0xFFF0FAF8);

  String get _phaseLabel => _isTension ? 'Tensión' : 'Relajación';

  double get _progressFraction => 1 - (_secondsLeft / kSecondsPerPhase);

  // ── build ──

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildBody()),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: const BackButton(color: Colors.black87),
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.accessibility_new, color: Color(0xFF7B61FF), size: 22),
          SizedBox(width: 6),
          Text(
            'RMP',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline, color: Colors.black54),
          onPressed: _showInfoDialog,
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Text(
            _current.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          _buildEmojiIllustration(),
          const SizedBox(height: 24),
          _buildPhaseCard(),
          const SizedBox(height: 20),
          if (_isRunning) _buildTimerSection(),
          const SizedBox(height: 20),
          _buildControls(),
          const SizedBox(height: 20),
          _buildGroupDots(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildEmojiIllustration() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, __) {
        final scale = _isRunning && !_isPaused
            ? 1.0 + (_pulseController.value * 0.07 * (_isTension ? 1.0 : -0.4))
            : 1.0;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _phaseBg,
              boxShadow: [
                BoxShadow(
                  color: _phaseColor.withValues(alpha: 0.18),
                  blurRadius: 22,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: Text(
                  _current.emoji(_isTension),
                  key: ValueKey('${_groupIndex}_$_isTension'),
                  style: const TextStyle(fontSize: 58),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhaseCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isRunning
              ? _phaseColor.withValues(alpha: 0.4)
              : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSection(
            label: 'Tensión',
            color: const Color(0xFFE53935),
            bgColor: const Color(0xFFFFF0F0),
            isActive: _isTension && _isRunning,
            steps: _current.tensionSteps,
            countdown: (_isTension && _isRunning) ? _secondsLeft : null,
          ),
          Divider(height: 1, color: Colors.grey.shade100),
          _buildSection(
            label: 'Relajación',
            color: const Color(0xFF26A69A),
            bgColor: const Color(0xFFF0FAF8),
            isActive: !_isTension && _isRunning,
            steps: _current.relaxationSteps,
            countdown: (!_isTension && _isRunning) ? _secondsLeft : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String label,
    required Color color,
    required Color bgColor,
    required bool isActive,
    required List<String> steps,
    int? countdown,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isActive ? bgColor : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isActive)
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: isActive ? color : Colors.grey.shade400,
                ),
              ),
              const Spacer(),
              if (countdown != null)
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                  child: Center(
                    child: Text(
                      '$countdown',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ...steps.asMap().entries.map((e) {
            final i = e.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.only(right: 8, top: 1),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: isActive
                          ? color.withValues(alpha: 0.15)
                          : Colors.grey.shade100,
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isActive ? color : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      e.value,
                      style: TextStyle(
                        fontSize: 14,
                        color: isActive ? color : Colors.grey.shade400,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimerSection() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _progressFraction,
            minHeight: 6,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(_phaseColor),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$_phaseLabel — $_secondsLeft s restantes',
          style: TextStyle(
            fontSize: 13,
            color: _phaseColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    if (!_isRunning) {
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: _startSession,
          icon: const Icon(Icons.play_arrow_rounded, size: 24),
          label: const Text(
            'Iniciar Sesión',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7B61FF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _pauseResume,
            icon: Icon(
              _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              size: 20,
            ),
            label: Text(
              _isPaused ? 'Reanudar' : 'Pausar',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              side: BorderSide(color: Colors.grey.shade300),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _stopSession(),
            icon: const Icon(Icons.stop_rounded, size: 20),
            label: const Text(
              'Detener',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupDots() {
    return Column(
      children: [
        SizedBox(
          height: 18,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: kActiveGroups.length,
            itemBuilder: (_, i) {
              final active = i == _groupIndex;
              final done = i < _groupIndex;
              return GestureDetector(
                onTap: () => _goTo(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: active ? 18 : 10,
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: active
                        ? const Color(0xFF7B61FF)
                        : done
                        ? const Color(0xFF7B61FF).withValues(alpha: 0.45)
                        : Colors.grey.shade300,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Grupo ${_groupIndex + 1}/${kActiveGroups.length}',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _groupIndex > 0
                  ? () => setState(() {
                      _groupIndex--;
                      _isTension = true;
                      _secondsLeft = kSecondsPerPhase;
                    })
                  : null,
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Atrás'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _groupIndex < kActiveGroups.length - 1
                  ? () => setState(() {
                      _groupIndex++;
                      _isTension = true;
                      _secondsLeft = kSecondsPerPhase;
                    })
                  : null,
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Siguiente'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── diálogos ──

  void _showFinishedDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¡Sesión completada! 🎉'),
        content: Text(
          'Excelente trabajo. Has completado tu sesión de Relajación Muscular Progresiva.\n\n'
          '• Grupos trabajados: ${kActiveGroups.length}\n'
          '• Duración: ${kTotalSessionSeconds ~/ 60} min ${kTotalSessionSeconds % 60} s',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Qué es RMP?'),
        content: Text(
          'La Relajación Muscular Progresiva (RMP) es una técnica de Edmund Jacobson.\n\n'
          'Consiste en tensar y relajar grupos musculares de forma progresiva para reducir la tensión física y el estrés.\n\n'
          '• Duración total: ${kTotalSessionSeconds ~/ 60} min ${kTotalSessionSeconds % 60} s\n'
          '• Grupos activos: ${kActiveGroups.length}\n'
          '• Tiempo por fase: ~${kSecondsPerPhase}s',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
