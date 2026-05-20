import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../core/constants/app_constants.dart';
import '../core/providers.dart';
import '../core/theme/app_theme.dart';
import '../models/reminder.dart';
import '../widgets/add_reminder_sheet.dart';
import '../widgets/reminder_tile.dart';
import '../widgets/premium_navigation.dart';
import '../features/tasks/controllers/reminder_controller.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _focused;
  DateTime? _selected;
  bool _monthView = true;

  Future<void> _editReminder(Reminder r) async {
    final user = ref.read(userControllerProvider);
    final reminders = ref.read(reminderControllerProvider);
    final isPersonal = user.lifeMode?.storageValue == 'personal';
    final result = await showModalBottomSheet<AddReminderResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddReminderSheet(
        lifeMode: isPersonal ? 'personal' : 'professional',
        role: isPersonal ? null : user.role,
        defaultDay: r.day,
        defaultCategory: r.category,
        editTitle: r.title,
        editHour: r.hour,
        editMinute: r.minute,
        editRepeatType: r.repeatType,
        editPriority: r.priority,
        editNotes: r.notes,
        editNotificationEnabled: r.notificationEnabled,
        editAlarmEnabled: r.alarmEnabled,
      ),
    );
    if (result == null) return;
    try {
      await reminders.editReminder(
        id: r.id,
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
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not update: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _focused = DateTime(n.year, n.month, n.day);
    _selected = _focused;
  }

  String _dayNameFor(DateTime d) => ZyvoraDays.fromWeekday(d.weekday);

  Set<DateTime> _daysWithTasks(ReminderController remindersController) {
    final set = <DateTime>{};
    final now = DateTime.now();
    for (final r in remindersController.activeReminders) {
      final idx = ZyvoraDays.ordered.indexOf(r.day);
      if (idx < 0) continue;
      final diff = (idx + 1) - now.weekday;
      for (var k = -5; k <= 5; k++) {
        final d = now.add(Duration(days: diff + 7 * k));
        set.add(DateTime(d.year, d.month, d.day));
      }
    }
    return set;
  }

  Set<DateTime> _examDays(ReminderController remindersController) {
    final set = <DateTime>{};
    final now = DateTime.now();
    for (final r in remindersController.activeReminders) {
      if (!r.category.toLowerCase().contains('exam')) continue;
      final idx = ZyvoraDays.ordered.indexOf(r.day);
      if (idx < 0) continue;
      final diff = (idx + 1) - now.weekday;
      for (var k = -5; k <= 5; k++) {
        final d = now.add(Duration(days: diff + 7 * k));
        set.add(DateTime(d.year, d.month, d.day));
      }
    }
    return set;
  }

  @override
  Widget build(BuildContext context) {
    final reminders = ref.watch(reminderControllerProvider);
    final theme = Theme.of(context);
    final marked = _daysWithTasks(reminders);
    final examDays = _examDays(reminders);
    final sel = _selected ?? _focused;
    final dayName = _dayNameFor(sel);
    final dayTasks = reminders.remindersForDay(dayName);

    return Scaffold(
      appBar: const PremiumAppBar(title: 'Calendar'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
        children: [
          Center(
            child: SegmentedButton<bool>(
              showSelectedIcon: false,
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
              segments: const [
                ButtonSegment(value: true, label: Text('Month')),
                ButtonSegment(value: false, label: Text('Agenda')),
              ],
              selected: {_monthView},
              onSelectionChanged: (s) => setState(() => _monthView = s.first),
            ),
          ),
          const SizedBox(height: 16),
          if (_monthView) ...[
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(ZyvoraRadius.hero),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.35),
                ),
              ),
              child: TableCalendar<dynamic>(
                firstDay: DateTime.utc(2020),
                lastDay: DateTime.utc(2035, 12, 31),
                focusedDay: _focused,
                selectedDayPredicate: (d) => isSameDay(_selected, d),
                onDaySelected: (s, f) {
                  setState(() {
                    _selected = s;
                    _focused = f;
                  });
                },
                onPageChanged: (f) => _focused = f,
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: ZyvoraColors.accentBlue.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: ZyvoraColors.accentBlue,
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                  defaultTextStyle: TextStyle(
                    color: theme.colorScheme.onSurface,
                  ),
                  outsideTextStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: theme.textTheme.titleMedium!,
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: theme.colorScheme.onSurface,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (ctx, day, _) {
                    final norm = DateTime(day.year, day.month, day.day);
                    final dot = marked.contains(norm);
                    final exam = examDays.contains(norm);
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Text('${day.day}'),
                        if (dot || exam)
                          Positioned(
                            bottom: 4,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (exam)
                                  Container(
                                    width: 5,
                                    height: 5,
                                    margin: const EdgeInsets.only(right: 2),
                                    decoration: const BoxDecoration(
                                      color: ZyvoraColors.warning,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                if (dot)
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                      color: ZyvoraColors.accentPurple,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              DateFormat('EEE, MMM d').format(sel),
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            if (dayTasks.isEmpty)
              Text(
                'No recurring items for this weekday.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              )
            else
              ...dayTasks.map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ReminderTile(
                    reminder: r,
                    onToggle: () => reminders.toggleReminderComplete(r.id),
                    onEdit: () => _editReminder(r),
                    onDelete: () => reminders.deleteReminder(r.id),
                  ),
                ),
              ),
            ] else ...[
            Text('Next two weeks', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            ..._buildAgenda(reminders, theme),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildAgenda(ReminderController ctrl, ThemeData theme) {
    final now = DateTime.now();
    final out = <Widget>[];
    for (var i = 0; i < 14; i++) {
      final d = DateTime(now.year, now.month, now.day).add(Duration(days: i));
      final name = ZyvoraDays.fromWeekday(d.weekday);
      final items = ctrl.remindersForDay(name);
      if (items.isEmpty) continue;
      final exam = items.any((r) => r.category.toLowerCase().contains('exam'));
      out.add(
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(ZyvoraRadius.md),
            border: Border.all(
              color: exam
                  ? ZyvoraColors.warning.withValues(alpha: 0.55)
                  : theme.colorScheme.outline.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    DateFormat('EEE, MMM d').format(d),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (exam) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: ZyvoraColors.warning.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(ZyvoraRadius.sm),
                      ),
                      child: const Text(
                        'Exam week',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: ZyvoraColors.warning,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              ...items.map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ReminderTile(
                    reminder: r,
                    onToggle: () => ctrl.toggleReminderComplete(r.id),
                    onEdit: () => _editReminder(r),
                    onDelete: () => ctrl.deleteReminder(r.id),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (out.isEmpty) {
      return [
        Text(
          'Nothing scheduled in the next two weeks.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ];
    }
    return out;
  }
}
