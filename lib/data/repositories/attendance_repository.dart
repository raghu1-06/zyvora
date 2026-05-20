import '../services/database_service.dart';

class AttendanceRepository {
  final DatabaseService _db;

  AttendanceRepository({required DatabaseService db}) : _db = db;

  Future<List<Map<String, dynamic>>> getSubjects() => _db.getSubjects();

  Future<int> insertSubject(Map<String, dynamic> data) =>
      _db.insertSubject(data);

  Future<int> deleteSubject(String name) => _db.deleteSubject(name);

  Future<List<Map<String, dynamic>>> getAllAttendance() =>
      _db.getAllAttendance();

  Future<List<Map<String, dynamic>>> getAttendanceForSubject(String subject) =>
      _db.getAttendanceForSubject(subject);

  Future<int> insertAttendance(Map<String, dynamic> data) =>
      _db.insertAttendance(data);

  Future<int> deleteAttendance(int id) => _db.deleteAttendance(id);

  Future<int> deleteAttendanceForSubjectDate(String subject, DateTime date) =>
      _db.deleteAttendanceForSubjectDate(subject, date);
}
