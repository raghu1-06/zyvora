import 'dart:math' as math;

enum AttendanceStatus {
  present('present'),
  absent('absent');

  const AttendanceStatus(this.storageValue);

  final String storageValue;

  static AttendanceStatus fromStorage(Object? value, {bool? legacyPresent}) {
    final raw = value?.toString().toLowerCase().trim();
    if (raw == AttendanceStatus.absent.storageValue) {
      return AttendanceStatus.absent;
    }
    if (raw == AttendanceStatus.present.storageValue) {
      return AttendanceStatus.present;
    }
    if (legacyPresent != null) {
      return legacyPresent ? AttendanceStatus.present : AttendanceStatus.absent;
    }
    return AttendanceStatus.present;
  }
}

/// A date-wise attendance entry for one subject.
///
/// One entry represents the regular class for the selected date, plus up to
/// eight extra classes that happened on the same date.
class AttendanceRecord {
  static const int maxExtraClasses = 8;

  final int id;
  final String subject;
  final DateTime date;
  final AttendanceStatus status;
  final int extraClasses;
  final int extraAttended;
  final String? note;

  const AttendanceRecord({
    required this.id,
    required this.subject,
    required this.date,
    required this.status,
    this.extraClasses = 0,
    this.extraAttended = 0,
    this.note,
  });

  bool get isPresent => status == AttendanceStatus.present;
  int get regularHeldClasses => 1;
  int get regularAttendedClasses => isPresent ? 1 : 0;
  int get heldClasses => regularHeldClasses + _clampExtra(extraClasses);
  int get attendedClasses {
    return regularAttendedClasses +
        _clampExtra(extraAttended).clamp(0, _clampExtra(extraClasses)).toInt();
  }

  int get missedClasses => math.max(0, heldClasses - attendedClasses);
  bool get hasExtraClasses => extraClasses > 0;
  String get dateKey => AttendanceRecord.dateKeyFor(date);

  AttendanceRecord copyWith({
    int? id,
    String? subject,
    DateTime? date,
    AttendanceStatus? status,
    int? extraClasses,
    int? extraAttended,
    String? note,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      date: date ?? this.date,
      status: status ?? this.status,
      extraClasses: extraClasses ?? this.extraClasses,
      extraAttended: extraAttended ?? this.extraAttended,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'date': normalizeDate(date).toIso8601String(),
      'status': status.storageValue,
      'isPresent': isPresent ? 1 : 0,
      'extraClasses': _clampExtra(extraClasses),
      'extraAttended': extraAttended
          .clamp(0, _clampExtra(extraClasses))
          .toInt(),
      'note': note,
    };
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    final legacyRaw = json['isPresent'];
    final legacyPresent = legacyRaw is num ? legacyRaw.toInt() == 1 : null;
    final status = AttendanceStatus.fromStorage(
      json['status'],
      legacyPresent: legacyPresent,
    );
    final extras = _readInt(
      json['extraClasses'],
    ).clamp(0, maxExtraClasses).toInt();
    final extraAttended = _readInt(
      json['extraAttended'],
    ).clamp(0, extras).toInt();

    return AttendanceRecord(
      id: _readInt(json['id']),
      subject: json['subject'] as String? ?? '',
      date: normalizeDate(
        DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      ),
      status: status,
      extraClasses: extras,
      extraAttended: extraAttended,
      note: json['note'] as String?,
    );
  }

  static DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static String dateKeyFor(DateTime date) {
    return normalizeDate(date).toIso8601String().substring(0, 10);
  }

  static int _readInt(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _clampExtra(int value) => value.clamp(0, maxExtraClasses).toInt();
}

/// Summary stats and predictions for a single subject.
class SubjectAttendance {
  final String subject;
  final int total;
  final int present;
  final int regularClasses;
  final int extraClasses;
  final double targetPercentage;
  final List<AttendanceRecord> records;

  const SubjectAttendance({
    required this.subject,
    required this.total,
    required this.present,
    this.regularClasses = 0,
    this.extraClasses = 0,
    this.targetPercentage = 75,
    this.records = const [],
  });

  int get absent => math.max(0, total - present);
  int get totalBunks => absent;
  double get percentage => total == 0 ? 0 : (present / total) * 100;
  bool get isAtRisk => total > 0 && percentage < targetPercentage;
  bool get isEmpty => total == 0;

  int bunkableClasses({double? target}) {
    final threshold = target ?? targetPercentage;
    if (total == 0 || percentage <= threshold) return 0;

    var safe = 0;
    var projectedTotal = total;
    while (true) {
      projectedTotal++;
      final projectedPercentage = (present / projectedTotal) * 100;
      if (projectedPercentage < threshold) break;
      safe++;
    }
    return safe;
  }

  int classesNeededForTarget({double? target}) {
    final threshold = target ?? targetPercentage;
    if (total == 0) return 1;
    if (percentage >= threshold) return 0;

    var needed = 0;
    var projectedPresent = present;
    var projectedTotal = total;
    while (needed < 500) {
      needed++;
      projectedPresent++;
      projectedTotal++;
      final projectedPercentage = (projectedPresent / projectedTotal) * 100;
      if (projectedPercentage >= threshold) return needed;
    }
    return needed;
  }

  int attendanceStreakClasses() {
    var streak = 0;
    final sorted = [...records]..sort((a, b) => b.date.compareTo(a.date));

    for (final record in sorted) {
      if (record.attendedClasses == record.heldClasses) {
        streak += record.heldClasses;
        continue;
      }
      if (record.attendedClasses > 0) {
        streak += record.attendedClasses;
      }
      break;
    }
    return streak;
  }

  String safeBunkMessage({double? target}) {
    final safe = bunkableClasses(target: target);
    if (safe == 1) return 'You can miss 1 more class safely.';
    if (safe > 1) return 'You can miss $safe more classes safely.';
    if (total == 0) return 'Start marking classes to unlock safe bunk math.';
    return 'No safe bunks available right now.';
  }

  String recoveryMessage({double? target}) {
    final threshold = target ?? targetPercentage;
    final needed = classesNeededForTarget(target: threshold);
    if (needed == 0) {
      return 'You are above ${threshold.round()}%. Keep the margin protected.';
    }
    if (needed == 1) {
      return 'Attend next 1 class to reach ${threshold.round()}%.';
    }
    return 'Attend next $needed classes to reach ${threshold.round()}%.';
  }

  MonthlyAttendanceStats monthlyStats(DateTime month) {
    final monthRecords = records.where((record) {
      return record.date.year == month.year && record.date.month == month.month;
    }).toList();

    final held = monthRecords.fold<int>(
      0,
      (sum, record) => sum + record.heldClasses,
    );
    final attended = monthRecords.fold<int>(
      0,
      (sum, record) => sum + record.attendedClasses,
    );
    final extras = monthRecords.fold<int>(
      0,
      (sum, record) => sum + record.extraClasses,
    );

    return MonthlyAttendanceStats(
      held: held,
      attended: attended,
      absent: math.max(0, held - attended),
      extraClasses: extras,
      records: monthRecords,
    );
  }
}

class MonthlyAttendanceStats {
  final int held;
  final int attended;
  final int absent;
  final int extraClasses;
  final List<AttendanceRecord> records;

  const MonthlyAttendanceStats({
    required this.held,
    required this.attended,
    required this.absent,
    required this.extraClasses,
    required this.records,
  });

  double get presentPercentage => held == 0 ? 0 : (attended / held) * 100;
  double get absentPercentage => held == 0 ? 0 : (absent / held) * 100;
}
