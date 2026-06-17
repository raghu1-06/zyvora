import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../../features/zeni/presentation/zeni_bottom_sheet.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _showZeni(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ZeniBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          navigationShell,
        ],
      ),
      bottomNavigationBar: ZyvoraNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        onZeniTap: () => _showZeni(context),
      ),
    );
  }
}

class ZyvoraNavBar extends StatelessWidget {
  const ZyvoraNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onZeniTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onZeniTap;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 68 + bottomPadding,
          padding: EdgeInsets.only(bottom: bottomPadding),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF111128) : const Color(0xFFFFFFFF),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 16,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavBarItem(
                iconOutlined: Icons.home_outlined,
                iconRounded: Icons.home_rounded,
                label: 'Home',
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavBarItem(
                iconOutlined: Icons.task_alt_outlined,
                iconRounded: Icons.task_alt_rounded,
                label: 'Tasks',
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              const SizedBox(width: 70), // Space for Zeni button
              _NavBarItem(
                iconOutlined: Icons.sticky_note_2_outlined,
                iconRounded: Icons.sticky_note_2_rounded,
                label: 'Notes',
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavBarItem(
                iconOutlined: Icons.fact_check_outlined,
                iconRounded: Icons.fact_check_rounded,
                label: 'Attendance',
                isSelected: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
        Positioned(
          top: -14,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: onZeniTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFF7C3AED),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x507C3AED),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 28,
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 1500.ms),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.iconOutlined,
    required this.iconRounded,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData iconOutlined;
  final IconData iconRounded;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isSelected 
        ? (isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED)) 
        : const Color(0xFF9CA3AF);
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 70),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? iconRounded : iconOutlined,
              key: ValueKey(isSelected),
              color: color,
              size: 24,
            ).animate(target: isSelected ? 1 : 0).scale(begin: const Offset(0.8, 0.8), duration: 150.ms),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                letterSpacing: 0.3,
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
