import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class CalmDrawingView extends StatefulWidget {
  const CalmDrawingView({super.key});

  @override
  State<CalmDrawingView> createState() => _CalmDrawingViewState();
}

class _CalmDrawingViewState extends State<CalmDrawingView> {
  final GlobalKey _canvasKey = GlobalKey();
  final List<_DrawingStroke> _strokes = [];
  _DrawingStroke? _activeStroke;
  Color _selectedColor = AppColors.mint;
  double _strokeWidth = 6;

  void _startStroke(DragStartDetails details) {
    final position = _localPosition(details.globalPosition);
    setState(() {
      _activeStroke = _DrawingStroke(
        points: [position],
        color: _selectedColor,
        strokeWidth: _strokeWidth,
      );
      _strokes.add(_activeStroke!);
    });
  }

  void _updateStroke(DragUpdateDetails details) {
    final stroke = _activeStroke;
    if (stroke == null) return;
    final position = _localPosition(details.globalPosition);
    setState(() => stroke.points.add(position));
  }

  void _endStroke([DragEndDetails? _]) {
    _activeStroke = null;
  }

  Offset _localPosition(Offset globalPosition) {
    final renderBox =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    return renderBox.globalToLocal(globalPosition);
  }

  void _undo() {
    if (_strokes.isEmpty) return;
    setState(() => _strokes.removeLast());
  }

  Future<void> _confirmClear() async {
    if (_strokes.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Limpiar dibujo'),
        content: const Text(
          'Se borrarán los trazos de esta actividad. Esta acción no afecta tus registros personales.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.surfaceLowest,
              minimumSize: const Size(120, 48),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      setState(_strokes.clear);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dibujo calmado'),
        actions: [
          IconButton(
            tooltip: 'Deshacer último trazo',
            onPressed: _strokes.isEmpty ? null : _undo,
            icon: const Icon(Icons.undo_rounded),
          ),
          IconButton(
            tooltip: 'Limpiar dibujo',
            onPressed: _strokes.isEmpty ? null : _confirmClear,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Desliza el dedo para dibujar trazos lentos. No se guarda información personal.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      border: Border.all(color: AppColors.outlineVariant),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: GestureDetector(
                      key: _canvasKey,
                      behavior: HitTestBehavior.opaque,
                      onPanStart: _startStroke,
                      onPanUpdate: _updateStroke,
                      onPanEnd: _endStroke,
                      child: RepaintBoundary(
                        child: CustomPaint(
                          painter: _CalmDrawingPainter(_strokes),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _DrawingControls(
                selectedColor: _selectedColor,
                strokeWidth: _strokeWidth,
                onColorChanged: (color) =>
                    setState(() => _selectedColor = color),
                onStrokeWidthChanged: (value) =>
                    setState(() => _strokeWidth = value),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawingControls extends StatelessWidget {
  const _DrawingControls({
    required this.selectedColor,
    required this.strokeWidth,
    required this.onColorChanged,
    required this.onStrokeWidthChanged,
  });

  final Color selectedColor;
  final double strokeWidth;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<double> onStrokeWidthChanged;

  @override
  Widget build(BuildContext context) {
    final colors = [AppColors.mint, AppColors.lavender, AppColors.tertiary];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: colors.map((color) {
              final selected = color == selectedColor;
              return Semantics(
                button: true,
                selected: selected,
                label: 'Color de trazo',
                child: InkWell(
                  onTap: () => onColorChanged(color),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      border: Border.all(
                        color: selected
                            ? AppColors.textPrimary
                            : AppColors.outlineVariant,
                        width: selected ? 3 : 1,
                      ),
                    ),
                    child: selected
                        ? Icon(
                            Icons.check_rounded,
                            color: AppColors.buttonPrimaryText,
                          )
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.line_weight_rounded, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Slider(
                  value: strokeWidth,
                  min: 3,
                  max: 12,
                  divisions: 3,
                  label: '${strokeWidth.round()}',
                  onChanged: onStrokeWidthChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DrawingStroke {
  _DrawingStroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });

  final List<Offset> points;
  final Color color;
  final double strokeWidth;
}

class _CalmDrawingPainter extends CustomPainter {
  const _CalmDrawingPainter(this.strokes);

  final List<_DrawingStroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path()
        ..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (final point in stroke.points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CalmDrawingPainter oldDelegate) {
    return true;
  }
}
