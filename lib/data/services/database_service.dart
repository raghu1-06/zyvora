import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static const _dbName = 'zyvora.db';
  static const _dbVersion = 3;

  static const _webRemindersKey = 'zyvora.web.reminders';
  static const _webAttendanceKey = 'zyvora.web.attendance';
  static const _webSubjectsKey = 'zyvora.web.subjects';
  static const _webCompletionLogsKey = 'zyvora.web.completionLogs';

  Database? _database;

  Future<Database> get database async {
    if (kIsWeb) {
      debugPrint('SQLite not available on web, using fallback storage');
      throw UnsupportedError('SQLite storage is not available on web.');
    }
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        day TEXT NOT NULL,
        hour INTEGER NOT NULL,
        minute INTEGER NOT NULL,
        category TEXT NOT NULL DEFAULT 'Custom',
        lifeMode TEXT NOT NULL DEFAULT 'professional',
        repeatType TEXT NOT NULL DEFAULT 'weekly',
        notificationEnabled INTEGER NOT NULL DEFAULT 1,
        alarmEnabled INTEGER NOT NULL DEFAULT 0,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        completedAt TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        priority TEXT NOT NULL DEFAULT 'medium',
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject TEXT NOT NULL,
        date TEXT NOT NULL,
        isPresent INTEGER NOT NULL DEFAULT 1,
        status TEXT NOT NULL DEFAULT 'present',
        extraClasses INTEGER NOT NULL DEFAULT 0,
        extraAttended INTEGER NOT NULL DEFAULT 0,
        note TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE completion_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reminderId INTEGER NOT NULL,
        completedAt TEXT NOT NULL,
        dayOfWeek INTEGER NOT NULL,
        hourOfDay INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE subjects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        requiredPercentage REAL NOT NULL DEFAULT 75.0,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('CREATE INDEX idx_reminders_day ON reminders(day)');
    await db.execute(
      'CREATE INDEX idx_reminders_lifeMode ON reminders(lifeMode)',
    );
    await db.execute(
      'CREATE INDEX idx_attendance_subject ON attendance(subject)',
    );
    await db.execute(
      'CREATE INDEX idx_attendance_subject_date ON attendance(subject, date)',
    );
    await db.execute(
      'CREATE INDEX idx_completion_logs_reminderId ON completion_logs(reminderId)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE reminders ADD COLUMN priority TEXT NOT NULL DEFAULT 'medium'",
      );
      await db.execute('ALTER TABLE reminders ADD COLUMN notes TEXT');
    }
    if (oldVersion < 3) {
      await _addColumnIfMissing(
        db,
        table: 'attendance',
        column: 'status',
        definition: "TEXT NOT NULL DEFAULT 'present'",
      );
      await _addColumnIfMissing(
        db,
        table: 'attendance',
        column: 'extraClasses',
        definition: 'INTEGER NOT NULL DEFAULT 0',
      );
      await _addColumnIfMissing(
        db,
        table: 'attendance',
        column: 'extraAttended',
        definition: 'INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        "UPDATE attendance SET status = CASE WHEN isPresent = 1 THEN 'present' ELSE 'absent' END",
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_attendance_subject_date ON attendance(subject, date)',
      );
    }
  }

  Future<void> _addColumnIfMissing(
    Database db, {
    required String table,
    required String column,
    required String definition,
  }) async {
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    final exists = columns.any((row) => row['name'] == column);
    if (!exists) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $definition');
    }
  }

  Future<int> insertReminder(Map<String, dynamic> data) async {
    if (kIsWeb) return _insertWebRow(_webRemindersKey, data);
    final db = await database;
    return db.insert('reminders', data);
  }

  Future<int> updateReminder(int id, Map<String, dynamic> data) async {
    if (kIsWeb) return _updateWebRow(_webRemindersKey, id, data);
    final db = await database;
    return db.update('reminders', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteReminder(int id) async {
    if (kIsWeb) {
      return _deleteWebRows(_webRemindersKey, (row) => row['id'] == id);
    }
    final db = await database;
    return db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getReminders({
    String? lifeMode,
    String? day,
  }) async {
    if (kIsWeb) {
      final rows = await _readWebRows(_webRemindersKey);
      final filtered = rows.where((row) {
        final lifeModeMatches = lifeMode == null || row['lifeMode'] == lifeMode;
        final dayMatches = day == null || row['day'] == day;
        return lifeModeMatches && dayMatches;
      }).toList();
      _sortReminderRows(filtered);
      return filtered;
    }

    final db = await database;
    final where = <String>[];
    final args = <dynamic>[];

    if (lifeMode != null) {
      where.add('lifeMode = ?');
      args.add(lifeMode);
    }
    if (day != null) {
      where.add('day = ?');
      args.add(day);
    }

    return db.query(
      'reminders',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'hour ASC, minute ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllReminders() async {
    if (kIsWeb) {
      final rows = await _readWebRows(_webRemindersKey);
      _sortReminderRows(rows);
      return rows;
    }

    final db = await database;
    return db.query('reminders', orderBy: 'hour ASC, minute ASC');
  }

  Future<int> insertAttendance(Map<String, dynamic> data) async {
    if (kIsWeb) return _insertWebRow(_webAttendanceKey, data);
    final db = await database;
    return db.insert('attendance', data);
  }

  Future<int> deleteAttendance(int id) async {
    if (kIsWeb) {
      return _deleteWebRows(_webAttendanceKey, (row) => row['id'] == id);
    }
    final db = await database;
    return db.delete('attendance', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAttendanceForSubjectDate(
    String subject,
    DateTime date,
  ) async {
    final datePrefix = date.toIso8601String().substring(0, 10);
    if (kIsWeb) {
      return _deleteWebRows(_webAttendanceKey, (row) {
        return row['subject'] == subject &&
            (row['date'] as String? ?? '').startsWith(datePrefix);
      });
    }

    final db = await database;
    return db.delete(
      'attendance',
      where: 'subject = ? AND date LIKE ?',
      whereArgs: [subject, '$datePrefix%'],
    );
  }

  Future<List<Map<String, dynamic>>> getAttendanceForSubject(
    String subject,
  ) async {
    if (kIsWeb) {
      final rows = await _readWebRows(_webAttendanceKey);
      final filtered = rows.where((row) => row['subject'] == subject).toList();
      _sortDateRowsDescending(filtered);
      return filtered;
    }

    final db = await database;
    return db.query(
      'attendance',
      where: 'subject = ?',
      whereArgs: [subject],
      orderBy: 'date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllAttendance() async {
    if (kIsWeb) {
      final rows = await _readWebRows(_webAttendanceKey);
      _sortDateRowsDescending(rows);
      return rows;
    }

    final db = await database;
    return db.query('attendance', orderBy: 'date DESC');
  }

  Future<int> insertSubject(Map<String, dynamic> data) async {
    if (kIsWeb) {
      final rows = await _readWebRows(_webSubjectsKey);
      final name = data['name'] as String? ?? '';
      final exists = rows.any(
        (row) =>
            (row['name'] as String? ?? '').toLowerCase() == name.toLowerCase(),
      );
      if (exists) return 0;
      return _insertWebRow(_webSubjectsKey, data);
    }

    final db = await database;
    return db.insert(
      'subjects',
      data,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<int> deleteSubject(String name) async {
    if (kIsWeb) {
      await _deleteWebRows(_webAttendanceKey, (row) => row['subject'] == name);
      return _deleteWebRows(_webSubjectsKey, (row) => row['name'] == name);
    }

    final db = await database;
    await db.delete('attendance', where: 'subject = ?', whereArgs: [name]);
    return db.delete('subjects', where: 'name = ?', whereArgs: [name]);
  }

  Future<List<Map<String, dynamic>>> getSubjects() async {
    if (kIsWeb) {
      final rows = await _readWebRows(_webSubjectsKey);
      rows.sort(
        (a, b) =>
            (a['name'] as String? ?? '').compareTo(b['name'] as String? ?? ''),
      );
      return rows;
    }

    final db = await database;
    return db.query('subjects', orderBy: 'name ASC');
  }

  Future<int> insertCompletionLog(Map<String, dynamic> data) async {
    if (kIsWeb) return _insertWebRow(_webCompletionLogsKey, data);
    final db = await database;
    return db.insert('completion_logs', data);
  }

  Future<int> deleteCompletionLogsForReminder(int reminderId) async {
    if (kIsWeb) {
      return _deleteWebRows(
        _webCompletionLogsKey,
        (row) => row['reminderId'] == reminderId,
      );
    }

    final db = await database;
    return db.delete(
      'completion_logs',
      where: 'reminderId = ?',
      whereArgs: [reminderId],
    );
  }

  Future<int> deleteCompletionLogsForReminderOnDate(
    int reminderId,
    DateTime date,
  ) async {
    final datePrefix = date.toIso8601String().substring(0, 10);
    if (kIsWeb) {
      return _deleteWebRows(_webCompletionLogsKey, (row) {
        return row['reminderId'] == reminderId &&
            (row['completedAt'] as String? ?? '').startsWith(datePrefix);
      });
    }

    final db = await database;
    return db.delete(
      'completion_logs',
      where: 'reminderId = ? AND completedAt LIKE ?',
      whereArgs: [reminderId, '$datePrefix%'],
    );
  }

  Future<List<Map<String, dynamic>>> getCompletionLogs({int? days}) async {
    if (kIsWeb) {
      final rows = await _readWebRows(_webCompletionLogsKey);
      final filtered = days == null
          ? rows
          : rows.where((row) {
              final since = DateTime.now()
                  .subtract(Duration(days: days))
                  .toIso8601String();
              final completedAt = row['completedAt'] as String? ?? '';
              return completedAt.compareTo(since) >= 0;
            }).toList();
      _sortCompletedRowsDescending(filtered);
      return filtered;
    }

    final db = await database;
    if (days != null) {
      final since = DateTime.now()
          .subtract(Duration(days: days))
          .toIso8601String();
      return db.query(
        'completion_logs',
        where: 'completedAt >= ?',
        whereArgs: [since],
        orderBy: 'completedAt DESC',
      );
    }
    return db.query('completion_logs', orderBy: 'completedAt DESC');
  }

  Future<List<Map<String, dynamic>>> getCompletionsByHour() async {
    if (kIsWeb) {
      final rows = await _readWebRows(_webCompletionLogsKey);
      final counts = <int, int>{};
      for (final row in rows) {
        final hour = (row['hourOfDay'] as num?)?.toInt() ?? 0;
        counts[hour] = (counts[hour] ?? 0) + 1;
      }
      final grouped = counts.entries
          .map((entry) => {'hourOfDay': entry.key, 'count': entry.value})
          .toList();
      grouped.sort(
        (a, b) => (a['hourOfDay'] as int).compareTo(b['hourOfDay'] as int),
      );
      return grouped;
    }

    final db = await database;
    return db.rawQuery(
      'SELECT hourOfDay, COUNT(*) as count FROM completion_logs GROUP BY hourOfDay ORDER BY hourOfDay',
    );
  }

  Future<List<Map<String, dynamic>>> getCompletionsByDayOfWeek() async {
    if (kIsWeb) {
      final rows = await _readWebRows(_webCompletionLogsKey);
      final counts = <int, int>{};
      for (final row in rows) {
        final day = (row['dayOfWeek'] as num?)?.toInt() ?? 1;
        counts[day] = (counts[day] ?? 0) + 1;
      }
      final grouped = counts.entries
          .map((entry) => {'dayOfWeek': entry.key, 'count': entry.value})
          .toList();
      grouped.sort(
        (a, b) => (a['dayOfWeek'] as int).compareTo(b['dayOfWeek'] as int),
      );
      return grouped;
    }

    final db = await database;
    return db.rawQuery(
      'SELECT dayOfWeek, COUNT(*) as count FROM completion_logs GROUP BY dayOfWeek ORDER BY dayOfWeek',
    );
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  Future<int> _insertWebRow(String key, Map<String, dynamic> data) async {
    final rows = await _readWebRows(key);
    final row = Map<String, dynamic>.from(data);
    row['id'] = (row['id'] as num?)?.toInt() ?? await _nextWebId(key, rows);
    rows.add(row);
    await _writeWebRows(key, rows);
    return row['id'] as int;
  }

  Future<int> _updateWebRow(
    String key,
    int id,
    Map<String, dynamic> data,
  ) async {
    final rows = await _readWebRows(key);
    final index = rows.indexWhere((row) => row['id'] == id);
    if (index == -1) return 0;
    rows[index] = {...rows[index], ...data, 'id': id};
    await _writeWebRows(key, rows);
    return 1;
  }

  Future<int> _deleteWebRows(
    String key,
    bool Function(Map<String, dynamic> row) test,
  ) async {
    final rows = await _readWebRows(key);
    final before = rows.length;
    rows.removeWhere(test);
    await _writeWebRows(key, rows);
    return before - rows.length;
  }

  Future<int> _nextWebId(String key, List<Map<String, dynamic>> rows) async {
    final prefs = await SharedPreferences.getInstance();
    final sequenceKey = '$key.nextId';
    final stored = prefs.getInt(sequenceKey) ?? 0;
    final maxExisting = rows.fold<int>(0, (max, row) {
      final id = (row['id'] as num?)?.toInt() ?? 0;
      return id > max ? id : max;
    });
    final next = (stored > maxExisting ? stored : maxExisting) + 1;
    await prefs.setInt(sequenceKey, next);
    return next;
  }

  Future<List<Map<String, dynamic>>> _readWebRows(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeWebRows(
    String key,
    List<Map<String, dynamic>> rows,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(rows));
  }

  void _sortReminderRows(List<Map<String, dynamic>> rows) {
    rows.sort((a, b) {
      final aHour = (a['hour'] as num?)?.toInt() ?? 0;
      final bHour = (b['hour'] as num?)?.toInt() ?? 0;
      if (aHour != bHour) return aHour.compareTo(bHour);
      final aMinute = (a['minute'] as num?)?.toInt() ?? 0;
      final bMinute = (b['minute'] as num?)?.toInt() ?? 0;
      return aMinute.compareTo(bMinute);
    });
  }

  void _sortDateRowsDescending(List<Map<String, dynamic>> rows) {
    rows.sort(
      (a, b) =>
          (b['date'] as String? ?? '').compareTo(a['date'] as String? ?? ''),
    );
  }

  void _sortCompletedRowsDescending(List<Map<String, dynamic>> rows) {
    rows.sort(
      (a, b) => (b['completedAt'] as String? ?? '').compareTo(
        a['completedAt'] as String? ?? '',
      ),
    );
  }
}
