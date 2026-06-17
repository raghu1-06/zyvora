import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'premium_components.dart';

/// Compact overview tile for the home dashboard. Shows a colored glyph,
/// a primary value, a label, and an optional trend hint.
class DashboardOverviewCard extends StatelessWidget {
  const DashboardOverviewCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.hint,
    this.accent = ZyvoraColors.primary,
    this.accentSoft = ZyvoraColors.primarySoft,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? hint;
  final Color accent;
  final Color accentSoft;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PremiumCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentSoft.withValues(alpha: isDark ? 0.16 : 1),
                  borderRadius: BorderRadius.circular(ZyvoraRadius.sm),
                ),
                child: Icon(icon, color: accent, size: 18),
              ),
              const Spacer(),
              if (hint != null)
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(hint!, style: t.labelSmall),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: t.headlineSmall),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(label, style: t.bodySmall),
          ),
        ],
      ),
    );
  }
}
