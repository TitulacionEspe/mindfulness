import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/text_limit_utils.dart';
import '../../models/thought_entry_model.dart';
import '../../viewmodels/thought_entries_viewmodel.dart';
import 'patient_appointments_view.dart';
import 'routines_library_view.dart';

class ThoughtEntriesView extends StatefulWidget {
  const ThoughtEntriesView({
    super.key,
    this.showBackButton = true,
    this.onOpenActivities,
  });

  final bool showBackButton;
  final VoidCallback? onOpenActivities;

  @override
  State<ThoughtEntriesView> createState() => _ThoughtEntriesViewState();
}

class _ThoughtEntriesViewState extends State<ThoughtEntriesView> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  ThoughtEntryModel? _editingEntry;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ThoughtEntriesViewModel>().loadEntries();
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTextChanged() {
    if (mounted) setState(() {});
  }

  int get _characterCount => TextLimitUtils.characterCount(_controller.text);

  String? get _characterLimitError => TextLimitUtils.maxCharactersError(
    _controller.text,
    maxCharacters: ThoughtEntriesViewModel.maxNoteCharacters,
    fieldName: 'La nota privada',
  );

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ThoughtEntriesViewModel>();
    final notesToday = viewModel.notesCreatedToday();
    final hasReachedDailyLimit =
        _editingEntry == null &&
        notesToday >= ThoughtEntriesViewModel.maxNotesPerDay;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.mint,
          backgroundColor: AppColors.surface,
          onRefresh: () => viewModel.loadEntries(force: true),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (widget.showBackButton)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            side: BorderSide(color: AppColors.outlineVariant),
                            backgroundColor: AppColors.surfaceLow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.textPrimary,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.fromLTRB(
                    20,
                    widget.showBackButton ? 12 : 18,
                    20,
                    14,
                  ),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _editingEntry == null
                            ? 'Diario personal'
                            : 'Editando una nota privada reciente.',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Las notas que registres en el diario son confidenciales: nadie podrá verlas, solo tú.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Puedes registrar hasta 10 notas por día. Hoy llevas $notesToday/10.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const _ThoughtPrivacyNotice(),
                      if (hasReachedDailyLimit) ...[
                        const SizedBox(height: 12),
                        _InlineFeedback(
                          message:
                              'Hoy ya registraste 10 notas. Puedes volver a escribir mañana.',
                          icon: Icons.info_outline_rounded,
                          color: AppColors.tertiaryOnContainer,
                          background: AppColors.tertiaryBg,
                        ),
                      ],
                      if (_editingEntry != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warningBg,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.lavender.withValues(alpha: 0.28),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_note_rounded,
                                size: 16,
                                color: AppColors.lavender,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Modo edición activo',
                                  style: TextStyle(
                                    color: AppColors.lavender,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _cancelEditing,
                                child: const Text('Cancelar'),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        minLines: 4,
                        maxLines: 8,
                        maxLength: ThoughtEntriesViewModel.maxNoteCharacters,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          height: 1.4,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Escribe una nota breve sobre cómo te sientes hoy.',
                          helperText:
                              'Máximo ${ThoughtEntriesViewModel.maxNoteCharacters} caracteres. $_characterCount/${ThoughtEntriesViewModel.maxNoteCharacters}',
                          counterText: '',
                          errorText: _characterLimitError,
                          errorMaxLines: 2,
                          semanticCounterText:
                              '$_characterCount de ${ThoughtEntriesViewModel.maxNoteCharacters} caracteres',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: viewModel.isSaving || hasReachedDailyLimit
                              ? null
                              : _saveCurrent,
                          icon: viewModel.isSaving
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.buttonPrimaryText,
                                  ),
                                )
                              : Icon(
                                  _editingEntry == null
                                      ? Icons.save_rounded
                                      : Icons.check_rounded,
                                ),
                          label: Text(
                            _editingEntry == null
                                ? 'Guardar nota privada'
                                : 'Actualizar nota privada',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (viewModel.errorMessage != null)
                SliverToBoxAdapter(
                  child: _InlineFeedback(
                    message: viewModel.errorMessage!,
                    icon: Icons.error_outline_rounded,
                    color: AppColors.error,
                    background: AppColors.tertiaryBg,
                  ),
                ),
              if (viewModel.successMessage != null)
                SliverToBoxAdapter(
                  child: _InlineFeedback(
                    message: viewModel.successMessage!,
                    icon: Icons.check_circle_outline_rounded,
                    color: AppColors.mint,
                    background: AppColors.successBg,
                  ),
                ),
              if (viewModel.isAnalyzing)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.lavender,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'El asistente de Nidara está analizando tu nota privada...',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (viewModel.aiRetrospect != null)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              color: AppColors.lavender,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Retrospectiva de Nidara',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          viewModel.aiRetrospect!,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        if (viewModel.aiSuggestsAppointment) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.mint,
                                foregroundColor: AppColors.buttonPrimaryText,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const PatientAppointmentsView(
                                          openRequestComposerOnStart: true,
                                        ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.calendar_month_rounded,
                                size: 18,
                              ),
                              label: const Text(
                                'Solicitar cita con Psicología',
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              if (viewModel.successMessage != null)
                SliverToBoxAdapter(
                  child: _AfterThoughtSaveActions(
                    onOpenActivities:
                        widget.onOpenActivities ?? _openActivitiesAsRoute,
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Text(
                    'Historial del diario',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              if (viewModel.isLoading && viewModel.entries.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.mint),
                  ),
                )
              else if (viewModel.entries.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyThoughtsState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  sliver: SliverList.separated(
                    itemBuilder: (context, index) {
                      final entry = viewModel.entries[index];
                      final editable = viewModel.canEditOrDelete(entry);
                      return _ThoughtEntryCard(
                        entry: entry,
                        editable: editable,
                        onEdit: editable ? () => _startEditing(entry) : null,
                        onDelete: editable ? () => _confirmDelete(entry) : null,
                      );
                    },
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemCount: viewModel.entries.length,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _openActivitiesAsRoute() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RoutinesLibraryView()));
  }

  Future<void> _saveCurrent() async {
    final viewModel = context.read<ThoughtEntriesViewModel>();
    viewModel.clearMessages();
    final content = _controller.text;
    if (_characterLimitError != null) {
      _focusNode.requestFocus();
      setState(() {});
      return;
    }
    final shouldShowSupportNotice = _containsRiskLanguage(content);
    final success = await viewModel.saveEntry(
      content: content,
      existingEntry: _editingEntry,
    );

    if (!mounted || !success) return;
    _controller.clear();
    _focusNode.unfocus();
    setState(() {
      _editingEntry = null;
    });
    if (shouldShowSupportNotice) {
      await _showResponsibleHelpDialog();
    } else {
      await viewModel.generateAIRetrospect(content);
    }
  }

  bool _containsRiskLanguage(String value) {
    final normalized = value.toLowerCase();
    const patterns = [
      'suicid',
      'no quiero vivir',
      'quiero morir',
      'hacerme daño',
      'hacerme dano',
      'lastimarme',
      'me voy a matar',
      'no puedo seguir',
    ];
    return patterns.any(normalized.contains);
  }

  Future<void> _showResponsibleHelpDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Busca apoyo si lo necesitas'),
          content: const Text(
            'Nidara no realiza diagnósticos ni reemplaza atención profesional. Si sientes que podrías hacerte daño o estás en emergencia, llama al 911 o busca ayuda inmediata. También puedes solicitar una cita con Psicología.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Entendido'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(120, 48)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PatientAppointmentsView(
                      openRequestComposerOnStart: true,
                    ),
                  ),
                );
              },
              child: const Text('Solicitar cita'),
            ),
          ],
        );
      },
    );
  }

  void _startEditing(ThoughtEntryModel entry) {
    setState(() {
      _editingEntry = entry;
      _controller.text = entry.content;
    });
    _focusNode.requestFocus();
  }

  void _cancelEditing() {
    setState(() {
      _editingEntry = null;
    });
    _controller.clear();
    _focusNode.unfocus();
  }

  Future<void> _confirmDelete(ThoughtEntryModel entry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Eliminar nota privada',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Text(
            'Esta acción elimina la nota de forma permanente.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.surfaceLowest,
                minimumSize: const Size(98, 48),
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;
    await context.read<ThoughtEntriesViewModel>().deleteEntry(entry);
    if (!mounted) return;
    if (_editingEntry?.id == entry.id) {
      _cancelEditing();
    }
  }
}

