import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/subject_model.dart';
import '../../../core/models/session_model.dart';
import '../../../core/providers/sessions_provider.dart';

class SubjectDetailScreen extends ConsumerStatefulWidget {
  final SubjectModel subject;
  
  const SubjectDetailScreen({super.key, required this.subject});

  @override
  ConsumerState<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends ConsumerState<SubjectDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(sessionsProvider).where((s) => s.subjectId == widget.subject.id).toList();
    final total = sessions.length;
    final present = sessions.where((s) => s.isPresent).length;
    final pct = total == 0 ? 0.0 : (present / total) * 100;
    
    int maxTotalFor75 = (present / 0.75).floor();
    int safeBunks = total == 0 ? 0 : ((maxTotalFor75 - total) > 0 ? (maxTotalFor75 - total) : 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(widget.subject.name, style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B33))),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E1B33), size: 20), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert, color: Color(0xFF1E1B33)), onPressed: () {}),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF7C3AED),
          unselectedLabelColor: const Color(0xFF9CA3AF),
          labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
          indicatorColor: const Color(0xFF7C3AED),
          tabs: const [
            Tab(text: "Calendar"),
            Tab(text: "Analysis"),
            Tab(text: "Sessions"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCalendarTab(),
          _buildAnalysisTab(pct, total, safeBunks),
          _buildSessionsTab(sessions),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openMarkAttendanceSheet,
        backgroundColor: const Color(0xFF7C3AED),
        icon: const Icon(Icons.fact_check_rounded, color: Colors.white, size: 18),
        label: Text("Mark", style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }

  Widget _buildCalendarTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.chevron_left_rounded, color: Color(0xFF6B7280)),
            Text("June 2026", style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1E1B33))),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF6B7280)),
          ],
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 12, crossAxisSpacing: 12),
          itemCount: 30, // Mock 30 days
          itemBuilder: (context, index) {
            bool isToday = index == 16;
            bool isPresent = index % 4 == 0;
            bool isAbsent = index % 11 == 0;
            
            return Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isToday ? const Color(0xFF10B981) : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      "${index + 1}",
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: isToday ? FontWeight.bold : FontWeight.w500, color: isToday ? Colors.white : const Color(0xFF1E1B33)),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                if (isPresent || isAbsent)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isAbsent ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFDDD6FE))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Legend", style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _legendItem(const Color(0xFF10B981), "Present"),
                  _legendItem(const Color(0xFFEF4444), "Absent"),
                  _legendItem(const Color(0xFF7C3AED), "Extra"),
                  _legendItem(const Color(0xFFD1D5DB), "No Class"),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendItem(Color c, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280))),
      ],
    );
  }

  Widget _buildAnalysisTab(double pct, int total, int safeBunks) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: CircularPercentIndicator(
            radius: 70,
            lineWidth: 8,
            percent: pct / 100,
            progressColor: pct >= 75 ? const Color(0xFF10B981) : const Color(0xFF7C3AED),
            backgroundColor: const Color(0xFFE5E7EB),
            circularStrokeCap: CircularStrokeCap.round,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${pct.toStringAsFixed(1)}%", style: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B33))),
                Text(pct >= 75 ? "On Track" : "Attention", style: GoogleFonts.inter(fontSize: 11, color: pct >= 75 ? const Color(0xFF10B981) : const Color(0xFFEF4444), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _statBox("Required", "75%", const Color(0xFFF3F4F6), const Color(0xFF1E1B33)),
            _statBox("Target", "80%", const Color(0xFFF3F4F6), const Color(0xFF1E1B33)),
            _statBox("Streak", "3 Days", const Color(0xFFFEF3C7), const Color(0xFFF59E0B)),
            _statBox("Sessions", "$total", const Color(0xFFEDE9FE), const Color(0xFF7C3AED)),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFDDD6FE))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Recovery Window", style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("$safeBunks", style: GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                        Text("Safe bunks available", style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280))),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 40, color: const Color(0xFFE5E7EB)),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("0", style: GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFFEF4444))),
                          Text("To reach target %", style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text("Attendance History", style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Container(
          height: 100,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFDDD6FE))),
          child: Center(child: Text("Heatmap Placeholder", style: GoogleFonts.inter(color: const Color(0xFF9CA3AF)))),
        ),
      ],
    );
  }

  Widget _statBox(String label, String val, Color bg, Color textCol) {
    return Container(
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280))),
          const SizedBox(height: 4),
          Text(val, style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.bold, color: textCol)),
        ],
      ),
    );
  }

  Widget _buildSessionsTab(List<SessionModel> sessions) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        for (var session in sessions)
          _sessionRow(session),
      ],
    );
  }

  Widget _sessionRow(SessionModel session) {
    bool present = session.isPresent;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: present ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(present ? Icons.check_circle_rounded : Icons.cancel_rounded, color: present ? const Color(0xFF10B981) : const Color(0xFFEF4444), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.sessionType, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF1E1B33))),
                Text(session.date.toString().substring(0, 10), style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF9CA3AF))),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFEF4444)),
            onPressed: () => ref.read(sessionsProvider.notifier).delete(session.id),
          ),
        ],
      ),
    );
  }

  void _openMarkAttendanceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(50)))),
            const SizedBox(height: 20),
            Text("Mark Attendance", style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _markOption(Icons.check_circle_outline, "Mark Present", const Color(0xFF10B981), const Color(0xFFD1FAE5), 'Present'),
            _markOption(Icons.cancel_outlined, "Mark Absent", const Color(0xFFEF4444), const Color(0xFFFEE2E2), 'Absent'),
            _markOption(Icons.undo, "Unmark", const Color(0xFF6B7280), const Color(0xFFF3F4F6), 'Unmark'),
            _markOption(Icons.add_circle_outline, "Add Extra Session", const Color(0xFF7C3AED), const Color(0xFFEDE9FE), 'Extra'),
            const SizedBox(height: 12),
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF6B7280)))),
          ],
        ),
      ),
    );
  }

  Widget _markOption(IconData icon, String label, Color color, Color bg, String action) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: bg.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: bg)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: color)),
        onTap: () {
          if (action == 'Present' || action == 'Absent') {
             ref.read(sessionsProvider.notifier).add(SessionModel(
               id: const Uuid().v4(),
               subjectId: widget.subject.id,
               isPresent: action == 'Present',
               sessionType: 'Lecture',
               date: DateTime.now(),
             ));
          }
          Navigator.pop(context);
        },
      ),
    );
  }
}
