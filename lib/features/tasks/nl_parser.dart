import 'package:intl/intl.dart';

class ParsedQuickTask {
  final String title;
  final String day;
  final int hour;
  final int minute;
  final String lifeMode;
  final String category;
  final String priority;
  final String repeatType;

  ParsedQuickTask({
    required this.title,
    required this.day,
    required this.hour,
    required this.minute,
    this.lifeMode = 'personal',
    this.category = 'Custom',
    this.priority = 'medium',
    this.repeatType = 'weekly',
  });
}

class NLParser {
  static final _dayNames = {
    'monday': 'Monday',
    'tuesday': 'Tuesday',
    'wednesday': 'Wednesday',
    'thursday': 'Thursday',
    'friday': 'Friday',
    'saturday': 'Saturday',
    'sunday': 'Sunday',
  };

  static ParsedQuickTask parse(String input) {
    final text = input.trim();
    final now = DateTime.now();
    final lower = text.toLowerCase();

    var day = DateFormat('EEEE').format(now);
    var hour = 9;
    var minute = 0;
    var category = 'Custom';
    var priority = 'medium';
    var repeatType = _detectRepeatType(lower);

    final timeReg = RegExp(
      r'(?:at\s*)?(\d{1,2})(?::(\d{2}))?\s*(am|pm)?',
      caseSensitive: false,
    );
    final timeMatch = timeReg.firstMatch(text);
    if (timeMatch != null) {
      var parsedHour = int.tryParse(timeMatch.group(1) ?? '') ?? 9;
      minute = int.tryParse(timeMatch.group(2) ?? '') ?? 0;
      final ampm = timeMatch.group(3)?.toLowerCase();
      if (ampm == 'pm' && parsedHour < 12) parsedHour += 12;
      if (ampm == 'am' && parsedHour == 12) parsedHour = 0;
      hour = parsedHour;
    }

    if (lower.contains('tomorrow')) {
      day = DateFormat('EEEE').format(now.add(const Duration(days: 1)));
    } else if (lower.contains('today')) {
      day = DateFormat('EEEE').format(now);
    } else {
      for (final entry in _dayNames.entries) {
        if (lower.contains(entry.key)) {
          day = entry.value;
          break;
        }
      }
    }

    if (lower.contains('urgent') || lower.contains('high priority')) {
      priority = 'high';
    } else if (lower.contains('low priority') || lower.contains('later')) {
      priority = 'low';
    }

    if (lower.contains('gym') || lower.contains('workout') || lower.contains('run')) {
      category = 'Health';
    } else if (lower.contains('meeting') || lower.contains('standup')) {
      category = 'Meeting';
    } else if (lower.contains('assignment') || lower.contains('homework') || lower.contains('project') || lower.contains('dbms') || lower.contains('exam')) {
      category = 'Study';
    } else if (lower.contains('call') || lower.contains('phone')) {
      category = 'Call';
    } else if (lower.contains('water') || lower.contains('hydrate')) {
      category = 'Habit';
    }

    var title = text
        .replaceAll(timeReg, ' ')
        .replaceAll(
          RegExp(
            r'\b(tomorrow|today|monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b',
            caseSensitive: false,
          ),
          ' ',
        )
        .replaceAll(
          RegExp(r'\b(every|daily|weekly|monthly|once)\b', caseSensitive: false),
          ' ',
        )
        .replaceAll(RegExp(r'\b(at|around|by)\b', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (title.isEmpty) title = 'Untitled';

    return ParsedQuickTask(
      title: _capitalize(title),
      day: day,
      hour: hour,
      minute: minute,
      category: category,
      priority: priority,
      repeatType: repeatType,
    );
  }

  static String _detectRepeatType(String lower) {
    if (lower.contains('monthly') || lower.contains('every month')) {
      return 'monthly';
    }
    if (lower.contains('daily') || lower.contains('every day') || lower.contains('each day')) {
      return 'daily';
    }
    if (lower.contains('once') || lower.contains('one time') || lower.contains('one-time')) {
      return 'once';
    }
    return 'weekly';
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
