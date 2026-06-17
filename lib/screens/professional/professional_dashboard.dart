import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/insight.dart';
import '../../models/reminder.dart';
import '../../models/zyvora_role.dart';
import '../../data/services/intelligence_engine.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/add_reminder_sheet.dart';
import '../../widgets/countdown_card.dart';
import '../../widgets/insight_card.dart';
import '../../widgets/premium_dashboard_header.dart';
import '../../widgets/productivity_ring.dart';
import '../../widgets/quick_action_strip.dart';
import '../../widgets/smart_summary_card.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/today_timeline.dart';

import '../../core/providers.dart';

class ProfessionalDashboard extends ConsumerStatefulWidget {
  const ProfessionalDashboard({super.key});
  @override
  ConsumerState<ProfessionalDashboard> createState() =>
      _ProfessionalDashboardState();
}

class _ProfessionalDashboardState extends ConsumerState<ProfessionalDashboard> {
  List<Insight> _insights = [];
  int _insightsLoadVersion = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      _loadInsights();
      final att = ref.read(attendanceControllerProvider);
      att.loadSubjects();
      att.loadRecords();
    });
  }

  Future<void> _loadInsights() async {
    if (!mounted) return;
    final version = ++_insightsLoadVersion;
    try {
      final ctrl = ref.read(reminderControllerProvider);
      final engine = IntelligenceEngine(db: ref.read(databaseProvider));
      final insights = await engine.generateInsights(ctrl.reminders);
      if (mounted && version == _insightsLoadVersion) {
        setState(() => _insights = insights);
      }
    } catch (_) {}
  }

  Future<void> _addReminder(BuildContext context) async {
    final reminderCtrl = ref.read(reminderControllerProvider);
    final userCtrl = ref.read(userControllerProvider);
    final result = await showModalBottomSheet<AddReminderResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddReminderSheet(
        lifeMode: 'professional',
        role: userCtrl.role,
        defaultDay: userCtrl.todayName,
      ),
    );
    if (result == null) return;
    if (!context.mounted) return;
    try {
      await reminderCtrl.addReminder(
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
      if (!mounted) return;
      await _loadInsights();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save reminder: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _HomeTab(
      insights: _insights,
      onRefresh: _loadInsights,
      onAddReminder: () => _addReminder(context),
      timersActive: true,
    );
  }
}

class _HomeTab extends ConsumerWidget {
  final List<Insight> insights;
  final VoidCallback onRefresh;
  final VoidCallback onAddReminder;
  final bool timersActive;

