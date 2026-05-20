import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/design_tokens.dart';
import '../core/providers.dart';
import '../core/theme/app_theme.dart';
import '../features/profile/controllers/user_controller.dart';
import '../features/tasks/controllers/reminder_controller.dart';
import '../models/insight.dart';
import '../models/reminder.dart';
import '../models/zyvora_role.dart';
import '../utils/time_utils.dart';
import '../widgets/add_reminder_sheet.dart';
import '../widgets/animated_segmented_switch.dart';
import '../widgets/nl_quick_add.dart';
import '../widgets/today_timeline.dart';

// ─── Palette constants (dark-first, pulled from design spec) ───────────────
const _kBg = Color(0xFF0D0D0D);
const _kCard = Color(0xFF161616);
const _kBorder = Color(0xFF252525);
const _kAccentStart = Color(0xFF7B61FF); // soft purple
const _kAccentEnd = Color(0xFF5B8CFF);   // soft blue
const _kTextPrimary = Color(0xFFF5F5F7);
const _kTextSecondary = Color(0xFF8A8A8E);
const _kTextMuted = Color(0xFF555558);

// ─── Entry point ──────────────────────────────────────────────────────────

class PremiumHomeDashboard extends ConsumerStatefulWidget {
  const PremiumHomeDashboard({super.key});

  @override
  ConsumerState<PremiumHomeDashboard> createState() =>
      _PremiumHomeDashboardState();
}

class _PremiumHomeDashboardState extends ConsumerState<PremiumHomeDashboard>
    with AutomaticKeepAliveClientMixin {
  int _insightLoadVersion = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final attendance = ref.read(attendanceControllerProvider);
      attendance.loadSubjects();
      attendance.loadRecords();
      _loadInsights();
    });
  }

  Future<void> _refresh() async {
    final attendance = ref.read(attendanceControllerProvider);
    await attendance.loadSubjects();
    await attendance.loadRecords();
    await _loadInsights();
  }

  Future<void> _loadInsights() async {
    if (!mounted) return;
    final version = ++_insightLoadVersion;
    try {
      final reminders = ref.read(reminderControllerProvider);
      final analytics = ref.read(analyticsControllerProvider);
      await analytics.loadInsights(reminders.reminders);
      if (!mounted || version != _insightLoadVersion) return;
      setState(() {});
    } catch (e) {
      debugPrint('Could not load insights: $e');
    }
  }

  Future<void> _addReminder(
    BuildContext context, {
    String? defaultCategory,
    String? forcedMode,
  }) async {
    final user = ref.read(userControllerProvider);
    final reminders = ref.read(reminderControllerProvider);
    final mode = forcedMode ?? user.lifeMode?.storageValue ?? 'personal';
    final isPersonal = mode == 'personal';
    final result = await showModalBottomSheet<AddReminderResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddReminderSheet(
        lifeMode: mode,
        role: isPersonal ? null : (user.role ?? ZyvoraRole.student),
        defaultDay: user.todayName,
        defaultCategory: defaultCategory,
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
      if (!mounted) return;
      await _loadInsights();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not save: $e')));
    }
  }

  Future<void> _editReminder(BuildContext context, Reminder reminder) async {
    final user = ref.read(userControllerProvider);
    final reminders = ref.read(reminderControllerProvider);
    final isPersonal = reminder.lifeMode == 'personal';
    final result = await showModalBottomSheet<AddReminderResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddReminderSheet(
        lifeMode: reminder.lifeMode,
        role: isPersonal ? null : (user.role ?? ZyvoraRole.student),
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
      await reminders.editReminder(
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
      if (!mounted) return;
      await _loadInsights();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not update: $e')));
    }
  }

  Future<void> _toggleReminder(BuildContext context, int id) async {
    final reminders = ref.read(reminderControllerProvider);
    try {
      await reminders.toggleReminderComplete(id);
      await _loadInsights();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not update: $e')));
    }
  }

  Future<void> _deleteReminder(BuildContext context, int id) async {
    final reminders = ref.read(reminderControllerProvider);
    try {
      await reminders.deleteReminder(id);
      await _loadInsights();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not delete: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final reminderCtrl = ref.watch(reminderControllerProvider);
    final userCtrl = ref.watch(userControllerProvider);
    final analyticsCtrl = ref.watch(analyticsControllerProvider);

    final vm = _DashboardVM.from(reminderCtrl, userCtrl);
    final insight =
        analyticsCtrl.insights.isNotEmpty ? analyticsCtrl.insights.first : null;

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: _kAccentStart,
          backgroundColor: _kCard,
          child: _HomeContent(
            vm: vm,
            insight: insight,
            insightLoading: analyticsCtrl.isLoading,
            onAddReminder: () => _addReminder(
              context,
              forcedMode: vm.lifeMode?.storageValue,
            ),
            onEditReminder: (r) => _editReminder(context, r),
            onToggleReminder: (id) => _toggleReminder(context, id),
            onDeleteReminder: (id) => _deleteReminder(context, id),
            onViewAllTasks: () => context.go('/app/tasks'),
            onFocusCardTap: () {
              if (vm.nextReminder != null) {
                _editReminder(context, vm.nextReminder!);
              } else {
                _addReminder(context);
              }
            },
            onCompleteFocus: (id) => _toggleReminder(context, id),
          ),
        ),
      ),
      floatingActionButton: _MinimalFAB(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => NLQuickAddSheet(onAdded: _loadInsights),
        ),
      ),
    );
  }
}

