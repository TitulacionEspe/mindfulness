import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/theme/app_colors.dart';
import '../../moduloCitas/model/appointment_model.dart';
import '../../moduloCitas/viewmodels/appointments_viewmodel.dart';
import 'componet/patient_navigation_helper.dart';

enum PatientAppointmentsTab { requests, agenda, history }

enum _PatientCalendarEventType { requested, proposed, confirmed, completed }

class PatientAppointmentsView extends StatefulWidget {
  const PatientAppointmentsView({
    super.key,
    this.initialTab,
    this.openRequestComposerOnStart = false,
  });

  final PatientAppointmentsTab? initialTab;
  final bool openRequestComposerOnStart;

  @override
  State<PatientAppointmentsView> createState() =>
      _PatientAppointmentsViewState();
}

class _PatientAppointmentsViewState extends State<PatientAppointmentsView> {
  DateTime _selectedDay = _normalizeDate(DateTime.now());
  DateTime _focusedDay = _normalizeDate(DateTime.now());
  PatientAppointmentsTab _tab = PatientAppointmentsTab.requests;
  List<Map<String, dynamic>> _professionals = const [];
  bool _loadingProfessionals = true;
  bool _openedComposer = false;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab ?? PatientAppointmentsTab.requests;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<AppointmentsViewModel>().loadAll();
      await _loadProfessionals();
      if (widget.openRequestComposerOnStart &&
          !_openedComposer &&
          mounted &&
          _professionals.isNotEmpty) {
        _openedComposer = true;
        _openRequestSheet(context);
      }
    });
  }

  Future<void> _loadProfessionals() async {
    try {
      final rows = await Supabase.instance.client
          .from('profiles')
          .select('id, full_name')
          .eq('role', 'professional');
      if (!mounted) return;
      setState(() {
        _professionals = List<Map<String, dynamic>>.from(rows);
        _loadingProfessionals = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingProfessionals = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppointmentsViewModel>();
    final appointments = vm.allAppointments;
    final eventsByDay = _buildEventsByDay(appointments);

    final requests = appointments.where((appointment) {
      return appointment.status == 'SOLICITADA' ||
          appointment.status == 'PROPUESTA';
    }).toList();

    final agenda = appointments.where((appointment) {
      if (appointment.status != 'CONFIRMADA' ||
          appointment.scheduledDate == null) {
        return false;
      }
      return _isSameDay(appointment.scheduledDate!, _selectedDay);
    }).toList();

    final history = appointments.where((appointment) {
      if (appointment.status == 'COMPLETADA') return true;
      if (appointment.status == 'RECHAZADA') return true;
      return false;
    }).toList();

    final tabItems = switch (_tab) {
      PatientAppointmentsTab.requests => requests,
      PatientAppointmentsTab.agenda => agenda,
      PatientAppointmentsTab.history => history,
    };

    final proposedCount = appointments
        .where((appointment) => appointment.status == 'PROPUESTA')
        .length;
    final confirmedCount = appointments
        .where((appointment) => appointment.status == 'CONFIRMADA')
        .length;
    final completedCount = appointments
        .where((appointment) => appointment.status == 'COMPLETADA')
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Citas con Psicología',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Menú principal',
            onPressed: () => PatientNavigationHelper.returnToMainMenu(context),
            icon: const Icon(Icons.home_outlined),
          ),
          IconButton(
            tooltip: 'Actualizar',
            onPressed: () async {
              await vm.loadAll();
              await _loadProfessionals();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await vm.loadAll();
          await _loadProfessionals();
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 92),
          children: [
            Text(
              'Gestiona tus solicitudes y agenda confirmada sin perder contexto.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            _buildMetrics(
              proposedCount: proposedCount,
              confirmedCount: confirmedCount,
              completedCount: completedCount,
            ),
            const SizedBox(height: 14),
            _buildTabSelector(),
            const SizedBox(height: 12),
            if (_tab == PatientAppointmentsTab.agenda) ...[
              _buildCalendar(eventsByDay),
              const SizedBox(height: 10),
              _buildLegend(eventsByDay),
              const SizedBox(height: 12),
            ],
            if (vm.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 22),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (tabItems.isEmpty)
              _emptyCard(_emptyMessageForTab(_tab))
            else
              ...tabItems.map(
                (appointment) => _appointmentCard(vm, appointment),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (_loadingProfessionals || _professionals.isEmpty)
            ? null
            : () => _openRequestSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Solicitar cita'),
      ),
    );
  }

  Widget _buildMetrics({
    required int proposedCount,
    required int confirmedCount,
    required int completedCount,
  }) {
    return Row(
      children: [
        Expanded(
          child: _metricCard(
            'Propuestas',
            '$proposedCount',
            Icons.mark_email_unread_outlined,
            AppColors.lavender,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _metricCard(
            'Confirmadas',
            '$confirmedCount',
            Icons.event_available_outlined,
            AppColors.mint,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _metricCard(
            'Completadas',
            '$completedCount',
            Icons.check_circle_outline,
            AppColors.tertiary,
          ),
        ),
      ],
    );
  }

  Widget _metricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(
    Map<DateTime, Set<_PatientCalendarEventType>> eventsByDay,
  ) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: TableCalendar<_PatientCalendarEventType>(
        locale: 'es',
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
        eventLoader: (day) =>
            eventsByDay[_normalizeDate(day)]?.toList() ?? const [],
        calendarFormat: CalendarFormat.twoWeeks,
        availableCalendarFormats: const {
          CalendarFormat.twoWeeks: '2 Semanas',
          CalendarFormat.month: 'Mes',
        },
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: AppColors.textSecondary,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
          ),
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          weekendStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          defaultTextStyle: TextStyle(color: AppColors.textPrimary),
          weekendTextStyle: TextStyle(color: AppColors.textPrimary),
          selectedTextStyle: TextStyle(
            color: AppColors.buttonPrimaryText,
            fontWeight: FontWeight.w700,
          ),
          todayTextStyle: TextStyle(
            color: AppColors.buttonPrimaryText,
            fontWeight: FontWeight.w700,
          ),
          selectedDecoration: BoxDecoration(
            color: AppColors.buttonPrimary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppColors.lavender.withValues(alpha: 0.45),
            shape: BoxShape.circle,
          ),
          markersMaxCount: 4,
        ),
        calendarBuilders: CalendarBuilders<_PatientCalendarEventType>(
          markerBuilder: (context, day, events) {
            if (events.isEmpty) return const SizedBox.shrink();
            final unique = events.toSet().toList();
            return Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: unique.take(3).map(_markerDot).toList(),
                ),
              ),
            );
          },
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = _normalizeDate(selectedDay);
            _focusedDay = _normalizeDate(focusedDay);
            _tab = PatientAppointmentsTab.agenda;
          });
        },
        onPageChanged: (focusedDay) => _focusedDay = _normalizeDate(focusedDay),
      ),
    );
  }

  Widget _markerDot(_PatientCalendarEventType eventType) {
    return Container(
      width: 6,
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: _eventColor(eventType),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildLegend(
    Map<DateTime, Set<_PatientCalendarEventType>> eventsByDay,
  ) {
    final hasRequested = _hasEvent(
      eventsByDay,
      _PatientCalendarEventType.requested,
    );
    final hasProposed = _hasEvent(
      eventsByDay,
      _PatientCalendarEventType.proposed,
    );
    final hasConfirmed = _hasEvent(
      eventsByDay,
      _PatientCalendarEventType.confirmed,
    );
    final hasCompleted = _hasEvent(
      eventsByDay,
      _PatientCalendarEventType.completed,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          if (hasRequested)
            _legendItem('Solicitada', _PatientCalendarEventType.requested),
          if (hasProposed)
            _legendItem('Propuesta', _PatientCalendarEventType.proposed),
          if (hasConfirmed)
            _legendItem('Confirmada', _PatientCalendarEventType.confirmed),
          if (hasCompleted)
            _legendItem('Completada', _PatientCalendarEventType.completed),
          if (!hasRequested && !hasProposed && !hasConfirmed && !hasCompleted)
            Text(
              'Aún no hay fechas asignadas para marcar.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, _PatientCalendarEventType eventType) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _eventColor(eventType),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTabSelector() {
    return SegmentedButton<PatientAppointmentsTab>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment(
          value: PatientAppointmentsTab.requests,
          icon: const Icon(Icons.mail_outline),
          label: _segmentLabel('Solicitudes'),
        ),
        ButtonSegment(
          value: PatientAppointmentsTab.agenda,
          icon: const Icon(Icons.calendar_month_outlined),
          label: _segmentLabel('Agenda'),
        ),
        ButtonSegment(
          value: PatientAppointmentsTab.history,
          icon: const Icon(Icons.history),
          label: _segmentLabel('Historial'),
        ),
      ],
      selected: {_tab},
      onSelectionChanged: (selection) {
        setState(() => _tab = selection.first);
      },
    );
  }

  Widget _segmentLabel(String label) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(label, maxLines: 1, softWrap: false),
    );
  }

  Widget _appointmentCard(AppointmentsViewModel vm, Appointment appointment) {
    final hasSchedule = appointment.scheduledDate != null;
    final dateText = hasSchedule
        ? DateFormat(
            'EEEE dd MMM, HH:mm',
            'es',
          ).format(appointment.scheduledDate!)
        : 'Pendiente de propuesta';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: AppColors.surfaceLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _statusChip(appointment.status),
                const Spacer(),
                Text(
                  appointment.type,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (appointment.professionalName != null &&
                appointment.professionalName!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: AppColors.lavender,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    appointment.professionalName!,
                    style: TextStyle(
                      color: AppColors.lavender,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Text(
              appointment.motive,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.schedule_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _capitalize(dateText),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            if (appointment.durationMinutes != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.timelapse_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${appointment.durationMinutes} min',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            _patientActions(vm, appointment),
          ],
        ),
      ),
    );
  }

  Widget _patientActions(AppointmentsViewModel vm, Appointment appointment) {
    if (appointment.id == null) return const SizedBox.shrink();

    if (appointment.status == 'PROPUESTA') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () =>
                  _updateStatus(vm, appointment.id!, 'RECHAZADA', false),
              child: const Text('Rechazar'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () =>
                  _updateStatus(vm, appointment.id!, 'CONFIRMADA', true),
              child: const Text('Confirmar horario'),
            ),
          ),
        ],
      );
    }

    if (appointment.status == 'SOLICITADA') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tu solicitud fue enviada. Te notificaremos cuando haya una propuesta.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () =>
                  _updateStatus(vm, appointment.id!, 'CANCELADA', false),
              icon: Icon(
                Icons.cancel_outlined,
                size: 18,
                color: AppColors.error,
              ),
              label: Text(
                'Cancelar solicitud',
                style: TextStyle(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
              ),
            ),
          ),
        ],
      );
    }

    if (appointment.status == 'CONFIRMADA') {
      return Text(
        'Cita confirmada. Llega unos minutos antes para iniciar con calma.',
        style: TextStyle(
          color: AppColors.mint,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _updateStatus(
    AppointmentsViewModel vm,
    String appointmentId,
    String status,
    bool accepted,
  ) async {
    try {
      await vm.updateStatusFromPatient(appointmentId, status);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            accepted
                ? 'Horario confirmado correctamente.'
                : 'Propuesta rechazada.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 5),
        ),
      );
      await vm.loadAll();
    }
  }

  Widget _statusChip(String status) {
    final (background, foreground, text) = switch (status) {
      'SOLICITADA' => (AppColors.warningBg, AppColors.lavender, 'Solicitada'),
      'PROPUESTA' => (AppColors.tertiaryBg, AppColors.tertiary, 'Propuesta'),
      'CONFIRMADA' => (AppColors.successBg, AppColors.mint, 'Confirmada'),
      'COMPLETADA' => (
        AppColors.surfaceHighest,
        AppColors.textPrimary,
        'Completada',
      ),
      'RECHAZADA' => (AppColors.tertiaryBg, AppColors.error, 'Rechazada'),
      'CANCELADA' => (
        AppColors.surfaceHighest,
        AppColors.textSecondary,
        'Cancelada',
      ),
      _ => (AppColors.surfaceHighest, AppColors.textSecondary, status),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _emptyCard(String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _emptyMessageForTab(PatientAppointmentsTab tab) {
    return switch (tab) {
      PatientAppointmentsTab.requests =>
        'No tienes solicitudes activas en este momento.',
      PatientAppointmentsTab.agenda =>
        'No hay citas confirmadas para la fecha seleccionada. Prueba otro día en el calendario.',
      PatientAppointmentsTab.history =>
        'Aún no hay citas finalizadas o rechazadas.',
    };
  }

  Future<void> _openRequestSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) =>
          _RequestAppointmentSheet(professionals: _professionals),
    );
  }

  Map<DateTime, Set<_PatientCalendarEventType>> _buildEventsByDay(
    List<Appointment> appointments,
  ) {
    final map = <DateTime, Set<_PatientCalendarEventType>>{};
    for (final appointment in appointments) {
      final scheduled = appointment.scheduledDate;
      if (scheduled == null) continue;
      final key = _normalizeDate(scheduled);
      map.putIfAbsent(key, () => <_PatientCalendarEventType>{});
      switch (appointment.status) {
        case 'SOLICITADA':
          map[key]!.add(_PatientCalendarEventType.requested);
          break;
        case 'PROPUESTA':
          map[key]!.add(_PatientCalendarEventType.proposed);
          break;
        case 'CONFIRMADA':
          map[key]!.add(_PatientCalendarEventType.confirmed);
          break;
        case 'COMPLETADA':
          map[key]!.add(_PatientCalendarEventType.completed);
          break;
      }
    }
    return map;
  }

  bool _hasEvent(
    Map<DateTime, Set<_PatientCalendarEventType>> eventsByDay,
    _PatientCalendarEventType eventType,
  ) {
    for (final events in eventsByDay.values) {
      if (events.contains(eventType)) return true;
    }
    return false;
  }

  Color _eventColor(_PatientCalendarEventType eventType) {
    return switch (eventType) {
      _PatientCalendarEventType.requested => AppColors.lavender,
      _PatientCalendarEventType.proposed => AppColors.tertiary,
      _PatientCalendarEventType.confirmed => AppColors.mint,
      _PatientCalendarEventType.completed => AppColors.textSecondary,
    };
  }

  static DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _RequestAppointmentSheet extends StatefulWidget {
  const _RequestAppointmentSheet({required this.professionals});

  final List<Map<String, dynamic>> professionals;

  @override
  State<_RequestAppointmentSheet> createState() =>
      _RequestAppointmentSheetState();
}

class _RequestAppointmentSheetState extends State<_RequestAppointmentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _motiveController = TextEditingController();
  String? _selectedProfessionalId;
  String _appointmentType = 'Primera vez';
  DateTime? _suggestedDate;

  @override
  void dispose() {
    _motiveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AppointmentsViewModel>();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nueva solicitud de cita',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Describe brevemente tu necesidad para que la psicóloga proponga un horario.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Profesional'),
              items: widget.professionals
                  .map(
                    (professional) => DropdownMenuItem<String>(
                      value: professional['id']?.toString(),
                      child: Text(professional['full_name'] ?? 'Profesional'),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _selectedProfessionalId = value),
              validator: (value) =>
                  value == null ? 'Selecciona un profesional' : null,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Primera vez', 'Seguimiento', 'Otro'].map((type) {
                final selected = _appointmentType == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: selected,
                  onSelected: (value) {
                    if (value) setState(() => _appointmentType = type);
                  },
                  backgroundColor: AppColors.surfaceLow,
                  selectedColor: AppColors.mint.withValues(alpha: 0.2),
                  side: BorderSide(
                    color: selected ? AppColors.mint : AppColors.outlineVariant,
                  ),
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    color: selected ? AppColors.mint : AppColors.textSecondary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _motiveController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Describeme lo que sucede',
                hintText:
                    'Ej: Necesito apoyo para regular ansiedad por exámenes.',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa el motivo de la cita';
                }
                if (value.trim().length < 10) {
                  return 'Describe un poco más tu situación';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _suggestedDate == null
                        ? '¿Tienes alguna fecha en mente? (Opcional)'
                        : 'Fecha sugerida: ${DateFormat('dd/MM/yyyy').format(_suggestedDate!)}',
                    style: TextStyle(
                      color: _suggestedDate == null
                          ? AppColors.textSecondary
                          : AppColors.mint,
                      fontSize: 14,
                      fontWeight: _suggestedDate == null
                          ? FontWeight.normal
                          : FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 60)),
                    );
                    if (date != null) {
                      setState(() => _suggestedDate = date);
                    }
                  },
                  child: Text(_suggestedDate == null ? 'Elegir' : 'Cambiar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (!_formKey.currentState!.validate() ||
                      _selectedProfessionalId == null) {
                    return;
                  }

                  String finalMotive = _motiveController.text.trim();
                  if (_suggestedDate != null) {
                    final dateStr = DateFormat(
                      'dd/MM/yyyy',
                    ).format(_suggestedDate!);
                    finalMotive +=
                        '\n\n(Fecha sugerida por el paciente: $dateStr)';
                  }

                  try {
                    await vm.createNewRequest(
                      _selectedProfessionalId!,
                      _appointmentType,
                      finalMotive,
                    );
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Solicitud enviada con éxito.'),
                      ),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    final msg = e.toString().replaceAll('Exception: ', '');
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Aviso'),
                        content: Text(msg),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Entendido'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.send_outlined),
                label: const Text('Enviar solicitud'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
