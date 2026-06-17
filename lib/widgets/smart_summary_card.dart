import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Hero summary: tasks, reminders, attendance, productivity.
class SmartSummaryCard extends StatelessWidget {
  const SmartSummaryCard({
    super.key,
    required this.todayTasks,
    required this.upcomingCount,
    required this.productivity,
    this.attendancePercent,
    this.showAttendanceSlot = true,
  });

  final int todayTasks;
  final int upcomingCount;
  final double productivity;
  final double? attendancePercent;
  final bool showAttendanceSlot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ZyvoraRadius.hero),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  ZyvoraColors.card,
                  ZyvoraColors.backgroundSecondary,
                  const Color(0xFF1A2332),
                ]
              : [
                  Colors.white,
                  ZyvoraColors.surfaceLight,
                  ZyvoraColors.surfaceSoftLight,
                ],
        ),
        border: Border.all(
          color: ZyvoraColors.accentBlue.withValues(alpha: isDark ? 0.35 : 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: ZyvoraColors.accentBlue.withValues(
              alpha: isDark ? 0.12 : 0.08,
            ),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 18,
                color: ZyvoraColors.accentBlue.withValues(alpha: 0.95),
              ),
              const SizedBox(width: 8),
              Text(
                "Today's pulse",
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _StatBlock(
                value: '$todayTasks',
                label: 'Today',
                accent: ZyvoraColors.accentBlue,
              ),
              _StatBlock(
                value: '$upcomingCount',
                label: 'Upcoming',
                accent: ZyvoraColors.accentPurple,
              ),
              if (showAttendanceSlot)
                _StatBlock(
                  value: attendancePercent == null
                      ? '—'
                      : '${attendancePercent!.round()}%',
                  label: 'Attendance',
                  accent: ZyvoraColors.success,
                ),
              _StatBlock(
                value: '${productivity.round()}%',
                label: 'Focus',
                accent: ZyvoraColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.value,
    required this.label,
    required this.accent,
  });

  final String value;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}
