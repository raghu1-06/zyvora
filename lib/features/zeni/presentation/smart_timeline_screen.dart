import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class SmartTimelineScreen extends StatefulWidget {
  const SmartTimelineScreen({super.key});

  @override
  State<SmartTimelineScreen> createState() => _SmartTimelineScreenState();
}

class _SmartTimelineScreenState extends State<SmartTimelineScreen> {
  int _activeFilter = 0;
  final List<String> _filters = ["All", "Actionable", "Notes", "Activity"];

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: topPad + 8, left: 16, right: 16),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E1B33), size: 20), onPressed: () => Navigator.pop(context)),
                Expanded(
                  child: Column(
                    children: [
                      Text("Smart Timeline", style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B33))),
                      Text("Your chronological memory", style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
                const SizedBox(width: 48), // balance back button
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: Color(0xFF9CA3AF), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(hintText: "Search memories, tasks, notes...", hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF9CA3AF)), border: InputBorder.none),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(_filters.length, (index) {
                final isActive = _activeFilter == index;
                return GestureDetector(
                  onTap: () => setState(() => _activeFilter = index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: isActive ? const Color(0xFF1E1B33) : Colors.white, borderRadius: BorderRadius.circular(50), border: Border.all(color: isActive ? const Color(0xFF1E1B33) : const Color(0xFFE5E7EB))),
                    child: Text(_filters[index], style: GoogleFonts.inter(fontSize: 13, fontWeight: isActive ? FontWeight.w600 : FontWeight.w500, color: isActive ? Colors.white : const Color(0xFF6B7280))),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CustomScrollView(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
              slivers: [
                SliverToBoxAdapter(child: _buildSectionLabel("Actionable Tasks", const Color(0xFF7C3AED))),
                SliverList(
                  delegate: SliverChildListDelegate([
                    _buildTaskTimelineItem("Finish Physics Lab Report", "Overdue • Yesterday, 11:59 PM", "STUDY", isOverdue: true),
                    _buildTaskTimelineItem("Review App Architecture", "Today, 4:00 PM", "WORK"),
                  ]),
                ),
                SliverToBoxAdapter(child: const SizedBox(height: 24)),
                SliverToBoxAdapter(child: _buildSectionLabel("Today", const Color(0xFF6B7280))),
                SliverList(
                  delegate: SliverChildListDelegate([
                    _buildAttendanceTimelineItem("Marked Present", "Mathematics", "10:30 AM"),
                    _buildAttendanceTimelineItem("Marked Absent", "Database Systems", "08:00 AM", isPresent: false),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(text, style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildTaskTimelineItem(String title, String time, String type, {bool isOverdue = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(width: 2, color: const Color(0xFFE5E7EB)),
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  width: 8, height: 8,
                  decoration: const BoxDecoration(color: Color(0xFF3B82F6), shape: BoxShape.circle, border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2))),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isOverdue ? const Color(0xFFFFF5F5) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isOverdue ? const Color(0xFFEF4444) : const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFD1D5DB)))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E1B33))),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(time, style: GoogleFonts.inter(fontSize: 11, color: isOverdue ? const Color(0xFFEF4444) : const Color(0xFF9CA3AF))),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(4)),
                              child: Text(type, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF6B7280))),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTimelineItem(String action, String subject, String time, {bool isPresent = true}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(width: 2, color: const Color(0xFFE5E7EB)),
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  width: 8, height: 8,
                  decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle, border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2))),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE5E7EB))),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: const Color(0xFFEDE9FE), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.fact_check, color: Color(0xFF7C3AED), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(action, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B33))),
                        Text(subject, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280))),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(time, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF9CA3AF))),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: isPresent ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(4)),
                              child: Text("ATTENDANCE", style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: isPresent ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
