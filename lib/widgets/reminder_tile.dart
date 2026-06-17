import 'package:flutter/material.dart';

import '../models/reminder.dart';
import '../core/theme/app_theme.dart';
import '../utils/time_utils.dart';

class ReminderTile extends StatelessWidget {
  final bool compact;
  final Reminder reminder;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ReminderTile({
    super.key,
    this.compact = false,
    required this.reminder,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final catColor = _categoryColor(reminder.category);
    final tilePadding = compact
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 9)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 11);
    final checkSize = compact ? 24.0 : 26.0;
    final checkIconSize = compact ? 16.0 : 18.0;
    final timeFontSize = compact ? 10.0 : 11.0;
    final titleStyle = compact
        ? theme.textTheme.titleSmall
        : theme.textTheme.titleMedium;
    final menuIconSize = compact ? 20.0 : 24.0;

    return AnimatedContainer(
      duration: ZyvoraMotion.regular,
      curve: ZyvoraMotion.curve,
      padding: tilePadding,
      decoration: BoxDecoration(
        color: reminder.isCompleted
            ? theme.colorScheme.surface.withValues(alpha: isDark ? 0.68 : 0.78)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ZyvoraRadius.md),
        border: Border.all(
          color: reminder.isCompleted
              ? ZyvoraColors.green.withValues(alpha: 0.38)
              : theme.colorScheme.outline.withValues(alpha: 0.72),
        ),
      ),
      child: Row(
        children: [
          InkResponse(
            onTap: onToggle,
            radius: 24,
            child: AnimatedContainer(
              duration: ZyvoraMotion.fast,
              width: checkSize,
              height: checkSize,
              decoration: BoxDecoration(
                color: reminder.isCompleted
                    ? ZyvoraColors.green
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(ZyvoraRadius.sm),
                border: Border.all(
                  color: reminder.isCompleted
                      ? ZyvoraColors.green
                      : theme.colorScheme.outline,
                  width: 1.4,
                ),
              ),
              child: AnimatedSwitcher(
                duration: ZyvoraMotion.fast,
                child: reminder.isCompleted
                ? Icon(
                        Icons.check_rounded,
                        key: ValueKey('done'),
                        size: checkIconSize,
                        color: Colors.white,
                      )
                    : const SizedBox(key: ValueKey('open')),
              ),
            ),
          ),
          SizedBox(width: compact ? 10 : 12),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8 : 9,
              vertical: compact ? 5 : 6,
            ),
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(ZyvoraRadius.sm),
            ),
            child: Text(
              TimeUtils.formatClockTime(reminder.hour, reminder.minute),
              style: TextStyle(
                fontSize: timeFontSize,
                fontWeight: FontWeight.w800,
                color: catColor,
              ),
            ),
          ),
          SizedBox(width: compact ? 10 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: titleStyle?.copyWith(
                    decoration: reminder.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    color: reminder.isCompleted
                        ? theme.textTheme.bodySmall?.color
                        : null,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  reminder.notes?.isNotEmpty == true
                      ? reminder.notes!
                      : '${reminder.category} · ${reminder.priority}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Reminder actions',
            icon: Icon(
              Icons.more_horiz,
              size: menuIconSize,
              color: theme.textTheme.bodySmall?.color,
            ),
            onSelected: (value) {
              if (value == 'edit') onEdit();
              if (value == 'delete') onDelete();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Class':
      case 'Academic':
      case 'Water':
        return ZyvoraColors.blue;
      case 'Meeting':
      case 'Client Meeting':
      case 'Sleep':
        return ZyvoraColors.purple;
      case 'Assignment':
      case 'Task':
      case 'Project':
      case 'Project Deadline':
      case 'Family':
        return ZyvoraColors.coral;
      case 'Exam':
      case 'Deadline':
      case 'Medicine':
        return ZyvoraColors.red;
      case 'Study Session':
      case 'Focus Session':
      case 'Study':
        return ZyvoraColors.cyan;
      case 'Gym':
        return ZyvoraColors.green;
      case 'Habit':
        return ZyvoraColors.yellow;
      default:
        return ZyvoraColors.primary;
    }
  }
}
