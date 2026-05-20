import 'package:flutter/material.dart';

import '../models/insight.dart';
import '../core/theme/app_theme.dart';

class InsightCard extends StatelessWidget {
  final Insight insight;

  const InsightCard({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _insightColor(insight.type);

    return AnimatedContainer(
      duration: ZyvoraMotion.regular,
      curve: ZyvoraMotion.curve,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ZyvoraRadius.md),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.72),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.18 : 0.1,
              ),
              borderRadius: BorderRadius.circular(ZyvoraRadius.md),
            ),
            child: Icon(_insightIcon(insight.type), color: color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(insight.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(insight.description, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _insightIcon(InsightType type) {
    switch (type) {
      case InsightType.productivity:
        return Icons.query_stats;
      case InsightType.attendance:
        return Icons.fact_check_outlined;
      case InsightType.routine:
        return Icons.loop;
      case InsightType.burnout:
        return Icons.priority_high_rounded;
      case InsightType.streak:
        return Icons.local_fire_department_outlined;
      case InsightType.suggestion:
        return Icons.lightbulb_outline;
    }
  }

  Color _insightColor(InsightType type) {
    switch (type) {
      case InsightType.productivity:
        return ZyvoraColors.green;
      case InsightType.attendance:
        return ZyvoraColors.blue;
      case InsightType.routine:
        return ZyvoraColors.purple;
      case InsightType.burnout:
        return ZyvoraColors.red;
      case InsightType.streak:
        return ZyvoraColors.coral;
      case InsightType.suggestion:
        return ZyvoraColors.cyan;
    }
  }
}
