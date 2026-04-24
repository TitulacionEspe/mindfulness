import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/reminder_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/reminders_viewmodel.dart';

class RemindersView extends StatefulWidget {
  const RemindersView({super.key});

  @override
  State<RemindersView> createState() => _RemindersViewState();
}

class _RemindersViewState extends State<RemindersView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final viewModel = context.read<RemindersViewModel>();
      await viewModel.ensureNotificationPermissions();
      await viewModel.loadReminders();
    });
  }

  void _showReminderDialog([ReminderModel? reminder]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ReminderFormSheet(reminder: reminder),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RemindersViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: viewModel.isLoading && viewModel.reminders.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.mint),
              )
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 44,
                            height: 44,
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                side: const BorderSide(
                                  color: AppColors.outlineVariant,
                                ),
                                backgroundColor: AppColors.surfaceLow,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: AppColors.textPrimary,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Recordatorios',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Manten la constancia',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              height: 1.08,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Configura avisos para higiene del sueno, inicio de rutina y pausas de relajacion.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                              height: 1.35,
                            ),
                          ),
                          if (viewModel.errorMessage != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.warningBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.lavender.withValues(
                                    alpha: 0.25,
                                  ),
                                ),
                              ),
                              child: Text(
                                viewModel.errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.lavender,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (viewModel.reminders.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList.separated(
                        itemBuilder: (context, index) {
                          final reminder = viewModel.reminders[index];
                          return _ReminderCard(
                            reminder: reminder,
                            onTap: () => _showReminderDialog(reminder),
                            onToggle: (_) => viewModel.toggleReminder(reminder),
                            daysSummary: _getDaysSummary(reminder.daysOfWeek),
                          );
                        },
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemCount: viewModel.reminders.length,
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 96)),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showReminderDialog(),
        backgroundColor: AppColors.mint,
        foregroundColor: AppColors.buttonPrimaryText,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo aviso'),
      ),
    );
  }

  String _getDaysSummary(int daysOfWeek) {
    if (daysOfWeek == 127) return 'Todos los dias';
    if (daysOfWeek == 0) return 'Ningun dia';

    final days = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];
    final selected = <String>[];
    for (int i = 0; i < 7; i++) {
      if ((daysOfWeek & (1 << i)) != 0) {
        selected.add(days[i]);
      }
    }
    return selected.join(', ');
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.reminder,
    required this.onTap,
    required this.onToggle,
    required this.daysSummary,
  });

  final ReminderModel reminder;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;
  final String daysSummary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLowest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.alarm_rounded,
                  color: AppColors.lavender,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.triggerTime.format(context),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warningBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            reminder.type.label,
                            style: const TextStyle(
                              color: AppColors.lavender,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      daysSummary,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: reminder.isActive,
                activeThumbColor: AppColors.mint,
                inactiveTrackColor: AppColors.surfaceLowest,
                inactiveThumbColor: AppColors.textSecondary,
                onChanged: onToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
          child: const Text(
            'Aun no tienes recordatorios configurados. Usa "Nuevo aviso" para crear el primero.',
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

class ReminderFormSheet extends StatefulWidget {
  const ReminderFormSheet({super.key, this.reminder});

  final ReminderModel? reminder;

  @override
  State<ReminderFormSheet> createState() => _ReminderFormSheetState();
}

class _ReminderFormSheetState extends State<ReminderFormSheet> {
  late TimeOfDay _time;
  late int _days;
  late ReminderType _type;

  @override
  void initState() {
    super.initState();
    _time =
        widget.reminder?.triggerTime ?? const TimeOfDay(hour: 21, minute: 0);
    _days = widget.reminder?.daysOfWeek ?? 127;
    _type = widget.reminder?.type ?? ReminderType.routineStart;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<RemindersViewModel>();
    final authViewModel = context.read<AuthViewModel>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.reminder == null
                    ? 'Nuevo recordatorio'
                    : 'Editar recordatorio',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (widget.reminder != null)
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final success = await viewModel.deleteReminder(
                      widget.reminder!.id!,
                    );
                    if (success) {
                      navigator.pop();
                    }
                  },
                ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Tipo de aviso',
            style: TextStyle(
              color: AppColors.lavender,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ReminderType.values.map((type) {
              final isSelected = _type == type;
              return ChoiceChip(
                label: Text(type.label),
                selected: isSelected,
                onSelected: (val) {
                  if (val) setState(() => _type = type);
                },
                selectedColor: AppColors.mint,
                backgroundColor: AppColors.surfaceLow,
                side: const BorderSide(color: AppColors.outlineVariant),
                labelStyle: TextStyle(
                  color: isSelected
                      ? AppColors.buttonPrimaryText
                      : AppColors.textPrimary,
                ),
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 22),
          const Text(
            'Horario',
            style: TextStyle(
              color: AppColors.lavender,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Material(
            color: AppColors.surfaceLow,
            borderRadius: BorderRadius.circular(16),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                _time.format(context),
                style: const TextStyle(
                  color: AppColors.mint,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              trailing: const Icon(Icons.access_time, color: AppColors.mint),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _time,
                );
                if (time != null) setState(() => _time = time);
              },
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Dias',
            style: TextStyle(
              color: AppColors.lavender,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _dayButton('L', 1),
              _dayButton('M', 2),
              _dayButton('M', 4),
              _dayButton('J', 8),
              _dayButton('V', 16),
              _dayButton('S', 32),
              _dayButton('D', 64),
            ],
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: viewModel.isLoading
                ? null
                : () async {
                    final currentUserId = authViewModel.currentUser?.id;
                    if (currentUserId == null) return;

                    final navigator = Navigator.of(context);
                    final newReminder = ReminderModel(
                      id: widget.reminder?.id,
                      patientId: currentUserId,
                      triggerTime: _time,
                      daysOfWeek: _days,
                      type: _type,
                      isActive: widget.reminder?.isActive ?? true,
                    );

                    final success = widget.reminder == null
                        ? await viewModel.addReminder(newReminder)
                        : await viewModel.updateReminder(newReminder);

                    if (success) {
                      navigator.pop();
                    }
                  },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
            ),
            child: viewModel.isLoading
                ? const CircularProgressIndicator(
                    color: AppColors.buttonPrimaryText,
                  )
                : const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget _dayButton(String label, int bitValue) {
    final isSelected = (_days & bitValue) != 0;
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _days &= ~bitValue;
          } else {
            _days |= bitValue;
          }
        });
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mint : AppColors.surfaceLow,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.mint : AppColors.outlineVariant,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? AppColors.buttonPrimaryText
                : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
