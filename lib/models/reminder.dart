import '../utils/time_utils.dart';

/// Represents a single reminder in either Personal or Professional mode.
class Reminder {
  final int id;
  final String title;
  final String day;
  final int hour;
  final int minute;
  final String category;
  final String lifeMode; // 'personal' or 'professional'
  final String repeatType; // 'once', 'daily', 'weekly'
  final bool notificationEnabled;
  final bool alarmEnabled;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// low | medium | high
  final String priority;
  final String? notes;

  const Reminder({
    required this.id,
    required this.title,
    required this.day,
    required this.hour,
    required this.minute,
    required this.category,
    required this.lifeMode,
    this.repeatType = 'weekly',
    required this.notificationEnabled,
    this.alarmEnabled = false,
    this.isCompleted = false,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.priority = 'medium',
    this.notes,
  });

  String get time24 =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  int get minutesFromMidnight => hour * 60 + minute;

  bool get isPersonal => lifeMode == 'personal';

  static const _sentinel = Object();

  Reminder copyWith({
    int? id,
    String? title,
    String? day,
    int? hour,
    int? minute,
    String? category,
    String? lifeMode,
    String? repeatType,
    bool? notificationEnabled,
    bool? alarmEnabled,
    bool? isCompleted,
    Object? completedAt = _sentinel,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? priority,
    Object? notes = _sentinel,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      day: day ?? this.day,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      category: category ?? this.category,
      lifeMode: lifeMode ?? this.lifeMode,
      repeatType: repeatType ?? this.repeatType,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      alarmEnabled: alarmEnabled ?? this.alarmEnabled,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: identical(completedAt, _sentinel)
          ? this.completedAt
          : completedAt as DateTime?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      priority: priority ?? this.priority,
      notes: identical(notes, _sentinel) ? this.notes : notes as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'day': day,
      'hour': hour,
      'minute': minute,
      'time': time24,
      'category': category,
      'lifeMode': lifeMode,
      'repeatType': repeatType,
      'notificationEnabled': notificationEnabled ? 1 : 0,
      'alarmEnabled': alarmEnabled ? 1 : 0,
      'isCompleted': isCompleted ? 1 : 0,
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'priority': priority,
      'notes': notes,
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    final parsedTime = TimeUtils.parseStoredTime(json['time'] as String?);
    final now = DateTime.now();

    return Reminder(
      id: (json['id'] as num?)?.toInt() ?? now.microsecondsSinceEpoch,
      title: (json['title'] as String? ?? 'Untitled').trim(),
      day: json['day'] as String? ?? 'Monday',
      hour: (json['hour'] as num?)?.toInt() ?? parsedTime.hour,
      minute: (json['minute'] as num?)?.toInt() ?? parsedTime.minute,
      category:
          (json['category'] as String? ?? json['mode'] as String? ?? 'Custom')
              .trim(),
      lifeMode: (json['lifeMode'] as String? ?? 'professional').trim(),
      repeatType: (json['repeatType'] as String? ?? 'weekly').trim(),
      notificationEnabled: _parseBool(json['notificationEnabled']),
      alarmEnabled: _parseBool(json['alarmEnabled']),
      isCompleted: _parseBool(json['isCompleted']),
      completedAt: DateTime.tryParse(json['completedAt'] as String? ?? ''),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? now,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? now,
      priority: _normalizePriority(json['priority'] as String?),
      notes: (json['notes'] as String?)?.trim().isEmpty == true
          ? null
          : json['notes'] as String?,
    );
  }

  static String _normalizePriority(String? raw) {
    final v = (raw ?? 'medium').toLowerCase().trim();
    if (v == 'low' || v == 'high' || v == 'medium') return v;
    return 'medium';
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    return false;
  }
}
