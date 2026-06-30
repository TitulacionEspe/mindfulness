// ═══════════════════════════════════════════════════════════════════════════
//  PANTALLA 1 — Selector de Terapia de Sonido
//
//  Solo UI/estado. No toca audio directamente — al presionar
//  "Iniciar Terapia de Sonido" navega a SoundTherapyPlayerScreen
//  pasándole un SoundTherapySessionConfig con todo lo elegido.
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
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
  int _selectedDuration = 10;
  double _volume = 0.7;

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
      backgroundColor: AppColors.background,
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
      backgroundColor: AppColors.surface,
      elevation: 0.5,
      leading: BackButton(color: AppColors.textPrimary),
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.graphic_eq, color: AppColors.lavender, size: 22),
          const SizedBox(width: 8),
          Text(
            'Terapia de Sonido',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.info_outline, color: AppColors.textSecondary),
          onPressed: _showInfoDialog,
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.lavender,
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
              color: selected ? AppColors.lavender.withValues(alpha: 0.15) : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? AppColors.lavender : AppColors.outlineVariant,
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
                      color: selected ? AppColors.lavender : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      freq.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: selected ? AppColors.lavender : AppColors.textPrimary,
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
                        ? AppColors.lavender.withValues(alpha: 0.85)
                        : AppColors.textSecondary,
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
          color: AppColors.mint,
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
          color: AppColors.lavender,
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
          color: selected ? color.withValues(alpha: 0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : AppColors.outlineVariant,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: selected ? color : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildVolumeSlider() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.volume_down, color: AppColors.lavender, size: 20),
          Expanded(
            child: Slider(
              value: _volume,
              onChanged: (v) => setState(() => _volume = v),
              activeColor: AppColors.lavender,
              inactiveColor: AppColors.surfaceHigh,
            ),
          ),
          Icon(Icons.volume_up, color: AppColors.lavender, size: 22),
          const SizedBox(width: 8),
          SizedBox(
            width: 44,
            child: Text(
              '${(_volume * 100).round()}%',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.lavender,
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
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outlineVariant)),
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
            backgroundColor: AppColors.mint,
            foregroundColor: AppColors.buttonPrimaryText,
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
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('¿Qué es la Terapia de Sonido?', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Las frecuencias Solfeggio son tonos asociados tradicionalmente con '
          'distintos estados de bienestar. Combinadas opcionalmente con ritmos '
          'binaurales, pueden ayudarte a relajarte, enfocarte o conciliar el sueño.\n\n'
          'Usa auriculares para una mejor experiencia, especialmente si activas '
          'un ritmo binaural.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Entendido', style: TextStyle(color: AppColors.lavender)),
          ),
        ],
      ),
    );
  }
}
