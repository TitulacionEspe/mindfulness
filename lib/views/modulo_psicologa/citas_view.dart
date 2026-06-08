import 'package:flutter/material.dart';
import 'package:mindfulness_app/moduloCitas/model/appointment_model.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/theme/app_colors.dart';
import '../../moduloCitas/viewmodels/appointments_viewmodel.dart';
import 'citas/components/appointment_card_item.dart';
import 'citas/components/citas_calendar_card.dart';
import 'citas/components/citas_calendar_legend.dart';
import 'citas/components/citas_dialogs.dart';
import 'citas/components/citas_empty_state.dart';
import 'citas/components/citas_enums.dart';
import 'citas/components/citas_metrics_row.dart';
import 'components/professional_navigation_helper.dart';

class CitasView extends StatefulWidget {
  const CitasView({super.key});

  @override
  State<CitasView> createState() => _CitasViewState();
}

class _CitasViewState extends State<CitasView> {
  DateTime _selectedDay = _normalizeDate(DateTime.now());
  DateTime _focusedDay = _normalizeDate(DateTime.now());
  CitasTab _currentTab = CitasTab.agenda;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentsViewModel>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppointmentsViewModel>();
    final appointments = vm.allAppointments;
    final eventsByDay = _buildEventsByDay(appointments);

    // Filtrado de citas
    final dailyAgenda = appointments.where((appointment) {
      if (appointment.scheduledDate == null) return false;
      return isSameDay(appointment.scheduledDate!, _selectedDay) &&
          (appointment.status == 'CONFIRMADA' ||
              appointment.status == 'PROPUESTA');
    }).toList();

    final pendingRequests = vm.pendingRequests;

    final completedByDay = appointments.where((appointment) {
      if (appointment.status != 'COMPLETADA' ||
          appointment.scheduledDate == null) {
        return false;
      }
      return isSameDay(appointment.scheduledDate!, _selectedDay);
    }).toList();

    // Métricas
    final todaysCount = dailyAgenda.length;
    final pendingCount = pendingRequests.length;
    final upcomingWeek = appointments.where((appointment) {
      if (appointment.scheduledDate == null ||
          appointment.status != 'CONFIRMADA') {
        return false;
      }
      final now = DateTime.now();
      final limit = now.add(const Duration(days: 7));
      return appointment.scheduledDate!.isAfter(now) &&
          appointment.scheduledDate!.isBefore(limit);
    }).length;

    final visibleAppointments = switch (_currentTab) {
      CitasTab.agenda => dailyAgenda,
      CitasTab.solicitudes => pendingRequests,
      CitasTab.historial => completedByDay,
    };

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: vm.loadAll,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                children: [
                  Text(
                    'Agenda de citas',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Gestiona próximas citas, solicitudes pendientes y citas finalizadas.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // PIEZA: Métricas
                  CitasMetricsRow(
                    todaysCount: todaysCount,
                    pendingCount: pendingCount,
                    upcomingWeek: upcomingWeek,
                  ),

                  const SizedBox(height: 16),

                  // PIEZA: Selector de pestañas
                  SegmentedButton<CitasTab>(
                    segments: const [
                      ButtonSegment<CitasTab>(
                        value: CitasTab.agenda,
                        icon: Icon(Icons.calendar_month_outlined),
                        label: Text('Agenda'),
                      ),
                      ButtonSegment<CitasTab>(
                        value: CitasTab.solicitudes,
                        icon: Icon(Icons.mail_outline),
                        label: Text('Solicitudes'),
                      ),
                      ButtonSegment<CitasTab>(
                        value: CitasTab.historial,
                        icon: Icon(Icons.history),
                        label: Text('Historial'),
                      ),
                    ],
                    selected: {_currentTab},
                    showSelectedIcon: false,
                    onSelectionChanged: (selection) {
                      setState(() => _currentTab = selection.first);
                    },
                  ),

                  const SizedBox(height: 14),

                  // Acciones rápidas
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              ProfessionalNavigationHelper.returnToHome(
                                context,
                              ),
                          icon: const Icon(Icons.home_outlined),
                          label: const Text('Ir al dashboard'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton.filledTonal(
                        tooltip: 'Recargar',
                        onPressed: vm.loadAll,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  if (vm.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (visibleAppointments.isEmpty)
                    // PIEZA: Estado vacío
                    CitasEmptyState(currentTab: _currentTab)
                  else
                    ...visibleAppointments.map(
                      (appointment) => AppointmentCardItem(
                        appointment: appointment,
                        onPropose: () => CitasDialogs.showProposeDialog(
                          context: context,
                          appointment: appointment,
                          initialDate: _selectedDay,
                          onSuccess: (newDate) {
                            setState(() {
                              _selectedDay = _normalizeDate(newDate);
                              _focusedDay = _normalizeDate(newDate);
                              _currentTab = CitasTab.agenda;
                            });
                          },
                        ),
                        onComplete: () => CitasDialogs.showCompleteDialog(
                          context: context,
                          appointment: appointment,
                        ),
                      ),
                    ),

                  if (_currentTab == CitasTab.agenda ||
                      _currentTab == CitasTab.historial) ...[
                    const SizedBox(height: 25),
                    const Divider(),
                    const SizedBox(height: 15),

                    Text(
                      'Vista de calendario',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // PIEZA: Calendario (Ahora al final)
                    CitasCalendarCard(
                      selectedDay: _selectedDay,
                      focusedDay: _focusedDay,
                      eventsByDay: eventsByDay,
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = _normalizeDate(selectedDay);
                          _focusedDay = _normalizeDate(focusedDay);
                        });
                      },
                      onPageChanged: (focusedDay) {
                        setState(() {
                          _focusedDay = _normalizeDate(focusedDay);
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    // PIEZA: Leyenda
                    CitasCalendarLegend(eventsByDay: eventsByDay),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<DateTime, Set<CalendarEventType>> _buildEventsByDay(
    List<Appointment> appointments,
  ) {
    final map = <DateTime, Set<CalendarEventType>>{};
    for (final appointment in appointments) {
      final scheduled = appointment.scheduledDate;
      if (scheduled == null) continue;
      final key = _normalizeDate(scheduled);
      map.putIfAbsent(key, () => <CalendarEventType>{});

      switch (appointment.status) {
        case 'SOLICITADA':
          map[key]!.add(CalendarEventType.solicitada);
          break;
        case 'PROPUESTA':
          map[key]!.add(CalendarEventType.propuesta);
          break;
        case 'CONFIRMADA':
          map[key]!.add(CalendarEventType.confirmada);
          break;
        case 'COMPLETADA':
          map[key]!.add(CalendarEventType.completada);
          break;
      }
    }
    return map;
  }

  static DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
