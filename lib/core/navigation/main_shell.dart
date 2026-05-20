import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers.dart';
import '../theme/app_theme.dart';
import '../../models/zyvora_role.dart';
import '../../utils/zyvora_design_system.dart';
import '../../widgets/add_reminder_sheet.dart';
import '../../widgets/premium_navigation.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  Future<void> _createReminder(BuildContext context, WidgetRef ref) async {
    final user = ref.read(userControllerProvider);
    final reminders = ref.read(reminderControllerProvider);
    final mode = user.lifeMode?.storageValue ?? 'personal';
    final role = mode == 'professional'
        ? (user.role ?? ZyvoraRole.student)
        : null;

    final result = await showModalBottomSheet<AddReminderResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddReminderSheet(
        lifeMode: mode,
        role: role,
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
    return Scaffold(
      extendBody: true,
      backgroundColor: ZyvoraDesignSystem.backgroundPrimary,
      body: navigationShell,
      bottomNavigationBar: PremiumNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onIndexChanged: (index) => navigationShell.goBranch(index),
        items: const [
          PremiumNavItem(label: 'Home', icon: Icons.home_outlined),
          PremiumNavItem(label: 'Tasks', icon: Icons.task_outlined),
          PremiumNavItem(label: 'Attendance', icon: Icons.school_outlined),
          PremiumNavItem(label: 'Calendar', icon: Icons.calendar_today_outlined),
          PremiumNavItem(label: 'Profile', icon: Icons.person_outlined),
        ],
      ),
    );
  }
}

