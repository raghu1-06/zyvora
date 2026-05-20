import 'package:flutter/material.dart';
import 'dart:async';
import '../models/reminder.dart';
import '../core/theme/app_theme.dart';
import '../utils/time_utils.dart';

class CountdownCard extends StatefulWidget {
  final Reminder? nextReminder;

  /// When false (e.g. another bottom tab is selected), periodic updates stop
  /// so hidden [IndexedStack] children do not tick every minute.
  final bool active;

  const CountdownCard({
    super.key,
    required this.nextReminder,
    this.active = true,
  });

  @override
  State<CountdownCard> createState() => _CountdownCardState();
}

class _CountdownCardState extends State<CountdownCard> {
  Timer? _timer;

  void _syncTimer() {
    _timer?.cancel();
    _timer = null;
    if (!widget.active || widget.nextReminder == null) return;
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    _syncTimer();
  }

  @override
  void didUpdateWidget(CountdownCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active ||
        oldWidget.nextReminder?.id != widget.nextReminder?.id ||
        oldWidget.nextReminder?.hour != widget.nextReminder?.hour ||
        oldWidget.nextReminder?.minute != widget.nextReminder?.minute) {
      _syncTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.nextReminder == null || !widget.active) {
      return const SizedBox.shrink();
    }

    final r = widget.nextReminder!;
    final now = DateTime.now();
    final reminderTime = DateTime(
      now.year,
      now.month,
      now.day,
      r.hour,
      r.minute,
    );

    final diff = reminderTime.difference(now);
    if (diff.isNegative) {
      return const SizedBox.shrink();
    }

    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;

    final timeStr = hours > 0 ? '$hours hr $minutes min' : '$minutes min';

    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: ZyvoraMotion.regular,
      curve: ZyvoraMotion.curve,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ZyvoraRadius.md),
        border: Border.all(color: ZyvoraColors.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ZyvoraColors.primary.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.2 : 0.1,
              ),
              borderRadius: BorderRadius.circular(ZyvoraRadius.md),
            ),
            child: const Icon(
              Icons.timer_outlined,
              color: ZyvoraColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UPCOMING IN $timeStr',
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  r.title,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  TimeUtils.formatClockTime(r.hour, r.minute),
                  style: const TextStyle(
                    color: ZyvoraColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
