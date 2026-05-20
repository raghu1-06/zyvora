import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';

class WeekSummaryCard extends StatelessWidget {
  final Map<String, int> stats;

  const WeekSummaryCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    int maxCompletions = 1;
    for (var val in stats.values) {
      if (val > maxCompletions) maxCompletions = val;
    }

    return AnimatedContainer(
      duration: ZyvoraMotion.regular,
      curve: ZyvoraMotion.curve,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ZyvoraRadius.md),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Week Overview', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: ZyvoraDays.ordered.map((day) {
              final count = stats[day] ?? 0;
              final height = (count / maxCompletions) * 60;
              final isToday =
                  day == ZyvoraDays.fromWeekday(DateTime.now().weekday);

              return Column(
                children: [
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 10,
                      color: count > 0
                          ? ZyvoraColors.primary
                          : ZyvoraColors.muted,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: ZyvoraMotion.regular,
                    curve: ZyvoraMotion.curve,
                    width: 24,
                    height: height < 4 ? 4 : height,
                    decoration: BoxDecoration(
                      color: count > 0
                          ? (isToday
                                ? ZyvoraColors.primary
                                : ZyvoraColors.cyan.withValues(alpha: 0.62))
                          : theme.colorScheme.outline.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ZyvoraDays.shortName(day).substring(0, 1),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday ? ZyvoraColors.primary : null,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
