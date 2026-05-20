import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async' show unawaited;

import '../core/providers.dart';
import '../features/attendance/controllers/attendance_controller.dart';
import '../models/attendance_record.dart';
import '../utils/zyvora_animations.dart';
import '../utils/zyvora_design_system.dart';
import '../widgets/premium_components.dart';
import '../widgets/premium_navigation.dart';
import '../widgets/safe_form_widgets.dart';
import 'subject_attendance_detail_screen.dart';

class PremiumAttendanceScreen extends ConsumerStatefulWidget {
  const PremiumAttendanceScreen({super.key});

  @override
  ConsumerState<PremiumAttendanceScreen> createState() =>
      _PremiumAttendanceScreenState();
}

class _PremiumAttendanceScreenState extends ConsumerState<PremiumAttendanceScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      unawaited(ref.read(attendanceControllerProvider).loadAll());
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: const PremiumAppBar(title: 'Attendance'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSubjectSheet(context),
        child: const Icon(Icons.add),
      ),
      body: Consumer(
        builder: (context, ref, _) {
          final service = ref.watch(attendanceControllerProvider);
          final stats = service.getAllStats();
          return ZyvoraAnimations.fadeSlideUp(
            duration: const Duration(milliseconds: 400),
            slideDistance: 24,
            child: _buildAttendanceContent(context, stats),
          );
        },
      ),
    );
  }

  Widget _buildAttendanceContent(
    BuildContext context,
    List<SubjectAttendance> stats,
  ) {
    final overallPercentage = _calculateOverallAttendance(stats);

    return CustomScrollView(
      slivers: [
        // Overall stats header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(ZyvoraDesignSystem.spacing16),
            child: PremiumCard(
              child: Padding(
                padding: const EdgeInsets.all(ZyvoraDesignSystem.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Overall Attendance',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: ZyvoraDesignSystem.weightSemiBold,
                          ),
                        ),
                        Text(
                          '${overallPercentage.round()}%',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: _getAttendanceColor(overallPercentage),
                            fontWeight: ZyvoraDesignSystem.weightBold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: ZyvoraDesignSystem.spacing12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        ZyvoraDesignSystem.radiusSmall,
                      ),
                      child: LinearProgressIndicator(
                        value: overallPercentage / 100,
                        backgroundColor: ZyvoraDesignSystem.surfaceAlt,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getAttendanceColor(overallPercentage),
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Subjects grid or empty state
        if (stats.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ZyvoraDesignSystem.spacing16,
                vertical: ZyvoraDesignSystem.spacing32,
              ),
              child: PremiumEmptyState(
                icon: Icons.school_outlined,
                title: 'No subjects yet',
                subtitle: 'Add your first subject to track attendance',
                action: PremiumButton(
                  label: 'Add Subject',
                  onPressed: () => _showAddSubjectSheet(context),
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(ZyvoraDesignSystem.spacing16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: ZyvoraDesignSystem.spacing12,
                crossAxisSpacing: ZyvoraDesignSystem.spacing12,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final stat = stats[index];
                  return ZyvoraAnimations.scaleIn(
                    duration: const Duration(milliseconds: 300),
                    begin: 0.8,
                    curve: Curves.easeOutBack,
                    child: _buildSubjectCard(context, stat),
                  );
                },
                childCount: stats.length,
              ),
            ),
          ),

        // Bottom padding for navbar
        SliverToBoxAdapter(child: const SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildSubjectCard(BuildContext context, SubjectAttendance stat) {
    final percentage = stat.percentage;

    return PremiumCard(
      onTap: () => _showSubjectDetails(context, stat),
      padding: const EdgeInsets.all(ZyvoraDesignSystem.spacing12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Circular progress
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 4,
                  backgroundColor: ZyvoraDesignSystem.surfaceAlt,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getAttendanceColor(percentage),
                  ),
                ),
                Text(
                  '${percentage.round()}%',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: ZyvoraDesignSystem.weightBold,
                  ),
                ),
              ],
            ),
          ),

          // Subject name
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ZyvoraDesignSystem.spacing8,
            ),
            child: Text(
              stat.subject,
              style: Theme.of(context).textTheme.titleSmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),

          // Stats
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ZyvoraDesignSystem.spacing8,
              vertical: ZyvoraDesignSystem.spacing8,
            ),
            decoration: BoxDecoration(
              color: ZyvoraDesignSystem.surfaceAlt,
              borderRadius: BorderRadius.circular(
                ZyvoraDesignSystem.radiusSmall,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '${stat.present}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: ZyvoraDesignSystem.weightBold,
                      ),
                    ),
                    Text(
                      'Present',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: ZyvoraDesignSystem.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 20,
                  width: 1,
                  color: ZyvoraDesignSystem.surfaceCard,
                ),
                Column(
                  children: [
                    Text(
                      '${stat.total}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: ZyvoraDesignSystem.weightBold,
                      ),
                    ),
                    Text(
                      'Total',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: ZyvoraDesignSystem.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateOverallAttendance(List<SubjectAttendance> stats) {
    if (stats.isEmpty) return 0;
    double totalPresent = 0;
    double totalClasses = 0;
    for (final stat in stats) {
      totalPresent += stat.present;
      totalClasses += stat.total;
    }
    return totalClasses > 0 ? (totalPresent / totalClasses * 100) : 0;
  }

  Color _getAttendanceColor(double percentage) {
    if (percentage >= 75) return ZyvoraDesignSystem.accentGreen;
    if (percentage >= 50) return ZyvoraDesignSystem.accentOrange;
    return ZyvoraDesignSystem.accentRed;
  }

  void _showAddSubjectSheet(BuildContext context) {
    final parentContext = context;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _AddSubjectSheet(
        onSave: (subject) {
          Navigator.pop(sheetContext);
          _saveSubject(parentContext, subject);
        },
      ),
    );
  }

  void _showSubjectDetails(BuildContext context, SubjectAttendance stat) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SubjectAttendanceDetailScreen(subject: stat.subject),
      ),
    );
  }

  void _saveSubject(BuildContext context, String subject) {
    if (!mounted) return;
    final svc = ref.read(attendanceControllerProvider);
    final scaffold = ScaffoldMessenger.of(context);

    unawaited(
      svc
          .addSubject(subject)
          .then((_) {
            if (!mounted) return;
            scaffold.clearSnackBars();
            scaffold.showSnackBar(
              const SnackBar(
                content: Text('Subject added'),
                duration: Duration(seconds: 2),
              ),
            );
          })
          .catchError((Object e) {
            if (!mounted) return;
            scaffold.clearSnackBars();
            scaffold.showSnackBar(
              SnackBar(
                content: Text(e.toString()),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }),
    );
  }
}

class _AddSubjectSheet extends StatefulWidget {
  final Function(String) onSave;

  const _AddSubjectSheet({required this.onSave});

  @override
  State<_AddSubjectSheet> createState() => _AddSubjectSheetState();
}

class _AddSubjectSheetState extends State<_AddSubjectSheet> {
  late TextEditingController _subjectCtrl;

  @override
  void initState() {
    super.initState();
    _subjectCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: ZyvoraDesignSystem.spacing16,
        right: ZyvoraDesignSystem.spacing16,
        top: ZyvoraDesignSystem.spacing16,
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            ZyvoraDesignSystem.spacing16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add Subject', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: ZyvoraDesignSystem.spacing16),
          SafeTextField(
            controller: _subjectCtrl,
            fieldName: 'Subject',
            labelText: 'Subject Name',
            hintText: 'e.g., Mathematics',
            maxLength: 50,
          ),
          const SizedBox(height: ZyvoraDesignSystem.spacing24),
          Row(
            children: [
              Expanded(
                child: PremiumButton(
                  label: 'Cancel',
                  outlined: true,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: ZyvoraDesignSystem.spacing12),
              Expanded(
                child: ListenableBuilder(
                  listenable: _subjectCtrl,
                  builder: (context, _) {
                    final isEmpty = _subjectCtrl.text.trim().isEmpty;
                    return PremiumButton(
                      label: 'Add',
                      onPressed: isEmpty ? () {} : () => widget.onSave(_subjectCtrl.text.trim()),
                    );
                  }
                ),
              ),
            ],
          ),
          const SizedBox(height: ZyvoraDesignSystem.spacing16),
        ],
      ),
    );
  }
}
