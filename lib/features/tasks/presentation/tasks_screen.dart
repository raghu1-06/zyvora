import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

// Sample data models and list for local state
class _Task {
  String id;
  String title;
  bool isCompleted;
  bool isOverdue;
  List<String> subtasks;
  bool isExpanded;
  String category;
  String time;

  _Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.isOverdue = false,
    this.subtasks = const [],
    this.isExpanded = false,
    required this.category,
    required this.time,
  });
}

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool _showBanner = true;
  int _viewIndex = 0; // 0=Timeline, 1=Kanban, 2=Matrix, 3=Zen
  int _filterIndex = 0; // 0=All, 1=Today, 2=Overdue, 3=Done

  final List<_Task> _tasks = [
    _Task(id: '1', title: 'maths', category: 'Study', time: '10:01 AM', subtasks: ['Finish chapter 1', 'Do exercises']),
    _Task(id: '2', title: 'physics', category: 'Study', time: '10:02 AM', isCompleted: true),
    _Task(id: '3', title: 'chemistry', category: 'Study', time: 'Yesterday', isOverdue: true),
    _Task(id: '4', title: 'Call John', category: 'Personal', time: '08:00 PM'),
  ];

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: topPadding + 16, left: 20, right: 20),
                  child: _buildHeader(),
                ),
              ),
              if (_showBanner)
                SliverToBoxAdapter(
                  child: _buildZeniBanner(),
                ),
              SliverToBoxAdapter(
                child: _buildSearchBar(),
              ),
              SliverToBoxAdapter(
                child: _buildViewSwitcher(),
              ),
              SliverToBoxAdapter(
                child: _buildFilterChips(),
              ),
              SliverFillRemaining(
                hasScrollBody: true,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 160), // padding for quick add & floating button
                  child: IndexedStack(
                    index: _viewIndex,
                    children: [
                      _buildTimelineView(),
                      _buildKanbanView(),
                      _buildMatrixView(),
                      _buildZenView(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Floating New Task Button
          Positioned(
            bottom: MediaQuery.of(context).viewInsets.bottom + 148,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _openNewTaskSheet,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text("New Task", style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Quick Add Bar
          Positioned(
            bottom: MediaQuery.of(context).viewInsets.bottom + 88,
            left: 16,
            right: 16,
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _openNewTaskSheet,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 22),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Type task... e.g. 'Call John tom...'",
                        hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF9CA3AF)),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        filled: false,
                      ),
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE9FE),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Color(0xFF7C3AED), size: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tasks", style: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B33))),
            Text("Plan, focus, achieve.", style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF9CA3AF))),
          ],
        ),
        const Spacer(),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFEDE9FE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.tune_rounded, color: Color(0xFF7C3AED), size: 20),
        ),
        const SizedBox(width: 8),
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            children: [
              const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 4),
              Text("Routine", style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildZeniBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFCCFBF1), Color(0xFFCFFAFE)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFFA7F3D0),
            child: Text("🌿", style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("ZENI INSIGHT", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF10B981), letterSpacing: 1.0)),
                const SizedBox(height: 2),
                Text("Good afternoon. You have 4 tasks today. You've got this.", style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF1E1B33))),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Color(0xFF9CA3AF)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              if (mounted) setState(() => _showBanner = false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search tasks...",
                hintStyle: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewSwitcher() {
    final views = [
      (Icons.timeline_rounded, "Timeline"),
      (Icons.view_kanban_outlined, "Kanban"),
      (Icons.grid_view_rounded, "Matrix"),
      (Icons.self_improvement_rounded, "Zen"),
    ];

    return Container(
      height: 52,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(views.length, (index) {
          final isActive = _viewIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (mounted) setState(() => _viewIndex = index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isActive ? const [BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 2))] : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(views[index].$1, size: 18, color: isActive ? const Color(0xFF7C3AED) : const Color(0xFF9CA3AF)),
                    const SizedBox(height: 2),
                    Text(
                      views[index].$2,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                        color: isActive ? const Color(0xFF7C3AED) : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ["All Tasks", "Today", "Overdue", "Done"];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: List.generate(filters.length, (index) {
          final isActive = _filterIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                if (mounted) setState(() => _filterIndex = index);
              },
              child: Container(
                padding: isActive ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8) : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFFEDE9FE) : Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: isActive ? const Color(0xFF7C3AED) : const Color(0xFFE5E7EB),
                    width: isActive ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      filters[index],
                      style: isActive 
                        ? GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF7C3AED))
                        : GoogleFonts.inter(fontSize: 12, color: const Color(0xFF9CA3AF)),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(color: Color(0xFF7C3AED), shape: BoxShape.circle),
                        child: const Center(
                          child: Text("4", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTimelineView() {
    return ListView(
      padding: const EdgeInsets.only(top: 8),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: const Color(0xFFEDE9FE), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.calendar_today_rounded, color: Color(0xFF7C3AED), size: 16),
              ),
              const SizedBox(width: 8),
              Text("TODAY", style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1, color: const Color(0xFF1E1B33))),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF7C3AED), borderRadius: BorderRadius.circular(50)),
                child: Text("4", style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            Positioned(
              left: 30,
              top: 0,
              bottom: 0,
              child: Container(width: 2, color: const Color(0xFF7C3AED).withValues(alpha: 0.2)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                children: _tasks.map((task) => _TaskCard(task: task)).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKanbanView() {
    final todo = _tasks.where((t) => !t.isCompleted).toList();
    final done = _tasks.where((t) => t.isCompleted).toList();
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKanbanColumn("To Do", todo),
          _buildKanbanColumn("In Progress", []),
          _buildKanbanColumn("Done", done),
        ],
      ),
    );
  }

  Widget _buildKanbanColumn(String title, List<_Task> tasks) {
    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E1B33))),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(50)),
                child: Text("${tasks.length}", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tasks.map((task) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Text(task.title, style: GoogleFonts.inter(fontSize: 14)),
          )),
        ],
      ),
    );
  }

  Widget _buildMatrixView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildQuadrant("Urgent & Important", const Color(0xFFFEE2E2), const Color(0xFFEF4444)),
          _buildQuadrant("Not Urgent & Important", const Color(0xFFFEF3C7), const Color(0xFFF59E0B)),
          _buildQuadrant("Urgent & Not Important", const Color(0xFFCFFAFE), const Color(0xFF06B6D4)),
          _buildQuadrant("Not Urgent & Not Important", const Color(0xFFF3F4F6), const Color(0xFF9CA3AF)),
        ],
      ),
    );
  }

  Widget _buildQuadrant(String title, Color bg, Color border) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1E1B33))),
          const Spacer(),
          Text("0 tasks", style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF6B7280))),
        ],
      ),
    );
  }

  Widget _buildZenView() {
    final currentTask = _tasks.where((t) => !t.isCompleted).firstOrNull;
    
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 24, offset: Offset(0, 12))],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -10,
              right: -10,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE).withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentTask?.title ?? "No tasks",
                  style: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B33)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: Text("Complete Task", style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {},
                  child: Text("Skip for now", style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF9CA3AF))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openNewTaskSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _NewTaskSheet(),
    );
  }
}