// ─── ViewModel ───────────────────────────────────────────────────────────

class _DashboardVM {
  final String greeting;
  final String userName;
  final int pendingToday;
  final double todayProductivity;
  final List<Reminder> todayItems;
  final Reminder? nextReminder;
  final LifeMode? lifeMode;

  const _DashboardVM({
    required this.greeting,
    required this.userName,
    required this.pendingToday,
    required this.todayProductivity,
    required this.todayItems,
    required this.nextReminder,
    required this.lifeMode,
  });

  factory _DashboardVM.from(
      ReminderController reminders, UserController user) {
    final todayItems = reminders.todayReminders;
    final pendingToday = todayItems.where((r) => !r.isCompleted).length;
    return _DashboardVM(
      greeting: user.greeting,
      userName: user.userName,
      pendingToday: pendingToday,
      todayProductivity: reminders.todayProductivity,
      todayItems: todayItems,
      nextReminder: reminders.nextReminderForToday(),
      lifeMode: user.lifeMode,
    );
  }
}

// ─── Main scrollable content ─────────────────────────────────────────────

class _HomeContent extends StatefulWidget {
  final _DashboardVM vm;
  final Insight? insight;
  final bool insightLoading;
  final VoidCallback onAddReminder;
  final Function(Reminder) onEditReminder;
  final Function(int) onToggleReminder;
  final Function(int) onDeleteReminder;
  final VoidCallback onViewAllTasks;
  final VoidCallback onFocusCardTap;
  final Function(int) onCompleteFocus;

  const _HomeContent({
    required this.vm,
    required this.insight,
    required this.insightLoading,
    required this.onAddReminder,
    required this.onEditReminder,
    required this.onToggleReminder,
    required this.onDeleteReminder,
    required this.onViewAllTasks,
    required this.onFocusCardTap,
    required this.onCompleteFocus,
  });

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceCtrl;
  late List<Animation<double>> _itemFades;
  late List<Animation<Offset>> _itemSlides;

