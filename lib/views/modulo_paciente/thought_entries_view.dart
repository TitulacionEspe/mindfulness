import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/thought_entry_model.dart';
import '../../viewmodels/thought_entries_viewmodel.dart';

class ThoughtEntriesView extends StatefulWidget {
  const ThoughtEntriesView({super.key});

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ThoughtEntriesViewModel>().loadEntries();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ThoughtEntriesViewModel>();

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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                  child: Row(
                    children: [
                      SizedBox(
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Descarga emocional',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 8, 20, 14),
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
                            ? 'Escribe y libera la mente antes de dormir.'
                            : 'Editando una entrada reciente.',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tus pensamientos son privados. Solo se permite editar o eliminar durante 24 horas.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
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
                                  'Modo edicion activo',
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
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          height: 1.4,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Escribe aqui tus preocupaciones, ideas o reflexiones de hoy.',
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
                          onPressed: viewModel.isSaving ? null : _saveCurrent,
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
                                ? 'Guardar pensamiento'
                                : 'Actualizar entrada',
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Text(
                    'Historial privado',
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

  Future<void> _saveCurrent() async {
    final viewModel = context.read<ThoughtEntriesViewModel>();
    final success = await viewModel.saveEntry(
      content: _controller.text,
      existingEntry: _editingEntry,
    );

    if (!mounted || !success) return;
    _controller.clear();
    _focusNode.unfocus();
    setState(() {
      _editingEntry = null;
    });
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
            'Eliminar entrada',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Text(
            'Esta accion elimina la entrada de forma permanente.',
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
                    tooltip: 'Editar entrada',
                    onPressed: onEdit,
                    icon: Icon(Icons.edit_outlined, color: AppColors.lavender),
                  ),
                ),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton(
                    tooltip: 'Eliminar entrada',
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
            'Aun no tienes entradas guardadas. Registra tu primer pensamiento para descargar tension emocional.',
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