class _TaskCard extends StatefulWidget {
  final _Task task;
  const _TaskCard({required this.task});

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard> {
  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Blue timeline dot replacement (purple here)
        Container(
          margin: const EdgeInsets.only(top: 24, right: 12),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: task.isCompleted ? const Color(0xFF9CA3AF) : const Color(0xFF7C3AED),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: task.isOverdue ? const Color(0xFFFFF5F5) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: task.isOverdue ? const Color(0xFFEF4444) : const Color(0xFFE5E7EB),
                width: task.isOverdue ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (mounted) setState(() => task.isCompleted = !task.isCompleted);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: task.isCompleted ? const Color(0xFF7C3AED) : Colors.transparent,
                          borderRadius: BorderRadius.circular(50),
                          border: task.isCompleted ? null : Border.all(color: const Color(0xFFD1D5DB), width: 2),
                        ),
                        child: task.isCompleted ? const Icon(Icons.check_rounded, color: Colors.white, size: 14) : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        task.title,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          color: task.isCompleted ? const Color(0xFF9CA3AF) : const Color(0xFF1E1B33),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (mounted) setState(() => task.isExpanded = !task.isExpanded);
                      },
                      child: const Icon(Icons.more_vert, color: Color(0xFF9CA3AF), size: 18),
                    ),
                  ],
                ),
                if (task.isExpanded) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 38, top: 10),
                    child: Column(
                      children: [
                        for (var subtask in task.subtasks)
                          Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                GestureDetector(
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: const Color(0xFFD1D5DB), width: 1.5),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(subtask, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF1E1B33)))),
                                const Icon(Icons.close, color: Color(0xFF9CA3AF), size: 14),
                              ],
                            ),
                          ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          child: Row(
                            children: [
                              const Icon(Icons.add, color: Color(0xFF7C3AED), size: 16),
                              const SizedBox(width: 4),
                              Text("Add Subtask", style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF7C3AED))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NewTaskSheet extends StatefulWidget {
  const _NewTaskSheet();

  @override
  State<_NewTaskSheet> createState() => _NewTaskSheetState();
}

class _NewTaskSheetState extends State<_NewTaskSheet> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(50))),
          ),
          const SizedBox(height: 20),
          Text("New Task", style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B33))),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: "Title",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 1.5)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Notes (Markdown supported)",
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.calendar_month_rounded, size: 16, color: Color(0xFF6B7280)),
                  label: Text("Pick date", style: GoogleFonts.inter(color: const Color(0xFF1E1B33))),
                  style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF6B7280)),
                  label: Text("Pick time", style: GoogleFonts.inter(color: const Color(0xFF1E1B33))),
                  style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Set Reminder / Alarm", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF1E1B33))),
              Switch(value: false, onChanged: (v) {}, activeColor: const Color(0xFF7C3AED)),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ["Study", "Work", "Personal", "Health", "Finance"].map((c) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Chip(
                  label: Text(c, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF4B5563))),
                  backgroundColor: const Color(0xFFF3F4F6),
                  side: BorderSide.none,
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.repeat_rounded, size: 18, color: Color(0xFF6B7280)),
              const SizedBox(width: 8),
              Text("Once", style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF1E1B33))),
              const Spacer(),
              const Icon(Icons.flag_outlined, size: 18, color: Color(0xFF6B7280)),
              const SizedBox(width: 8),
              Text("Medium", style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF1E1B33))),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Blocked By", style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF6B7280))),
                const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF6B7280)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFEC4899)]),
              borderRadius: BorderRadius.circular(50),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              ),
              child: Text("Create Task", style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
