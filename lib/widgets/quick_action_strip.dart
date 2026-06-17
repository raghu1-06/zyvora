import 'package:flutter/material.dart';

/// Horizontal circular quick actions (premium strip).
class QuickActionStrip extends StatelessWidget {
  const QuickActionStrip({super.key, required this.actions});

  final List<({IconData icon, String label, VoidCallback onTap, Color accent})>
  actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemCount: actions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final a = actions[i];
          return Column(
            children: [
              Material(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: a.onTap,
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: Icon(a.icon, color: a.accent, size: 24),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxWidth: 80),
                child: Text(
                  a.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
