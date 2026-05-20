import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../core/constants/app_constants.dart';
import '../../utils/time_utils.dart';
import '../../models/reminder.dart';

class NotificationService {
  static const _channelId = 'zyvora_reminders';
  static const _channelName = 'Zyvora Reminders';
  static const _channelDescription = 'Scheduled reminders from Zyvora.';
  static const _pluginCallTimeout = Duration(seconds: 5);

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Same plugin instance used for reminder scheduling; [AlarmController] attaches
  /// here so alarm notifications reuse the initialized channel and timezone.
  FlutterLocalNotificationsPlugin get notificationsPlugin => _plugin;

  bool _initialized = false;
  bool _requestedRuntimePermissions = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    await _configureLocalTimezone();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    try {
      await _plugin.initialize(settings: settings).timeout(_pluginCallTimeout);
      await _createAndroidChannel();
      _initialized = true;
    } catch (_) {
      _initialized = false;
    }
  }

  Future<void> scheduleWeeklyReminder(Reminder item) async {
    if (!item.notificationEnabled) {
      await cancel(item.id);
      return;
    }

    await initialize();
    if (!_initialized) return;

    await _requestRuntimePermissions();
    await cancel(item.id);

    final scheduledDate = _nextWeeklyOccurrence(item);
    final details = NotificationDetails(
      android: _androidDetails(),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      macOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    try {
      await _plugin.zonedSchedule(
        id: item.id,
        title: 'Zyvora - ${item.category}',
        body:
            '${item.title} at ${TimeUtils.formatClockTime(item.hour, item.minute)}',
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: item.id.toString(),
      );
    } on PlatformException {
      await _plugin.zonedSchedule(
        id: item.id,
        title: 'Zyvora - ${item.category}',
        body:
            '${item.title} at ${TimeUtils.formatClockTime(item.hour, item.minute)}',
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: item.id.toString(),
      );
    } catch (_) {
      // Scheduling can fail on platforms without notification support.
    }
  }

  Future<void> rescheduleAll(Iterable<Reminder> items) async {
    await initialize();
    for (final item in items) {
      await scheduleWeeklyReminder(item);
    }
  }

  Future<void> cancel(int id) async {
    try {
      await _plugin.cancel(id: id);
    } catch (_) {}
  }

  Future<void> _configureLocalTimezone() async {
    var timeZoneName = 'UTC';
    try {
      final timezone = await FlutterTimezone.getLocalTimezone().timeout(
        _pluginCallTimeout,
      );
      timeZoneName = timezone.toString();
    } catch (_) {}

    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  Future<void> _createAndroidChannel() async {
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel)
        .timeout(_pluginCallTimeout);
  }

  Future<void> _requestRuntimePermissions() async {
    if (_requestedRuntimePermissions) return;
    _requestedRuntimePermissions = true;

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    try {
      await android?.requestNotificationsPermission();
      await android?.requestExactAlarmsPermission();
    } catch (_) {}

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final macos = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    try {
      await ios?.requestPermissions(alert: true, badge: true, sound: true);
      await macos?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (_) {}
  }

  AndroidNotificationDetails _androidDetails() {
    return const AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Zyvora reminder',
    );
  }

  tz.TZDateTime _nextWeeklyOccurrence(Reminder item) {
    final now = tz.TZDateTime.now(tz.local);
    final targetWeekday = ZyvoraDays.weekdayNumbers[item.day] ?? now.weekday;
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      item.hour,
      item.minute,
    );
    while (scheduled.weekday != targetWeekday || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
