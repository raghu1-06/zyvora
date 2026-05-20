import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/design_tokens.dart';
import '../core/providers.dart';
import '../models/zyvora_role.dart';

class AnimatedSegmentedSwitch extends ConsumerWidget {
  const AnimatedSegmentedSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userControllerProvider);
    final mode = user.lifeMode ?? LifeMode.personal;
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _SegmentButton(
                  label: 'Personal',
                  active: mode == LifeMode.personal,
                  onTap: () => _selectMode(ref, LifeMode.personal),
                ),
              ),
              const SizedBox(width: DT.s8),
              Expanded(
                child: _SegmentButton(
                  label: 'Professional',
                  active: mode == LifeMode.professional,
                  onTap: () => _selectMode(ref, LifeMode.professional),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectMode(WidgetRef ref, LifeMode mode) async {
    final current = ref.read(userControllerProvider).lifeMode;
    if (current == mode) return;
    await HapticFeedback.selectionClick();
    await ref.read(userControllerProvider).setLifeMode(mode);
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Semantics(
      button: true,
      selected: active,
      label: label,
      child: AnimatedContainer(
        duration: DT.motionMed,
        curve: Curves.easeOutCubic,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: active
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accent.withValues(alpha: 0.18),
                    accent.withValues(alpha: 0.08),
                  ],
                )
              : null,
          boxShadow: active
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
          border: Border.all(
            color: active ? accent.withValues(alpha: 0.2) : Colors.transparent,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onTap,
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: DT.motionShort,
                curve: Curves.easeOutCubic,
                style: theme.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: active
                      ? accent
                      : theme.colorScheme.onSurface.withValues(alpha: 0.68),
                ),
                child: Text(label),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
