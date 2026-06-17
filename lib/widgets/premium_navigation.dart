import 'package:flutter/material.dart';
import '../utils/zyvora_design_system.dart';

/// **PREMIUM BOTTOM NAVIGATION BAR** - Floating navbar design
class PremiumNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onIndexChanged;
  final List<PremiumNavItem> items;

  const PremiumNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: ZyvoraDesignSystem.spacing20,
          left: ZyvoraDesignSystem.spacing16,
          right: ZyvoraDesignSystem.spacing16,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: ZyvoraDesignSystem.backgroundSecondary,
            borderRadius: BorderRadius.circular(ZyvoraDesignSystem.radiusXL),
            border: Border.all(color: ZyvoraDesignSystem.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              items.length,
              (index) => Expanded(
                child: _buildNavItem(
                  context,
                  items[index],
                  index == currentIndex,
                  () => onIndexChanged(index),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    PremiumNavItem item,
    bool isActive,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ZyvoraDesignSystem.radiusXL),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: ZyvoraDesignSystem.spacing12,
            horizontal: ZyvoraDesignSystem.spacing8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.icon,
                color: isActive
                    ? ZyvoraDesignSystem.accentBlue
                    : ZyvoraDesignSystem.textTertiary,
                size: 24,
              ),
              const SizedBox(height: ZyvoraDesignSystem.spacing4),
              Text(
                item.label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isActive
                      ? ZyvoraDesignSystem.accentBlue
                      : ZyvoraDesignSystem.textTertiary,
                  fontWeight: isActive
                      ? ZyvoraDesignSystem.weightSemiBold
                      : ZyvoraDesignSystem.weightRegular,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// **NAVIGATION ITEM MODEL**
class PremiumNavItem {
  final String label;
  final IconData icon;
  final IconData? activeIcon;

  const PremiumNavItem({
    required this.label,
    required this.icon,
    this.activeIcon,
  });
}

/// **PREMIUM APP SHELL** - Main app container with navigation
class PremiumAppShell extends StatefulWidget {
  final List<Widget> screens;
  final List<PremiumNavItem> navItems;
  final int initialIndex;

  const PremiumAppShell({
    super.key,
    required this.screens,
    required this.navItems,
    this.initialIndex = 0,
  }) : assert(screens.length == navItems.length);

  @override
  State<PremiumAppShell> createState() => _PremiumAppShellState();
}

class _PremiumAppShellState extends State<PremiumAppShell>
    with TickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _fadeController = AnimationController(
      duration: ZyvoraDesignSystem.durationBase,
      vsync: this,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    if (index == _currentIndex) return;
    if (!mounted) return;

    _fadeController.forward(from: 0);
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZyvoraDesignSystem.backgroundPrimary,
      body: Stack(
        children: [
          // Screen content
          FadeTransition(
            opacity: _fadeController,
            child: IndexedStack(index: _currentIndex, children: widget.screens),
          ),

          // Navigation bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: PremiumNavigationBar(
              currentIndex: _currentIndex,
              items: widget.navItems,
              onIndexChanged: _onNavItemTapped,
            ),
          ),
        ],
      ),
    );
  }
}

/// **PREMIUM APP BAR** - Elegant top bar
class PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool withBackButton;
  final VoidCallback? onBackPressed;
  final Widget? titleWidget;
  final double? elevation;

  const PremiumAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.withBackButton = true,
    this.onBackPressed,
    this.titleWidget,
    this.elevation = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: ZyvoraDesignSystem.backgroundPrimary,
        border: Border(
          bottom: BorderSide(color: ZyvoraDesignSystem.divider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Leading
          if (leading != null)
            leading!
          else if (withBackButton && Navigator.of(context).canPop())
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          else
            const SizedBox(width: ZyvoraDesignSystem.spacing16),

          // Title
          Expanded(
            child:
                titleWidget ??
                (title != null
                    ? Text(
                        title!,
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : const SizedBox()),
          ),

          // Actions
          if (actions != null) ...[
            ...actions!,
            const SizedBox(width: ZyvoraDesignSystem.spacing8),
          ] else
            const SizedBox(width: ZyvoraDesignSystem.spacing16),
        ],
      ),
    );
  }
}

/// **PREMIUM SLIVER APP BAR** - Scrollable header
class PremiumSliverAppBar extends StatelessWidget {
  final String title;
  final double expandedHeight;
  final Widget? flexibleSpace;
  final List<Widget>? actions;
  final bool pinned;

  const PremiumSliverAppBar({
    super.key,
    required this.title,
    this.expandedHeight = 200,
    this.flexibleSpace,
    this.actions,
    this.pinned = true,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: ZyvoraDesignSystem.backgroundPrimary,
      foregroundColor: ZyvoraDesignSystem.textPrimary,
      elevation: 0,
      pinned: pinned,
      expandedHeight: expandedHeight,
      title: Text(title, style: Theme.of(context).textTheme.titleLarge),
      actions: actions,
      flexibleSpace:
          flexibleSpace ??
          FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ZyvoraDesignSystem.backgroundPrimary,
                    ZyvoraDesignSystem.backgroundSecondary,
                  ],
                ),
              ),
            ),
          ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: ZyvoraDesignSystem.divider),
      ),
    );
  }
}
