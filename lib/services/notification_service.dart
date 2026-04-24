import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/reminder_model.dart';

class NotificationPermissionState {
  final bool notificationsGranted;
  final bool exactAlarmsGranted;

  const NotificationPermissionState({
    required this.notificationsGranted,
    required this.exactAlarmsGranted,
  });
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const int _testNotificationId = 999001;

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    await _configureLocalTimezone();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(android: android, iOS: darwin);
    await _notificationsPlugin.initialize(settings: settings);
  }

  Future<void> _configureLocalTimezone() async {
    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  Future<NotificationPermissionState> requestPermissions() {
    return _resolvePermissionState(requestRuntimePermissions: true);
  }

  Future<NotificationPermissionState> getPermissionState() {
    return _resolvePermissionState(requestRuntimePermissions: false);
  }

  Future<void> showTestNotificationNow() async {
    await _notificationsPlugin.show(
      id: _testNotificationId,
      title: 'Prueba de recordatorio',
      body: 'Si recibes este aviso, las notificaciones locales funcionan.',
      notificationDetails: _notificationDetails,
    );
  }

  Future<NotificationPermissionState> _resolvePermissionState({
    required bool requestRuntimePermissions,
  }) async {
    bool notificationsGranted = true;
    bool exactAlarmsGranted = true;

    final android = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (android != null) {
      if (requestRuntimePermissions) {
        final notificationRequest = await android
            .requestNotificationsPermission();
        if (notificationRequest != null) {
          notificationsGranted = notificationRequest;
        }

        final exactAlarmRequest = await android.requestExactAlarmsPermission();
        if (exactAlarmRequest != null) {
          exactAlarmsGranted = exactAlarmRequest;
        }
      }

      final notificationsEnabled = await android.areNotificationsEnabled();
      if (notificationsEnabled != null) {
        notificationsGranted = notificationsGranted && notificationsEnabled;
      }

      final canScheduleExact = await android.canScheduleExactNotifications();
      if (canScheduleExact != null) {
        exactAlarmsGranted = exactAlarmsGranted && canScheduleExact;
      }
    }

    return NotificationPermissionState(
      notificationsGranted: notificationsGranted,
      exactAlarmsGranted: exactAlarmsGranted,
    );
  }

  Future<void> scheduleReminder(ReminderModel reminder) async {
    final baseId = reminder.notificationBaseId;
    if (baseId == null) {
      return;
    }

    await cancelReminder(baseId);

    if (!reminder.isActive || reminder.daysOfWeek == 0) {
      return;
    }

    for (int i = 0; i < 7; i++) {
      final dayBit = 1 << i;
      if ((reminder.daysOfWeek & dayBit) != 0) {
        final weekDay = i + 1;

        await _scheduleWeekly(
          id: baseId + weekDay,
          title: 'Mindfulness',
          body: _getReminderMessage(reminder.type),
          time: reminder.triggerTime,
          day: weekDay,
        );
      }
    }
  }

  String _getReminderMessage(ReminderType type) {
    switch (type) {
      case ReminderType.sleepInduction:
        return 'Es momento de tu induccion al sueno. Descansa.';
      case ReminderType.routineStart:
        return 'Tu rutina nocturna esta por comenzar. Preparate.';
      case ReminderType.briefRelaxation:
        return 'Tomate un momento para una relajacion breve.';
    }
  }

  Future<void> _scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    required int day,
  }) async {
    final scheduledDate = _nextInstanceOfDayAndTime(day, time);

    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } on PlatformException {
      // Fallback when exact alarms are blocked by device policy.
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  tz.TZDateTime _nextInstanceOfDayAndTime(int day, TimeOfDay time) {
    var scheduledDate = _nextInstanceOfTime(time);
    while (scheduledDate.weekday != day) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> cancelReminder(int id) async {
    for (int i = 1; i <= 7; i++) {
      await _notificationsPlugin.cancel(id: id + i);
    }
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<int> getPendingScheduledCount() async {
    final pending = await _notificationsPlugin.pendingNotificationRequests();
    return pending.length;
  }

  static const NotificationDetails _notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'reminders_channel',
      'Recordatorios',
      channelDescription: 'Notificaciones de habitos de sueno',
      importance: Importance.max,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );
}
