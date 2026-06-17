import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import '../../../core/models/task_model.dart';
import '../../../core/providers/tasks_provider.dart';

class RoutineScreen extends ConsumerStatefulWidget {
  const RoutineScreen({super.key});

  @override
  ConsumerState<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends ConsumerState<RoutineScreen> {
  late ConfettiController _confettiController;
  late List<TaskModel> _routineTasks;
  int _currentIndex = 0;
  int _completedCount = 0;
  Timer? _timer;
  int _secondsLeft = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _routineTasks = ref.read(tasksProvider.notifier).pendingTasks;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_routineTasks.isNotEmpty) {
        _startCurrentTaskTimer();
      }
    });
  }

  void _startCurrentTaskTimer() {
    _timer?.cancel();
    if (_currentIndex < _routineTasks.length) {
      final task = _routineTasks[_currentIndex];
      int mins = task.durationMinutes ?? 25;
      setState(() {
        _secondsLeft = mins * 60;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return timer.cancel();
        if (_secondsLeft > 0) {
          setState(() => _secondsLeft--);
        } else {
          _completeCurrentTaskAndNext();
        }
      });
    }
  }

  void _completeCurrentTaskAndNext() {
    if (_currentIndex < _routineTasks.length) {
      final task = _routineTasks[_currentIndex];
      ref.read(tasksProvider.notifier).toggleComplete(task.id);
      _completedCount++;
    }
    _nextTask();
  }

  void _nextTask() {
    if (_currentIndex < _routineTasks.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _startCurrentTaskTimer();
    } else {
      _timer?.cancel();
      setState(() {
        _currentIndex++; // past the end = finished
      });
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final total = _routineTasks.length;
    final isFinished = _currentIndex >= total || total == 0;
    final progress = total == 0 ? 1.0 : (_currentIndex / total);

    return Scaffold(
      backgroundColor: const Color(0xFF07060F), // Dark theme for focus
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              "ROUTINE MODE",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: const Color(0xFF2D2B50),
                                valueColor: const AlwaysStoppedAnimation(Color(0xFF7C3AED)),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48), // balance close button
                    ],
                  ),
                ),

                Expanded(
                  child: isFinished
                      ? _buildFinishedState()
                      : _buildActiveTaskState(),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              maxBlastForce: 100,
              minBlastForce: 80,
              gravity: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinishedState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: Color(0xFF10B981),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 24),
        Text(
          "Routine Complete!",
          style: GoogleFonts.sora(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "You completed $_completedCount tasks.",
          style: GoogleFonts.inter(
            fontSize: 16,
            color: const Color(0xFF9CA3AF),
          ),
        ),
        const SizedBox(height: 48),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7C3AED),
            minimumSize: const Size(200, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          ),
          child: Text(
            "Back to Tasks",
            style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveTaskState() {
    final task = _routineTasks[_currentIndex];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2B50),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              "Task ${_currentIndex + 1} of ${_routineTasks.length}",
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFFA78BFA),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            task.title,
            style: GoogleFonts.sora(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          if (task.notes != null && task.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              task.notes!,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF9CA3AF),
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 48),
          Text(
            _formatTime(_secondsLeft),
            style: GoogleFonts.sora(
              fontSize: 64,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF7C3AED),
            ),
          ),
          const SizedBox(height: 48),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _nextTask(); // Skip
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF2D2B50), width: 2),
                    minimumSize: const Size(0, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    "Skip",
                    style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _completeCurrentTaskAndNext,
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: Text(
                    "Complete",
                    style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