  static const _sectionCount = 5;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _itemFades = List.generate(_sectionCount, (i) {
      final start = i * 0.12;
      final end = (start + 0.55).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _itemSlides = List.generate(_sectionCount, (i) {
      final start = i * 0.12;
      final end = (start + 0.55).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
          .animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  Widget _animated(int index, Widget child) {
    return FadeTransition(
      opacity: _itemFades[index],
      child: SlideTransition(position: _itemSlides[index], child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(DT.s24, DT.s32, DT.s24, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ── 1. GREETING HEADER ───────────────────────────
              _animated(0, _GreetingHeader(vm: vm)),
              const SizedBox(height: DT.s32),

              // ── 2. LIFE MODE SWITCH ──────────────────────────
              _animated(
                1,
                const _LifeModeSwitch(),
              ),
              const SizedBox(height: DT.s32),

              // ── 3. PRIMARY FOCUS CARD ────────────────────────
              _animated(
                2,
                _PrimaryFocusCard(
                  reminder: vm.nextReminder,
                  onTap: widget.onFocusCardTap,
                  onComplete: widget.onCompleteFocus,
                ),
              ),
              const SizedBox(height: DT.s32),

              // ── 4. TODAY TIMELINE ────────────────────────────
              _animated(
                3,
                _TimelineSection(
                  vm: vm,
                  onAddReminder: widget.onAddReminder,
                  onEdit: widget.onEditReminder,
                  onToggle: widget.onToggleReminder,
                  onDelete: widget.onDeleteReminder,
                  onViewAll: widget.onViewAllTasks,
                ),
              ),
              const SizedBox(height: DT.s32),

              // ── 5. SMART INSIGHT CARD ────────────────────────
              _animated(
                4,
                _SmartInsightCard(
                  loading: widget.insightLoading,
                  insight: widget.insight,
                  onAction: widget.onViewAllTasks,
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 1 — GREETING HEADER
// ═══════════════════════════════════════════════════════════════════════════

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.vm});
  final _DashboardVM vm;

  @override
  Widget build(BuildContext context) {
    final score = vm.todayProductivity.round();
    final productivityColor = _productivityColor(vm.todayProductivity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting label
        Text(
          vm.greeting.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.6,
            color: _kTextMuted,
          ),
        ),
        const SizedBox(height: DT.s8),

        // Name — large, heavy
        Text(
          vm.userName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 32,
            fontWeight: FontWeight.w800,
            height: 1.05,
            color: _kTextPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: DT.s12),

        // Stats row
        Row(
          children: [
            _HeaderStatChip(
              icon: Icons.radio_button_unchecked_rounded,
              label: vm.pendingToday == 0
                  ? 'All done'
                  : '${vm.pendingToday} remaining',
              color: vm.pendingToday == 0
                  ? ZyvoraColors.success
                  : _kTextSecondary,
            ),
            const SizedBox(width: DT.s12),
            _HeaderStatChip(
              icon: Icons.show_chart_rounded,
              label: '$score% done',
              color: productivityColor,
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderStatChip extends StatelessWidget {
  const _HeaderStatChip({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 2 — LIFE MODE SWITCH (re-exported from existing widget)
// ═══════════════════════════════════════════════════════════════════════════

class _LifeModeSwitch extends StatelessWidget {
  const _LifeModeSwitch();

  @override
  Widget build(BuildContext context) {
    // Wrap existing AnimatedSegmentedSwitch — it's already polished
    return const AnimatedSegmentedSwitch();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 3 — PRIMARY FOCUS CARD
// ═══════════════════════════════════════════════════════════════════════════

class _PrimaryFocusCard extends StatelessWidget {
  const _PrimaryFocusCard({
    required this.reminder,
    required this.onTap,
    required this.onComplete,
  });

  final Reminder? reminder;
  final VoidCallback onTap;
  final ValueChanged<int> onComplete;

  @override
  Widget build(BuildContext context) {
    final hasTask = reminder != null;
    return _GlassCard(
      onTap: onTap,
      withAccentBorder: hasTask,
      child: hasTask
          ? _FocusCardContent(reminder: reminder!, onComplete: onComplete)
          : const _FocusCardEmpty(),
    );
  }
}

class _FocusCardContent extends StatelessWidget {
  const _FocusCardContent({
    required this.reminder,
    required this.onComplete,
  });

  final Reminder reminder;
  final ValueChanged<int> onComplete;

  @override
  Widget build(BuildContext context) {
    final priorityColor = _priorityColor(reminder.priority);
    final countdown = _countdownLabel(reminder);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row: label + countdown
        Row(
          children: [
            _MicroPill(
              label: 'FOCUS',
              color: _kAccentStart,
            ),
            const Spacer(),
            Text(
              countdown,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _kTextSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: DT.s16),

        // Task title
        Text(
          reminder.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.25,
            color: _kTextPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: DT.s8),

        // Meta: time · category · priority
        Text(
          '${TimeUtils.formatClockTime(reminder.hour, reminder.minute)}  ·  ${reminder.category}',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _kTextSecondary,
          ),
        ),
        const SizedBox(height: DT.s24),

        // CTA button
        Row(
          children: [
            _PillButton(
              label: 'Mark Complete',
              icon: Icons.check_rounded,
              onTap: () {
                HapticFeedback.mediumImpact();
                onComplete(reminder.id);
              },
            ),
            const Spacer(),
            _PriorityDot(color: priorityColor, label: reminder.priority),
          ],
        ),
      ],
    );
  }

  String _countdownLabel(Reminder reminder) {
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final remaining = reminder.minutesFromMidnight - nowMinutes;
    if (remaining <= 0) return 'Now';
    final hours = remaining ~/ 60;
    final minutes = remaining % 60;
    if (hours == 0) return 'In ${minutes}m';
    if (minutes == 0) return 'In ${hours}h';
    return 'In ${hours}h ${minutes}m';
  }
}

class _FocusCardEmpty extends StatelessWidget {
  const _FocusCardEmpty();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _MicroPill(label: 'FOCUS', color: _kTextMuted),
            const Spacer(),
            const Text(
              'Clear',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _kTextMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: DT.s16),
        const Text(
          'No priority task',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.25,
            color: _kTextSecondary,
          ),
        ),
        const SizedBox(height: DT.s8),
        const Text(
          'Tap to add a focused intention for today.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: _kTextMuted,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 4 — TODAY TIMELINE
// ═══════════════════════════════════════════════════════════════════════════

class _TimelineSection extends StatelessWidget {
  const _TimelineSection({
    required this.vm,
    required this.onAddReminder,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
    required this.onViewAll,
  });

  final _DashboardVM vm;
  final VoidCallback onAddReminder;
  final Function(Reminder) onEdit;
  final Function(int) onToggle;
  final Function(int) onDelete;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            const Text(
              'Today',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _kTextPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const Spacer(),
            if (vm.todayItems.isNotEmpty)
              GestureDetector(
                onTap: onViewAll,
                child: const Text(
                  'View all',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kAccentStart,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: DT.s16),

        // Timeline or empty
        if (vm.todayItems.isEmpty)
          _TimelineEmpty(onAdd: onAddReminder)
        else
          _GlassCard(
            padding: const EdgeInsets.symmetric(
              horizontal: DT.s16,
              vertical: DT.s12,
            ),
            child: TodayTimeline(
              dense: true,
              items: vm.todayItems,
              onToggle: (id) => onToggle(id),
              onEdit: (r) => onEdit(r),
              onDelete: (id) => onDelete(id),
            ),
          ),
      ],
    );
  }
}

class _TimelineEmpty extends StatelessWidget {
  const _TimelineEmpty({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _kAccentStart.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.event_available_outlined,
              size: 18,
              color: _kAccentStart,
            ),
          ),
          const SizedBox(width: DT.s12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Clear day ahead',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _kTextPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Add a task when you\'re ready.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _kTextMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: DT.s8),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DT.s12,
                vertical: DT.s8,
              ),
              decoration: BoxDecoration(
                color: _kAccentStart.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Add',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _kAccentStart,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 5 — SMART INSIGHT CARD
// ═══════════════════════════════════════════════════════════════════════════

class _SmartInsightCard extends StatelessWidget {
  const _SmartInsightCard({
    required this.loading,
    required this.insight,
    required this.onAction,
  });

  final bool loading;
  final Insight? insight;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final title = insight?.title ?? 'Plan a calm evening';
    final message = insight?.description ??
        'You have room for one focused block. Keep it small and finish clean.';
    final iconColor = _insightColor(insight?.type);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Insight',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _kTextPrimary,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: DT.s16),
        _GlassCard(
          onTap: loading ? null : onAction,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: loading
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _insightIcon(insight?.type),
                        color: iconColor,
                        size: 18,
                      ),
              ),
              const SizedBox(width: DT.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _kTextPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: DT.s4),
                    Text(
                      loading ? 'Reading your day...' : message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _kTextSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: DT.s8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: _kTextMuted,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SHARED MICRO-COMPONENTS
// ═══════════════════════════════════════════════════════════════════════════

/// Subtle glass card — the universal container for all sections
class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.child,
    this.onTap,
    this.withAccentBorder = false,
    this.padding,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool withAccentBorder;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final borderColor = withAccentBorder
        ? _kAccentStart.withValues(alpha: 0.22)
        : _kBorder;

    final card = ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: padding ?? const EdgeInsets.all(DT.s16),
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: _kAccentStart.withValues(alpha: 0.06),
        highlightColor: _kAccentStart.withValues(alpha: 0.03),
        child: card,
      ),
    );
  }
}

/// Compact uppercase label pill
class _MicroPill extends StatelessWidget {
  const _MicroPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: color,
        ),
      ),
    );
  }
}

/// Single CTA button for focus card
class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DT.s16,
          vertical: DT.s8,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_kAccentStart, _kAccentEnd],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _kAccentStart.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Priority indicator dot
class _PriorityDot extends StatelessWidget {
  const _PriorityDot({required this.color, required this.label});
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
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label[0].toUpperCase() + label.substring(1),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Minimal FAB
class _MinimalFAB extends StatelessWidget {
  const _MinimalFAB({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_kAccentStart, _kAccentEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _kAccentStart.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.auto_awesome_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════

Color _productivityColor(double p) {
  if (p >= 75) return ZyvoraColors.success;
  if (p >= 50) return ZyvoraColors.warning;
  return ZyvoraColors.error;
}

Color _priorityColor(String p) {
  switch (p) {
    case 'high':
      return ZyvoraColors.error;
    case 'low':
      return ZyvoraColors.success;
    default:
      return ZyvoraColors.warning;
  }
}

Color _insightColor(InsightType? type) {
  return switch (type) {
    InsightType.productivity => const Color(0xFF7B61FF),
    InsightType.attendance => ZyvoraColors.warning,
    InsightType.routine => const Color(0xFF5B8CFF),
    InsightType.burnout => ZyvoraColors.error,
    InsightType.streak => ZyvoraColors.success,
    InsightType.suggestion => ZyvoraColors.cyan,
    null => const Color(0xFF7B61FF),
  };
}

IconData _insightIcon(InsightType? type) {
  return switch (type) {
    InsightType.productivity => Icons.auto_graph_rounded,
    InsightType.attendance => Icons.school_rounded,
    InsightType.routine => Icons.event_repeat_rounded,
    InsightType.burnout => Icons.warning_amber_rounded,
    InsightType.streak => Icons.local_fire_department_rounded,
    InsightType.suggestion => Icons.auto_awesome_rounded,
    null => Icons.auto_awesome_rounded,
  };
}
