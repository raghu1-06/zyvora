import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/design_tokens.dart';
import '../core/providers.dart';
import '../features/tasks/nl_parser.dart';
import 'premium_components.dart';

class NLQuickAddBar extends ConsumerStatefulWidget {
  final VoidCallback? onAdded;

  const NLQuickAddBar({super.key, this.onAdded});

  @override
  ConsumerState<NLQuickAddBar> createState() => _NLQuickAddBarState();
}

class _NLQuickAddBarState extends ConsumerState<NLQuickAddBar> {
  final _ctrl = TextEditingController();
  bool _loading = false;
  ParsedQuickTask? _preview;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleChange(String value) {
    final text = value.trim();
    setState(() {
      _preview = text.isEmpty ? null : NLParser.parse(text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PremiumCard(
      padding: const EdgeInsets.all(DT.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.18),
                      theme.colorScheme.secondary.withValues(alpha: 0.12),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: DT.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick capture',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: DT.s4),
                    Text(
                      'Type naturally. The app will shape the reminder for you.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DT.s16),
          TextField(
            controller: _ctrl,
            onChanged: _handleChange,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: 'Gym tomorrow at 6 PM',
              prefixIcon: const Icon(Icons.edit_outlined),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
            ),
          ),
          if (_preview != null) ...[
            const SizedBox(height: DT.s12),
            Wrap(
              spacing: DT.s8,
              runSpacing: DT.s8,
              children: [
                _PreviewChip(icon: Icons.event_outlined, label: _preview!.day),
                _PreviewChip(icon: Icons.schedule_outlined, label: _clockLabel(_preview!.hour, _preview!.minute)),
                _PreviewChip(icon: Icons.label_outline, label: _preview!.category),
                _PreviewChip(icon: Icons.flag_outlined, label: _preview!.priority),
                _PreviewChip(icon: Icons.repeat_rounded, label: _preview!.repeatType),
              ],
            ),
          ],
          const SizedBox(height: DT.s12),
          Wrap(
            spacing: DT.s8,
            runSpacing: DT.s8,
            children: [
              _SuggestionChip(label: 'Gym tomorrow at 6 PM', onTap: () => _applySuggestion('Gym tomorrow at 6 PM')),
              _SuggestionChip(label: 'DBMS assignment Friday', onTap: () => _applySuggestion('DBMS assignment Friday')),
              _SuggestionChip(label: 'Drink water every 2 hours', onTap: () => _applySuggestion('Drink water every 2 hours')),
              _SuggestionChip(label: 'Meeting Monday 10 AM', onTap: () => _applySuggestion('Meeting Monday 10 AM')),
            ],
          ),
          const SizedBox(height: DT.s16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _loading ? null : _submit,
              icon: _loading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
              label: const Text('Capture task'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _loading) return;

    setState(() => _loading = true);
    try {
      final parsed = NLParser.parse(text);
      final reminders = ref.read(reminderControllerProvider);
      final currentMode = ref.read(userControllerProvider).lifeMode?.storageValue ?? 'personal';
      await HapticFeedback.lightImpact();
      await reminders.addReminder(
        title: parsed.title,
        day: parsed.day,
        hour: parsed.hour,
        minute: parsed.minute,
        category: parsed.category,
        lifeMode: currentMode,
        repeatType: parsed.repeatType,
        priority: parsed.priority,
      );
      _ctrl.clear();
      if (mounted) {
        setState(() => _preview = null);
      }
      widget.onAdded?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not add quick task: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applySuggestion(String text) {
    _ctrl.text = text;
    _ctrl.selection = TextSelection.collapsed(offset: _ctrl.text.length);
    _handleChange(text);
    HapticFeedback.selectionClick();
  }

  String _clockLabel(int hour, int minute) {
    final normalizedHour = hour % 24;
    final suffix = normalizedHour >= 12 ? 'PM' : 'AM';
    final displayHour = normalizedHour % 12 == 0 ? 12 : normalizedHour % 12;
    final minuteLabel = minute.toString().padLeft(2, '0');
    return '$displayHour:$minuteLabel $suffix';
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _PreviewChip extends StatelessWidget {
  const _PreviewChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DT.s12, vertical: DT.s8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: DT.s4),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class NLQuickAddSheet extends ConsumerStatefulWidget {
  final VoidCallback? onAdded;

  const NLQuickAddSheet({super.key, this.onAdded});

  @override
  ConsumerState<NLQuickAddSheet> createState() => _NLQuickAddSheetState();
}

class _NLQuickAddSheetState extends ConsumerState<NLQuickAddSheet> {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();
  bool _loading = false;
  ParsedQuickTask? _preview;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleChange(String value) {
    final text = value.trim();
    setState(() {
      _preview = text.isEmpty ? null : NLParser.parse(text);
    });
  }

  void _applySuggestion(String text) {
    _ctrl.text = text;
    _ctrl.selection = TextSelection.collapsed(offset: _ctrl.text.length);
    _handleChange(text);
    HapticFeedback.selectionClick();
  }

  Future<void> _submit() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _loading) return;

    setState(() => _loading = true);
    try {
      final parsed = NLParser.parse(text);
      final reminders = ref.read(reminderControllerProvider);
      final currentMode = ref.read(userControllerProvider).lifeMode?.storageValue ?? 'personal';
      await HapticFeedback.lightImpact();
      await reminders.addReminder(
        title: parsed.title,
        day: parsed.day,
        hour: parsed.hour,
        minute: parsed.minute,
        category: parsed.category,
        lifeMode: currentMode,
        repeatType: parsed.repeatType,
        priority: parsed.priority,
      );
      
      if (!mounted) return;
      widget.onAdded?.call();
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not add quick task: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Quick Capture',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _ctrl,
                focusNode: _focusNode,
                onChanged: _handleChange,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: 'e.g. Gym tomorrow at 6 PM',
                  prefixIcon: const Icon(Icons.edit_outlined),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                ),
              ),
              if (_preview != null) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _PreviewChip(icon: Icons.event_outlined, label: _preview!.day),
                    _PreviewChip(
                      icon: Icons.schedule_outlined,
                      label: _clockLabel(_preview!.hour, _preview!.minute),
                    ),
                    _PreviewChip(icon: Icons.label_outline, label: _preview!.category),
                    _PreviewChip(icon: Icons.flag_outlined, label: _preview!.priority),
                  ],
                ),
              ],
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _SuggestionChip(
                      label: 'Gym tomorrow at 6 PM',
                      onTap: () => _applySuggestion('Gym tomorrow at 6 PM'),
                    ),
                    const SizedBox(width: 6),
                    _SuggestionChip(
                      label: 'DBMS assignment Friday',
                      onTap: () => _applySuggestion('DBMS assignment Friday'),
                    ),
                    const SizedBox(width: 6),
                    _SuggestionChip(
                      label: 'Drink water every 2 hours',
                      onTap: () => _applySuggestion('Drink water every 2 hours'),
                    ),
                    const SizedBox(width: 6),
                    _SuggestionChip(
                      label: 'Meeting Monday 10 AM',
                      onTap: () => _applySuggestion('Meeting Monday 10 AM'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _loading ? null : _submit,
                  icon: _loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                  label: const Text('Capture task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _clockLabel(int hour, int minute) {
    final normalizedHour = hour % 24;
    final suffix = normalizedHour >= 12 ? 'PM' : 'AM';
    final displayHour = normalizedHour % 12 == 0 ? 12 : normalizedHour % 12;
    final minuteLabel = minute.toString().padLeft(2, '0');
    return '$displayHour:$minuteLabel $suffix';
  }
}

