import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/providers/tasks_provider.dart';

class FocusModeScreen extends ConsumerStatefulWidget {
  const FocusModeScreen({super.key});

  @override
  ConsumerState<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends ConsumerState<FocusModeScreen> {
  late AudioPlayer _audioPlayer;
  bool _isPlayingSound = false;
  
  Timer? _timer;
  int _secondsLeft = 25 * 60; // 25 mins work
  bool _isBreak = false;
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDNDHint();
    });
  }

  void _showDNDHint() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Tip: Turn on Do Not Disturb on your device for maximum focus.",
          style: GoogleFonts.inter(),
        ),
        backgroundColor: const Color(0xFF7C3AED),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleTimer() {
    if (_isActive) {
      _timer?.cancel();
      setState(() => _isActive = false);
    } else {
      setState(() => _isActive = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return timer.cancel();
        if (_secondsLeft > 0) {
          setState(() => _secondsLeft--);
        } else {
          _timer?.cancel();
          setState(() {
            _isActive = false;
            _isBreak = !_isBreak;
            _secondsLeft = (_isBreak ? 5 : 25) * 60;
          });
        }
      });
    }
  }

  void _toggleSound() async {
    if (_isPlayingSound) {
      await _audioPlayer.stop();
      setState(() => _isPlayingSound = false);
    } else {
      // In a real app we would play an asset like 'assets/sounds/rain.mp3'
      // For now, we simulate success as we might not have the asset physically.
      // await _audioPlayer.play(AssetSource('sounds/rain.mp3'));
      setState(() => _isPlayingSound = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Playing ambient sound (Rain)", style: GoogleFonts.inter()),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _endFocus() {
    _timer?.cancel();
    _audioPlayer.stop();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final pendingTasks = ref.watch(tasksProvider).where((t) => !t.isCompleted).toList();
    final currentTask = pendingTasks.isNotEmpty ? pendingTasks.first : null;

    return Scaffold(
      backgroundColor: const Color(0xFF111128),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isBreak ? "BREAK TIME" : "FOCUS MODE",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: _isBreak ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isPlayingSound ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                      color: Colors.white,
                    ),
                    onPressed: _toggleSound,
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 280,
                          height: 280,
                          child: CircularProgressIndicator(
                            value: _secondsLeft / ((_isBreak ? 5 : 25) * 60),
                            strokeWidth: 8,
                            backgroundColor: const Color(0xFF2D2B50),
                            valueColor: AlwaysStoppedAnimation(
                              _isBreak ? const Color(0xFF10B981) : const Color(0xFF7C3AED),
                            ),
                          ),
                        ),
                        Text(
                          _formatTime(_secondsLeft),
                          style: GoogleFonts.sora(
                            fontSize: 72,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 64),
                    if (currentTask != null) ...[
                      Text(
                        "Currently focusing on:",
                        style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF9CA3AF)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentTask.title,
                        style: GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      Text(
                        "No pending tasks.",
                        style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF9CA3AF)),
                      ),
                    ],
                    const SizedBox(height: 48),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _toggleTimer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isActive ? const Color(0xFF2D2B50) : const Color(0xFF7C3AED),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(80, 80),
                            shape: const CircleBorder(),
                          ),
                          child: Icon(_isActive ? Icons.pause : Icons.play_arrow, size: 36),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: TextButton.icon(
                onPressed: _endFocus,
                icon: const Icon(Icons.stop_circle_rounded, color: Color(0xFFEF4444)),
                label: Text("End Focus", style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFFEF4444))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
