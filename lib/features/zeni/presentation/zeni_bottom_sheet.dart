import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/zeni_repository.dart';
import '../../../core/models/task_model.dart';
import '../../../core/models/note_model.dart';
import '../../../core/models/subject_model.dart';
import '../../../core/models/session_model.dart';
import '../../../core/providers/tasks_provider.dart';
import '../../../core/providers/notes_provider.dart';
import '../../../core/providers/subjects_provider.dart';
import '../../../core/providers/sessions_provider.dart';

class Message {
  final String text;
  final bool isUser;
  Message(this.text, this.isUser);
}

class ZeniBottomSheet extends ConsumerStatefulWidget {
  const ZeniBottomSheet({super.key});

  @override
  ConsumerState<ZeniBottomSheet> createState() => _ZeniBottomSheetState();
}

class _ZeniBottomSheetState extends ConsumerState<ZeniBottomSheet> {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<Message> _messages = [];
  bool _isLoading = false;
  String _apiKey = '';
  final _repo = ZeniRepository();

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }
  
  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiKey = prefs.getString('zeni_api_key') ?? '';
    });
  }

  Future<void> _saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('zeni_api_key', key);
    setState(() {
      _apiKey = key;
    });
  }
  
  void _promptApiKey() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Gemini API Key", style: GoogleFonts.sora(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Please enter your free Gemini API key from Google AI Studio to use Zeni.", style: GoogleFonts.inter(fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(hintText: "AIzaSy...", border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              _saveApiKey(ctrl.text.trim());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), foregroundColor: Colors.white),
            child: const Text("Save"),
          ),
        ],
      )
    );
  }

  void _sendMessage([String? predefinedText]) async {
    final text = predefinedText ?? _inputCtrl.text.trim();
    if (text.isEmpty) return;
    
    if (_apiKey.isEmpty) {
      _promptApiKey();
      return;
    }
    
    _inputCtrl.clear();
    setState(() {
      _messages.add(Message(text, true));
      _isLoading = true;
    });
    _scrollToBottom();
    
    final result = await _repo.process(text, _apiKey);
    
    String responseText = "";
    if (result is ZeniTaskCreated) {
      responseText = "✅ Created task: ${result.title} [${result.priority} priority, ${result.category}]";
      ref.read(tasksProvider.notifier).add(TaskModel(
        id: const Uuid().v4(),
        title: result.title,
        dueDate: result.dueDate.isNotEmpty ? DateTime.tryParse(result.dueDate) : null,
        dueTime: result.dueTime.isNotEmpty ? result.dueTime : null,
        priority: result.priority,
        category: result.category,
        createdAt: DateTime.now(),
      ));
    } else if (result is ZeniAttendanceLogged) {
      responseText = "✅ Marked ${result.subject} as ${result.isPresent ? 'Present' : 'Absent'}.";
      final subjects = ref.read(subjectsProvider);
      SubjectModel? subject;
      try {
        subject = subjects.firstWhere((s) => s.name.toLowerCase() == result.subject.toLowerCase());
      } catch (e) {
        subject = SubjectModel(id: const Uuid().v4(), name: result.subject);
        ref.read(subjectsProvider.notifier).add(subject);
      }
      ref.read(sessionsProvider.notifier).add(SessionModel(
        id: const Uuid().v4(),
        subjectId: subject.id,
        isPresent: result.isPresent,
        sessionType: 'Lecture',
        date: DateTime.now(),
      ));
    } else if (result is ZeniNoteCreated) {
      responseText = "✅ Created note: ${result.title}";
      ref.read(notesProvider.notifier).add(NoteModel(
        id: const Uuid().v4(),
        title: result.title,
        body: result.body,
        noteType: 'plain',
        colorIndex: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    } else if (result is ZeniChatResponse) {
      responseText = result.message;
    } else if (result is ZeniError) {
      responseText = "⚠️ Error: ${result.error}";
    }
    
    if (mounted) {
      setState(() {
        _messages.add(Message(responseText, false));
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }
  
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(50)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 22, backgroundColor: Color(0xFF7C3AED), child: Icon(Icons.auto_awesome, color: Colors.white, size: 24)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Zeni", style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B33))),
                        Text("Your personal AI assistant", style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF9CA3AF))),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD1FAE5)), borderRadius: BorderRadius.circular(50)),
                      child: Row(
                        children: [
                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text("ONLINE", style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF10B981))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
              
              Expanded(
                child: _messages.isEmpty ? _buildEmptyState() : _buildChatState(),
              ),
              
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(color: const Color(0xFFF9F9FF), borderRadius: BorderRadius.circular(50), border: Border.all(color: const Color(0xFFE5E7EB))),
                        child: TextField(
                          controller: _inputCtrl,
                          style: GoogleFonts.inter(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: "Ask Zeni anything...",
                            hintStyle: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF9CA3AF)),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(width: 40, height: 40, decoration: const BoxDecoration(color: Color(0xFFEDE9FE), shape: BoxShape.circle), child: const Icon(Icons.mic_none_rounded, color: Color(0xFF7C3AED), size: 20)),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _sendMessage(),
                      child: Container(width: 40, height: 40, decoration: const BoxDecoration(color: Color(0xFF3B82F6), shape: BoxShape.circle), child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Column(
        children: [
          Container(
            width: 90, height: 90,
            decoration: const BoxDecoration(
              color: Color(0xFFEDE9FE),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Color(0x407C3AED), blurRadius: 28, spreadRadius: 4)],
            ),
            child: const Icon(Icons.auto_awesome, color: Color(0xFF7C3AED), size: 42),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Meet Zeni ", style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B33))),
              const Text("✨", style: TextStyle(fontSize: 22)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Your intelligent productivity partner.\nManage tasks, note down thoughts,\nand log attendance naturally.",
            style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF6B7280), height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          _ZeniAction(Icons.checklist_rounded, "Review what I learned today", () => _sendMessage("Review what I learned today")),
          _ZeniAction(Icons.task_alt_rounded, "Plan tomorrow's assignments", () => _sendMessage("Plan tomorrow's assignments")),
          _ZeniAction(Icons.school_outlined, "Log my study hours", () => _sendMessage("Log my study hours")),
        ],
      ),
    );
  }

  Widget _buildChatState() {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        if (msg.isUser) {
          return Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12, left: 40),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF7C3AED),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(18), bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18), topRight: Radius.circular(4)),
              ),
              child: Text(msg.text, style: GoogleFonts.inter(fontSize: 14, color: Colors.white)),
            ),
          );
        } else {
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12, right: 40),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(topRight: Radius.circular(18), bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18), topLeft: Radius.circular(4)),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.auto_awesome, color: Color(0xFF7C3AED), size: 14),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(msg.text, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF1E1B33)))),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

class _ZeniAction extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  
  const _ZeniAction(this.icon, this.text, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE5E7EB))),
        child: Row(
          children: [
            Container(width: 32, height: 32, decoration: BoxDecoration(color: const Color(0xFFEDE9FE), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: const Color(0xFF7C3AED), size: 16)),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF1E1B33)))),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFD1D5DB)),
          ],
        ),
      ),
    );
  }
}
