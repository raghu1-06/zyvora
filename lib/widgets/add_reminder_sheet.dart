import 'package:flutter/material.dart';

import '../models/zyvora_role.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../utils/time_utils.dart';

class AddReminderResult {
  final String title;
  final String day;
  final int hour;
  final int minute;
  final String category;
  final String lifeMode;
  final String repeatType;
  final String priority;
  final String? notes;
  final bool notificationEnabled;
  final bool alarmEnabled;

  const AddReminderResult({
    required this.title,
    required this.day,
    required this.hour,
    required this.minute,
    required this.category,
    required this.lifeMode,
    required this.repeatType,
    required this.priority,
    this.notes,
    required this.notificationEnabled,
    required this.alarmEnabled,
  });
}

class AddReminderSheet extends StatefulWidget {
  final String lifeMode;
  final ZyvoraRole? role;
  final String defaultDay;
  final String? defaultCategory;
  final String? editTitle;
  final int? editHour;
  final int? editMinute;
  final String? editRepeatType;
  final String? editPriority;
  final String? editNotes;
  final bool? editNotificationEnabled;
  final bool? editAlarmEnabled;

  const AddReminderSheet({
    super.key,
    required this.lifeMode,
    this.role,
    required this.defaultDay,
    this.defaultCategory,
    this.editTitle,
    this.editHour,
    this.editMinute,
    this.editRepeatType,
    this.editPriority,
    this.editNotes,
    this.editNotificationEnabled,
    this.editAlarmEnabled,
  });

  @override
  State<AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<AddReminderSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _notesCtrl;
  late String _day;
  late String _category;
  late TimeOfDay _time;
  late String _repeatType;
  late String _priority;
  bool _notifEnabled = true;
  bool _alarmEnabled = false;
  String? _error;

  static const _repeats = ['once', 'daily', 'weekly', 'monthly'];

  List<String> get _categories {
    if (widget.lifeMode == 'personal') return PersonalCategories.all;
    return widget.role?.categories ?? ['Custom'];
  }

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.editTitle ?? '');
    _notesCtrl = TextEditingController(text: widget.editNotes ?? '');
    _day = widget.defaultDay;
    _category = widget.defaultCategory ?? _categories.first;
    if (!_categories.contains(_category)) _category = _categories.first;
    _time = TimeOfDay(
      hour: widget.editHour ?? TimeOfDay.now().hour,
      minute: widget.editMinute ?? TimeOfDay.now().minute,
    );
    final er = widget.editRepeatType?.toLowerCase().trim() ?? 'weekly';
    _repeatType = _repeats.contains(er) ? er : 'weekly';
    final ep = widget.editPriority?.toLowerCase().trim() ?? 'medium';
    _priority = {'low', 'medium', 'high'}.contains(ep) ? ep : 'medium';
    _notifEnabled = widget.editNotificationEnabled ?? true;
    _alarmEnabled = widget.editAlarmEnabled ?? false;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _applySuggestion(String phrase) {
    final t = _titleCtrl.text.trim();
    if (t.isEmpty) {
      _titleCtrl.text = phrase;
    } else if (!t.toLowerCase().contains(phrase.toLowerCase())) {
      _titleCtrl.text = '$t · $phrase';
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(ZyvoraRadius.hero),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(ZyvoraRadius.sm),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  widget.editTitle != null ? 'Edit reminder' : 'New reminder',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Smart suggestions help you capture intent faster — tap to merge into the title.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      label: const Text('Focus block'),
                      onPressed: () => _applySuggestion('Deep work'),
                    ),
                    ActionChip(
                      label: const Text('Review notes'),
                      onPressed: () => _applySuggestion('Review class notes'),
                    ),
                    ActionChip(
                      label: const Text('Hydrate'),
                      onPressed: () => _applySuggestion('Drink water'),
                    ),
                    ActionChip(
                      label: const Text('Walk break'),
                      onPressed: () => _applySuggestion('10m walk'),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _titleCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'What should we remind you about?',
                    errorText: _error,
                    prefixIcon: const Icon(Icons.edit_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    hintText: 'Context, links, or mini checklist',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                Text('Priority', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _PrioChip(
                      label: 'Low',
                      selected: _priority == 'low',
                      onTap: () => setState(() => _priority = 'low'),
                    ),
                    const SizedBox(width: 8),
                    _PrioChip(
                      label: 'Medium',
                      selected: _priority == 'medium',
                      onTap: () => setState(() => _priority = 'medium'),
                    ),
                    const SizedBox(width: 8),
                    _PrioChip(
                      label: 'High',
                      selected: _priority == 'high',
                      accent: ZyvoraColors.error,
                      onTap: () => setState(() => _priority = 'high'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _day,
                  decoration: const InputDecoration(
                    labelText: 'Day',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                  items: ZyvoraDays.ordered
                      .map(
                        (d) => DropdownMenuItem(
                          value: d,
                          child: Text(d, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _day = v);
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                  items: _categories
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(c, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _category = v);
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _repeatType,
                  decoration: const InputDecoration(
                    labelText: 'Repeat',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'once', child: Text('Once')),
                    DropdownMenuItem(value: 'daily', child: Text('Daily')),
                    DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                    DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _repeatType = v);
                  },
                ),
                const SizedBox(height: 14),
                Material(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(ZyvoraRadius.md),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                    leading: const Icon(Icons.schedule_rounded),
                    title: Text(
                      TimeUtils.formatClockTime(_time.hour, _time.minute),
                    ),
                    trailing: const Icon(Icons.expand_more_rounded),
                    onTap: _pickTime,
                  ),
                ),
                const SizedBox(height: 6),
                SwitchListTile(
                  value: _notifEnabled,
                  onChanged: (v) => setState(() => _notifEnabled = v),
                  title: const Text('Notification'),
                  secondary: const Icon(Icons.notifications_active_outlined),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  value: _alarmEnabled,
                  onChanged: (v) => setState(() => _alarmEnabled = v),
                  title: const Text('Alarm'),
                  secondary: const Icon(Icons.alarm_rounded),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check_rounded),
                    label: Text(
                      widget.editTitle != null
                          ? 'Save changes'
                          : 'Save reminder',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: ZyvoraColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ZyvoraRadius.md),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (!mounted || picked == null) return;
    setState(() => _time = picked);
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      if (!mounted) return;
      setState(() => _error = 'Add a title');
      return;
    }
    final notesRaw = _notesCtrl.text.trim();
    Navigator.of(context).pop(
      AddReminderResult(
        title: title,
        day: _day,
        hour: _time.hour,
        minute: _time.minute,
        category: _category,
        lifeMode: widget.lifeMode,
        repeatType: _repeatType,
        priority: _priority,
        notes: notesRaw.isEmpty ? null : notesRaw,
        notificationEnabled: _notifEnabled,
        alarmEnabled: _alarmEnabled,
      ),
    );
  }
}

class _PrioChip extends StatelessWidget {
  const _PrioChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.accent,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? ZyvoraColors.accentBlue;
    return Expanded(
      child: Material(
        color: selected
            ? color.withValues(alpha: 0.22)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(ZyvoraRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ZyvoraRadius.md),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ZyvoraRadius.md),
              border: Border.all(
                color: selected
                    ? color.withValues(alpha: 0.65)
                    : Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.45),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected ? color : null,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
