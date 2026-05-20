import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../utils/zyvora_design_system.dart';
import '../widgets/premium_components.dart';

/// Premium Reminders Screen - Simple version
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
      appBar: AppBar(title: const Text('Tasks')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: ctrl.reminders.isEmpty
          ? Center(
              child: PremiumEmptyState(
                icon: Icons.task_outlined,
                title: 'No Tasks',
                subtitle: 'Add a new task to get started',
              ),
            )
          : ListView.builder(
              itemCount: ctrl.reminders.length,
              itemBuilder: (context, index) {
                final reminder = ctrl.reminders[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ZyvoraDesignSystem.spacing12,
                    vertical: ZyvoraDesignSystem.spacing8,
                  ),
                  child: PremiumCard(
                    child: ListTile(
                      title: Text(reminder.title),
                      subtitle: Text(reminder.notes ?? 'No notes'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
