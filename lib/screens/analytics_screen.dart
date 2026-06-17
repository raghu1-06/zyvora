import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/providers.dart';
import '../core/theme/app_theme.dart';
import '../features/tasks/controllers/reminder_controller.dart';
import '../widgets/insight_card.dart';
import '../widgets/productivity_ring.dart';
import '../widgets/stat_card.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    if (!mounted) return;
    try {
      final reminders = ref.read(reminderControllerProvider);
      await ref.read(analyticsControllerProvider).loadInsights(
            reminders.reminders,
          );
      if (mounted) setState(() {});
    } catch (_) {
      // Insights generation failed; UI still works without them
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reminders = ref.watch(reminderControllerProvider);
    final analytics = ref.watch(analyticsControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Builder(
        builder: (context) {
          final vm = _AnalyticsVM.from(reminders);
          return RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
              children: [
                _OverviewCard(
                  completed: vm.completed,
                  total: vm.total,
                  rate: vm.rate,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.check_circle_outline,
                        value: '${vm.completed}',
                        label: 'Completed',
                        color: ZyvoraColors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        icon: Icons.pending_actions_outlined,
                        value: '${vm.total - vm.completed}',
                        label: 'Pending',
                        color: ZyvoraColors.yellow,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.local_fire_department_outlined,
                        value: '${vm.currentStreak}',
                        label: 'Day streak',
                        color: ZyvoraColors.coral,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        icon: Icons.today_outlined,
                        value: '${vm.todayTotalCount}',
                        label: 'Today',
                        color: ZyvoraColors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Weekly Completions', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                _WeeklyChart(stats: vm.weekCompletionStats),
                if (vm.categoryCounts.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('By Category', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  _CategoryChart(data: vm.categoryCounts),
                ],
                if (analytics.insights.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Smart Insights', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ...analytics.insights.map(
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InsightCard(insight: i),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AnalyticsVM {
  final int total;
  final int completed;
  final int currentStreak;
  final int todayTotalCount;
  final double rate;
  final Map<String, int> weekCompletionStats;
  final Map<String, int> categoryCounts;

  const _AnalyticsVM({
    required this.total,
    required this.completed,
    required this.currentStreak,
    required this.todayTotalCount,
    required this.rate,
    required this.weekCompletionStats,
    required this.categoryCounts,
  });

  factory _AnalyticsVM.from(ReminderController remindersController) {
    final active = remindersController.activeReminders;
    final total = active.length;
    final completed = active.where((r) => r.isCompleted).length;
    final rate = total > 0 ? completed / total * 100 : 0.0;

    final catCounts = <String, int>{};
    for (final r in active) {
      catCounts[r.category] = (catCounts[r.category] ?? 0) + 1;
    }

    return _AnalyticsVM(
      total: total,
      completed: completed,
      currentStreak: remindersController.currentStreak,
      todayTotalCount: remindersController.todayTotalCount,
      rate: rate,
      weekCompletionStats: remindersController.weekCompletionStats,
      categoryCounts: catCounts,
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final int completed;
  final int total;
  final double rate;

  const _OverviewCard({
    required this.completed,
    required this.total,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = rate >= 80
        ? 'Strong rhythm'
        : rate >= 50
        ? 'Good movement'
        : 'Start with one win';

    return AnimatedContainer(
      duration: ZyvoraMotion.regular,
      curve: ZyvoraMotion.curve,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ZyvoraRadius.md),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.7),
        ),
      ),
      child: Row(
        children: [
          ProductivityRing(percentage: rate, size: 88, label: 'done'),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Productivity Score', style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  '$completed of $total reminders complete',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: ZyvoraColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final Map<String, int> stats;

  const _WeeklyChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highest = stats.values.fold<int>(
      0,
      (max, value) => value > max ? value : max,
    );
    final maxY = highest <= 0 ? 4.0 : (highest + 1).toDouble();

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ZyvoraRadius.md),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.7),
        ),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value < 0 || value >= ZyvoraDays.ordered.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      ZyvoraDays.shortName(
                        ZyvoraDays.ordered[value.toInt()],
                      ).substring(0, 1),
                      style: theme.textTheme.labelSmall,
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: theme.colorScheme.outline.withValues(alpha: 0.16),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (i) {
            final day = ZyvoraDays.ordered[i];
            final count = stats[day] ?? 0;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: count.toDouble(),
                  color: count > 0
                      ? ZyvoraColors.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.22),
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _CategoryChart extends StatelessWidget {
  final Map<String, int> data;

  const _CategoryChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = data.entries.toList();

    return Container(
      height: 214,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ZyvoraRadius.md),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.7),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 38,
                sections: List.generate(entries.length, (i) {
                  final entry = entries[i];
                  return PieChartSectionData(
                    color: _getColorForIndex(i),
                    value: entry.value.toDouble(),
                    title: '${entry.value}',
                    radius: 48,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: 18),
          SizedBox(
            width: 132,
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entries.length,
              itemBuilder: (context, i) {
                final entry = entries[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _getColorForIndex(i),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${entry.key} (${entry.value})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForIndex(int index) {
    const colors = [
      ZyvoraColors.primary,
      ZyvoraColors.cyan,
      ZyvoraColors.green,
      ZyvoraColors.purple,
      ZyvoraColors.coral,
      ZyvoraColors.red,
      ZyvoraColors.yellow,
    ];
    return colors[index % colors.length];
  }
}
