class ParsedTime {
  final int hour;
  final int minute;

  const ParsedTime(this.hour, this.minute);
}

class TimeUtils {
  static const fallback = ParsedTime(9, 0);

  static ParsedTime parseStoredTime(String? value) {
    final raw = value?.trim();
    if (raw == null || raw.isEmpty || raw == 'No Time') {
      return fallback;
    }

    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*([AaPp][Mm])?$',
    ).firstMatch(raw);
    if (match == null) {
      return fallback;
    }

    var hour = int.tryParse(match.group(1) ?? '') ?? fallback.hour;
    final minute = int.tryParse(match.group(2) ?? '') ?? fallback.minute;
    final meridiem = match.group(3)?.toUpperCase();

    if (meridiem == 'PM' && hour < 12) {
      hour += 12;
    }
    if (meridiem == 'AM' && hour == 12) {
      hour = 0;
    }

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return fallback;
    }

    return ParsedTime(hour, minute);
  }

  static String formatClockTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  static String formatDurationUntil(DateTime now, DateTime target) {
    final difference = target.difference(now);
    if (difference.inMinutes <= 0) {
      return 'now';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes} min';
    }
    if (difference.inHours < 24) {
      final minutes = difference.inMinutes.remainder(60);
      return minutes == 0
          ? '${difference.inHours} hr'
          : '${difference.inHours} hr $minutes min';
    }
    return '${difference.inDays} days';
  }
}
