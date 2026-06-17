import 'package:flutter/material.dart';

import '../models/alarm.dart';
import '../core/theme/app_theme.dart';
import 'premium_components.dart';

class AlarmTile extends StatelessWidget {
  const AlarmTile({
    super.key,
    required this.alarm,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  final Alarm alarm;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final timeStr =
        '${alarm.hour.toString().padLeft(2, '0')}:${alarm.minute.toString().padLeft(2, '0')}';

    return Dismissible(
      key: ValueKey('alarm-${alarm.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: ZyvoraColors.red.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(ZyvoraRadius.lg),
        ),
        child: const Icon(Icons.delete_outline, color: ZyvoraColors.red),
      ),
      onDismissed: (_) => onDelete(),
      child: PremiumCard(
        onTap: onTap,
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeStr,
                    style: t.headlineMedium?.copyWith(
                      color: alarm.enabled ? scheme.onSurface : scheme.outline,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alarm.label,
                    style: t.titleSmall?.copyWith(
                      color: alarm.enabled ? scheme.onSurface : scheme.outline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(alarm.repeatLabel(), style: t.bodySmall),
                ],
              ),
            ),
            Switch.adaptive(
              value: alarm.enabled,
              onChanged: onToggle,
              activeThumbColor: ZyvoraColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
