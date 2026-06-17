import 'package:flutter/material.dart';
import '../utils/zyvora_design_system.dart';

/// **PREMIUM BUTTON WIDGET** - Unified button system
class PremiumButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Widget? icon;
  final bool outlined;
  final bool fullWidth;
  final double? customHeight;

  const PremiumButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.outlined = false,
    this.fullWidth = true,
    this.customHeight,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon!,
              const SizedBox(width: ZyvoraDesignSystem.spacing8),
              Text(label),
            ],
          )
        : Text(label);

    final button = outlined
        ? OutlinedButton(
            onPressed: isLoading || isDisabled ? null : onPressed,
            child: content,
          )
        : ElevatedButton(
            onPressed: isLoading || isDisabled ? null : onPressed,
            child: content,
          );

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        height: customHeight,
        child: button,
      );
    }

    return button;
  }
}

/// **PREMIUM CARD** - Elegant floating card
class PremiumCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final bool withBorder;
  final Color? borderColor;
  final bool withGradient;

  const PremiumCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.height,
    this.withBorder = true,
    this.borderColor,
    this.withGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding ?? const EdgeInsets.all(ZyvoraDesignSystem.spacing16),
      decoration: BoxDecoration(
        color: ZyvoraDesignSystem.surfaceCard,
        borderRadius: BorderRadius.circular(ZyvoraDesignSystem.radiusLarge),
        border: Border.all(
          color: borderColor ?? ZyvoraDesignSystem.border,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ZyvoraDesignSystem.radiusLarge),
          child: child,
        ),
      ),
    );
  }
}

/// **PREMIUM STAT CARD** - Display metrics beautifully
class PremiumStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final IconData icon;
  final Color accentColor;
  final double progress;
  final VoidCallback? onTap;

  const PremiumStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.unit,
    this.progress = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      padding: const EdgeInsets.all(ZyvoraDesignSystem.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: ZyvoraDesignSystem.spacing4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          value,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: accentColor,
                                fontWeight: ZyvoraDesignSystem.weightBold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (unit != null) ...[
                          const SizedBox(width: ZyvoraDesignSystem.spacing4),
                          Text(
                            unit!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: ZyvoraDesignSystem.textSecondary,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    ZyvoraDesignSystem.radiusMedium,
                  ),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
            ],
          ),
          if (progress > 0)
            ClipRRect(
              borderRadius: BorderRadius.circular(
                ZyvoraDesignSystem.radiusSmall,
              ),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: ZyvoraDesignSystem.surfaceAlt,
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                minHeight: 4,
              ),
            ),
        ],
      ),
    );
  }
}

/// **PREMIUM LIST TILE** - Beautiful list items
class PremiumListTile extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? minHeight;

  const PremiumListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.backgroundColor,
    this.minHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight ?? 56),
      decoration: BoxDecoration(
        color: backgroundColor ?? ZyvoraDesignSystem.surfaceCard,
        borderRadius: BorderRadius.circular(ZyvoraDesignSystem.radiusMedium),
        border: Border.all(color: ZyvoraDesignSystem.border, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ZyvoraDesignSystem.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ZyvoraDesignSystem.spacing16,
              vertical: ZyvoraDesignSystem.spacing12,
            ),
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: ZyvoraDesignSystem.spacing12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: ZyvoraDesignSystem.spacing4),
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: ZyvoraDesignSystem.spacing12),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// **PREMIUM BOTTOM SHEET** - Elegant modal
class PremiumBottomSheet extends StatelessWidget {
  final String? title;
  final Widget child;
  final VoidCallback? onClose;
  final List<Widget>? actions;

  const PremiumBottomSheet({
    super.key,
    this.title,
    required this.child,
    this.onClose,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (context, controller) => Container(
        decoration: const BoxDecoration(
          color: ZyvoraDesignSystem.surfaceCard,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(ZyvoraDesignSystem.radiusLarge),
            topRight: Radius.circular(ZyvoraDesignSystem.radiusLarge),
          ),
          border: Border(
            top: BorderSide(color: ZyvoraDesignSystem.border, width: 1),
          ),
        ),
        child: SingleChildScrollView(
          controller: controller,
          child: Padding(
            padding: const EdgeInsets.all(ZyvoraDesignSystem.spacing20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ZyvoraDesignSystem.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: ZyvoraDesignSystem.spacing16),

                // Title
                if (title != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title!,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      IconButton(
                        onPressed: onClose ?? () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: ZyvoraDesignSystem.spacing16),
                ],

                // Content
                child,

                // Actions
                if (actions != null) ...[
                  const SizedBox(height: ZyvoraDesignSystem.spacing20),
                  ...actions!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// **PREMIUM EMPTY STATE** - Beautiful empty content
class PremiumEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const PremiumEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: ZyvoraDesignSystem.accentBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                ZyvoraDesignSystem.radiusLarge,
              ),
            ),
            child: Icon(icon, color: ZyvoraDesignSystem.accentBlue, size: 40),
          ),
          const SizedBox(height: ZyvoraDesignSystem.spacing20),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: ZyvoraDesignSystem.spacing8),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ZyvoraDesignSystem.spacing20,
              ),
              child: Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ZyvoraDesignSystem.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: ZyvoraDesignSystem.spacing20),
            action!,
          ],
        ],
      ),
    );
  }
}

/// **PREMIUM LOADING STATE** - Elegant progress indicator
class PremiumLoadingState extends StatelessWidget {
  final String? message;

  const PremiumLoadingState({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          if (message != null) ...[
            const SizedBox(height: ZyvoraDesignSystem.spacing16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: ZyvoraDesignSystem.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// **PREMIUM DIVIDER** - Clean section separator
class PremiumDivider extends StatelessWidget {
  final EdgeInsets padding;

  const PremiumDivider({
    super.key,
    this.padding = const EdgeInsets.symmetric(
      vertical: ZyvoraDesignSystem.spacing16,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Container(height: 1, color: ZyvoraDesignSystem.divider),
    );
  }
}

/// **PREMIUM SECTION HEADER** - Section title with action
class PremiumSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const PremiumSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ZyvoraDesignSystem.spacing16,
        vertical: ZyvoraDesignSystem.spacing12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

/// **PREMIUM GRADIENT BUTTON** - Advanced gradient styling
class PremiumGradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final Gradient? gradient;

  const PremiumGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient:
            gradient ??
            LinearGradient(
              colors: [
                ZyvoraDesignSystem.accentBlue,
                ZyvoraDesignSystem.accentPurple,
              ],
            ),
        borderRadius: BorderRadius.circular(ZyvoraDesignSystem.radiusMedium),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(ZyvoraDesignSystem.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ZyvoraDesignSystem.spacing24,
              vertical: ZyvoraDesignSystem.spacing12,
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    label,
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }
}
