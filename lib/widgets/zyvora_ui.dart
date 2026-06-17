import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class ZyvoraCard extends StatelessWidget {
  const ZyvoraCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.onTap,
    this.color,
    this.gradient,
    this.borderColor,
    this.radius = ZyvoraRadius.xl,
    this.shadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;
  final double radius;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final border =
        borderColor ?? theme.colorScheme.outline.withValues(alpha: 0.62);
    final bg = color ?? theme.colorScheme.surface;

    final content = AnimatedContainer(
      duration: ZyvoraMotion.regular,
      curve: ZyvoraMotion.curve,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? bg : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border),
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.055),
                  blurRadius: 26,
                  offset: const Offset(0, 14),
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: content,
      ),
    );
  }
}

class ZyvoraHeaderButton extends StatelessWidget {
  const ZyvoraHeaderButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.badge = false,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool badge;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final button = Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.62),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.045),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Icon(icon, color: theme.colorScheme.onSurface, size: 24),
              ),
              if (badge)
                Positioned(
                  right: 10,
                  top: 9,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: ZyvoraColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

class ZyvoraSectionHeader extends StatelessWidget {
  const ZyvoraSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.icon,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
      child: Row(
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const Spacer(),
          if (actionLabel != null && onAction != null)
            TextButton.icon(
              onPressed: onAction,
              icon: Icon(icon ?? Icons.chevron_right_rounded, size: 18),
              label: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}

class ZyvoraIconBadge extends StatelessWidget {
  const ZyvoraIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 50,
    this.iconSize = 25,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}

class ZyvoraMetricTile extends StatelessWidget {
  const ZyvoraMetricTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.caption,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ZyvoraIconBadge(icon: icon, color: color, size: 48, iconSize: 24),
        const SizedBox(height: 12),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall,
        ),
        if (caption != null) ...[
          const SizedBox(height: 2),
          Text(
            caption!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ],
    );
  }
}

class ZyvoraProgressRing extends StatelessWidget {
  const ZyvoraProgressRing({
    super.key,
    required this.value,
    this.size = 132,
    this.stroke = 12,
    this.color = ZyvoraColors.primary,
    this.backgroundColor,
    this.child,
  });

  final double value;
  final double size;
  final double stroke;
  final Color color;
  final Color? backgroundColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final bg =
        backgroundColor ??
        Theme.of(context).colorScheme.outline.withValues(alpha: 0.18);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          value: value.clamp(0, 1),
          stroke: stroke,
          color: color,
          backgroundColor: bg,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.value,
    required this.stroke,
    required this.color,
    required this.backgroundColor,
  });

  final double value;
  final double stroke;
  final Color color;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (math.min(size.width, size.height) - stroke) / 2;
    final base = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final active = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, base);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * value,
      false,
      active,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.stroke != stroke;
  }
}

class ZyvoraPill extends StatelessWidget {
  const ZyvoraPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class ZyvoraEmptyState extends StatelessWidget {
  const ZyvoraEmptyState({
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
    final theme = Theme.of(context);
    return ZyvoraCard(
      shadow: false,
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          ZyvoraIconBadge(icon: icon, color: ZyvoraColors.primary, size: 58),
          const SizedBox(height: 14),
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}

Color zyvoraPriorityColor(String priority) {
  switch (priority.toLowerCase()) {
    case 'high':
      return ZyvoraColors.error;
    case 'low':
      return ZyvoraColors.success;
    default:
      return ZyvoraColors.primary;
  }
}

Color zyvoraCategoryColor(String category) {
  switch (category) {
    case 'Class':
    case 'Academic':
    case 'Water':
      return ZyvoraColors.secondary;
    case 'Meeting':
    case 'Client Meeting':
    case 'Sleep':
      return ZyvoraColors.primary;
    case 'Assignment':
    case 'Task':
    case 'Project':
    case 'Project Deadline':
    case 'Family':
      return ZyvoraColors.warning;
    case 'Exam':
    case 'Deadline':
    case 'Medicine':
      return ZyvoraColors.error;
    case 'Study Session':
    case 'Focus Session':
    case 'Study':
      return ZyvoraColors.cyan;
    case 'Gym':
      return ZyvoraColors.success;
    case 'Habit':
      return ZyvoraColors.warning;
    default:
      return ZyvoraColors.primary;
  }
}
