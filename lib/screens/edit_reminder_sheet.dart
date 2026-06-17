import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/reminder.dart';
import '../utils/app_categories.dart';

/// Lightweight edit sheet for an existing [Reminder]. Returns a tuple via
/// Navigator.pop:
///   - `Reminder` -> save updates
///   - `'delete'` -> request delete
///   - `null`     -> cancel
class EditReminderSheet extends StatefulWidget {
  const EditReminderSheet({super.key, required this.reminder});

  final Reminder reminder;

  @override
  State<EditReminderSheet> createState() => _EditReminderSheetState();
}

class _EditReminderSheetState extends State<EditReminderSheet> {
  late TextEditingController _title;
  late TimeOfDay _time;
  late String _category;
  late String _repeat;
  late bool _notify;

  @override
  void initState() {
    super.initState();
    final r = widget.reminder;
    _title = TextEditingController(text: r.title);
    _time = TimeOfDay(hour: r.hour, minute: r.minute);
    _category = r.category;
    _repeat = r.repeatType;
    _notify = r.notificationEnabled;
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (!mounted || picked == null) return;
    setState(() => _time = picked);
  }

  void _save() {
    final r = widget.reminder;
    final next = Reminder(
      id: r.id,
      title: _title.text.trim().isEmpty ? r.title : _title.text.trim(),
      day: r.day,
      hour: _time.hour,
      minute: _time.minute,
      category: _category,
      lifeMode: r.lifeMode,
      repeatType: _repeat,
      notificationEnabled: _notify,
      alarmEnabled: r.alarmEnabled,
      isCompleted: r.isCompleted,
      completedAt: r.completedAt,
      createdAt: r.createdAt,
      updatedAt: DateTime.now(),
      priority: r.priority,
      notes: r.notes,
    );
    Navigator.of(context).pop(next);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
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
              Text('Edit reminder', style: t.titleLarge),
              const SizedBox(height: 18),
              TextField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: _pickTime,
                borderRadius: BorderRadius.circular(ZyvoraRadius.md),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Time'),
                  child: Text(_time.format(context), style: t.titleMedium),
                ),
              ),
              const SizedBox(height: 14),
              Text('Category', style: t.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppCategories.all.map((c) {
                  final on = c.id == _category;
                  return ChoiceChip(
                    selected: on,
                    onSelected: (_) => setState(() => _category = c.id),
                    avatar: Icon(c.icon, size: 16, color: c.color),
                    label: Text(c.label),
                    selectedColor: c.softColor.withValues(alpha: 0.5),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              Text('Repeat', style: t.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'once', label: Text('Once')),
                  ButtonSegment(value: 'daily', label: Text('Daily')),
                  ButtonSegment(value: 'weekly', label: Text('Weekly')),
                  ButtonSegment(value: 'monthly', label: Text('Monthly')),
                ],
                selected: {_repeat},
                onSelectionChanged: (s) => setState(() => _repeat = s.first),
              ),
              const SizedBox(height: 6),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _notify,
                onChanged: (v) => setState(() => _notify = v),
                title: Text('Notify me', style: t.titleSmall),
                activeThumbColor: ZyvoraColors.primary,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop('delete'),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: ZyvoraColors.red,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: ZyvoraColors.redSoft.withValues(
                        alpha: 0.4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ZyvoraRadius.md),
                      ),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: _save,
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
