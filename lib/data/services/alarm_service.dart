import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../models/alarm.dart';
import '../../core/utils/safe_notifier.dart';

/// Lightweight alarm store + scheduler. Persists to SharedPreferences and
/// schedules system notifications via flutter_local_notifications.
class AlarmService extends ChangeNotifier with SafeNotifier {
  static const _prefsKey = 'zyvora_alarms_v1';
  static const _channelId = 'zyvora_alarms';
  static const _channelName = 'Zyvora Alarms';
  static const _channelDescription = 'Scheduled alarms from Zyvora.';

  FlutterLocalNotificationsPlugin? _plugin;
  final List<Alarm> _alarms = [];

  List<Alarm> get alarms => List.unmodifiable(_alarms);

  /// Call this after constructing, passing the same plugin instance used by
  /// your existing NotificationService.
  void attachPlugin(FlutterLocalNotificationsPlugin plugin) {
    _plugin = plugin;
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? const [];
    _alarms
      ..clear()
      ..addAll(raw.map(Alarm.fromJson));
    notifySafely();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      _alarms.map((a) => a.toJson()).toList(),
    );
  }

  Future<Alarm> add({
    required String label,
    required int hour,
    required int minute,
    Set<int> repeatDays = const {},
    String sound = 'default',
    bool vibrate = true,
  }) async {
    final alarm = Alarm(
      id: DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
      label: label.trim().isEmpty ? 'Alarm' : label.trim(),
      hour: hour,
      minute: minute,
      repeatDays: repeatDays,
      sound: sound,
      vibrate: vibrate,
      createdAt: DateTime.now(),
    );
    _alarms.add(alarm);
    await _persist();
    await _schedule(alarm);
    notifySafely();
    return alarm;
  }

  Future<void> update(Alarm next) async {
    final i = _alarms.indexWhere((a) => a.id == next.id);
    if (i == -1) return;
    _alarms[i] = next;
    await _cancel(next.id);
    if (next.enabled) await _schedule(next);
    await _persist();
    notifySafely();
  }

  Future<void> toggle(int id, bool enabled) async {
    final i = _alarms.indexWhere((a) => a.id == id);
    if (i == -1) return;
    await update(_alarms[i].copyWith(enabled: enabled));
  }

  Future<void> remove(int id) async {
    _alarms.removeWhere((a) => a.id == id);
    await _cancel(id);
    await _persist();
    notifySafely();
  }

  Future<void> _schedule(Alarm alarm) async {
    final plugin = _plugin;
    if (plugin == null || !alarm.enabled) return;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        category: AndroidNotificationCategory.alarm,
        fullScreenIntent: true,
        playSound: true,
        enableVibration: alarm.vibrate,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
      macOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );

    if (alarm.isOneShot) {
      final when = _nextOneShot(alarm.hour, alarm.minute);
      await plugin.zonedSchedule(
        id: alarm.id,
        title: alarm.label,
        body: _formatTime(alarm.hour, alarm.minute),
        scheduledDate: when,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      return;
    }

    for (final weekday in alarm.repeatDays) {
      final when = _nextWeekday(weekday, alarm.hour, alarm.minute);
      final notifId = (alarm.id ^ (weekday << 24)) & 0x7fffffff;
      await plugin.zonedSchedule(
        id: notifId,
        title: alarm.label,
        body: _formatTime(alarm.hour, alarm.minute),
        scheduledDate: when,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<void> _cancel(int id) async {
    final plugin = _plugin;
    if (plugin == null) return;
    await plugin.cancel(id: id);
    for (var d = 1; d <= 7; d++) {
      await plugin.cancel(id: (id ^ (d << 24)) & 0x7fffffff);
    }
  }

  tz.TZDateTime _nextOneShot(int h, int m) {
    final now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, h, m);
    if (!when.isAfter(now)) when = when.add(const Duration(days: 1));
    return when;
  }

  tz.TZDateTime _nextWeekday(int weekday, int h, int m) {
    final now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, h, m);
    while (when.weekday != weekday || !when.isAfter(now)) {
      when = when.add(const Duration(days: 1));
    }
    return when;
  }

  String _formatTime(int h, int m) {
    final hh = h.toString().padLeft(2, '0');
    final mm = m.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
