import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/insight.dart';
import '../../models/reminder.dart';
import '../../data/services/intelligence_engine.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/add_reminder_sheet.dart';
import '../../widgets/insight_card.dart';
import '../../widgets/premium_dashboard_header.dart';
import '../../widgets/productivity_ring.dart';
import '../../widgets/quick_action_strip.dart';
import '../../widgets/smart_summary_card.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/today_timeline.dart';
import '../../widgets/week_summary_card.dart';

import '../../core/providers.dart';
import '../../features/tasks/controllers/reminder_controller.dart';

class PersonalDashboard extends ConsumerStatefulWidget {
  const PersonalDashboard({super.key});
  @override
  ConsumerState<PersonalDashboard> createState() => _PersonalDashboardState();
}

class _PersonalDashboardState extends ConsumerState<PersonalDashboard> {
  List<Insight> _insights = [];
  int _insightsLoadVersion = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadInsights);
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

  Future<void> _addReminder(BuildContext context, {String? category}) async {
    final ctrl = ref.read(reminderControllerProvider);
    final result = await showModalBottomSheet<AddReminderResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddReminderSheet(
        lifeMode: 'personal',
        defaultDay: ctrl.todayName,
        defaultCategory: category,
      ),
    );
    if (result == null) return;
    if (!context.mounted) return;
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
      onAddReminder: (c) => _addReminder(context, category: c),
    );
  }
}

class _HomeTab extends ConsumerWidget {
  final List<Insight> insights;
  final VoidCallback onRefresh;
  final void Function(String?) onAddReminder;
  const _HomeTab({
    required this.insights,
    required this.onRefresh,
    required this.onAddReminder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.watch(reminderControllerProvider);
    final user = ref.watch(userControllerProvider);
    final theme = Theme.of(context);
    final todayItems = ctrl.todayReminders;
    final upcoming = ctrl.activeReminders.where((r) => !r.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zyvora'),
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () => context.go('/app/profile'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => onAddReminder(null),
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
              showAttendanceSlot: false,
            ),
            const SizedBox(height: 22),
            Text('Quick actions', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            QuickActionStrip(
              actions: [
                (
                  icon: Icons.add_alert_rounded,
                  label: 'Reminder',
                  onTap: () => onAddReminder(null),
                  accent: ZyvoraColors.accentBlue,
                ),
                (
                  icon: Icons.fact_check_outlined,
                  label: 'Attendance',
                  onTap: () => context.go('/app/attendance'),
                  accent: ZyvoraColors.success,
                ),
                (
                  icon: Icons.self_improvement,
                  label: 'Routine',
                  onTap: () => onAddReminder('Habit'),
                  accent: ZyvoraColors.accentPurple,
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
            Row(
              children: [
                Text("Today's timeline", style: theme.textTheme.titleMedium),
                const Spacer(),
                ProductivityRing(percentage: ctrl.todayProductivity, size: 48),
              ],
            ),
            const SizedBox(height: 14),
            if (todayItems.isEmpty)
              _EmptyState(
                message: 'No reminders for today',
                icon: Icons.check_circle_outline,
              )
            else
              TodayTimeline(
                items: todayItems,
                onToggle: (id) => ctrl.toggleReminderComplete(id),
                onEdit: (r) => _editReminder(context, r, ctrl),
                onDelete: (id) => ctrl.deleteReminder(id),
              ),
            const SizedBox(height: 24),
            Text('Overview', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
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
                  .take(4)
                  .map(
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InsightCard(insight: i),
                    ),
                  ),
            ],
            const SizedBox(height: 28),
              WeekSummaryCard(stats: ctrl.weekCompletionStats),
          ],
        ),
      ),
    );
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
                    'Complete a few tasks to unlock personalized suggestions.',
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

  Future<void> _editReminder(
    BuildContext context,
    Reminder r,
    ReminderController ctrl,
  ) async {
    final result = await showModalBottomSheet<AddReminderResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddReminderSheet(
        lifeMode: 'personal',
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
}

class _EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  const _EmptyState({required this.message, required this.icon});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          Icon(icon, size: 40, color: ZyvoraColors.success),
          const SizedBox(height: 8),
          Text(message, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
