import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/safe_notifier.dart';

/// Lightweight notification preferences (toggles only — actual scheduling
/// stays in NotificationService / AlarmService). Use as a ChangeNotifier
/// from your settings screen.
class NotificationPrefs extends ChangeNotifier with SafeNotifier {
  static const _kReminders = 'np_reminders_enabled';
  static const _kAlarms = 'np_alarms_enabled';
  static const _kQuietStart = 'np_quiet_start';
  static const _kQuietEnd = 'np_quiet_end';

  bool _remindersEnabled = true;
  bool _alarmsEnabled = true;
  int? _quietStart; // minutes from midnight
  int? _quietEnd;

  bool get remindersEnabled => _remindersEnabled;
  bool get alarmsEnabled => _alarmsEnabled;
  int? get quietStart => _quietStart;
  int? get quietEnd => _quietEnd;
  bool get quietHoursEnabled => _quietStart != null && _quietEnd != null;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _remindersEnabled = p.getBool(_kReminders) ?? true;
    _alarmsEnabled = p.getBool(_kAlarms) ?? true;
    _quietStart = p.getInt(_kQuietStart);
    _quietEnd = p.getInt(_kQuietEnd);
    notifySafely();
  }

  Future<void> setReminders(bool v) async {
    _remindersEnabled = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kReminders, v);
    notifySafely();
  }

  Future<void> setAlarms(bool v) async {
    _alarmsEnabled = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kAlarms, v);
    notifySafely();
  }

  Future<void> setQuietHours({int? startMinutes, int? endMinutes}) async {
    _quietStart = startMinutes;
    _quietEnd = endMinutes;
    final p = await SharedPreferences.getInstance();
    if (startMinutes == null) {
      await p.remove(_kQuietStart);
    } else {
      await p.setInt(_kQuietStart, startMinutes);
    }
    if (endMinutes == null) {
      await p.remove(_kQuietEnd);
    } else {
      await p.setInt(_kQuietEnd, endMinutes);
    }
    notifySafely();
  }
}
