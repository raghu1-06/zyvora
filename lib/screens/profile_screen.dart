import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/reminder.dart';
import '../core/providers.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/error_handler.dart';
import '../features/attendance/controllers/attendance_controller.dart';
import '../features/profile/controllers/user_controller.dart';
import '../features/tasks/controllers/reminder_controller.dart';
import '../utils/page_transitions.dart';
import '../widgets/zyvora_ui.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userControllerProvider);
    final reminders = ref.watch(reminderControllerProvider);
    final attendance = ref.watch(attendanceControllerProvider);
    final vm = _ProfileVM.from(reminders, user);
    final attendanceVm = _ProfileAttendanceVM.from(attendance);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 126),
          children: [
            _ProfileTopBar(
              onSettings: () => _open(context, const SettingsScreen()),
            ),
            const SizedBox(height: 18),
            _ProfileHero(
              name: vm.userName,
              greeting: vm.greeting,
              streak: vm.currentStreak,
              onEdit: () => _editName(context, ref.read(userControllerProvider)),
            ),
            const SizedBox(height: 18),
            _ProductivityStats(
              items: [
                _ProfileStat(
                  'Tasks done',
                  '${vm.completed}',
                  Icons.task_alt_rounded,
                  ZyvoraColors.primary,
                ),
                _ProfileStat(
                  'Attendance',
                  attendanceVm.attendanceValue,
                  Icons.school_rounded,
                  ZyvoraColors.success,
                ),
                _ProfileStat(
                  'Streak',
                  '${vm.currentStreak}d',
                  Icons.local_fire_department_rounded,
                  ZyvoraColors.warning,
                ),
                _ProfileStat(
                  'Upcoming',
                  '${vm.todayPending}',
                  Icons.schedule_rounded,
                  ZyvoraColors.secondary,
                ),
                _ProfileStat(
                  'Study',
                  '${vm.studySessions}',
                  Icons.menu_book_rounded,
                  ZyvoraColors.cyan,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SmartInsights(
              reminders: vm.reminders,
              completed: vm.completed,
              attendanceAverage: attendanceVm.attendanceAverage,
            ),
            const SizedBox(height: 22),
            _SettingsSection(
              title: 'Productivity',
              children: [
                _SettingAction(
                  Icons.track_changes_rounded,
                  ZyvoraColors.primary,
                  'Goals',
                  'Shape your weekly targets',
                  () => _comingSoon(context, 'Goals'),
                ),
                _SettingAction(
                  Icons.analytics_rounded,
                  ZyvoraColors.success,
                  'Analytics',
                  'Review your progress patterns',
                  () => _open(context, const AnalyticsScreen()),
                ),
                _SettingAction(
                  Icons.insights_rounded,
                  ZyvoraColors.warning,
                  'Productivity insights',
                  'Personal patterns and suggestions',
                  () => _open(context, const AnalyticsScreen()),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SettingsSection(
              title: 'Personalization',
              children: [
                _SettingAction(
                  Icons.person_outline_rounded,
                  ZyvoraColors.primary,
                  'Profile name',
                  'Change how Zyvora greets you',
                  () => _editName(context, ref.read(userControllerProvider)),
                ),
                _SettingAction(
                  Icons.palette_outlined,
                  ZyvoraColors.secondary,
                  'Theme',
                  vm.isDarkMode
                      ? 'Dark mode enabled'
                      : 'Light mode enabled',
                  null,
                  trailing: Switch(
                    value: vm.isDarkMode,
                    onChanged: (v) =>
                        ref.read(userControllerProvider).setDarkMode(v),
                  ),
                ),
                _SettingAction(
                  Icons.tune_rounded,
                  ZyvoraColors.success,
                  'App customization',
                  'Personalize your workspace',
                  () => _open(context, const SettingsScreen()),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SettingsSection(
              title: 'Data & Security',
              children: [
                _SettingAction(
                  Icons.cloud_sync_outlined,
                  ZyvoraColors.primary,
                  'Backup & sync',
                  'Keep your data safe',
                  () => _comingSoon(context, 'Backup & sync'),
                ),
                _SettingAction(
                  Icons.shield_outlined,
                  ZyvoraColors.secondary,
                  'Privacy',
                  'Control your local data',
                  () => _comingSoon(context, 'Privacy'),
                ),
                _SettingAction(
                  Icons.file_download_outlined,
                  ZyvoraColors.success,
                  'Export data',
                  'Take your records with you',
                  () => _comingSoon(context, 'Export data'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SettingsSection(
              title: 'Support',
              children: [
                _SettingAction(
                  Icons.feedback_outlined,
                  ZyvoraColors.warning,
                  'Feedback',
                  'Share what should improve',
                  () => _comingSoon(context, 'Feedback'),
                ),
                _SettingAction(
                  Icons.help_outline_rounded,
                  ZyvoraColors.primary,
                  'Help',
                  'Get guidance when needed',
                  () => _comingSoon(context, 'Help'),
                ),
                _SettingAction(
                  Icons.info_outline_rounded,
                  ZyvoraColors.textSecondary,
                  'About Zyvora',
                  'A calm productivity system',
                  () => _comingSoon(context, 'About Zyvora'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  static bool _isStudySession(Reminder r) {
    final category = r.category.toLowerCase();
    final title = r.title.toLowerCase();
    return category.contains('study') || title.contains('study');
  }

  static Future<void> _open(BuildContext context, Widget page) {
    return Navigator.of(context).push(SoftPageRoute<void>(page));
  }

  static void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature will be available soon.')));
  }

  static Future<void> _editName(
    BuildContext context,
    UserController ctrl,
  ) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _EditNameDialog(initial: ctrl.storedUserName),
    );

    if (!context.mounted) return;
    final trimmed = name?.trim() ?? '';
    if (trimmed.isEmpty) return;

    try {
      await ctrl.setUserName(trimmed);
      if (!context.mounted) return;
      ZyvoraErrorHandler.showSuccess(context, message: 'Profile updated');
    } catch (e) {
      if (!context.mounted) return;
      ZyvoraErrorHandler.showError(
        context,
        title: 'Failed to save name',
        message: ZyvoraErrorHandler.formatErrorMessage(e),
      );
    }
  }
}

class _ProfileTopBar extends StatelessWidget {
  const _ProfileTopBar({required this.onSettings});

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profile', style: theme.textTheme.headlineLarge),
              const SizedBox(height: 4),
              Text(
                'Your personal productivity identity',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        ZyvoraHeaderButton(
          icon: Icons.settings_rounded,
          tooltip: 'Settings',
          onTap: onSettings,
        ),
      ],
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.name,
    required this.greeting,
    required this.streak,
    required this.onEdit,
  });

  final String name;
  final String greeting;
  final int streak;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cleanName = name.trim().isEmpty || name == 'there'
        ? 'Raghu'
        : name.trim();
    final initial = cleanName.substring(0, 1).toUpperCase();
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: ZyvoraMotion.regular,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 12),
            child: child,
          ),
        );
      },
      child: ZyvoraCard(
        padding: const EdgeInsets.all(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            ZyvoraColors.primary.withValues(alpha: 0.08),
            ZyvoraColors.secondary.withValues(alpha: 0.05),
          ],
        ),
        borderColor: ZyvoraColors.primary.withValues(alpha: 0.18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 420;
            final avatar = _Avatar(initial: initial, onEdit: onEdit);
            final text = Column(
              crossAxisAlignment: compact
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, $cleanName',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                ZyvoraPill(
                  label: streak == 1
                      ? '1-day productivity streak'
                      : '$streak-day productivity streak',
                  icon: Icons.local_fire_department_rounded,
                  color: ZyvoraColors.warning,
                ),
                const SizedBox(height: 14),
                Text(
                  '"Consistency creates success."',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: const Text('Edit profile'),
                ),
              ],
            );
            if (compact) {
              return Column(
                children: [avatar, const SizedBox(height: 18), text],
              );
            }
            return Row(
              children: [
                avatar,
                const SizedBox(width: 22),
                Expanded(child: text),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial, required this.onEdit});

  final String initial;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 88,
          height: 88,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [ZyvoraColors.secondary, ZyvoraColors.primary],
            ),
            boxShadow: [
              BoxShadow(
                color: ZyvoraColors.primary.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Text(
            initial,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Positioned(
          right: -2,
          bottom: 2,
          child: IconButton.filled(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded, size: 17),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: ZyvoraColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileStat {
  const _ProfileStat(this.label, this.value, this.icon, this.color);

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class _ProductivityStats extends StatelessWidget {
  const _ProductivityStats({required this.items});

  final List<_ProfileStat> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 94,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          return SizedBox(
            width: 140,
            child: ZyvoraCard(
              shadow: false,
              padding: const EdgeInsets.all(12),
              borderColor: item.color.withValues(alpha: 0.13),
              child: Row(
                children: [
                  Icon(item.icon, color: item.color, size: 22),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(color: item.color),
                        ),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SmartInsights extends StatelessWidget {
  const _SmartInsights({
    required this.reminders,
    required this.completed,
    required this.attendanceAverage,
  });

  final List<Reminder> reminders;
  final int completed;
  final double? attendanceAverage;

  @override
  Widget build(BuildContext context) {
    final eveningCount = reminders
        .where((r) => r.hour >= 17 && r.hour <= 22)
        .length;
    final attendanceText = attendanceAverage == null
        ? 'Add attendance subjects to unlock academic insights.'
        : attendanceAverage! >= 75
        ? 'Attendance is safe at ${attendanceAverage!.round()}%.'
        : 'Attendance needs care at ${attendanceAverage!.round()}%.';
    final insights = [
      _InsightData(
        Icons.nights_stay_rounded,
        ZyvoraColors.primary,
        'Best rhythm',
        eveningCount >= 2
            ? 'Your plan leans strongest in the evening.'
            : 'Your day has space for a calm focus block.',
      ),
      _InsightData(
        Icons.task_alt_rounded,
        ZyvoraColors.success,
        'This week',
        'You completed $completed task${completed == 1 ? '' : 's'} recently.',
      ),
      _InsightData(
        Icons.school_rounded,
        ZyvoraColors.warning,
        'Attendance',
        attendanceText,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Smart Insights', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...insights.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _InsightCard(data: item),
          ),
        ),
      ],
    );
  }
}

class _InsightData {
  const _InsightData(this.icon, this.color, this.title, this.message);

  final IconData icon;
  final Color color;
  final String title;
  final String message;
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.data});

  final _InsightData data;

  @override
  Widget build(BuildContext context) {
    return ZyvoraCard(
      shadow: false,
      padding: const EdgeInsets.all(14),
      borderColor: data.color.withValues(alpha: 0.12),
      child: Row(
        children: [
          ZyvoraIconBadge(
            icon: data.icon,
            color: data.color,
            size: 40,
            iconSize: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  data.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<_SettingAction> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        ZyvoraCard(
          padding: EdgeInsets.zero,
          shadow: false,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1)
                  Divider(
                    height: 1,
                    indent: 72,
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.45),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingAction extends StatelessWidget {
  const _SettingAction(
    this.icon,
    this.color,
    this.title,
    this.subtitle,
    this.onTap, {
    this.trailing,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              ZyvoraIconBadge(icon: icon, color: color, size: 42, iconSize: 21),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.48),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditNameDialog extends StatefulWidget {
  final String initial;
  const _EditNameDialog({required this.initial});

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profile'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 100,
        decoration: const InputDecoration(hintText: 'Your name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _ProfileVM {
  final String userName;
  final String greeting;
  final int currentStreak;
  final int completed;
  final int todayPending;
  final int studySessions;
  final List<Reminder> reminders;
  final bool isDarkMode;

  const _ProfileVM({
    required this.userName,
    required this.greeting,
    required this.currentStreak,
    required this.completed,
    required this.todayPending,
    required this.studySessions,
    required this.reminders,
    required this.isDarkMode,
  });

  factory _ProfileVM.from(ReminderController remindersCtrl, UserController user) {
    final reminders = remindersCtrl.activeReminders;
    final completed = reminders.where((r) => r.isCompleted).length;
    final todayPending =
        remindersCtrl.todayReminders.where((r) => !r.isCompleted).length;
    final studySessions = reminders.where(ProfileScreen._isStudySession).length;

    return _ProfileVM(
      userName: user.userName,
      greeting: user.greeting,
      currentStreak: remindersCtrl.currentStreak,
      completed: completed,
      todayPending: todayPending,
      studySessions: studySessions,
      reminders: reminders,
      isDarkMode: user.isDarkMode,
    );
  }
}

class _ProfileAttendanceVM {
  final String attendanceValue;
  final double? attendanceAverage;

  const _ProfileAttendanceVM({
    required this.attendanceValue,
    required this.attendanceAverage,
  });

  factory _ProfileAttendanceVM.from(AttendanceController attendance) {
    final hasSubjects = attendance.subjects.isNotEmpty;
    return _ProfileAttendanceVM(
      attendanceValue: hasSubjects
          ? '${attendance.overallPercentage.round()}%'
          : '--',
      attendanceAverage: hasSubjects ? attendance.overallPercentage : null,
    );
  }
}
