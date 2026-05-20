import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/providers.dart';
import '../core/theme/app_theme.dart';
import '../models/reminder.dart';
import '../models/zyvora_role.dart';
import '../features/tasks/controllers/reminder_controller.dart';
import '../features/profile/controllers/user_controller.dart';
import '../utils/time_utils.dart';
import '../widgets/add_reminder_sheet.dart';
import '../widgets/zyvora_ui.dart';

enum _TaskFilter { all, today, upcoming, completed }

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  _TaskFilter _filter = _TaskFilter.all;

  Future<void> _add(BuildContext context) async {
    final reminders = ref.read(reminderControllerProvider);
    final user = ref.read(userControllerProvider);
    final mode = user.lifeMode?.storageValue ?? 'personal';
    final isPersonal = mode == 'personal';
    final result = await showModalBottomSheet<AddReminderResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddReminderSheet(
        lifeMode: mode,
        role: isPersonal ? null : (user.role ?? ZyvoraRole.student),
        defaultDay: user.todayName,
      ),
    );
    if (result == null) return;

    try {
      await reminders.addReminder(
        title: result.title,
        day: result.day,
        hour: result.hour,
        minute: result.minute,
        category: result.category,
        lifeMode: result.lifeMode,
        repeatType: result.repeatType,
        priority: result.priority,
        notes: result.notes,
        notificationEnabled: result.notificationEnabled,
        alarmEnabled: result.alarmEnabled,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save task: $e')));
    }
  }

  Future<void> _edit(
    BuildContext context,
    Reminder reminder,
  ) async {
    final remindersController = ref.read(reminderControllerProvider);
    final userController = ref.read(userControllerProvider);
    final isPersonal = reminder.lifeMode == 'personal';
    final result = await showModalBottomSheet<AddReminderResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddReminderSheet(
        lifeMode: reminder.lifeMode,
        role: isPersonal ? null : (userController.role ?? ZyvoraRole.student),
        defaultDay: reminder.day,
        defaultCategory: reminder.category,
        editTitle: reminder.title,
        editHour: reminder.hour,
        editMinute: reminder.minute,
        editRepeatType: reminder.repeatType,
        editPriority: reminder.priority,
        editNotes: reminder.notes,
        editNotificationEnabled: reminder.notificationEnabled,
        editAlarmEnabled: reminder.alarmEnabled,
      ),
    );
    if (result == null) return;

    try {
      await remindersController.editReminder(
        id: reminder.id,
        title: result.title,
        day: result.day,
        hour: result.hour,
        minute: result.minute,
        category: result.category,
        lifeMode: result.lifeMode,
        repeatType: result.repeatType,
        priority: result.priority,
        notes: result.notes,
        notificationEnabled: result.notificationEnabled,
        alarmEnabled: result.alarmEnabled,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not update task: $e')));
    }
  }

  Future<void> _toggle(
    BuildContext context,
    Reminder reminder,
  ) async {
    final remindersController = ref.read(reminderControllerProvider);
    try {
      await remindersController.toggleReminderComplete(reminder.id);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update completion: $e')),
      );
    }
  }

  Future<void> _delete(
    BuildContext context,
    Reminder reminder,
  ) async {
    final remindersController = ref.read(reminderControllerProvider);
    try {
      await remindersController.deleteReminder(reminder.id);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not delete task: $e')));
    }
  }

  List<Reminder> _filtered(
    ReminderController remindersController,
    UserController userController,
  ) {
    final today = userController.todayName;
    final items = remindersController.activeReminders.toList()
      ..sort((a, b) {
        final dayA = ZyvoraDays.ordered.indexOf(a.day);
        final dayB = ZyvoraDays.ordered.indexOf(b.day);
        if (dayA != dayB) return dayA.compareTo(dayB);
        return a.minutesFromMidnight.compareTo(b.minutesFromMidnight);
      });

    return switch (_filter) {
      _TaskFilter.all => items,
      _TaskFilter.today => items.where((r) => r.day == today).toList(),
      _TaskFilter.upcoming =>
        items.where((r) => r.day != today && !r.isCompleted).toList(),
      _TaskFilter.completed => items.where((r) => r.isCompleted).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final reminders = ref.watch(reminderControllerProvider);
    final user = ref.watch(userControllerProvider);
    final theme = Theme.of(context);
    final items = _filtered(reminders, user);
    final today = user.todayName;
    final all = reminders.activeReminders;
    final completed = all.where((r) => r.isCompleted).length;
    final todayPending = all
        .where((r) => r.day == today && !r.isCompleted)
        .length;
    final upcoming = all.where((r) => r.day != today && !r.isCompleted).length;
    final nextTask = reminders.nextReminderForToday();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 126),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tasks', style: theme.textTheme.headlineLarge),
                      const SizedBox(height: 4),
                      Text(
                        'Organize, focus and get things done',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                ZyvoraHeaderButton(
                  icon: Icons.add_rounded,
                  tooltip: 'Add task',
                  onTap: () => _add(context),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _TaskFocusHero(
              total: all.length,
              completed: completed,
              todayPending: todayPending,
              upcoming: upcoming,
              nextTask: nextTask,
              onAdd: () => _add(context),
            ),
            const SizedBox(height: 18),
            _FilterChips(
              selected: _filter,
              onChanged: (value) => setState(() => _filter = value),
            ),
            const SizedBox(height: 18),
            if (items.isEmpty)
              ZyvoraEmptyState(
                icon: Icons.task_alt_rounded,
                title: 'A clear lane',
                message:
                    'Add one focused task or switch filters to review your plan.',
                action: FilledButton.icon(
                  onPressed: () => _add(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add task'),
                ),
              )
            else ...[
              _TaskGroup(
                title: switch (_filter) {
                  _TaskFilter.upcoming => 'Upcoming',
                  _TaskFilter.completed => 'Completed',
                  _TaskFilter.today => 'Today',
                  _TaskFilter.all => 'Today',
                },
                count: _filter == _TaskFilter.all
                    ? items.where((r) => r.day == today).length
                    : items.length,
                initiallyExpanded: true,
                children: items
                    .where((r) => _filter != _TaskFilter.all || r.day == today)
                      .map(
                      (reminder) => _TaskCard(
                        reminder: reminder,
                        onToggle: () => _toggle(context, reminder),
                        onEdit: () => _edit(context, reminder),
                        onDelete: () => _delete(context, reminder),
                      ),
                    )
                    .toList(),
              ),
              if (_filter == _TaskFilter.all)
                _TaskGroup(
                  title: 'Upcoming',
                  count: items.where((r) => r.day != today).length,
                  initiallyExpanded: true,
                  children: items
                      .where((r) => r.day != today)
                      .map(
                        (reminder) => _TaskCard(
                          reminder: reminder,
                          onToggle: () => _toggle(context, reminder),
                          onEdit: () => _edit(context, reminder),
                          onDelete: () => _delete(context, reminder),
                        ),
                      )
                      .toList(),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TaskFocusHero extends StatelessWidget {
  const _TaskFocusHero({
    required this.total,
    required this.completed,
    required this.todayPending,
    required this.upcoming,
    required this.nextTask,
    required this.onAdd,
  });

  final int total;
  final int completed;
  final int todayPending;
  final int upcoming;
  final Reminder? nextTask;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = total == 0 ? 0.0 : completed / total;
    final title =
        nextTask?.title ??
        (todayPending == 0
            ? 'No pressure right now'
            : '$todayPending priorities waiting');
    final subtitle = nextTask == null
        ? 'Plan a small next move and keep the day clean.'
        : '${nextTask!.day}, ${TimeUtils.formatClockTime(nextTask!.hour, nextTask!.minute)}';

    return ZyvoraCard(
      padding: const EdgeInsets.all(18),
      borderColor: ZyvoraColors.primary.withValues(alpha: 0.16),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.colorScheme.surface,
          ZyvoraColors.primary.withValues(alpha: 0.06),
          ZyvoraColors.secondary.withValues(alpha: 0.04),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ZyvoraProgressRing(
                value: progress,
                size: 78,
                stroke: 9,
                color: ZyvoraColors.primary,
                child: Text(
                  '${(progress * 100).round()}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: ZyvoraColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ZyvoraPill(
                label: '$completed done',
                icon: Icons.check_rounded,
                color: ZyvoraColors.success,
              ),
              ZyvoraPill(
                label: '$todayPending today',
                icon: Icons.today_rounded,
                color: ZyvoraColors.primary,
              ),
              ZyvoraPill(
                label: '$upcoming upcoming',
                icon: Icons.schedule_rounded,
                color: ZyvoraColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add focused task'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onChanged});

  final _TaskFilter selected;
  final ValueChanged<_TaskFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final labels = {
      _TaskFilter.all: 'All',
      _TaskFilter.today: 'Today',
      _TaskFilter.upcoming: 'Upcoming',
      _TaskFilter.completed: 'Completed',
    };
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final entry = labels.entries.elementAt(index);
          final isSelected = entry.key == selected;
          return ChoiceChip(
            selected: isSelected,
            label: Text(entry.value),
            avatar: Icon(switch (entry.key) {
              _TaskFilter.all => Icons.layers_rounded,
              _TaskFilter.today => Icons.today_rounded,
              _TaskFilter.upcoming => Icons.schedule_rounded,
              _TaskFilter.completed => Icons.check_circle_rounded,
            }, size: 17),
            onSelected: (_) => onChanged(entry.key),
            labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: isSelected ? ZyvoraColors.primary : null,
              fontWeight: FontWeight.w800,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            side: BorderSide(
              color: isSelected
                  ? ZyvoraColors.primary.withValues(alpha: 0.25)
                  : Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.55),
            ),
          );
        },
      ),
    );
  }
}

class _TaskGroup extends StatelessWidget {
  const _TaskGroup({
    required this.title,
    required this.count,
    required this.children,
    this.initiallyExpanded = true,
  });

  final String title;
  final int count;
  final List<Widget> children;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ZyvoraSectionHeader(
            title: title,
            actionLabel: '$count tasks',
            onAction: () {},
            icon: Icons.expand_less_rounded,
          ),
          ...children,
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.reminder,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final Reminder reminder;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = zyvoraCategoryColor(reminder.category);
    final priorityColor = zyvoraPriorityColor(reminder.priority);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ZyvoraCard(
        shadow: false,
        padding: EdgeInsets.zero,
        borderColor: categoryColor.withValues(alpha: 0.24),
        child: IntrinsicHeight(
          child: Row(
            children: [
              AnimatedContainer(
                duration: ZyvoraMotion.regular,
                width: 4,
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(ZyvoraRadius.xl),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 16, 8, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: onToggle,
                        borderRadius: BorderRadius.circular(8),
                        child: AnimatedContainer(
                          duration: ZyvoraMotion.fast,
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: reminder.isCompleted
                                ? ZyvoraColors.success
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              color: reminder.isCompleted
                                  ? ZyvoraColors.success
                                  : theme.colorScheme.outline,
                              width: 1.5,
                            ),
                          ),
                          child: reminder.isCompleted
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 18,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reminder.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                decoration: reminder.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: reminder.isCompleted
                                    ? ZyvoraColors.textSecondary
                                    : null,
                              ),
                            ),
                            if (reminder.notes?.isNotEmpty == true) ...[
                              const SizedBox(height: 4),
                              Text(
                                reminder.notes!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ZyvoraPill(
                                  label:
                                      '${reminder.day}, ${TimeUtils.formatClockTime(reminder.hour, reminder.minute)}',
                                  icon: Icons.schedule_rounded,
                                  color: ZyvoraColors.primary,
                                ),
                                ZyvoraPill(
                                  label: reminder.category,
                                  icon: Icons.sell_outlined,
                                  color: categoryColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        tooltip: 'Task actions',
                        icon: Icon(
                          Icons.more_vert_rounded,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.54,
                          ),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
