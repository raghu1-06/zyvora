import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/subject_model.dart';
import '../../../core/providers/subjects_provider.dart';
import '../../../core/providers/sessions_provider.dart';
import 'subject_detail_screen.dart';
import '../../../core/theme/app_colors.dart' as colors;

class SubjectStats {
  final SubjectModel subject;
  final int present;
  final int total;
  
  SubjectStats({required this.subject, required this.present, required this.total});
  
  double get percent => total == 0 ? 0.0 : (present / total) * 100;
  
  int get safeBunks {
    if (total == 0) return 0;
    int maxTotalFor75 = (present / 0.75).floor();
    int safe = maxTotalFor75 - total;
    return safe > 0 ? safe : 0;
  }
}

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    
    final allSubjects = ref.watch(subjectsProvider);
    final allSessions = ref.watch(sessionsProvider);
    
    final subjects = allSubjects.map((s) {
      final sessions = allSessions.where((session) => session.subjectId == s.id);
      final total = sessions.length;
      final present = sessions.where((s) => s.isPresent).length;
      return SubjectStats(subject: s, present: present, total: total);
    }).toList();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: topPadding + 16, left: 20, right: 20, bottom: 8),
            child: Row(
              children: [
                Text("Attendance", style: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B33))),
                const Spacer(),
                GestureDetector(
                  onTap: _openAddSubjectSheet,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: const Color(0xFF7C3AED), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.all(4),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 2))]),
              labelColor: const Color(0xFF7C3AED),
              unselectedLabelColor: const Color(0xFF9CA3AF),
              labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: "Subjects"),
                Tab(text: "Analytics"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSubjectsTab(subjects),
                _buildAnalyticsTab(subjects),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsTab(List<SubjectStats> subjects) {
    if (subjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text("No subjects yet", style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text("Tap + to add your first subject", style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    
    return ListView.separated(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 100),
      itemCount: subjects.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => SubjectDetailScreen(subject: subjects[index].subject)));
          },
          child: _SubjectCard(subject: subjects[index]),
        );
      },
    );
  }

  Widget _buildAnalyticsTab(List<SubjectStats> subjects) {
    double totalPresent = subjects.fold(0, (sum, item) => sum + item.present);
    double totalClasses = subjects.fold(0, (sum, item) => sum + item.total);
    double overallPct = totalClasses == 0 ? 0 : (totalPresent / totalClasses) * 100;
    
    int overallSafeBunks = subjects.fold(0, (sum, item) => sum + item.safeBunks);
    
    SubjectStats? strongest;
    SubjectStats? weakest;
    if (subjects.isNotEmpty) {
      strongest = subjects.reduce((curr, next) => curr.percent > next.percent ? curr : next);
      weakest = subjects.reduce((curr, next) => curr.percent < next.percent ? curr : next);
    }
    
    return ListView(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 100),
      children: [
        Center(
          child: CircularPercentIndicator(
            radius: 80,
            lineWidth: 10,
            percent: overallPct / 100,
            progressColor: overallPct >= 75 ? const Color(0xFF10B981) : const Color(0xFF7C3AED),
            backgroundColor: const Color(0xFFE5E7EB),
            circularStrokeCap: CircularStrokeCap.round,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${overallPct.toStringAsFixed(1)}%", style: GoogleFonts.sora(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B33))),
                Text("Overall", style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF9CA3AF))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            overallPct >= 75 ? "You are on track! Keep it up." : "Needs attention. Attend more classes.",
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF1E1B33)),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatChip("Present", "${totalPresent.toInt()}", const Color(0xFFD1FAE5), const Color(0xFF10B981)),
            _buildStatChip("Absent", "${(totalClasses - totalPresent).toInt()}", const Color(0xFFFEE2E2), const Color(0xFFEF4444)),
            _buildStatChip("Safe Bunks", "$overallSafeBunks", const Color(0xFFEDE9FE), const Color(0xFF7C3AED)),
          ],
        ),
        const SizedBox(height: 24),
        Text("Subject Performance", style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildMinMaxCard("Strongest", strongest?.subject.name ?? "-", strongest != null ? "${strongest.percent.round()}%" : "-", const Color(0xFF10B981))),
            const SizedBox(width: 12),
            Expanded(child: _buildMinMaxCard("Weakest", weakest?.subject.name ?? "-", weakest != null ? "${weakest.percent.round()}%" : "-", const Color(0xFFEF4444))),
          ],
        ),
        const SizedBox(height: 24),
        Text("Comparison Bars", style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFDDD6FE))),
          child: Column(
            children: subjects.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(width: 60, child: Text(s.subject.name, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: LinearProgressIndicator(
                        value: s.percent / 100,
                        minHeight: 8,
                        color: s.percent >= 75 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        backgroundColor: const Color(0xFFE5E7EB),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(width: 40, child: Text("${s.percent.round()}%", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(String label, String value, Color bg, Color textCol) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
          child: Text(value, style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.bold, color: textCol)),
        ),
        const SizedBox(height: 6),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF6B7280))),
      ],
    );
  }

  Widget _buildMinMaxCard(String title, String subject, String val, Color valCol) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFDDD6FE))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF9CA3AF))),
          const SizedBox(height: 4),
          Text(subject, style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1E1B33))),
          const SizedBox(height: 2),
          Text(val, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: valCol)),
        ],
      ),
    );
  }

  void _openAddSubjectSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _AddSubjectSheet(),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final SubjectStats subject;
  
  const _SubjectCard({required this.subject});

  (IconData, Color) _getStyle() {
    final n = subject.subject.name.toLowerCase();
    if (n.contains('math')) return (Icons.calculate_outlined, const Color(0xFF8B5CF6));
    if (n.contains('phys')) return (Icons.science_outlined, const Color(0xFF60A5FA));
    if (n.contains('eng')) return (Icons.menu_book_outlined, const Color(0xFFFB923C));
    if (n.contains('dbms')) return (Icons.storage_outlined, const Color(0xFF8B5CF6));
    if (n.contains('chem')) return (Icons.biotech_outlined, const Color(0xFF60A5FA));
    return (Icons.book_outlined, const Color(0xFF10B981));
  }

  @override
  Widget build(BuildContext context) {
    final style = _getStyle();
    final pct = subject.percent;
    
    Color badgeBg;
    Color badgeText;
    String badgeLabel;
    
    if (pct >= 75) {
      badgeBg = const Color(0xFFD1FAE5);
      badgeText = const Color(0xFF10B981);
      badgeLabel = "✓ On Track";
    } else if (pct >= 60) {
      badgeBg = const Color(0xFFFEF3C7);
      badgeText = const Color(0xFFF59E0B);
      badgeLabel = "⚠ Caution";
    } else {
      badgeBg = const Color(0xFFFEE2E2);
      badgeText = const Color(0xFFEF4444);
      badgeLabel = "⚠ Attention";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDDD6FE), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: style.$2.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(style.$1, color: style.$2, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(subject.subject.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E1B33))),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(4)),
                      child: Text(badgeLabel, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: badgeText)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text("${subject.present} present / ${subject.total} classes", style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF9CA3AF))),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: LinearProgressIndicator(
                    value: pct / 100,
                    minHeight: 4,
                    color: pct >= 75 ? const Color(0xFF10B981) : const Color(0xFF7C3AED),
                    backgroundColor: const Color(0xFFE5E7EB),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              CircularPercentIndicator(
                radius: 22,
                lineWidth: 4,
                percent: pct / 100,
                progressColor: pct >= 75 ? const Color(0xFF10B981) : const Color(0xFF7C3AED),
                backgroundColor: const Color(0xFFE5E7EB),
                circularStrokeCap: CircularStrokeCap.round,
                center: Text("${pct.round()}%", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 4),
              const Icon(Icons.more_vert, size: 14, color: Color(0xFF9CA3AF)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddSubjectSheet extends ConsumerStatefulWidget {
  const _AddSubjectSheet();

  @override
  ConsumerState<_AddSubjectSheet> createState() => _AddSubjectSheetState();
}

class _AddSubjectSheetState extends ConsumerState<_AddSubjectSheet> {
  final _nameCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(50)))),
          const SizedBox(height: 20),
          Text("Add Subject", style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B33))),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              hintText: "Subject Name (e.g. Mathematics)",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 1.5)),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                if (_nameCtrl.text.isEmpty) return;
                ref.read(subjectsProvider.notifier).add(SubjectModel(
                  id: const Uuid().v4(),
                  name: _nameCtrl.text.trim(),
                ));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              ),
              child: Text("Add Subject", style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
