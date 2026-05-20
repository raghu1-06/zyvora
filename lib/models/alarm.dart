import 'dart:convert';

/// A simple, reliable alarm. Repeats are encoded as weekday flags
/// (1 = Mon ... 7 = Sun, matching DateTime.weekday).
class Alarm {
  final int id;
  final String label;
  final int hour;
  final int minute;
  final Set<int> repeatDays; // empty = one-shot
  final bool enabled;
  final String sound; // 'default' | 'gentle' | 'chime'
  final bool vibrate;
  final DateTime createdAt;

  const Alarm({
    required this.id,
    required this.label,
    required this.hour,
    required this.minute,
    this.repeatDays = const {},
    this.enabled = true,
    this.sound = 'default',
    this.vibrate = true,
    required this.createdAt,
  });

  bool get isOneShot => repeatDays.isEmpty;
  bool get isDaily => repeatDays.length == 7;

  String repeatLabel() {
    if (isOneShot) return 'Once';
    if (isDaily) return 'Every day';
    if (repeatDays.length == 5 && repeatDays.containsAll({1, 2, 3, 4, 5})) {
      return 'Weekdays';
    }
    if (repeatDays.length == 2 && repeatDays.containsAll({6, 7})) {
      return 'Weekends';
    }
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sorted = repeatDays.toList()..sort();
    return sorted.map((d) => names[d - 1]).join(' · ');
  }

  Alarm copyWith({
    String? label,
    int? hour,
    int? minute,
    Set<int>? repeatDays,
    bool? enabled,
    String? sound,
    bool? vibrate,
  }) {
    return Alarm(
      id: id,
      label: label ?? this.label,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      repeatDays: repeatDays ?? this.repeatDays,
      enabled: enabled ?? this.enabled,
      sound: sound ?? this.sound,
      vibrate: vibrate ?? this.vibrate,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'label': label,
    'hour': hour,
    'minute': minute,
    'repeatDays': repeatDays.toList(),
    'enabled': enabled,
    'sound': sound,
    'vibrate': vibrate,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Alarm.fromMap(Map<String, dynamic> m) {
    int asInt(dynamic v, [int fallback = 0]) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return fallback;
    }

    bool asBool(dynamic v, bool fallback) {
      if (v is bool) return v;
      if (v is int) return v != 0;
      return fallback;
    }

    final rawDays = m['repeatDays'];
    final days = rawDays is List
        ? rawDays.map((e) => (e as num).toInt()).toSet()
        : <int>{};

    return Alarm(
      id: asInt(m['id']),
      label: (m['label'] as String?)?.trim().isNotEmpty == true
          ? (m['label'] as String).trim()
          : 'Alarm',
      hour: asInt(m['hour'], 7),
      minute: asInt(m['minute']),
      repeatDays: days,
      enabled: asBool(m['enabled'], true),
      sound: (m['sound'] as String?) ?? 'default',
      vibrate: asBool(m['vibrate'], true),
      createdAt:
          DateTime.tryParse(m['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  String toJson() => jsonEncode(toMap());
  factory Alarm.fromJson(String s) =>
      Alarm.fromMap(jsonDecode(s) as Map<String, dynamic>);
}
