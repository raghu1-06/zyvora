import 'package:flutter/material.dart';

import '../models/attendance_record.dart';
import '../core/theme/app_theme.dart';

/// Horizontal attendance percentage bar for a subject.
class AttendanceBar extends StatelessWidget {
  final SubjectAttendance stats;
  final VoidCallback? onTap;

  const AttendanceBar({super.key, required this.stats, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = stats.percentage;
    final color = pct >= 75
        ? ZyvoraColors.green
        : pct >= 50
        ? ZyvoraColors.yellow
        : ZyvoraColors.red;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(ZyvoraRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ZyvoraRadius.md),
        child: AnimatedContainer(
          duration: ZyvoraMotion.regular,
          curve: ZyvoraMotion.curve,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ZyvoraRadius.md),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.7),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      stats.subject,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${pct.round()}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: pct / 100,
                  minHeight: 8,
                  backgroundColor: color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${stats.present}/${stats.total} classes',
                    style: theme.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  if (stats.isAtRisk)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: ZyvoraColors.redSoft,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'At Risk',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: ZyvoraColors.red,
                        ),
                      ),
                    ),
                  if (!stats.isAtRisk && stats.bunkableClasses() > 0)
                    Text(
                      'Can skip ${stats.bunkableClasses()}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: ZyvoraColors.green,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
