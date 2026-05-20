import 'package:flutter/foundation.dart';

import '../../../core/utils/error_handler.dart';
import '../../../core/utils/safe_notifier.dart';
import '../../../data/repositories/attendance_repository.dart';
import '../../../models/attendance_record.dart';

/// Manages date-wise attendance tracking for subjects.
class AttendanceController extends ChangeNotifier with SafeNotifier {
  final AttendanceRepository _repo;

  AttendanceController({required AttendanceRepository repo}) : _repo = repo;

  List<String> _subjects = [];
  Map<String, double> _targets = {};
  Map<String, List<AttendanceRecord>> _records = {};
  bool _disposed = false;
  int _subjectsLoadVersion = 0;
  int _recordsLoadVersion = 0;
  bool _isLoading = false;
  String? _errorMessage;

  List<String> get subjects => List.unmodifiable(_subjects);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String _normalizeSubject(String name) => name.trim();

  bool _subjectMatches(String a, String b) {
    return a.trim().toLowerCase() == b.trim().toLowerCase();
  }

  bool _containsSubject(String name) {
    final normalized = _normalizeSubject(name);
    return _subjects.any((subject) => _subjectMatches(subject, normalized));
  }

  String _resolveSubject(String name) {
    final normalized = _normalizeSubject(name);
    for (final subject in _subjects) {
      if (_subjectMatches(subject, normalized)) return subject;
    }
    return normalized;
  }

  double targetForSubject(String subject) {
    final resolved = _resolveSubject(subject);
    return _targets[resolved] ?? 75;
  }

