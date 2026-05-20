import '../../models/insight.dart';
import '../../models/reminder.dart';
import 'database_service.dart';

class IntelligenceEngine {
  final DatabaseService _db;

  IntelligenceEngine({required DatabaseService db}) : _db = db;

  Future<List<Insight>> generateInsights(List<Reminder> reminders) async {
    final insights = <Insight>[];
    final now = DateTime.now();
    final todayName = _dayFromWeekday(now.weekday);
    final todayReminders = reminders.where((r) => r.day == todayName).toList();
    final completedToday = todayReminders.where((r) => r.isCompleted).length;

    if (todayReminders.isNotEmpty) {
      final pct = (completedToday / todayReminders.length * 100).round();
      insights.add(
        Insight(
          id: 'productivity_today',
          title: 'Today in motion',
          description:
              '$completedToday of ${todayReminders.length} reminders are complete ($pct%).',
          type: InsightType.productivity,
          generatedAt: now,
        ),
      );
    }

    final batch = await Future.wait<List<Map<String, dynamic>>>([
      _db.getCompletionsByHour(),
      _db.getCompletionsByDayOfWeek(),
      _db.getCompletionLogs(days: 30),
    ]);
    final hourData = batch[0];
    final dayData = batch[1];
    final completionLogs = batch[2];

    if (hourData.length >= 3) {
      var bestHour = 0;
      var bestCount = 0;
      for (final row in hourData) {
        final count = (row['count'] as num?)?.toInt() ?? 0;
        if (count > bestCount) {
          bestCount = count;
          bestHour = (row['hourOfDay'] as num?)?.toInt() ?? 0;
        }
      }
      final endHour = (bestHour + 3) % 24;
      insights.add(
        Insight(
          id: 'best_time',
          title: 'Best focus window',
          description:
              'Your strongest completion pattern is ${_formatHour(bestHour)} to ${_formatHour(endHour)}.',
          type: InsightType.suggestion,
          generatedAt: now,
        ),
      );
    }

    if (dayData.length >= 2) {
      var worstDay = 1;
      var worstCount = 999999;
      for (final row in dayData) {
        final count = (row['count'] as num?)?.toInt() ?? 0;
        if (count < worstCount) {
          worstCount = count;
          worstDay = (row['dayOfWeek'] as num?)?.toInt() ?? 1;
        }
      }
      final dayName = _dayFromWeekday(worstDay);
      insights.add(
        Insight(
          id: 'weak_day',
          title: 'Consistency check',
          description: '$dayName tends to need a lighter, clearer plan.',
          type: InsightType.routine,
          generatedAt: now,
        ),
      );
    }

    final streak = _calculateStreak(completionLogs);
    if (streak > 0) {
      insights.add(
        Insight(
          id: 'streak',
          title: '$streak-day streak',
          description: streak >= 7
              ? 'That rhythm is holding. Keep tomorrow simple enough to win.'
              : 'Momentum is starting to build.',
          type: InsightType.streak,
          generatedAt: now,
        ),
      );
    }

    final pendingToday = todayReminders.where((r) => !r.isCompleted).length;
    if (pendingToday > 3) {
      insights.add(
        Insight(
          id: 'burnout_warning',
          title: 'Trim the load',
          description:
              '$pendingToday reminders are still open today. Pick the top three first.',
          type: InsightType.burnout,
          generatedAt: now,
        ),
      );
    }

    final totalAll = reminders.length;
    final completedAll = reminders.where((r) => r.isCompleted).length;
    if (totalAll > 5) {
      final rate = (completedAll / totalAll * 100).round();
      final message = rate >= 80
          ? 'You complete $rate% of active reminders.'
          : rate >= 50
              ? 'You complete $rate% of active reminders. A smaller daily list could lift that.'
              : 'You complete $rate% of active reminders. Try fewer, sharper commitments.';
      insights.add(
        Insight(
          id: 'completion_rate',
          title: 'Completion rate',
          description: message,
          type: InsightType.productivity,
          generatedAt: now,
        ),
      );
    }

    return insights;
  }

  int _calculateStreak(List<Map<String, dynamic>> completionLogs) {
    final now = DateTime.now();
    var streak = 0;
    for (var i = 0; i < 30; i++) {
      final day = now.subtract(Duration(days: i));
      final dateKey = day.toIso8601String().substring(0, 10);
      final completedOnDay = completionLogs.any((log) {
        final completedAt = log['completedAt'] as String?;
        return completedAt != null && completedAt.startsWith(dateKey);
      });
      if (completedOnDay) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return streak;
  }

  String _dayFromWeekday(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[(weekday - 1) % 7];
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }
}
