import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/models/task_model.dart';
import '../../../core/providers/tasks_provider.dart';

class AgendaScreen extends ConsumerStatefulWidget {
  const AgendaScreen({super.key});

  @override
  ConsumerState<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends ConsumerState<AgendaScreen> {
  DateTime _selectedDate = DateTime.now();
  late List<DateTime> _weekDates;

  @override
  void initState() {
    super.initState();
    _generateWeekDates();
  }

  void _generateWeekDates() {
    final now = DateTime.now();
    // Start from today and show next 7 days
    _weekDates = List.generate(7, (index) => now.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    final allTasks = ref.watch(tasksProvider);
    // Filter tasks for the selected date
    final selectedDateString = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final tasksForDate = allTasks.where((t) {
      if (t.dueDate == null) return false;
      return DateFormat('yyyy-MM-dd').format(t.dueDate!) == selectedDateString;
    }).toList();

    // Unscheduled tasks: tasks for this date that don't have a dueTime
    final unscheduledTasks = tasksForDate.where((t) => t.dueTime == null && !t.isCompleted).toList();
    // Scheduled tasks: tasks for this date that have a dueTime
    final scheduledTasks = tasksForDate.where((t) => t.dueTime != null && !t.isCompleted).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E1B33)),
        title: Text("Agenda Builder", style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF1E1B33))),
      ),
      body: Column(
        children: [
          // Date Strip
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SizedBox(
              height: 64,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _weekDates.length,
                itemBuilder: (context, index) {
                  final date = _weekDates[index];
                  final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                    child: Container(
                      width: 52,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF7C3AED) : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(DateFormat('E').format(date), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : const Color(0xFF6B7280))),
                          const SizedBox(height: 4),
                          Text(date.day.toString(), style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : const Color(0xFF1E1B33))),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Unscheduled Tasks Strip
          if (unscheduledTasks.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFF3F4F6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Unscheduled Tasks", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280))),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: unscheduledTasks.length,
                      itemBuilder: (context, index) {
                        final task = unscheduledTasks[index];
                        return Draggable<TaskModel>(
                          data: task,
                          feedback: Material(
                            color: Colors.transparent,
                            child: _buildTaskChip(task, isDragging: true),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: _buildTaskChip(task),
                          ),
                          child: _buildTaskChip(task),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Time Grid
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: 24,
              itemBuilder: (context, index) {
                final hour = index;
                final hourString = "${hour.toString().padLeft(2, '0')}:00";
                
                // Find tasks scheduled in this hour
                final tasksInHour = scheduledTasks.where((t) {
                  return t.dueTime?.startsWith(hour.toString().padLeft(2, '0')) ?? false;
                }).toList();

                return DragTarget<TaskModel>(
                  onAcceptWithDetails: (details) {
                    final task = details.data;
                    ref.read(tasksProvider.notifier).updateTask(
                      task.id,
                      dueTime: hourString,
                    );
                  },
                  builder: (context, candidateData, rejectedData) {
                    final isHovering = candidateData.isNotEmpty;
                    return Container(
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: const Color(0xFFE5E7EB), width: 0.5)),
                        color: isHovering ? const Color(0xFFEDE9FE) : Colors.transparent,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 60,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8, right: 8),
                              child: Text(
                                hourString,
                                textAlign: TextAlign.right,
                                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280)),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Stack(
                              children: [
                                if (tasksInHour.isEmpty && !isHovering)
                                  Positioned.fill(
                                    child: Center(
                                      child: Text("Drop task here", style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFD1D5DB))),
                                    ),
                                  ),
                                if (tasksInHour.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: tasksInHour.map((t) => Container(
                                        margin: const EdgeInsets.only(bottom: 4),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.3)),
                                        ),
                                        child: Text(t.title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF7C3AED)), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      )).toList(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskChip(TaskModel task, {bool isDragging = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDragging ? const Color(0xFF7C3AED) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDragging ? const Color(0xFF7C3AED) : const Color(0xFFD1D5DB)),
        boxShadow: isDragging ? [BoxShadow(color: const Color(0xFF7C3AED).withValues(alpha: 0.3), blurRadius: 8, spreadRadius: 2)] : [],
      ),
      child: Text(
        task.title,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDragging ? Colors.white : const Color(0xFF1E1B33),
        ),
      ),
    );
  }
}
