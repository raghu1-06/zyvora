import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../zeni/presentation/smart_timeline_screen.dart';
import '../../../core/providers/tasks_provider.dart';
import 'focus_mode_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isProfessional = true;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: topPadding + 16, left: 20, right: 20, bottom: 8),
              child: _buildHeader(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildToggle(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
              child: _buildZeniCard(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 24),
              child: _buildOverview(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 24),
              child: _buildAttendanceSnapshot(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 24),
              child: _buildQuickActions(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 24),
              child: _buildProductivityInsights(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 100),
              child: _buildSmartTimeline(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Good ${_getGreeting()},\nraghu.",
                style: GoogleFonts.sora(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E1B33),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat("EEEE, d MMMM yyyy").format(DateTime.now()),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  iconSize: 24,
                  color: const Color(0xFF6B7280),
                  onPressed: () {},
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              },
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFF7C3AED),
                backgroundImage: null,
                child: Text(
                  "R",
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ).animate().slideX(begin: -0.1).fadeIn();
  }

  Widget _buildToggle() {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E4F8),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (mounted) setState(() => _isProfessional = true);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _isProfessional ? const Color(0xFF5B21B6) : Colors.transparent,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Text(
                    "Professional",
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _isProfessional ? Colors.white : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (mounted) setState(() => _isProfessional = false);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: !_isProfessional ? const Color(0xFF5B21B6) : Colors.transparent,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Text(
                    "Personal",
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: !_isProfessional ? Colors.white : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZeniCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFFEC4899), Color(0xFF06B6D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(1.5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(19),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(0xFF7C3AED),
                  child: Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Zeni", style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF7C3AED))),
                    Text("Your personal AI assistant", style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF9CA3AF))),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: const Color(0xFFD1FAE5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text("ACTIVE", style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF10B981))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "You have 4 tasks lined up for today. Let's crush it!",
              style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF1E1B33), height: 1.5),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                ),
                child: Text("Ask Zeni  →", style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverview() {
    final pendingTasks = ref.watch(tasksProvider.notifier).pendingTasks.length;
    final allTasks = ref.watch(tasksProvider);
    final completed = allTasks.where((t) => t.isCompleted).length;
    final pct = allTasks.isEmpty ? 0 : (completed / allTasks.length * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Today's Overview", style: GoogleFonts.sora(fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.25,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            _StatCard(iconBg: const Color(0xFFEDE9FE), icon: Icons.assignment_outlined, iconColor: const Color(0xFF7C3AED), value: "$pendingTasks", label: "Pending Tasks", sublabel: "Total pending").animate().slideY(begin: 0.2).fadeIn(delay: 0.ms),
            _StatCard(iconBg: const Color(0xFFD1FAE5), icon: Icons.fact_check_outlined, iconColor: const Color(0xFF10B981), value: "100%", label: "Today's Attendance", sublabel: "All classes attended").animate().slideY(begin: 0.2).fadeIn(delay: 100.ms),
            _StatCard(iconBg: const Color(0xFFFEF3C7), icon: Icons.notifications_outlined, iconColor: const Color(0xFFF59E0B), value: "0", label: "Reminders", sublabel: "Upcoming tasks").animate().slideY(begin: 0.2).fadeIn(delay: 200.ms),
            _StatCard(iconBg: const Color(0xFFCFFAFE), icon: Icons.trending_up_rounded, iconColor: const Color(0xFF06B6D4), value: "$pct%", label: "Completion Rate", sublabel: "Overall").animate().slideY(begin: 0.2).fadeIn(delay: 300.ms),
          ],
        ),
      ],
    );
  }

  Widget _buildAttendanceSnapshot() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("Attendance Snapshot", style: GoogleFonts.sora(fontSize: 17, fontWeight: FontWeight.w600)),
            const Spacer(),
            Text("View Details", style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF7C3AED))),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDDD6FE), width: 1),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircularPercentIndicator(
                radius: 50,
                lineWidth: 7,
                percent: 1.0,
                progressColor: const Color(0xFF10B981),
                backgroundColor: const Color(0xFFE5E7EB),
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("100", style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B33))),
                    Text("%", style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF9CA3AF))),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Today", style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF1E1B33))),
                        Text("1/3 classes", style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF6B7280))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("This week", style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF1E1B33))),
                        Text("100%", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (var i = 0; i < 7; i++)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 6,
                                height: [44.0, 36.0, 44.0, 28.0, 20.0, 14.0, 10.0][i],
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7C3AED).withValues(alpha: [1.0, 0.75, 1.0, 0.55, 0.35, 0.2, 0.1][i]),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(["M", "T", "W", "T", "F", "S", "S"][i], style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF9CA3AF))),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Quick Actions", style: GoogleFonts.sora(fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _ActionTile(bg: const Color(0xFFEDE9FE), icon: Icons.add_task_rounded, color: const Color(0xFF7C3AED), label: "Add Task")),
            const SizedBox(width: 8),
            Expanded(child: _ActionTile(bg: const Color(0xFFD1FAE5), icon: Icons.fact_check_rounded, color: const Color(0xFF10B981), label: "Mark\nAttendance")),
            const SizedBox(width: 8),
            Expanded(child: _ActionTile(bg: const Color(0xFFFEF3C7), icon: Icons.add_alarm_rounded, color: const Color(0xFFF59E0B), label: "Add Reminder")),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const FocusModeScreen()));
                },
                child: _ActionTile(bg: const Color(0xFFCFFAFE), icon: Icons.center_focus_strong_outlined, color: const Color(0xFF06B6D4), label: "Focus Mode"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductivityInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Productivity Insights", style: GoogleFonts.sora(fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDDD6FE), width: 1),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: IntrinsicHeight(
            child: Row(
              children: [
                _InsightCol(icon: Icons.local_fire_department, iconBg: const Color(0xFFFEE2E2), iconColor: const Color(0xFFEF4444), value: "1", label: "Day Streak", subtext: "Keep it up!"),
                const VerticalDivider(width: 1, color: Color(0xFFF3F4F6), thickness: 1),
                _InsightCol(icon: Icons.check_circle_outline, iconBg: const Color(0xFFD1FAE5), iconColor: const Color(0xFF10B981), value: "${ref.watch(tasksProvider).where((t) => t.isCompleted).length}", label: "Total Completed", subtext: "Great progress!"),
                const VerticalDivider(width: 1, color: Color(0xFFF3F4F6), thickness: 1),
                _InsightCol(icon: Icons.bolt_rounded, iconBg: const Color(0xFFEDE9FE), iconColor: const Color(0xFF7C3AED), value: "85", label: "Productivity Score", subtext: "Keep going!"),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmartTimeline() {
    final tasks = ref.watch(tasksProvider);
    final sampleItems = tasks.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("Smart Timeline", style: GoogleFonts.sora(fontSize: 17, fontWeight: FontWeight.w600)),
            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SmartTimelineScreen()));
              },
              child: Text("View All", style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF7C3AED))),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDDD6FE), width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: sampleItems.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(sampleItems[index].title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF1E1B33))),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEDE9FE),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text("TASK", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF7C3AED), letterSpacing: 0.5)),
                              ),
                              const Spacer(),
                              Text(sampleItems[index].dueTime ?? "", style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF9CA3AF))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final String sublabel;

  const _StatCard({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDD6FE), width: 1),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(value, style: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B33))),
                Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF1E1B33)), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(sublabel, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF9CA3AF)), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final Color bg;
  final IconData icon;
  final Color color;
  final String label;

  const _ActionTile({
    required this.bg,
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDD6FE), width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF1E1B33)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InsightCol extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String value;
  final String label;
  final String subtext;

  const _InsightCol({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.subtext,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(height: 6),
            Text(value, style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B33))),
            Text(label, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280)), textAlign: TextAlign.center),
            const SizedBox(height: 2),
            Text(subtext, style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF9CA3AF)), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
