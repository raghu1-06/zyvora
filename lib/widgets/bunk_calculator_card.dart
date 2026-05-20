import 'package:flutter/material.dart';
import '../models/attendance_record.dart';
import '../core/theme/app_theme.dart';

class BunkCalculatorCard extends StatelessWidget {
  final SubjectAttendance stats;

  const BunkCalculatorCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.total == 0) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final safeBunks = stats.bunkableClasses();
    final isSafe = safeBunks > 0;

    return AnimatedContainer(
      duration: ZyvoraMotion.fast,
      curve: ZyvoraMotion.curve,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ZyvoraRadius.md),
        border: Border.all(
          color: isSafe
              ? ZyvoraColors.green.withValues(alpha: 0.3)
              : ZyvoraColors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSafe
                  ? ZyvoraColors.green.withValues(alpha: 0.1)
                  : ZyvoraColors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ZyvoraRadius.md),
            ),
            child: Icon(
              isSafe ? Icons.check_circle_outline : Icons.warning_amber_rounded,
              color: isSafe ? ZyvoraColors.green : ZyvoraColors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stats.subject, style: theme.textTheme.titleMedium),
                Text(
                  'Attendance: ${stats.percentage.round()}%',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isSafe ? '+$safeBunks safe' : '0 safe',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSafe ? ZyvoraColors.green : ZyvoraColors.red,
                ),
              ),
              Text(
                isSafe ? 'bunks' : 'can\'t skip',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
