import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/providers.dart';
import '../features/tasks/controllers/reminder_controller.dart';
import '../models/zyvora_role.dart';
import '../utils/zyvora_design_system.dart';
import '../widgets/add_reminder_sheet.dart';
import '../widgets/premium_components.dart';
import '../widgets/premium_navigation.dart';

/// Premium Reminders Screen
class PremiumRemindersScreen extends ConsumerStatefulWidget {
  const PremiumRemindersScreen({super.key});

  @override
  ConsumerState<PremiumRemindersScreen> createState() => _PremiumRemindersScreenState();
}

class _PremiumRemindersScreenState extends ConsumerState<PremiumRemindersScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ctrl = ref.watch(reminderControllerProvider);

    return Scaffold(
      appBar: PremiumAppBar(
        title: 'Tasks',
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterOptions(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReminderSheet(context),
        child: const Icon(Icons.add),
      ),
      body: _buildRemindersList(context, ctrl),
    );
  }

  Widget _buildRemindersList(BuildContext context, ReminderController ctrl) {
    final reminders = ctrl.reminders;

    if (reminders.isEmpty) {
      return PremiumEmptyState(
        icon: Icons.done_all,
        title: 'All tasks complete!',
        subtitle: 'Add a new task to get started',
        action: PremiumButton(
          label: 'Add Task',
          onPressed: () => _showAddReminderSheet(context),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(ZyvoraDesignSystem.spacing16),
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: ZyvoraDesignSystem.spacing12),
          child: Dismissible(
            key: Key(reminder.id.toString()),
            background: Container(
              decoration: BoxDecoration(
                color: ZyvoraDesignSystem.accentRed.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(ZyvoraDesignSystem.radiusLarge),
              ),
              child: const Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.all(ZyvoraDesignSystem.spacing16),
                  child: Icon(Icons.delete_outline, color: ZyvoraDesignSystem.accentRed),
                ),
              ),
            ),
            onDismissed: (_) {
              ref.read(reminderControllerProvider).deleteReminder(reminder.id);
            },
            child: _buildReminderCard(context, reminder),
          ),
        );
      },
    );
  }

  Widget _buildReminderCard(BuildContext context, dynamic reminder) {
    return PremiumCard(
      padding: const EdgeInsets.all(ZyvoraDesignSystem.spacing12),
      onTap: () {
        // Edit reminder
      },
      child: Row(
        children: [
          Checkbox(
            value: reminder.isCompleted,
            onChanged: (val) {
              ref.read(reminderControllerProvider).toggleReminderComplete(reminder.id);
            },
          ),
          const SizedBox(width: ZyvoraDesignSystem.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    decoration: reminder.isCompleted ? TextDecoration.lineThrough : null,
                    color: reminder.isCompleted ? ZyvoraDesignSystem.textTertiary : ZyvoraDesignSystem.textPrimary,
                  ),
                ),
                if (reminder.notes != null && reminder.notes!.isNotEmpty)
                  Text(
                    reminder.notes!,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: ZyvoraDesignSystem.spacing12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ZyvoraDesignSystem.spacing8,
              vertical: ZyvoraDesignSystem.spacing4,
            ),
            decoration: BoxDecoration(
              color: _getPriorityColor(reminder.priority).withValues(alpha: 0.1),
              borderRadius:
                  BorderRadius.circular(ZyvoraDesignSystem.radiusSmall),
            ),
            child: Text(
              reminder.priority.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: _getPriorityColor(reminder.priority),
                    fontWeight: ZyvoraDesignSystem.weightBold,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return ZyvoraDesignSystem.accentRed;
      case 'medium':
        return ZyvoraDesignSystem.accentOrange;
      default:
        return ZyvoraDesignSystem.accentBlue;
    }
  }

  Future<void> _showAddReminderSheet(BuildContext context) async {
    final user = ref.read(userControllerProvider);
    final mode = user.lifeMode?.storageValue ?? 'personal';
    final role = mode == 'professional' ? (user.role ?? ZyvoraRole.student) : null;

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
      await ref.read(reminderControllerProvider).addReminder(
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder saved')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save reminder: $e')),
      );
    }
  }

  void _showFilterOptions(BuildContext context) {
    final ctrl = ref.read(reminderControllerProvider);
    final categories = ['All', ...PersonalCategories.all];

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Category'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = (category == 'All' && ctrl.selectedCategory == null) ||
                  (category == ctrl.selectedCategory);

              return ListTile(
                title: Text(category),
                trailing: isSelected ? const Icon(Icons.check, color: ZyvoraDesignSystem.accentBlue) : null,
                onTap: () {
                  ctrl.selectCategory(category == 'All' ? null : category);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
