import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/error_handler.dart';
import '../models/attendance_record.dart';
import '../widgets/zyvora_ui.dart';
import '../features/attendance/controllers/attendance_controller.dart';
import 'subject_attendance_detail_screen.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!mounted) return;
      final svc = ref.read(attendanceControllerProvider);
      await svc.loadSubjects();
      await svc.loadRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Builder(
          builder: (context) {
            final svc = ref.watch(attendanceControllerProvider);
            final vm = _AttendanceVM.from(svc);
            return RefreshIndicator(
              onRefresh: () async {
                final ctrl = ref.read(attendanceControllerProvider);
                await ctrl.loadSubjects();
                await ctrl.loadRecords();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 126),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Attendance',
                              style: theme.textTheme.headlineLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Track, analyze and improve consistency',
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                      ZyvoraHeaderButton(
                        icon: Icons.add_rounded,
                        tooltip: 'Add subject',
                        onTap: () => _addSubject(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  ZyvoraCard(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: ZyvoraProgressRing(
                        value: vm.percent / 100,
                        size: 120,
                        stroke: 13,
                        color: vm.percent >= 75
                            ? ZyvoraColors.primary
                            : ZyvoraColors.warning,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.school_rounded,
                              color: ZyvoraColors.primary,
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${vm.percent.round()}%',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: ZyvoraColors.primary,
                              ),
                            ),
                            Text(
                              'Overall',
                              style: theme.textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _StatsGrid(
                    totalClasses: vm.totalClasses,
                    attended: vm.attended,
                    missed: vm.missed,
                    bunkable: vm.bunkable,
                  ),
                  const SizedBox(height: 24),
                  ZyvoraSectionHeader(
                    title: 'Subjects',
                    actionLabel: 'Manage Subjects',
                    onAction: () => _addSubject(context),
                  ),
                  if (vm.stats.isEmpty)
                    ZyvoraEmptyState(
                      icon: Icons.school_outlined,
                      title: 'No subjects yet',
                      message:
                          'Add a subject, then open its calendar to mark any date.',
                      action: FilledButton.icon(
                        onPressed: () => _addSubject(context),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add subject'),
                      ),
                    )
                  else
                    ZyvoraCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          ...vm.stats.asMap().entries.map((entry) {
                            final isLast = entry.key == vm.stats.length - 1;
                            return _SubjectRow(
                              stats: entry.value,
                              index: entry.key,
                              showDivider: !isLast,
                              onTap: () => _openSubjectDetails(
                                context,
                                entry.value.subject,
                              ),
                              onDelete: () =>
                                  _removeSubject(context, entry.value.subject),
                            );
                          }),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _addSubject(context),
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(ZyvoraRadius.xl),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    ZyvoraIconBadge(
                                      icon: Icons.add_rounded,
                                      color: ZyvoraColors.primary,
                                      size: 36,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Add New Subject',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                        color: ZyvoraColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (vm.stats.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _TrendCard(stats: vm.stats),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _addSubject(BuildContext context) async {
    final ctrl = TextEditingController();
    try {
      final name = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Add Subject'),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            maxLength: 100,
            decoration: const InputDecoration(
              hintText: 'Subject name',
              helperText: 'Example: Mathematics, Physics',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: const Text('Add'),
            ),
          ],
        ),
      );

      if (!context.mounted) return;
      final trimmed = name?.trim() ?? '';
      if (trimmed.isEmpty) return;

      try {
        await ref.read(attendanceControllerProvider).addSubject(trimmed);
        if (!context.mounted) return;
        ZyvoraErrorHandler.showSuccess(
          context,
          message: 'Subject added successfully',
        );
      } catch (e) {
        if (!context.mounted) return;
        ZyvoraErrorHandler.showError(
          context,
          title: 'Failed to add subject',
          message: ZyvoraErrorHandler.formatErrorMessage(e),
        );
      }
    } finally {
      ctrl.dispose();
    }
  }

  Future<void> _removeSubject(BuildContext context, String subject) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove $subject?'),
        content: const Text(
          'This removes the subject and its attendance records.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (!context.mounted || confirmed != true) return;

    try {
      await ref.read(attendanceControllerProvider).removeSubject(subject);
      if (!context.mounted) return;
      ZyvoraErrorHandler.showSuccess(context, message: 'Subject removed');
    } catch (e) {
      if (!context.mounted) return;
      ZyvoraErrorHandler.showError(
        context,
        title: 'Failed to remove subject',
        message: ZyvoraErrorHandler.formatErrorMessage(e),
      );
    }
  }

  void _openSubjectDetails(BuildContext context, String subject) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SubjectAttendanceDetailScreen(subject: subject),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.totalClasses,
    required this.attended,
    required this.missed,
    required this.bunkable,
  });

  final int totalClasses;
  final int attended;
  final int missed;
  final int bunkable;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = ((constraints.maxWidth - 10) / 2).clamp(120.0, 520.0);
        final ratio = tileWidth / 84;
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: ratio,
          children: [
            _MiniStat(
              label: 'Classes Held',
              value: '$totalClasses',
              icon: Icons.event_note_rounded,
              color: ZyvoraColors.secondary,
            ),
            _MiniStat(
              label: 'Attended',
              value: '$attended',
              icon: Icons.check_circle_rounded,
              color: ZyvoraColors.success,
            ),
            _MiniStat(
              label: 'Missed',
              value: '$missed',
              icon: Icons.cancel_rounded,
              color: ZyvoraColors.error,
            ),
            _MiniStat(
              label: 'Bunkable',
              value: '$bunkable',
              icon: Icons.person_off_rounded,
              color: ZyvoraColors.primary,
            ),
          ],
        );
      },
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
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
          ),
        ],
      ),
    );
  }
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({
    required this.stats,
    required this.index,
    required this.showDivider,
    required this.onTap,
    required this.onDelete,
  });

  final SubjectAttendance stats;
  final int index;
  final bool showDivider;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _subjectColor(index, stats.percentage);
    final pct = stats.percentage;
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ZyvoraIconBadge(
                    icon: _subjectIcon(index),
                    color: color,
                    size: 56,
                    iconSize: 27,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stats.subject,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(99),
                                child: LinearProgressIndicator(
                                  value: (pct / 100).clamp(0, 1),
                                  minHeight: 7,
                                  backgroundColor: color.withValues(
                                    alpha: 0.12,
                                  ),
                                  color: color,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${stats.present}/${stats.total}',
                              style: theme.textTheme.labelMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ZyvoraPill(label: '${pct.round()}%', color: color),
                  PopupMenuButton<String>(
                    tooltip: 'Subject actions',
                    icon: const Icon(Icons.more_vert_rounded),
                    onSelected: (value) {
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'delete', child: Text('Remove')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 86,
            color: theme.colorScheme.outline.withValues(alpha: 0.6),
          ),
      ],
    );
  }

  Color _subjectColor(int index, double pct) {
    if (pct > 0 && pct < 75) return ZyvoraColors.warning;
    const colors = [
      ZyvoraColors.primary,
      ZyvoraColors.success,
      ZyvoraColors.warning,
      ZyvoraColors.secondary,
      Color(0xFFEC4899),
    ];
    return colors[index % colors.length];
  }

  IconData _subjectIcon(int index) {
    const icons = [
      Icons.functions_rounded,
      Icons.science_rounded,
      Icons.biotech_rounded,
      Icons.code_rounded,
      Icons.language_rounded,
    ];
    return icons[index % icons.length];
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.stats});

  final List<SubjectAttendance> stats;

  @override
  Widget build(BuildContext context) {
    final values = stats.map((s) => s.percentage).toList();
    return ZyvoraCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Attendance Trend',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ZyvoraPill(
                label: 'This Month',
                color: ZyvoraColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 132,
            child: CustomPaint(
              painter: _TrendPainter(values: values),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceVM {
  final List<SubjectAttendance> stats;
  final int totalClasses;
  final int attended;
  final int missed;
  final int bunkable;
  final double percent;

  const _AttendanceVM({
    required this.stats,
    required this.totalClasses,
    required this.attended,
    required this.missed,
    required this.bunkable,
    required this.percent,
  });

  factory _AttendanceVM.from(AttendanceController svc) {
    final stats = svc.getAllStats();
    final totalClasses = stats.fold<int>(0, (sum, s) => sum + s.total);
    final attended = stats.fold<int>(0, (sum, s) => sum + s.present);
    final missed = totalClasses - attended;
    final bunkable =
        stats.fold<int>(0, (sum, s) => sum + s.bunkableClasses());

    return _AttendanceVM(
      stats: stats,
      totalClasses: totalClasses,
      attended: attended,
      missed: missed,
      bunkable: bunkable,
      percent: svc.overallPercentage,
    );
  }
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter({required this.values});

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = ZyvoraColors.borderLight
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (values.isEmpty) return;
    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? size.width / 2
          : size.width * i / (values.length - 1);
      final y = size.height - (values[i].clamp(0, 100) / 100 * size.height);
      points.add(Offset(x, y));
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }

    final fill = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()..color = ZyvoraColors.primary.withValues(alpha: 0.08),
    );
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
  bool shouldRepaint(covariant _TrendPainter oldDelegate) {
    if (oldDelegate.values.length != values.length) return true;
    for (var i = 0; i < values.length; i++) {
      if (oldDelegate.values[i] != values[i]) return true;
    }
    return false;
  }
}