class _ThoughtEntryCard extends StatelessWidget {
  const _ThoughtEntryCard({
    required this.entry,
    required this.editable,
    required this.onEdit,
    required this.onDelete,
  });

  final ThoughtEntryModel entry;
  final bool editable;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final createdText = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(entry.createdAt.toLocal());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      createdText,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _EditabilityLabel(editable: editable),
                  ],
                ),
              ),
              if (editable) ...[
                SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton(
                    tooltip: 'Editar nota privada',
                    onPressed: onEdit,
                    icon: Icon(Icons.edit_outlined, color: AppColors.lavender),
                  ),
                ),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton(
                    tooltip: 'Eliminar nota privada',
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            entry.content,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThoughtPrivacyNotice extends StatelessWidget {
  const _ThoughtPrivacyNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.tertiaryBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline_rounded, color: AppColors.tertiary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Este diario es personal y no se usa para diagnosticar. Si escribes algo que indique riesgo o necesitas ayuda inmediata, busca apoyo profesional o comunícate con emergencias.',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AfterThoughtSaveActions extends StatelessWidget {
  const _AfterThoughtSaveActions({required this.onOpenActivities});

  final VoidCallback onOpenActivities;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Puedes continuar con una actividad breve.',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onOpenActivities,
              icon: const Icon(Icons.self_improvement_rounded, size: 18),
              label: const Text('Ir a actividades'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditabilityLabel extends StatelessWidget {
  const _EditabilityLabel({required this.editable});

  final bool editable;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: editable ? AppColors.successBg : AppColors.tertiaryBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: editable ? AppColors.mint : AppColors.tertiaryOnContainer,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            editable ? Icons.timer_outlined : Icons.lock_outline_rounded,
            size: 14,
            color: editable ? AppColors.mint : AppColors.tertiaryOnContainer,
          ),
          const SizedBox(width: 6),
          Text(
            editable ? 'Editable por 24h' : 'Solo lectura',
            style: TextStyle(
              color: editable ? AppColors.mint : AppColors.tertiaryOnContainer,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineFeedback extends StatelessWidget {
  const _InlineFeedback({
    required this.message,
    required this.icon,
    required this.color,
    required this.background,
  });

  final String message;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyThoughtsState extends StatelessWidget {
  const _EmptyThoughtsState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Text(
            'Aún no tienes notas guardadas. Escribe una nota breve para registrar cómo te sientes hoy.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.35,
            ),
          ),
        ),
      ),
    );
  }
}
