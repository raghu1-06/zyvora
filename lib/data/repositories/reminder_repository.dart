import '../services/database_service.dart';

class ReminderRepository {
  final DatabaseService _db;

  ReminderRepository({required DatabaseService db}) : _db = db;

  Future<List<Map<String, dynamic>>> fetchAll() => _db.getAllReminders();

  Future<int> insert(Map<String, dynamic> data) => _db.insertReminder(data);

  Future<int> update(int id, Map<String, dynamic> data) =>
      _db.updateReminder(id, data);

  Future<int> delete(int id) => _db.deleteReminder(id);

  Future<int> deleteCompletionLogsForReminder(int id) =>
      _db.deleteCompletionLogsForReminder(id);

  Future<int> deleteCompletionLogsForReminderOnDate(int id, DateTime date) =>
      _db.deleteCompletionLogsForReminderOnDate(id, date);

  Future<int> insertCompletionLog(Map<String, dynamic> data) =>
      _db.insertCompletionLog(data);

  Future<List<Map<String, dynamic>>> getCompletionLogs({int? days}) =>
      _db.getCompletionLogs(days: days);

  Future<List<Map<String, dynamic>>> getCompletionsByHour() =>
      _db.getCompletionsByHour();

  Future<List<Map<String, dynamic>>> getCompletionsByDayOfWeek() =>
      _db.getCompletionsByDayOfWeek();
}
