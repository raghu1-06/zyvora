import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/safe_notifier.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../../../data/services/notification_service.dart';
import '../../../models/reminder.dart';
import '../../../models/zyvora_role.dart';
import '../../profile/controllers/user_controller.dart';
import '../../../utils/time_utils.dart';

class ReminderController extends ChangeNotifier with SafeNotifier {
  final ReminderRepository _repo;
  final NotificationService _notificationService;
  final UserController _userController;

  ReminderController({
    required ReminderRepository repo,
    required NotificationService notificationService,
    required UserController userController,
  })  : _repo = repo,
        _notificationService = notificationService,
        _userController = userController {
    _userController.addListener(_handleUserChange);
  }

  List<Reminder> _reminders = [];
  List<Map<String, dynamic>> _completionLogs = [];
  String? _selectedCategory;
  bool _isReady = false;
  bool _isLoading = false;
  String? _errorMessage;

  List<Reminder> get reminders => List.unmodifiable(_reminders);
  List<Map<String, dynamic>> get completionLogs => List.unmodifiable(_completionLogs);
  String? get selectedCategory => _selectedCategory;
  bool get isReady => _isReady;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  LifeMode? get lifeMode => _userController.lifeMode;
  ZyvoraRole? get role => _userController.role;
  String get todayName => _userController.todayName;

  List<Reminder> get activeReminders {
    final mode = _userController.lifeMode;
    if (mode == null) return List.unmodifiable(_reminders);
    final modeValue = mode.storageValue;
    return _reminders.where((r) => r.lifeMode == modeValue).toList();
  }

  List<Reminder> get todayReminders {
    final today = todayName;
    return activeReminders.where((r) => r.day == today).toList()
      ..sort((a, b) => a.minutesFromMidnight.compareTo(b.minutesFromMidnight));
  }

  int get totalReminderCount => activeReminders.length;

  int get todayCompletedCount =>
      todayReminders.where((r) => r.isCompleted).length;

  int get todayTotalCount => todayReminders.length;

  double get todayProductivity {
    if (todayTotalCount == 0) return 0;
    return (todayCompletedCount / todayTotalCount) * 100;
  }

