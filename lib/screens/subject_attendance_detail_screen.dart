import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../core/providers.dart';
import '../core/theme/app_theme.dart';
import '../features/attendance/controllers/attendance_controller.dart';
import '../models/attendance_record.dart';
import '../core/utils/error_handler.dart';
import '../widgets/zyvora_ui.dart';

class SubjectAttendanceDetailScreen extends ConsumerStatefulWidget {
  const SubjectAttendanceDetailScreen({super.key, required this.subject});

  final String subject;

  @override
  ConsumerState<SubjectAttendanceDetailScreen> createState() =>
      _SubjectAttendanceDetailScreenState();
}

class _SubjectAttendanceDetailScreenState
    extends ConsumerState<SubjectAttendanceDetailScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final today = AttendanceRecord.normalizeDate(DateTime.now());
    _focusedDay = today;
    _selectedDay = today;

    Future.microtask(() {
      if (!mounted) return;
      ref.read(attendanceControllerProvider).loadRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(attendanceControllerProvider);
    final vm = _SubjectAttendanceVM.from(service, widget.subject, _focusedDay);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
          children: [
            _DetailTopBar(subject: vm.stats.subject),
            const SizedBox(height: 18),
            _SubjectHero(stats: vm.stats),
            const SizedBox(height: 24),
            _AttendanceCalendarCard(
              focusedDay: _focusedDay,
              selectedDay: _selectedDay,
              recordsByDate: vm.recordsByDate,
              onPreviousMonth: () => _moveMonth(-1),
              onNextMonth: () => _moveMonth(1),
              onToday: _jumpToToday,
              onPageChanged: (day) {
                if (!mounted) return;
                setState(() => _focusedDay = day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (!mounted) return;
                final normalized = AttendanceRecord.normalizeDate(selectedDay);
                setState(() {
                  _selectedDay = normalized;
                  _focusedDay = focusedDay;
                });
                _openAttendanceSheet(
                  context,
                  subject: vm.stats.subject,
                  date: normalized,
                  existing:
                      vm.recordsByDate[AttendanceRecord.dateKeyFor(normalized)],
                );
              },
            ),
            const SizedBox(height: 20),
            _AttendanceTimeline(records: vm.stats.records),
            const SizedBox(height: 24),
            _MonthlyAnalyticsCard(
              month: _focusedDay,
              stats: vm.monthlyStats,
              recordsByDate: vm.recordsByDate,
            ),
          ],
        ),
      ),
    );
  }

  void _moveMonth(int delta) {
    if (!mounted) return;
    final next = DateTime(_focusedDay.year, _focusedDay.month + delta);
    setState(() => _focusedDay = next);
  }

  void _jumpToToday() {
    if (!mounted) return;
    final today = AttendanceRecord.normalizeDate(DateTime.now());
    setState(() {
      _focusedDay = today;
      _selectedDay = today;
    });
  }

  Future<void> _openAttendanceSheet(
    BuildContext context, {
    required String subject,
    required DateTime date,
    required AttendanceRecord? existing,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (sheetContext) {
        return _AttendanceEntrySheet(
          subject: subject,
          date: date,
          existing: existing,
        );
      },
    );
  }
}

class _DetailTopBar extends StatelessWidget {
  const _DetailTopBar({required this.subject});

