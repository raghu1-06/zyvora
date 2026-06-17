import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'premium_components.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: ZyvoraColors.primarySoft.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.12
                    : 1,
              ),
              borderRadius: BorderRadius.circular(ZyvoraRadius.md),
            ),
            child: Icon(icon, color: scheme.primary, size: 26),
          ),
          const SizedBox(height: 14),
          Text(title, style: t.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(message, style: t.bodySmall, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}
