import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../core/theme/app_theme.dart';
import '../utils/time_utils.dart';
import 'reminder_tile.dart';

class TodayTimeline extends StatelessWidget {
  final bool dense;
  final List<Reminder> items;
  final Function(int id) onToggle;
  final Function(Reminder r) onEdit;
  final Function(int id) onDelete;

  const TodayTimeline({
    super.key,
    this.dense = false,
    required this.items,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final timeColumnWidth = dense ? 40.0 : 44.0;
    final timeFontSize = dense ? 10.5 : 11.0;
    final dotSize = dense ? 10.0 : 12.0;
    final dotTopMargin = dense ? 3.0 : 4.0;
    final lineHeight = dense ? 54.0 : 62.0;
    final trailingGap = dense ? 10.0 : 12.0;
    final rowBottom = dense ? 12.0 : 16.0;
    return AnimatedSwitcher(
      duration: ZyvoraMotion.regular,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: Column(
        key: ValueKey(items.map((r) => '${r.id}:${r.isCompleted}').join('|')),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(items.length, (index) {
          final r = items[index];
          final isLast = index == items.length - 1;
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 200 + (index * 50).clamp(0, 200)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, (1 - value) * 6),
                  child: child,
                ),
              );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: timeColumnWidth,
                  child: Column(
                    children: [
                      Text(
                        TimeUtils.formatClockTime(
                          r.hour,
                          r.minute,
                        ).replaceAll(' ', '\n'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: timeFontSize,
                          fontWeight: FontWeight.w800,
                          color: r.isCompleted
                              ? ZyvoraColors.muted
                              : theme.colorScheme.onSurface,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    AnimatedContainer(
                      duration: ZyvoraMotion.fast,
                      width: dotSize,
                      height: dotSize,
                      margin: EdgeInsets.only(top: dotTopMargin),
                      decoration: BoxDecoration(
                        color: r.isCompleted
                            ? ZyvoraColors.green
                            : theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: r.isCompleted
                              ? ZyvoraColors.green
                              : _priorityColor(r.priority),
                          width: dense ? 1.8 : 2,
                        ),
                      ),
                    ),
                    if (!isLast)
                      AnimatedContainer(
                        duration: ZyvoraMotion.fast,
                        width: 1.5,
                        height: lineHeight,
                        decoration: BoxDecoration(
                          color: r.isCompleted
                              ? ZyvoraColors.green.withValues(alpha: 0.4)
                              : theme.colorScheme.outline.withValues(alpha: 0.24),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: trailingGap),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: !isLast ? rowBottom : 0),
                    child: RepaintBoundary(
                      child: ReminderTile(
                        compact: dense,
                        reminder: r,
                        onToggle: () => onToggle(r.id),
                        onEdit: () => onEdit(r),
                        onDelete: () => onDelete(r.id),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Color _priorityColor(String p) {
    switch (p) {
      case 'high':
        return ZyvoraColors.error;
      case 'low':
        return ZyvoraColors.textSecondary;
      default:
        return ZyvoraColors.warning;
    }
  }
}