  const _HomeTab({
    required this.insights,
    required this.onRefresh,
    required this.onAddReminder,
    required this.timersActive,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.watch(reminderControllerProvider);
    final att = ref.watch(attendanceControllerProvider);
    final user = ref.watch(userControllerProvider);
    final theme = Theme.of(context);
    final role = user.role ?? ZyvoraRole.student;
    final todayItems = ctrl.remindersForDay(ctrl.todayName);
    final nextReminder = ctrl.nextReminderForToday();
    final upcoming = ctrl.activeReminders.where((r) => !r.isCompleted).length;

    final roleQuick = _roleQuickAction(role);

    return Scaffold(
      appBar: AppBar(
        title: Text('${role.label} · Home'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: ZyvoraColors.accentBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(ZyvoraRadius.md),
            ),
            child: Text(
              role.label,
              style: const TextStyle(
                color: ZyvoraColors.accentBlue,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () => context.go('/app/profile'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onAddReminder,
        child: const Icon(Icons.add_rounded),
      ),
      body: RefreshIndicator(
        onRefresh: () async => onRefresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
          children: [
            PremiumDashboardHeader(
              greeting: user.greeting,
              userName: user.userName,
              onProfileTap: () => context.go('/app/profile'),
            ),
            const SizedBox(height: 14),
            SmartSummaryCard(
              todayTasks: ctrl.todayTotalCount,
              upcomingCount: upcoming,
              productivity: ctrl.todayProductivity,
              attendancePercent: att.subjects.isEmpty
                  ? null
                  : att.overallPercentage,
              showAttendanceSlot: true,
            ),
            const SizedBox(height: 22),
            Text('Quick actions', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            QuickActionStrip(
              actions: [
                (
                  icon: Icons.add_alert_rounded,
                  label: 'Reminder',
                  onTap: onAddReminder,
                  accent: ZyvoraColors.accentBlue,
                ),
                (
                  icon: Icons.fact_check_outlined,
                  label: 'Attendance',
                  onTap: () => context.go('/app/attendance'),
                  accent: ZyvoraColors.success,
                ),
                (
                  icon: roleQuick.$1,
                  label: roleQuick.$2,
                  onTap: () => _quickAdd(context, ref, roleQuick.$3),
                  accent: roleQuick.$4,
                ),
                (
                  icon: Icons.auto_awesome_outlined,
                  label: 'AI tips',
                  onTap: () => _showAiSheet(context, insights),
                  accent: ZyvoraColors.accentPurple,
                ),
              ],
            ),
            const SizedBox(height: 28),
            CountdownCard(nextReminder: nextReminder, active: timersActive),
            if (nextReminder != null && timersActive)
              const SizedBox(height: 20),
            Row(
              children: [
                Text("Today's timeline", style: theme.textTheme.titleMedium),
                const Spacer(),
                ProductivityRing(percentage: ctrl.todayProductivity, size: 48),
              ],
            ),
            const SizedBox(height: 14),
            if (todayItems.isEmpty)
              _buildEmpty(theme, 'No tasks for today')
            else
              TodayTimeline(
                items: todayItems,
                onToggle: (id) => ctrl.toggleReminderComplete(id),
                onEdit: (r) => _editReminder(context, ref, r),
                onDelete: (id) => ctrl.deleteReminder(id),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.notifications_active_outlined,
                    value: '${ctrl.totalReminderCount}',
                    label: 'Reminders',
                    color: ZyvoraColors.accentBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.local_fire_department_outlined,
                    value: '${ctrl.currentStreak}',
                    label: 'Streak',
                    color: ZyvoraColors.error,
                  ),
                ),
              ],
            ),
            if (insights.isNotEmpty) ...[
              const SizedBox(height: 28),
              Text('Smart suggestions', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              ...insights
                  .take(3)
                  .map(
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InsightCard(insight: i),
                    ),
                  ),
            ],
            const SizedBox(height: 28),
            Text('This week', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            ...ZyvoraDays.ordered.map((day) {
              final items = ctrl.remindersForDay(day);
              final isToday = day == ctrl.todayName;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(ZyvoraRadius.md),
                  border: Border.all(
                    color: isToday
                        ? ZyvoraColors.accentBlue
                        : theme.colorScheme.outline.withValues(alpha: 0.4),
                    width: isToday ? 1.4 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 44,
                      child: Text(
                        ZyvoraDays.shortName(day),
                        style: TextStyle(
                          fontWeight: isToday
                              ? FontWeight.w800
                              : FontWeight.w500,
                          color: isToday ? ZyvoraColors.accentBlue : null,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        items.isEmpty
                            ? 'Free'
                            : '${items.length} task${items.length > 1 ? 's' : ''}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    if (isToday)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: ZyvoraColors.accentBlue.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(ZyvoraRadius.sm),
                        ),
                        child: const Text(
                          'Today',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: ZyvoraColors.accentBlue,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  (IconData, String, String, Color) _roleQuickAction(ZyvoraRole role) {
    switch (role) {
      case ZyvoraRole.student:
        return (
          Icons.school_outlined,
          'Class',
          'Class',
          ZyvoraColors.accentBlue,
        );
      case ZyvoraRole.employee:
        return (
          Icons.groups_outlined,
          'Meet',
          'Meeting',
          ZyvoraColors.accentPurple,
        );
      case ZyvoraRole.teacher:
        return (Icons.school_outlined, 'Class', 'Class', ZyvoraColors.success);
      case ZyvoraRole.freelancer:
        return (
          Icons.handshake_outlined,
          'Client',
          'Client Meeting',
          ZyvoraColors.accentPurple,
        );
    }
  }

  Future<void> _quickAdd(BuildContext context, WidgetRef ref, String category) async {
    final ctrl = ref.read(reminderControllerProvider);
    final user = ref.read(userControllerProvider);
    final result = await showModalBottomSheet<AddReminderResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddReminderSheet(
        lifeMode: 'professional',
        role: user.role,
        defaultDay: user.todayName,
        defaultCategory: category,
      ),
    );
    if (result == null) return;
    try {
      await ctrl.addReminder(
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
      onRefresh();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save reminder: $e')));
    }
  }

  void _showAiSheet(BuildContext context, List<Insight> insights) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ZyvoraRadius.hero),
        ),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
            child: insights.isEmpty
                ? Text(
                    'Complete tasks to see attendance risk and timing tips.',
                    style: Theme.of(ctx).textTheme.bodyLarge,
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Suggestions',
                        style: Theme.of(ctx).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      ...insights
                          .take(3)
                          .map(
                            (i) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: InsightCard(insight: i),
                            ),
                          ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Future<void> _editReminder(BuildContext context, WidgetRef ref, Reminder r) async {
    final ctrl = ref.read(reminderControllerProvider);
    final user = ref.read(userControllerProvider);
    final result = await showModalBottomSheet<AddReminderResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddReminderSheet(
        lifeMode: 'professional',
        role: user.role,
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
      await ctrl.editReminder(
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
      onRefresh();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not update reminder: $e')));
    }
  }

  Widget _buildEmpty(ThemeData theme, String msg) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(ZyvoraRadius.md),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 40,
            color: ZyvoraColors.success,
          ),
          const SizedBox(height: 8),
          Text(msg, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
