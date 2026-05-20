import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../core/theme/app_theme.dart';
import '../models/zyvora_role.dart';
import 'attendance_screen.dart';
import 'home_dashboard.dart';
import 'profile_screen.dart';
import 'tasks_screen.dart';
import '../widgets/add_reminder_sheet.dart';

class MainWrapper extends ConsumerWidget {
  const MainWrapper({super.key});

  static final _screens = [
    HomeDashboard(),
    TasksScreen(),
    AttendanceScreen(),
    ProfileScreen(),
  ];

  Future<void> _createReminder(BuildContext context, WidgetRef ref) async {
    final userCtrl = ref.read(userControllerProvider);
    final reminderCtrl = ref.read(reminderControllerProvider);
    final mode = userCtrl.lifeMode?.storageValue ?? 'personal';
    final role = mode == 'professional'
        ? (userCtrl.role ?? ZyvoraRole.student)
        : null;

    final result = await showModalBottomSheet<AddReminderResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddReminderSheet(
        lifeMode: mode,
        role: role,
        defaultDay: reminderCtrl.todayName,
      ),
    );

    if (result == null) return;
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
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reminder saved')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save reminder: $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(navTabProviderIndex);

    return Scaffold(
      extendBody: false,
      body: IndexedStack(index: tabIndex, children: _screens),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
          child: _FloatingDockNav(
            currentIndex: tabIndex,
            onSelect:
                (index) => ref.read(navTabProviderIndex.notifier).state = index,
            onCreate: () => _createReminder(context, ref),
          ),
        ),
      ),
    );
  }
}

class _FloatingDockNav extends StatelessWidget {
  const _FloatingDockNav({
    required this.currentIndex,
    required this.onSelect,
    required this.onCreate,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(ZyvoraRadius.hero),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(ZyvoraRadius.hero),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.7),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.11),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                selected: currentIndex == 0,
                onTap: () => onSelect(0),
              ),
              _NavItem(
                icon: Icons.task_alt_rounded,
                label: 'Tasks',
                selected: currentIndex == 1,
                onTap: () => onSelect(1),
              ),
              _CenterAddButton(onTap: onCreate),
              _NavItem(
                icon: Icons.school_rounded,
                label: 'Attendance',
                selected: currentIndex == 2,
                onTap: () => onSelect(2),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                selected: currentIndex == 3,
                onTap: () => onSelect(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterAddButton extends StatelessWidget {
  const _CenterAddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Add reminder',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: 1,
          duration: ZyvoraMotion.fast,
          curve: Curves.easeOutCubic,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [ZyvoraColors.primary, ZyvoraColors.secondary],
              ),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: ZyvoraColors.primary.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected ? ZyvoraColors.primary : theme.colorScheme.onSurface;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: ZyvoraMotion.regular,
            curve: ZyvoraMotion.curve,
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: selected ? 1.05 : 1,
                  duration: ZyvoraMotion.fast,
                  curve: Curves.easeOutCubic,
                  child: Icon(
                    icon,
                    color: selected ? color : color.withValues(alpha: 0.78),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: selected
                        ? ZyvoraColors.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.72),
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: ZyvoraMotion.fast,
                  width: selected ? 6 : 0,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: ZyvoraColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