  int get currentStreak {
    final now = DateTime.now();
    var streak = 0;
    for (var i = 0; i < 30; i++) {
      final dateStr = _dateKey(now.subtract(Duration(days: i)));
      final completedOnDay = _completionLogs.any((log) {
        final completedAt = log['completedAt'] as String?;
        return completedAt != null && completedAt.startsWith(dateStr);
      });

      if (completedOnDay) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return streak;
  }

  Map<String, int> get weekCompletionStats {
    final stats = {for (final day in ZyvoraDays.ordered) day: 0};
    final now = DateTime.now();

    for (var i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: i));
      final dateStr = _dateKey(day);
      final dayName = ZyvoraDays.fromWeekday(day.weekday);
      final completedCount = _completionLogs.where((log) {
        final completedAt = log['completedAt'] as String?;
        return completedAt != null && completedAt.startsWith(dateStr);
      }).length;

      stats[dayName] = (stats[dayName] ?? 0) + completedCount;
    }
    return stats;
  }

  Future<void> initialize() async {
    if (_isReady || _isLoading) return;
    _setLoading(true);

    try {
      final prefs = await SharedPreferences.getInstance();

      try {
        final rows = await _repo.fetchAll();
        _reminders = rows.map((r) => Reminder.fromJson(r)).toList();
      } catch (e) {
        debugPrint('Could not load reminders: $e');
        _reminders = [];
      }

      await _migrateFromSharedPreferences(prefs);
      await _resetStaleCompletions();

      try {
        _completionLogs = await _repo.getCompletionLogs(days: 30);
      } catch (e) {
        debugPrint('Could not load completion logs: $e');
        _completionLogs = [];
      }

      _errorMessage = null;
    } catch (e) {
      debugPrint('Reminder startup failed: $e');
      _errorMessage = 'Could not load reminders.';
    }

    unawaited(
      _notificationService.initialize().catchError((Object e) {
        debugPrint('Notification startup skipped: $e');
      }),
    );

    _isReady = true;
    _setLoading(false);
  }

  void selectCategory(String? category) {
    _selectedCategory = category;
    notifySafely();
  }

  List<Reminder> remindersForDay(String day) {
    var items = _reminders.where((r) => r.day == day);
    if (_userController.lifeMode != null) {
      items = items.where((r) => r.lifeMode == _userController.lifeMode!.storageValue);
    }
    if (_selectedCategory != null) {
      items = items.where((r) => r.category == _selectedCategory);
    }
    return items.toList()
      ..sort((a, b) => a.minutesFromMidnight.compareTo(b.minutesFromMidnight));
  }

  Reminder? nextReminderForToday() {
    final now = DateTime.now();
    final currentMinute = now.hour * 60 + now.minute;
    final today = todayReminders.where((r) => !r.isCompleted).toList();

    for (final item in today) {
      if (item.minutesFromMidnight >= currentMinute) return item;
    }
    return null;
  }

  Future<void> addReminder({
    required String title,
    required String day,
    required int hour,
    required int minute,
    required String category,
    required String lifeMode,
    String repeatType = 'weekly',
    String priority = 'medium',
    String? notes,
    bool notificationEnabled = true,
    bool alarmEnabled = false,
  }) async {
    final now = DateTime.now();
    final data = {
      'title': title.trim(),
      'day': day,
      'hour': hour,
      'minute': minute,
      'category': category,
      'lifeMode': lifeMode,
      'repeatType': repeatType,
      'priority': _normalizeRemPriority(priority),
      'notes': notes?.trim().isEmpty == true ? null : notes?.trim(),
      'notificationEnabled': notificationEnabled ? 1 : 0,
      'alarmEnabled': alarmEnabled ? 1 : 0,
      'isCompleted': 0,
      'completedAt': null,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    };

    final id = await _repo.insert(data);
    final reminder = Reminder.fromJson({...data, 'id': id});
    _reminders.add(reminder);
    _sortReminders();
    notifySafely();

    if (notificationEnabled) {
      try {
        await _notificationService.scheduleWeeklyReminder(reminder);
      } catch (_) {}
    }
  }

  Future<void> editReminder({
    required int id,
    required String title,
    required String day,
    required int hour,
    required int minute,
    required String category,
    required String lifeMode,
    String repeatType = 'weekly',
    String priority = 'medium',
    String? notes,
    bool notificationEnabled = true,
    bool alarmEnabled = false,
  }) async {
    final now = DateTime.now();
    final data = {
      'title': title.trim(),
      'day': day,
      'hour': hour,
      'minute': minute,
      'category': category,
      'lifeMode': lifeMode,
      'repeatType': repeatType,
      'priority': _normalizeRemPriority(priority),
      'notes': notes?.trim().isEmpty == true ? null : notes?.trim(),
      'notificationEnabled': notificationEnabled ? 1 : 0,
      'alarmEnabled': alarmEnabled ? 1 : 0,
      'updatedAt': now.toIso8601String(),
    };

    await _repo.update(id, data);
    await _notificationService.cancel(id);

    final idx = _reminders.indexWhere((r) => r.id == id);
    if (idx == -1) return;

    _reminders[idx] = _reminders[idx].copyWith(
      title: title.trim(),
      day: day,
      hour: hour,
      minute: minute,
      category: category,
      lifeMode: lifeMode,
      repeatType: repeatType,
      priority: _normalizeRemPriority(priority),
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
      notificationEnabled: notificationEnabled,
      alarmEnabled: alarmEnabled,
      updatedAt: now,
    );
    _sortReminders();
    notifySafely();

    if (notificationEnabled) {
      try {
        await _notificationService.scheduleWeeklyReminder(_reminders[idx]);
      } catch (_) {}
    }
  }

  Future<void> deleteReminder(int id) async {
    await _repo.delete(id);
    await _repo.deleteCompletionLogsForReminder(id);
    await _notificationService.cancel(id);
    _reminders.removeWhere((r) => r.id == id);
    _completionLogs = await _repo.getCompletionLogs(days: 30);
    notifySafely();
  }

  Future<void> toggleReminderComplete(int id) async {
    final idx = _reminders.indexWhere((r) => r.id == id);
    if (idx == -1) return;

    final reminder = _reminders[idx];
    final nowCompleted = !reminder.isCompleted;
    final now = DateTime.now();

    final updated = reminder.copyWith(
      isCompleted: nowCompleted,
      completedAt: nowCompleted ? now : null,
      updatedAt: now,
    );

    try {
      await _repo.update(id, {
        'isCompleted': nowCompleted ? 1 : 0,
        'completedAt': nowCompleted ? now.toIso8601String() : null,
        'updatedAt': now.toIso8601String(),
      });

      await _repo.deleteCompletionLogsForReminderOnDate(id, now);
      if (nowCompleted) {
        await _repo.insertCompletionLog({
          'reminderId': id,
          'completedAt': now.toIso8601String(),
          'dayOfWeek': now.weekday,
          'hourOfDay': now.hour,
        });
      }

      _reminders[idx] = updated;
      _completionLogs = await _repo.getCompletionLogs(days: 30);
      notifySafely();
    } catch (e) {
      debugPrint('Could not toggle reminder completion: $e');
      rethrow;
    }
  }

  Future<void> _migrateFromSharedPreferences(SharedPreferences prefs) async {
    final oldRole = prefs.getString('zyvora.role');
    if (oldRole != null && _userController.lifeMode == null) {
      await prefs.setString('zyvora.lifeMode', 'professional');
    }

    final oldSchedules =
        prefs.getString('zyvora.schedules.v2') ?? prefs.getString('schedules');
    if (oldSchedules == null || _reminders.isNotEmpty) return;

    try {
      final decoded = jsonDecode(oldSchedules) as Map<String, dynamic>;
      final now = DateTime.now();
      for (final day in ZyvoraDays.ordered) {
        final rawItems = decoded[day];
        if (rawItems is! List) continue;
        for (final item in rawItems) {
          if (item is! Map) continue;
          final map = Map<String, dynamic>.from(item);
          final parsedTime = TimeUtils.parseStoredTime(map['time'] as String?);
          map['day'] = day;
          map['hour'] = (map['hour'] as num?)?.toInt() ?? parsedTime.hour;
          map['minute'] = (map['minute'] as num?)?.toInt() ?? parsedTime.minute;
          map['lifeMode'] = 'professional';
          map['category'] = map['mode'] ?? map['category'] ?? 'Custom';
          map['repeatType'] = map['repeatType'] ?? 'weekly';
          map['priority'] = map['priority'] ?? 'medium';
          map['createdAt'] ??= now.toIso8601String();
          map['updatedAt'] ??= now.toIso8601String();
          map['notificationEnabled'] =
              (map['notificationEnabled'] == true ||
                      map['notificationEnabled'] == 1)
                  ? 1
                  : 0;
          map['alarmEnabled'] =
              (map['alarmEnabled'] == true || map['alarmEnabled'] == 1) ? 1 : 0;
          map['isCompleted'] =
              (map['isCompleted'] == true || map['isCompleted'] == 1) ? 1 : 0;
          map.remove('id');
          map.remove('mode');
          map.remove('time');
          final id = await _repo.insert(map);
          _reminders.add(Reminder.fromJson({...map, 'id': id}));
        }
      }
      _sortReminders();
      await prefs.remove('zyvora.schedules.v2');
      await prefs.remove('schedules');
    } catch (_) {}
  }

  Future<void> _resetStaleCompletions() async {
    final now = DateTime.now();
    final today = todayName;
    for (var i = 0; i < _reminders.length; i++) {
      final reminder = _reminders[i];
      if (!reminder.isCompleted) continue;

      final completedAt = reminder.completedAt;
      final isFresh =
          completedAt != null &&
          reminder.day == today &&
          _dateKey(completedAt) == _dateKey(now);
      if (isFresh) continue;

      _reminders[i] = reminder.copyWith(
        isCompleted: false,
        completedAt: null,
        updatedAt: now,
      );
      await _repo.update(reminder.id, {
        'isCompleted': 0,
        'completedAt': null,
        'updatedAt': now.toIso8601String(),
      });
    }
  }

  void _sortReminders() {
    _reminders.sort((a, b) {
      final dayCompare = ZyvoraDays.ordered
          .indexOf(a.day)
          .compareTo(ZyvoraDays.ordered.indexOf(b.day));
      if (dayCompare != 0) return dayCompare;
      return a.minutesFromMidnight.compareTo(b.minutesFromMidnight);
    });
  }

  String _dateKey(DateTime value) => value.toIso8601String().substring(0, 10);

  void _handleUserChange() {
    notifySafely();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifySafely();
  }

  @override
  void dispose() {
    _userController.removeListener(_handleUserChange);
    super.dispose();
  }
}

String _normalizeRemPriority(String raw) {
  final v = raw.toLowerCase().trim();
  if (v == 'low' || v == 'high' || v == 'medium') return v;
  return 'medium';
}
