import 'package:flutter/material.dart';

import '../models/alarm.dart';
import '../core/theme/app_theme.dart';

/// Bottom sheet for creating or editing an [Alarm]. Returns a fully-formed
/// alarm draft via Navigator.pop.
class AddAlarmSheet extends StatefulWidget {
  const AddAlarmSheet({super.key, this.initial});

  final Alarm? initial;

  @override
  State<AddAlarmSheet> createState() => _AddAlarmSheetState();
}

class _AddAlarmSheetState extends State<AddAlarmSheet> {
  late TimeOfDay _time;
  late TextEditingController _label;
  late Set<int> _days;
  late bool _vibrate;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _time = TimeOfDay(hour: i?.hour ?? 7, minute: i?.minute ?? 0);
    _label = TextEditingController(text: i?.label ?? '');
    _days = {...?i?.repeatDays};
    _vibrate = i?.vibrate ?? true;
  }

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: child!,
      ),
    );
    if (!mounted || picked == null) return;
    setState(() => _time = picked);
  }

  void _toggleDay(int d) {
    if (!mounted) return;
    setState(() {
      if (_days.contains(d)) {
        _days.remove(d);
      } else {
        _days.add(d);
      }
    });
  }

  void _save() {
    final draft =
        (widget.initial ??
                Alarm(
                  id: 0,
                  label: _label.text,
                  hour: _time.hour,
                  minute: _time.minute,
                  createdAt: DateTime.now(),
                ))
            .copyWith(
              label: _label.text.trim().isEmpty ? 'Alarm' : _label.text.trim(),
              hour: _time.hour,
              minute: _time.minute,
              repeatDays: _days,
              vibrate: _vibrate,
            );
    Navigator.of(context).pop(draft);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final isEdit = widget.initial != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: scheme.outline.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(isEdit ? 'Edit alarm' : 'New alarm', style: t.titleLarge),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: _pickTime,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      border: Border.all(
                        color: scheme.outline.withValues(alpha: 0.5),
                      ),
                      borderRadius: BorderRadius.circular(ZyvoraRadius.lg),
                    ),
                    child: Center(
                      child: Text(
                        _time.format(context),
                        style: t.headlineLarge?.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _label,
                  decoration: const InputDecoration(
                    labelText: 'Label',
                    hintText: 'Wake up',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 18),
                Text('Repeat', style: t.titleSmall),
                const SizedBox(height: 8),
                _DayPicker(selected: _days, onToggle: _toggleDay),
                const SizedBox(height: 14),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _vibrate,
                  onChanged: (v) => setState(() => _vibrate = v),
                  title: Text('Vibrate', style: t.titleSmall),
                  activeThumbColor: ZyvoraColors.primary,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _save,
                        child: Text(isEdit ? 'Save' : 'Create'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DayPicker extends StatelessWidget {
  const _DayPicker({required this.selected, required this.onToggle});

  final Set<int> selected;
  final void Function(int weekday) onToggle;

  @override
  Widget build(BuildContext context) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = i + 1;
        final on = selected.contains(day);
        return GestureDetector(
          onTap: () => onToggle(day),
          child: AnimatedContainer(
            duration: ZyvoraMotion.fast,
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on ? ZyvoraColors.primary : scheme.surface,
              border: Border.all(
                color: on
                    ? ZyvoraColors.primary
                    : scheme.outline.withValues(alpha: 0.5),
              ),
              borderRadius: BorderRadius.circular(ZyvoraRadius.md),
            ),
            child: Text(
              labels[i],
              style: TextStyle(
                color: on ? Colors.white : scheme.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        );
      }),
    );
  }
}
