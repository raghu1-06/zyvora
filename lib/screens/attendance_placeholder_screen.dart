import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'mode_selection_screen.dart';

/// Shown for Personal mode on the Attendance tab — encourages Pro mode for tracking.
class AttendancePlaceholderScreen extends StatelessWidget {
  const AttendancePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 56,
              color: ZyvoraColors.accentBlue.withValues(alpha: 0.85),
            ),
            const SizedBox(height: 22),
            Text(
              'Attendance tracking',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Switch to Professional mode to log classes, see safe attendance, and use the bunk calculator.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                    builder: (_) => const ModeSelectionScreen(),
                  ),
                  (_) => false,
                );
              },
              child: const Text('Switch life mode'),
            ),
          ],
        ),
      ),
    );
  }
}
