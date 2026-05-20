import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../models/alarm.dart';
import '../widgets/add_alarm_sheet.dart';
import '../widgets/alarm_tile.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_header.dart';

class AlarmsScreen extends ConsumerWidget {
  const AlarmsScreen({super.key});

  Future<void> _openSheet(
    BuildContext context,
    WidgetRef ref, {
    Alarm? initial,
  }) async {
    final service = ref.read(alarmControllerProvider);
    final result = await showModalBottomSheet<Alarm>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddAlarmSheet(initial: initial),
    );
    if (result == null) return;
    if (!context.mounted) return;
    if (initial == null) {
      await service.add(
        label: result.label,
        hour: result.hour,
        minute: result.minute,
        repeatDays: result.repeatDays,
        vibrate: result.vibrate,
      );
    } else {
      await service.update(result);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(alarmControllerProvider);
    final alarms = [...service.alarms]
      ..sort((a, b) {
        final am = a.hour * 60 + a.minute;
        final bm = b.hour * 60 + b.minute;
        return am.compareTo(bm);
      });

    return Scaffold(
      appBar: AppBar(title: const Text('Alarms')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSheet(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New alarm'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          children: [
            const SectionHeader(
              title: 'Your alarms',
              subtitle: 'Reliable, minimal, dark-first.',
            ),
            if (alarms.isEmpty)
              EmptyState(
                icon: Icons.alarm_rounded,
                title: 'No alarms yet',
                message: 'Tap the button below to schedule your first alarm.',
                action: FilledButton.icon(
                  onPressed: () => _openSheet(context, ref),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('New alarm'),
                ),
              )
            else
              ...alarms.map(
                (a) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AlarmTile(
                    alarm: a,
                    onToggle: (v) => service.toggle(a.id, v),
                    onTap: () => _openSheet(context, ref, initial: a),
                    onDelete: () => service.remove(a.id),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