  final String subject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        ZyvoraHeaderButton(
          icon: Icons.arrow_back_rounded,
          tooltip: 'Back',
          onTap: () => Navigator.pop(context),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subject,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 2),
              Text('Attendance workspace', style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _SubjectHero extends StatelessWidget {
  const _SubjectHero({required this.stats});

  final SubjectAttendance stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _attendanceColor(stats.percentage);
    final streak = stats.attendanceStreakClasses();
    final statusLabel = stats.isEmpty
        ? 'Ready to track'
        : stats.percentage >= 90
        ? 'Excellent consistency'
        : stats.isAtRisk
        ? 'Needs focused recovery'
        : 'Healthy attendance';

    return ZyvoraCard(
      padding: const EdgeInsets.all(20),
      borderColor: color.withValues(alpha: 0.18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 420;
          final ringSize = narrow ? 116.0 : 144.0;
          final ring = _AnimatedAttendanceRing(
            percentage: stats.percentage,
            color: color,
            size: ringSize,
          );

          final header = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stats.subject,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 5),
                        AnimatedSwitcher(
                          duration: ZyvoraMotion.regular,
                          child: Text(
                            statusLabel,
                            key: ValueKey(statusLabel),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ZyvoraPill(
                    label: stats.isAtRisk ? 'Needs work' : 'Safe',
                    icon: stats.isAtRisk
                        ? Icons.trending_down_rounded
                        : Icons.verified_rounded,
                    color: stats.isAtRisk
                        ? ZyvoraColors.warning
                        : ZyvoraColors.success,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                stats.safeBunkMessage(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (narrow)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: ring),
                    const SizedBox(height: 18),
                    header,
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ring,
                    const SizedBox(width: 24),
                    Expanded(child: header),
                  ],
                ),
              const SizedBox(height: 18),
              _CompactStatsBar(stats: stats),
              const SizedBox(height: 14),
              _InsightRail(
                insights: [
                  _InsightItem(
                    icon: Icons.shield_rounded,
                    color: ZyvoraColors.primary,
                    title: 'Safe bunk',
                    message: stats.safeBunkMessage(),
                  ),
                  _InsightItem(
                    icon: Icons.trending_up_rounded,
                    color: ZyvoraColors.success,
                    title: 'Recovery',
                    message: stats.recoveryMessage(),
                  ),
                  _InsightItem(
                    icon: Icons.local_fire_department_rounded,
                    color: ZyvoraColors.warning,
                    title: 'Streak',
                    message: streak == 1
                        ? '1 class attended continuously.'
                        : '$streak classes attended continuously.',
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AnimatedAttendanceRing extends StatelessWidget {
  const _AnimatedAttendanceRing({
    required this.percentage,
    required this.color,
    required this.size,
  });

  final double percentage;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: (percentage / 100).clamp(0, 1)),
      duration: const Duration(milliseconds: 720),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.16),
                blurRadius: 26,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ZyvoraProgressRing(
            value: value,
            size: size,
            stroke: size < 120 ? 11 : 13,
            color: color,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(value * 100).round()}%',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text('Current', style: theme.textTheme.labelSmall),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CompactStatsBar extends StatelessWidget {
  const _CompactStatsBar({required this.stats});

  final SubjectAttendance stats;

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatPillData(
        'Held',
        '${stats.total}',
        Icons.event_rounded,
        ZyvoraColors.secondary,
      ),
      _StatPillData(
        'Attended',
        '${stats.present}',
        Icons.check_rounded,
        ZyvoraColors.success,
      ),
      _StatPillData(
        'Extras',
        '${stats.extraClasses}',
        Icons.add_circle_rounded,
        ZyvoraColors.primary,
      ),
      _StatPillData(
        'Bunks',
        '${stats.totalBunks}',
        Icons.person_off_rounded,
        ZyvoraColors.error,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 420 ? 2 : 4;
        return GridView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: columns == 2 ? 2.65 : 1.72,
          ),
          itemBuilder: (context, index) => _CompactStatPill(data: items[index]),
        );
      },
    );
  }
}

class _StatPillData {
  const _StatPillData(this.label, this.value, this.icon, this.color);

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class _CompactStatPill extends StatelessWidget {
  const _CompactStatPill({required this.data});

  final _StatPillData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: ZyvoraMotion.fast,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: data.color.withValues(alpha: 0.13)),
      ),
      child: Row(
        children: [
          Icon(data.icon, color: data.color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: data.color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightItem {
  const _InsightItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String message;
}

class _InsightRail extends StatelessWidget {
  const _InsightRail({required this.insights});

  final List<_InsightItem> insights;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 640) {
          return SizedBox(
            height: 98,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: insights.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: math.min(286, constraints.maxWidth * 0.82),
                  child: _InsightCard(item: insights[index]),
                );
              },
            ),
          );
        }

        return Row(
          children: insights
              .map(
                (item) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _InsightCard(item: item),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.item});

  final _InsightItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.94, end: 1),
      duration: ZyvoraMotion.regular,
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          alignment: Alignment.centerLeft,
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: item.color.withValues(alpha: 0.075),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: item.color.withValues(alpha: 0.14)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ZyvoraIconBadge(
              icon: item.icon,
              color: item.color,
              size: 36,
              iconSize: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item.title, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    item.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceCalendarCard extends StatelessWidget {
  const _AttendanceCalendarCard({
    required this.focusedDay,
    required this.selectedDay,
    required this.recordsByDate,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onToday,
    required this.onPageChanged,
    required this.onDaySelected,
  });

  final DateTime focusedDay;
  final DateTime selectedDay;
  final Map<String, AttendanceRecord> recordsByDate;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onToday;
  final ValueChanged<DateTime> onPageChanged;
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthLabel = DateFormat('MMMM yyyy').format(focusedDay);
    final selectedRecord =
        recordsByDate[AttendanceRecord.dateKeyFor(selectedDay)];

    return ZyvoraCard(
      padding: const EdgeInsets.all(18),
      borderColor: ZyvoraColors.primary.withValues(alpha: 0.14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final controls = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Previous month',
                    onPressed: onPreviousMonth,
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  AnimatedSwitcher(
                    duration: ZyvoraMotion.fast,
                    child: SizedBox(
                      key: ValueKey(monthLabel),
                      width: 132,
                      child: Text(
                        monthLabel,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Next month',
                    onPressed: onNextMonth,
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                  IconButton(
                    tooltip: 'Today',
                    onPressed: onToday,
                    icon: const Icon(Icons.today_rounded),
                  ),
                ],
              );

              if (constraints.maxWidth < 420) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Calendar', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Align(alignment: Alignment.centerLeft, child: controls),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: Text('Calendar', style: theme.textTheme.titleLarge),
                  ),
                  controls,
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: ZyvoraMotion.regular,
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: TableCalendar<AttendanceRecord>(
              key: ValueKey('${focusedDay.year}-${focusedDay.month}'),
              firstDay: DateTime(2020),
              lastDay: DateTime(2035, 12, 31),
              focusedDay: focusedDay,
              selectedDayPredicate: (day) => isSameDay(day, selectedDay),
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {CalendarFormat.month: 'Month'},
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerVisible: false,
              rowHeight: 60,
              daysOfWeekHeight: 30,
              onPageChanged: onPageChanged,
              onDaySelected: onDaySelected,
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: theme.textTheme.labelSmall!.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                weekendStyle: theme.textTheme.labelSmall!.copyWith(
                  color: ZyvoraColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              calendarStyle: const CalendarStyle(markersMaxCount: 0),
              calendarBuilders: CalendarBuilders<AttendanceRecord>(
                defaultBuilder: (context, day, focusedDay) {
                  return _CalendarDayCell(
                    day: day,
                    record: recordsByDate[AttendanceRecord.dateKeyFor(day)],
                  );
                },
                todayBuilder: (context, day, focusedDay) {
                  return _CalendarDayCell(
                    day: day,
                    isToday: true,
                    record: recordsByDate[AttendanceRecord.dateKeyFor(day)],
                  );
                },
                selectedBuilder: (context, day, focusedDay) {
                  return _CalendarDayCell(
                    day: day,
                    isSelected: true,
                    isToday: isSameDay(day, DateTime.now()),
                    record: recordsByDate[AttendanceRecord.dateKeyFor(day)],
                  );
                },
                outsideBuilder: (context, day, focusedDay) {
                  return _CalendarDayCell(
                    day: day,
                    isOutside: true,
                    record: recordsByDate[AttendanceRecord.dateKeyFor(day)],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          _SelectedDateSummary(day: selectedDay, record: selectedRecord),
          const SizedBox(height: 14),
          const Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _LegendDot(color: ZyvoraColors.success, label: 'Present'),
              _LegendDot(color: ZyvoraColors.error, label: 'Absent'),
              _LegendDot(color: ZyvoraColors.primary, label: 'Extra classes'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.day,
    this.record,
    this.isToday = false,
    this.isSelected = false,
    this.isOutside = false,
  });

  final DateTime day;
  final AttendanceRecord? record;
  final bool isToday;
  final bool isSelected;
  final bool isOutside;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = _recordColor(record);
    final extraClasses = record?.extraClasses ?? 0;
    final intensity = record == null
        ? 0.0
        : (0.08 + record!.heldClasses.clamp(1, 9) * 0.018)
              .clamp(0.08, 0.24)
              .toDouble();
    final borderColor = isSelected
        ? ZyvoraColors.primary
        : isToday
        ? ZyvoraColors.secondary
        : baseColor.withValues(alpha: record == null ? 0.08 : 0.25);

    return AnimatedScale(
      scale: isSelected ? 1.06 : 1,
      duration: ZyvoraMotion.fast,
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: ZyvoraMotion.regular,
        curve: ZyvoraMotion.curve,
        margin: const EdgeInsets.all(3),
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? ZyvoraColors.primary.withValues(
                  alpha: record == null ? 0.07 : 0.1,
                )
              : record == null
              ? Colors.transparent
              : baseColor.withValues(alpha: intensity),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: borderColor,
            width: isSelected || isToday ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: ZyvoraColors.primary.withValues(alpha: 0.14),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: theme.textTheme.labelLarge?.copyWith(
                color: isOutside
                    ? ZyvoraColors.textTertiary
                    : isSelected
                    ? ZyvoraColors.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              height: 16,
              child: record == null
                  ? const SizedBox.shrink()
                  : FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: record!.isPresent
                                  ? ZyvoraColors.success
                                  : ZyvoraColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (extraClasses > 0) ...[
                            const SizedBox(width: 4),
                            Tooltip(
                              message:
                                  '$extraClasses extra class${extraClasses == 1 ? '' : 'es'}',
                              child: Container(
                                width: 16,
                                height: 14,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: ZyvoraColors.primary,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Text(
                                  '$extraClasses',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontSize: 8.5,
                                    height: 1,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedDateSummary extends StatelessWidget {
  const _SelectedDateSummary({required this.day, required this.record});

  final DateTime day;
  final AttendanceRecord? record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _recordColor(record);
    final title = DateFormat('EEE, d MMM').format(day);
    final message = record == null
        ? 'Tap to mark attendance, extras or notes.'
        : record!.isPresent
        ? 'Present · ${record!.attendedClasses}/${record!.heldClasses} attended'
        : 'Absent · ${record!.missedClasses} missed';

    return AnimatedSwitcher(
      duration: ZyvoraMotion.regular,
      child: Container(
        key: ValueKey('${AttendanceRecord.dateKeyFor(day)}-${record?.id ?? 0}'),
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: color.withValues(alpha: record == null ? 0.06 : 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.14)),
        ),
        child: Row(
          children: [
            ZyvoraIconBadge(
              icon: record == null
                  ? Icons.touch_app_rounded
                  : record!.isPresent
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
              color: color,
              size: 38,
              iconSize: 19,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if ((record?.extraClasses ?? 0) > 0)
              ZyvoraPill(
                label: '+${record!.extraClasses}',
                color: ZyvoraColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _AttendanceTimeline extends StatelessWidget {
  const _AttendanceTimeline({required this.records});

  final List<AttendanceRecord> records;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recent = [...records]..sort((a, b) => b.date.compareTo(a.date));
    final items = recent.take(6).toList();

    return ZyvoraCard(
      padding: const EdgeInsets.all(16),
      shadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recent Activity',
                  style: theme.textTheme.titleLarge,
                ),
              ),
              ZyvoraPill(
                label: '${records.length} days',
                color: ZyvoraColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            _EmptyTimeline()
          else
            Column(
              children: [
                for (var i = 0; i < items.length; i++)
                  _TimelineRow(record: items[i], isLast: i == items.length - 1),
              ],
            ),
        ],
      ),
    );
  }
}

class _EmptyTimeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          const ZyvoraIconBadge(
            icon: Icons.timeline_rounded,
            color: ZyvoraColors.primary,
            size: 42,
            iconSize: 21,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your attendance timeline will appear as you mark dates.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.record, required this.isLast});

  final AttendanceRecord record;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _recordColor(record);
    final date = DateFormat('d MMM').format(record.date);
    final title = record.isPresent
        ? 'Attended ${record.subject} class'
        : 'Marked absent';
    final detail = record.extraClasses > 0
        ? 'Added ${record.extraClasses} extra class${record.extraClasses == 1 ? '' : 'es'}'
        : '${record.attendedClasses}/${record.heldClasses} attended';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: ZyvoraMotion.regular,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 8),
            child: child,
          ),
        );
      },
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 46,
              child: Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: color.withValues(alpha: 0.25)),
                    ),
                    child: Icon(
                      record.isPresent
                          ? Icons.check_rounded
                          : Icons.close_rounded,
                      color: color,
                      size: 18,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 1,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: color.withValues(alpha: 0.16),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.055),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: theme.textTheme.titleSmall),
                            const SizedBox(height: 2),
                            Text(
                              detail,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(date, style: theme.textTheme.labelMedium),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyAnalyticsCard extends StatelessWidget {
  const _MonthlyAnalyticsCard({
    required this.month,
    required this.stats,
    required this.recordsByDate,
  });

  final DateTime month;
  final MonthlyAttendanceStats stats;
  final Map<String, AttendanceRecord> recordsByDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ZyvoraCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Monthly Analytics',
                  style: theme.textTheme.titleLarge,
                ),
              ),
              ZyvoraPill(
                label: DateFormat('MMM yyyy').format(month),
                color: ZyvoraColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MonthlyInsightBanner(stats: stats),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 640;
              final metrics = _MonthlyMetricGrid(stats: stats);
              final trend = _TrendPanel(stats: stats);
              if (compact) {
                return Column(
                  children: [metrics, const SizedBox(height: 14), trend],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: metrics),
                  const SizedBox(width: 14),
                  Expanded(flex: 2, child: trend),
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Attendance Heatmap',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Text(
                'Intensity by held classes',
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AttendanceHeatmap(month: month, recordsByDate: recordsByDate),
        ],
      ),
    );
  }
}

class _MonthlyInsightBanner extends StatelessWidget {
  const _MonthlyInsightBanner({required this.stats});

  final MonthlyAttendanceStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = stats.presentPercentage >= 75
        ? ZyvoraColors.success
        : ZyvoraColors.warning;
    final message = stats.held == 0
        ? 'No classes marked this month yet.'
        : stats.presentPercentage >= 75
        ? 'This month is on track at ${stats.presentPercentage.round()}%.'
        : 'This month needs attention at ${stats.presentPercentage.round()}%.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          ZyvoraIconBadge(
            icon: stats.presentPercentage >= 75
                ? Icons.trending_up_rounded
                : Icons.insights_rounded,
            color: color,
            size: 40,
            iconSize: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyMetricGrid extends StatelessWidget {
  const _MonthlyMetricGrid({required this.stats});

  final MonthlyAttendanceStats stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MetricProgress(
          label: 'Present %',
          value: '${stats.presentPercentage.round()}%',
          progress: stats.presentPercentage / 100,
          color: ZyvoraColors.success,
        ),
        const SizedBox(height: 10),
        _MetricProgress(
          label: 'Absent %',
          value: '${stats.absentPercentage.round()}%',
          progress: stats.absentPercentage / 100,
          color: ZyvoraColors.error,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MiniCountTile(
                label: 'Extras',
                value: '${stats.extraClasses}',
                color: ZyvoraColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniCountTile(
                label: 'Held',
                value: '${stats.held}',
                color: ZyvoraColors.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricProgress extends StatelessWidget {
  const _MetricProgress({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });

  final String label;
  final String value;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: theme.textTheme.labelMedium)),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 9),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress.clamp(0, 1)),
            duration: ZyvoraMotion.regular,
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 7,
                  backgroundColor: color.withValues(alpha: 0.11),
                  color: color,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MiniCountTile extends StatelessWidget {
  const _MiniCountTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(color: color),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _TrendPanel extends StatelessWidget {
  const _TrendPanel({required this.stats});

  final MonthlyAttendanceStats stats;

  @override
  Widget build(BuildContext context) {
    final values = [...stats.records]..sort((a, b) => a.date.compareTo(b.date));
    return Container(
      height: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.55),
        ),
      ),
      child: CustomPaint(
        painter: _MonthlyTrendPainter(
          values: values
              .map((record) => record.attendedClasses / record.heldClasses)
              .toList(),
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(
            'Attendance trend',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      ),
    );
  }
}

class _MonthlyTrendPainter extends CustomPainter {
  const _MonthlyTrendPainter({required this.values});

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    final chartTop = 40.0;
    final chartHeight = size.height - chartTop;
    final gridPaint = Paint()
      ..color = ZyvoraColors.borderLight
      ..strokeWidth = 1;

    for (var i = 0; i <= 3; i++) {
      final y = chartTop + chartHeight * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (values.isEmpty) return;

    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? size.width / 2
          : size.width * i / (values.length - 1);
      final y = chartTop + chartHeight - values[i].clamp(0, 1) * chartHeight;
      points.add(Offset(x, y));
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = ZyvoraColors.primary
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    for (final point in points) {
      canvas.drawCircle(point, 4, Paint()..color = Colors.white);
      canvas.drawCircle(
        point,
        4,
        Paint()
          ..color = ZyvoraColors.primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MonthlyTrendPainter oldDelegate) {
    if (oldDelegate.values.length != values.length) return true;
    for (var i = 0; i < values.length; i++) {
      if (oldDelegate.values[i] != values[i]) return true;
    }
    return false;
  }
}

class _SubjectAttendanceVM {
  final SubjectAttendance stats;
  final Map<String, AttendanceRecord> recordsByDate;
  final MonthlyAttendanceStats monthlyStats;

  const _SubjectAttendanceVM({
    required this.stats,
    required this.recordsByDate,
    required this.monthlyStats,
  });

  factory _SubjectAttendanceVM.from(
    AttendanceController service,
    String subject,
    DateTime focusedDay,
  ) {
    final stats = service.getSubjectStats(subject);
    final recordsByDate = {
      for (final record in stats.records) record.dateKey: record,
    };
    return _SubjectAttendanceVM(
      stats: stats,
      recordsByDate: recordsByDate,
      monthlyStats: stats.monthlyStats(focusedDay),
    );
  }
}

class _AttendanceHeatmap extends StatelessWidget {
  const _AttendanceHeatmap({required this.month, required this.recordsByDate});

  final DateTime month;
  final Map<String, AttendanceRecord> recordsByDate;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final leadingCells = firstDay.weekday - 1;
    final totalCells = ((leadingCells + daysInMonth + 6) ~/ 7) * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 7,
        mainAxisSpacing: 7,
      ),
      itemBuilder: (context, index) {
        final dayNumber = index - leadingCells + 1;
        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return const SizedBox.shrink();
        }

        final day = DateTime(month.year, month.month, dayNumber);
        final record = recordsByDate[AttendanceRecord.dateKeyFor(day)];
        final color = _recordColor(record);
        final alpha = record == null
            ? 0.08
            : (0.16 + record.heldClasses.clamp(1, 9) * 0.045)
                  .clamp(0.16, 0.58)
                  .toDouble();

        final label = record == null
            ? '${DateFormat('d MMM').format(day)} · no class'
            : '${DateFormat('d MMM').format(day)} · ${record.attendedClasses}/${record.heldClasses} attended';

        return Tooltip(
          message: label,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                ScaffoldMessenger.of(context)
                  ..clearSnackBars()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(label),
                      duration: const Duration(milliseconds: 1400),
                    ),
                  );
              },
              child: AnimatedContainer(
                duration: ZyvoraMotion.fast,
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: alpha),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: color.withValues(
                      alpha: record == null ? 0.12 : 0.28,
                    ),
                  ),
                  boxShadow: record == null
                      ? null
                      : [
                          BoxShadow(
                            color: color.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AttendanceEntrySheet extends ConsumerStatefulWidget {
  const _AttendanceEntrySheet({
    required this.subject,
    required this.date,
    required this.existing,
  });

  final String subject;
  final DateTime date;
  final AttendanceRecord? existing;

  @override
  ConsumerState<_AttendanceEntrySheet> createState() =>
      _AttendanceEntrySheetState();
}

class _AttendanceEntrySheetState extends ConsumerState<_AttendanceEntrySheet> {
  late AttendanceStatus _status;
  late int _extraClasses;
  late int _extraAttended;
  late TextEditingController _noteController;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _status = existing?.status ?? AttendanceStatus.present;
    _extraClasses = existing?.extraClasses ?? 0;
    _extraAttended = existing?.extraAttended ?? 0;
    _noteController = TextEditingController(text: existing?.note ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = DateFormat('EEE, d MMM yyyy').format(widget.date);
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.subject,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 2),
                          Text(dateLabel, style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    if (widget.existing != null)
                      IconButton(
                        tooltip: 'Delete attendance entry',
                        onPressed: _busy ? null : _delete,
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: ZyvoraColors.error,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _StatusChoice(
                        title: 'Present',
                        icon: Icons.check_circle_rounded,
                        color: ZyvoraColors.success,
                        selected: _status == AttendanceStatus.present,
                        onTap: () => _setStatus(AttendanceStatus.present),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatusChoice(
                        title: 'Absent',
                        icon: Icons.cancel_rounded,
                        color: ZyvoraColors.error,
                        selected: _status == AttendanceStatus.absent,
                        onTap: () => _setStatus(AttendanceStatus.absent),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _CounterControl(
                  label:
                      'Extra classes · max ${AttendanceRecord.maxExtraClasses}',
                  value: _extraClasses,
                  color: ZyvoraColors.primary,
                  onDecrement: _busy
                      ? null
                      : () => _setExtraClasses(_extraClasses - 1),
                  onIncrement: _busy
                      ? null
                      : () => _setExtraClasses(_extraClasses + 1),
                ),
                if (_extraClasses > 0) ...[
                  const SizedBox(height: 10),
                  _CounterControl(
                    label: 'Extra attended',
                    value: _extraAttended,
                    color: ZyvoraColors.success,
                    onDecrement: _busy
                        ? null
                        : () => _setExtraAttended(_extraAttended - 1),
                    onIncrement: _busy
                        ? null
                        : () => _setExtraAttended(_extraAttended + 1),
                  ),
                ],
                const SizedBox(height: 12),
                _DayClassSummary(
                  status: _status,
                  extraClasses: _extraClasses,
                  extraAttended: _extraAttended,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _noteController,
                  enabled: !_busy,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Optional context',
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    if (widget.existing != null)
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: _busy ? null : _delete,
                            icon: const Icon(Icons.delete_outline_rounded),
                            label: const Text('Delete'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ZyvoraColors.error,
                            ),
                          ),
                        ),
                      ),
                    if (widget.existing != null) const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 50,
                        child: FilledButton.icon(
                          onPressed: _busy ? null : _save,
                          icon: _busy
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.done_rounded),
                          label: Text(
                            widget.existing == null ? 'Save entry' : 'Update',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _setStatus(AttendanceStatus status) {
    if (_busy || !mounted) return;
    setState(() {
      _status = status;
      _extraAttended = status == AttendanceStatus.present ? _extraClasses : 0;
    });
  }

  void _setExtraClasses(int value) {
    if (!mounted) return;
    final next = value.clamp(0, AttendanceRecord.maxExtraClasses).toInt();
    setState(() {
      final hadAllExtras = _extraAttended == _extraClasses;
      _extraClasses = next;
      if (_status == AttendanceStatus.present && hadAllExtras) {
        _extraAttended = next;
      } else {
        _extraAttended = _extraAttended.clamp(0, next).toInt();
      }
    });
  }

  void _setExtraAttended(int value) {
    if (!mounted) return;
    setState(() {
      _extraAttended = value.clamp(0, _extraClasses).toInt();
    });
  }

  Future<void> _save() async {
    if (_busy || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(attendanceControllerProvider).saveAttendanceEntry(
        subject: widget.subject,
        date: widget.date,
        status: _status,
        extraClasses: _extraClasses,
        extraAttended: _extraAttended,
        note: _noteController.text,
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ZyvoraErrorHandler.showError(
        context,
        title: 'Failed to save attendance',
        message: ZyvoraErrorHandler.formatErrorMessage(e),
      );
    }
  }

  Future<void> _delete() async {
    if (_busy || widget.existing == null || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(attendanceControllerProvider).deleteAttendanceForDate(
        subject: widget.subject,
        date: widget.date,
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ZyvoraErrorHandler.showError(
        context,
        title: 'Failed to delete attendance',
        message: ZyvoraErrorHandler.formatErrorMessage(e),
      );
    }
  }
}

class _DayClassSummary extends StatelessWidget {
  const _DayClassSummary({
    required this.status,
    required this.extraClasses,
    required this.extraAttended,
  });

  final AttendanceStatus status;
  final int extraClasses;
  final int extraAttended;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final regularAttended = status == AttendanceStatus.present ? 1 : 0;
    final held = 1 + extraClasses;
    final attended = regularAttended + extraAttended;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: ZyvoraColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ZyvoraColors.primary.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          const ZyvoraIconBadge(
            icon: Icons.auto_graph_rounded,
            color: ZyvoraColors.primary,
            size: 38,
            iconSize: 19,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This date counts as $attended/$held attended',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall,
            ),
          ),
          if (extraClasses > 0)
            ZyvoraPill(
              label: '+$extraClasses extra',
              color: ZyvoraColors.primary,
            ),
        ],
      ),
    );
  }
}

class _StatusChoice extends StatelessWidget {
  const _StatusChoice({
    required this.title,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: ZyvoraMotion.fast,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.12)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? color.withValues(alpha: 0.5)
                  : theme.colorScheme.outline.withValues(alpha: 0.55),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              if (selected) Icon(Icons.done_rounded, color: color, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _CounterControl extends StatelessWidget {
  const _CounterControl({
    required this.label,
    required this.value,
    required this.color,
    required this.onDecrement,
    required this.onIncrement,
  });

  final String label;
  final int value;
  final Color color;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall,
            ),
          ),
          IconButton.filledTonal(
            tooltip: 'Decrease',
            onPressed: onDecrement,
            icon: const Icon(Icons.remove_rounded),
          ),
          SizedBox(
            width: 48,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(color: color),
            ),
          ),
          IconButton.filled(
            tooltip: 'Increase',
            onPressed: onIncrement,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

Color _attendanceColor(double percentage) {
  if (percentage == 0) return ZyvoraColors.primary;
  if (percentage < 75) return ZyvoraColors.warning;
  return ZyvoraColors.success;
}

Color _recordColor(AttendanceRecord? record) {
  if (record == null) return ZyvoraColors.textTertiary;
  if (record.extraClasses > 0) return ZyvoraColors.primary;
  return record.isPresent ? ZyvoraColors.success : ZyvoraColors.error;
}
