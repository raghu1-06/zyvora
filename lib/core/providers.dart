import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/alarm_repository.dart';
import '../data/repositories/analytics_repository.dart';
import '../data/repositories/attendance_repository.dart';
import '../data/repositories/reminder_repository.dart';
import '../data/services/alarm_service.dart';
import '../data/services/database_service.dart';
import '../data/services/notification_service.dart';
import '../features/alarms/controllers/alarm_controller.dart';
import '../features/analytics/controllers/analytics_controller.dart';
import '../features/attendance/controllers/attendance_controller.dart';
import '../features/profile/controllers/user_controller.dart';
import '../features/tasks/controllers/reminder_controller.dart';

final databaseProvider = Provider<DatabaseService>((ref) {
  final db = DatabaseService();
  ref.onDispose(() => db.close());
  return db;
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final alarmServiceProvider = Provider<AlarmService>((ref) {
  final service = AlarmService();
  final notifications = ref.watch(notificationServiceProvider);
  service.attachPlugin(notifications.notificationsPlugin);
  return service;
});

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return ReminderRepository(db: ref.watch(databaseProvider));
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(db: ref.watch(databaseProvider));
});

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(db: ref.watch(databaseProvider));
});

final alarmRepositoryProvider = Provider<AlarmRepository>((ref) {
  return AlarmRepository(service: ref.watch(alarmServiceProvider));
});

final userControllerProvider = ChangeNotifierProvider<UserController>((ref) {
  return UserController();
});

final reminderControllerProvider = ChangeNotifierProvider<ReminderController>((ref) {
  return ReminderController(
    repo: ref.watch(reminderRepositoryProvider),
    notificationService: ref.watch(notificationServiceProvider),
    userController: ref.watch(userControllerProvider),
  );
});

final attendanceControllerProvider = ChangeNotifierProvider<AttendanceController>((ref) {
  return AttendanceController(repo: ref.watch(attendanceRepositoryProvider));
});

final analyticsControllerProvider = ChangeNotifierProvider<AnalyticsController>((ref) {
  return AnalyticsController(repo: ref.watch(analyticsRepositoryProvider));
});

final alarmControllerProvider = ChangeNotifierProvider<AlarmController>((ref) {
  return AlarmController(repo: ref.watch(alarmRepositoryProvider));
});

final navTabProviderIndex = StateProvider<int>((ref) => 0);
