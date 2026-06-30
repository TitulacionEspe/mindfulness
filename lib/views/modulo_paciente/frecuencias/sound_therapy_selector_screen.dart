// ═══════════════════════════════════════════════════════════════════════════
//  PANTALLA 1 — Selector de Terapia de Sonido
//
//  Solo UI/estado. No toca audio directamente — al presionar
//  "Iniciar Terapia de Sonido" navega a SoundTherapyPlayerScreen
//  pasándole un SoundTherapySessionConfig con todo lo elegido.
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import 'sound_therapy_models.dart';
import 'sound_therapy_player_screen.dart';

class SoundTherapySelectorScreen extends StatefulWidget {
  const SoundTherapySelectorScreen({super.key});

  @override
  State<SoundTherapySelectorScreen> createState() =>
      _SoundTherapySelectorScreenState();
}

class _SoundTherapySelectorScreenState
    extends State<SoundTherapySelectorScreen> {
  SoundFrequency _selectedFrequency = kSoundFrequencies[3]; // 528Hz default
  BinauralBeat? _selectedBinaural = kBinauralBeats[0]; // Delta 2Hz default
  ModulationLevel _selectedModulation = ModulationLevel.suave;
  int _selectedDuration = 5;
  double _volume = 0.5;

  static const Color _purple = Color(0xFF5B4FE5);

  void _startSession() {
    final config = SoundTherapySessionConfig(
      frequency: _selectedFrequency,
      binauralBeat: _selectedBinaural,
      modulation: _selectedModulation,
      durationMinutes: _selectedDuration,
      volume: _volume,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SoundTherapyPlayerScreen(config: config),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FB),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          children: [
            _buildSectionLabel('SELECCIONAR FRECUENCIA'),
            const SizedBox(height: 12),
            _buildFrequencyGrid(),
            const SizedBox(height: 24),
            _buildSectionLabel('RITMOS BINAURALES (OPCIONAL)'),
            const SizedBox(height: 12),
            _buildBinauralRow(),
            const SizedBox(height: 24),
            _buildSectionLabel('MODULACIÓN (OPCIONAL)'),
            const SizedBox(height: 12),
            _buildModulationRow(),
            const SizedBox(height: 24),
            _buildSectionLabel('DURACIÓN'),
            const SizedBox(height: 12),
            _buildDurationRow(),
            const SizedBox(height: 24),
            _buildSectionLabel('VOLUMEN'),
            const SizedBox(height: 12),
            _buildVolumeSlider(),
          ],
        ),
      ),
      bottomNavigationBar: _buildStartButton(),
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
          Icon(Icons.graphic_eq, color: _purple, size: 22),
          SizedBox(width: 8),
          Text(
            'Terapia de Sonido',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
              fontSize: 18,
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

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: _purple,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildFrequencyGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: kSoundFrequencies.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (_, i) {
        final freq = kSoundFrequencies[i];
        final selected = freq.hz == _selectedFrequency.hz;
        return GestureDetector(
          onTap: () => setState(() => _selectedFrequency = freq),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFEDEBFF) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? _purple : Colors.grey.shade200,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      freq.icon,
                      size: 18,
                      color: selected ? _purple : Colors.grey.shade500,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      freq.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: selected ? _purple : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  freq.description,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: selected
                        ? _purple.withOpacity(0.85)
                        : Colors.grey.shade600,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBinauralRow() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ...kBinauralBeats.map((beat) {
          final selected = _selectedBinaural?.label == beat.label;
          return _buildPillChoice(
            label: beat.label,
            selected: selected,
            color: beat.accentColor,
            onTap: () => setState(() {
              _selectedBinaural = selected ? null : beat;
            }),
          );
        }),
      ],
    );
  }

  Widget _buildModulationRow() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: ModulationLevel.values.map((level) {
        final selected = _selectedModulation == level;
        return _buildPillChoice(
          label: level.label,
          selected: selected,
          color: Colors.blue,
          onTap: () => setState(() => _selectedModulation = level),
        );
      }).toList(),
    );
  }

  Widget _buildDurationRow() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: kDurationsMinutes.map((min) {
        final selected = _selectedDuration == min;
        return _buildPillChoice(
          label: '$min min',
          selected: selected,
          color: const Color(0xFF8E24AA),
          onTap: () => setState(() => _selectedDuration = min),
        );
      }).toList(),
    );
  }

  Widget _buildPillChoice({
    required String label,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: selected ? color : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildVolumeSlider() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.volume_down, color: _purple, size: 20),
          Expanded(
            child: Slider(
              value: _volume,
              onChanged: (v) => setState(() => _volume = v),
              activeColor: _purple,
              inactiveColor: Colors.grey.shade300,
            ),
          ),
          const Icon(Icons.volume_up, color: _purple, size: 22),
          const SizedBox(width: 8),
          SizedBox(
            width: 44,
            child: Text(
              '${(_volume * 100).round()}%',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: _purple,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: _startSession,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text(
            'Iniciar Terapia de Sonido',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _purple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Qué es la Terapia de Sonido?'),
        content: const Text(
          'Las frecuencias Solfeggio son tonos asociados tradicionalmente con '
          'distintos estados de bienestar. Combinadas opcionalmente con ritmos '
          'binaurales, pueden ayudarte a relajarte, enfocarte o conciliar el sueño.\n\n'
          'Usa auriculares para una mejor experiencia, especialmente si activas '
          'un ritmo binaural.',
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