  Future<void> loadSubjects() async {
    final version = ++_subjectsLoadVersion;
    _setLoading(true);
    try {
      final rows = await _repo.getSubjects();
      if (_disposed || version != _subjectsLoadVersion) return;

      final nextSubjects = <String>[];
      final nextTargets = <String, double>{};
      for (final row in rows) {
        final name = (row['name'] as String? ?? '').trim();
        if (name.isEmpty) continue;
        nextSubjects.add(name);
        nextTargets[name] =
            (row['requiredPercentage'] as num?)?.toDouble() ?? 75;
      }

      _subjects = nextSubjects;
      _targets = nextTargets;
      _errorMessage = null;
      _notifySafely();
    } catch (e) {
      debugPrint('Error loading subjects: $e');
      if (_disposed || version != _subjectsLoadVersion) return;
      _subjects = [];
      _targets = {};
      _errorMessage = 'Could not load subjects.';
      _notifySafely();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadRecords() async {
    final version = ++_recordsLoadVersion;
    _setLoading(true);
    try {
      final rows = await _repo.getAllAttendance();
      if (_disposed || version != _recordsLoadVersion) return;

      final nextRecords = <String, List<AttendanceRecord>>{};
      for (final row in rows) {
        final record = AttendanceRecord.fromJson(row);
        if (record.subject.trim().isEmpty) continue;
        final subject = _resolveSubject(record.subject);
        nextRecords
            .putIfAbsent(subject, () => [])
            .add(record.copyWith(subject: subject));
      }

      for (final records in nextRecords.values) {
        records.sort((a, b) => b.date.compareTo(a.date));
      }

      _records = nextRecords;
      _errorMessage = null;
      _notifySafely();
    } catch (e) {
      debugPrint('Error loading attendance records: $e');
      if (_disposed || version != _recordsLoadVersion) return;
      _records = {};
      _errorMessage = 'Could not load attendance records.';
      _notifySafely();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAll() async {
    await loadSubjects();
    await loadRecords();
  }

  Future<void> addSubject(String name) async {
    final trimmed = InputValidator.trimAndValidate(
      name,
      fieldName: 'Subject name',
    );

    if (_containsSubject(trimmed)) {
      throw Exception('Subject "$trimmed" already exists');
    }

    try {
      final id = await _repo.insertSubject({
        'name': trimmed,
        'requiredPercentage': 75.0,
        'createdAt': DateTime.now().toIso8601String(),
      });

      if (id == 0) {
        throw Exception('Failed to create subject (database error)');
      }

      _subjects.add(trimmed);
      _targets[trimmed] = 75;
      _records[trimmed] = [];
      _notifySafely();
    } catch (e) {
      debugPrint('Error adding subject: $e');
      rethrow;
    }
  }

  Future<void> removeSubject(String name) async {
    final trimmed = _normalizeSubject(name);
    final resolved = _resolveSubject(trimmed);
    try {
      await _repo.deleteSubject(resolved);
      _subjects.removeWhere((subject) => _subjectMatches(subject, resolved));
      _targets.removeWhere((subject, _) => _subjectMatches(subject, resolved));
      _records.removeWhere((subject, _) => _subjectMatches(subject, resolved));
      _notifySafely();
    } catch (e) {
      debugPrint('Error removing subject: $e');
      rethrow;
    }
  }

  Future<void> markAttendance({
    required String subject,
    required DateTime date,
    required bool isPresent,
    String? note,
    int extraClasses = 0,
    int? extraAttended,
  }) {
    return saveAttendanceEntry(
      subject: subject,
      date: date,
      status: isPresent ? AttendanceStatus.present : AttendanceStatus.absent,
      extraClasses: extraClasses,
      extraAttended: extraAttended ?? (isPresent ? extraClasses : 0),
      note: note,
    );
  }

  Future<void> saveAttendanceEntry({
    required String subject,
    required DateTime date,
    required AttendanceStatus status,
    int extraClasses = 0,
    int? extraAttended,
    String? note,
  }) async {
    final normalizedSubject = _resolveSubject(subject);
    if (normalizedSubject.isEmpty) {
      throw Exception('Subject name cannot be empty');
    }
    if (extraClasses < 0 || extraClasses > AttendanceRecord.maxExtraClasses) {
      throw Exception(
        'Extra classes must be between 0 and ${AttendanceRecord.maxExtraClasses}',
      );
    }

    final attendedExtras =
        extraAttended ??
        (status == AttendanceStatus.present ? extraClasses : 0);
    if (attendedExtras < 0 || attendedExtras > extraClasses) {
      throw Exception('Extra attended classes cannot exceed extra classes');
    }

    final normalizedDate = AttendanceRecord.normalizeDate(date);
    final trimmedNote = note?.trim();
    final data = {
      'subject': normalizedSubject,
      'date': normalizedDate.toIso8601String(),
      'status': status.storageValue,
      'isPresent': status == AttendanceStatus.present ? 1 : 0,
      'extraClasses': extraClasses,
      'extraAttended': attendedExtras,
      'note': trimmedNote == null || trimmedNote.isEmpty ? null : trimmedNote,
    };

    try {
      await _repo.deleteAttendanceForSubjectDate(
        normalizedSubject,
        normalizedDate,
      );
      final id = await _repo.insertAttendance(data);

      if (id == 0) {
        throw Exception('Failed to save attendance record');
      }

      final record = AttendanceRecord(
        id: id,
        subject: normalizedSubject,
        date: normalizedDate,
        status: status,
        extraClasses: extraClasses,
        extraAttended: attendedExtras,
        note: data['note'] as String?,
      );

      final records = _records.putIfAbsent(normalizedSubject, () => []);
      final dateKey = record.dateKey;
      records.removeWhere((r) => r.dateKey == dateKey);
      records.insert(0, record);
      records.sort((a, b) => b.date.compareTo(a.date));
      _notifySafely();
    } catch (e) {
      debugPrint('Error saving attendance: $e');
      try {
        await loadRecords();
      } catch (reloadError) {
        debugPrint('Error reloading attendance records: $reloadError');
      }
      rethrow;
    }
  }

  Future<void> deleteRecord(int id, String subject) async {
    final resolved = _resolveSubject(subject);
    final records = _records[resolved];
    if (records == null) return;

    final index = records.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final originalRecord = records[index];

    // Optimistic update
    records.removeAt(index);
    _notifySafely();

    try {
      await _repo.deleteAttendance(id);
    } catch (e) {
      debugPrint('Error deleting attendance record, rolling back: $e');
      records.insert(index, originalRecord);
      records.sort((a, b) => b.date.compareTo(a.date));
      _notifySafely();
      rethrow;
    }
  }

  Future<void> deleteAttendanceForDate({
    required String subject,
    required DateTime date,
  }) async {
    final resolved = _resolveSubject(subject);
    final records = _records[resolved];
    if (records == null) return;

    final normalizedDate = AttendanceRecord.normalizeDate(date);
    final dateKey = AttendanceRecord.dateKeyFor(normalizedDate);

    final index = records.indexWhere((r) => r.dateKey == dateKey);
    if (index == -1) return;

    final originalRecord = records[index];

    // Optimistic update
    records.removeAt(index);
    _notifySafely();

    try {
      await _repo.deleteAttendanceForSubjectDate(resolved, normalizedDate);
    } catch (e) {
      debugPrint('Error deleting attendance date entry, rolling back: $e');
      records.insert(index, originalRecord);
      records.sort((a, b) => b.date.compareTo(a.date));
      _notifySafely();
      rethrow;
    }
  }

  List<AttendanceRecord> recordsForSubject(String subject) {
    final resolved = _resolveSubject(subject);
    final records =
        _records[resolved] ??
        _records.entries
            .firstWhere(
              (entry) => _subjectMatches(entry.key, resolved),
              orElse: () => const MapEntry('', <AttendanceRecord>[]),
            )
            .value;
    final sorted = [...records]..sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(sorted);
  }

  AttendanceRecord? recordForDate(String subject, DateTime date) {
    final key = AttendanceRecord.dateKeyFor(date);
    for (final record in recordsForSubject(subject)) {
      if (record.dateKey == key) return record;
    }
    return null;
  }

  SubjectAttendance getSubjectStats(String subject) {
    final resolved = _resolveSubject(subject);
    final records = recordsForSubject(resolved);
    final total = records.fold<int>(
      0,
      (sum, record) => sum + record.heldClasses,
    );
    final present = records.fold<int>(
      0,
      (sum, record) => sum + record.attendedClasses,
    );
    final extraClasses = records.fold<int>(
      0,
      (sum, record) => sum + record.extraClasses,
    );

    return SubjectAttendance(
      subject: resolved,
      total: total,
      present: present,
      regularClasses: records.length,
      extraClasses: extraClasses,
      targetPercentage: targetForSubject(resolved),
      records: records,
    );
  }

  List<SubjectAttendance> get stats {
    return subjects.map(getSubjectStats).toList()
      ..sort((a, b) => b.percentage.compareTo(a.percentage));
  }

  List<SubjectAttendance> getAllStats() => stats;

  double get overallPercentage {
    final stats = this.stats;
    if (stats.isEmpty) return 0;
    final sum = stats.fold<double>(0, (acc, s) => acc + s.percentage);
    return sum / stats.length;
  }

  int get totalHeld {
    return stats.fold<int>(0, (acc, s) => acc + s.total);
  }

  int get totalAttended {
    return stats.fold<int>(0, (acc, s) => acc + s.present);
  }

  int get totalMissed => totalHeld - totalAttended;

  int get totalBunkable {
    return stats.fold<int>(0, (acc, s) => acc + s.bunkableClasses());
  }

  void _notifySafely() {
    if (_disposed || !hasListeners) return;
    notifySafely();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _notifySafely();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
