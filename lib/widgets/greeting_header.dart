import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class GreetingHeader extends StatelessWidget {
  final String greeting;
  final String userName;
  final double productivityPercent;
  final int todayCount;
  final int completedCount;
  final VoidCallback? onSettingsTap;

  const GreetingHeader({
    super.key,
    required this.greeting,
    required this.userName,
    required this.productivityPercent,
    required this.todayCount,
    required this.completedCount,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = productivityPercent.clamp(0, 100);

    return AnimatedContainer(
      duration: ZyvoraMotion.regular,
      curve: ZyvoraMotion.curve,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ZyvoraRadius.md),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: ZyvoraColors.primary.withValues(
                    alpha: theme.brightness == Brightness.dark ? 0.2 : 0.1,
                  ),
                  borderRadius: BorderRadius.circular(ZyvoraRadius.md),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: ZyvoraColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(greeting, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 2),
                    Text(
                      userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
              if (onSettingsTap != null)
                IconButton.filledTonal(
                  tooltip: 'Settings',
                  onPressed: onSettingsTap,
                  icon: const Icon(Icons.settings_outlined),
                ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(ZyvoraRadius.sm),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: percent / 100),
              duration: ZyvoraMotion.regular,
              curve: ZyvoraMotion.curve,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  minHeight: 8,
                  value: value,
                  backgroundColor: theme.colorScheme.outline.withValues(
                    alpha: theme.brightness == Brightness.dark ? 0.24 : 0.3,
                  ),
                  valueColor: const AlwaysStoppedAnimation(
                    ZyvoraColors.primary,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatPill(
                icon: Icons.check_circle_outline,
                label: '$completedCount of $todayCount done',
                color: ZyvoraColors.green,
              ),
              _StatPill(
                icon: Icons.trending_up,
                label: '${percent.round()}% today',
                color: ZyvoraColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(ZyvoraRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
