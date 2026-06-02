import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/app_colors.dart';
import 'citas_enums.dart';

class CitasCalendarCard extends StatelessWidget {
  final DateTime selectedDay;
  final DateTime focusedDay;
  final Map<DateTime, Set<CalendarEventType>> eventsByDay;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;

  const CitasCalendarCard({
    super.key,
    required this.selectedDay,
    required this.focusedDay,
    required this.eventsByDay,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: TableCalendar<CalendarEventType>(
        locale: 'es',
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(day, selectedDay),
        eventLoader: (day) => eventsByDay[_normalizeDate(day)]?.toList() ?? [],
        calendarFormat: CalendarFormat.twoWeeks,
        availableCalendarFormats: const {
          CalendarFormat.twoWeeks: '2 Semanas',
          CalendarFormat.month: 'Mes'
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
          weekendTextStyle: TextStyle(color: AppColors.textPrimary),
          defaultTextStyle: TextStyle(color: AppColors.textPrimary),
          todayTextStyle: TextStyle(
            color: AppColors.buttonPrimaryText,
            fontWeight: FontWeight.w700,
          ),
          selectedTextStyle: TextStyle(
            color: AppColors.buttonPrimaryText,
            fontWeight: FontWeight.w700,
          ),
          todayDecoration: BoxDecoration(
            color: AppColors.lavender.withValues(alpha: 0.45),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: AppColors.buttonPrimary,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 4,
          markerDecoration: BoxDecoration(
            color: AppColors.mint,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        calendarBuilders: CalendarBuilders<CalendarEventType>(
          markerBuilder: (context, day, events) {
            if (events.isEmpty) return const SizedBox.shrink();
            final uniqueEvents = events.toSet().toList();

            return Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: uniqueEvents
                      .take(3)
                      .map((eventType) => _buildMarkerDot(eventType))
                      .toList(),
                ),
              ),
            );
          },
        ),
        onDaySelected: onDaySelected,
        onPageChanged: onPageChanged,
      ),
    );
  }

  Widget _buildMarkerDot(CalendarEventType eventType) {
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

  Color _eventColor(CalendarEventType eventType) {
    return switch (eventType) {
      CalendarEventType.solicitada => AppColors.lavender,
      CalendarEventType.propuesta => AppColors.tertiary,
      CalendarEventType.confirmada => AppColors.mint,
      CalendarEventType.completada => AppColors.textSecondary,
    };
  }

  static DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
