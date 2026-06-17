import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/note_model.dart';
import '../../../core/providers/notes_provider.dart';

class NewNoteScreen extends ConsumerStatefulWidget {
  final NoteModel? existingNote;
  const NewNoteScreen({super.key, this.existingNote});

  @override
  ConsumerState<NewNoteScreen> createState() => _NewNoteScreenState();
}

class _NewNoteScreenState extends ConsumerState<NewNoteScreen> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _contentCtrl = TextEditingController();
  
  int _wordCount = 0;
  int _activeTool = 5; // Date tool is default
  Timer? _saveTimer;
  bool _isSaving = false;
  late final String _noteId;
  bool _isFirstSave = true;

  final List<(IconData, String)> _tools = const [
    (Icons.check_box_outline_blank, "To-do"),
    (Icons.format_list_bulleted, "Bullet"),
    (Icons.format_list_numbered, "List"),
    (Icons.image_outlined, "Image"),
    (Icons.auto_awesome, "Zeni"),
    (Icons.calendar_today_outlined, "Date"),
  ];

  @override
  void initState() {
    super.initState();
    _noteId = widget.existingNote?.id ?? const Uuid().v4();
    _isFirstSave = widget.existingNote == null;
    
    if (widget.existingNote != null) {
      _titleCtrl.text = widget.existingNote!.title;
      _contentCtrl.text = widget.existingNote!.body;
    }
    
    _contentCtrl.addListener(_onContentChanged);
    _titleCtrl.addListener(_onTextChanged);
  }

  void _onContentChanged() {
    final text = _contentCtrl.text;
    final words = text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
    if (words != _wordCount) {
      setState(() {
        _wordCount = words;
      });
    }
    _onTextChanged();
  }

  void _onTextChanged() {
    if (_saveTimer?.isActive ?? false) _saveTimer!.cancel();
    setState(() => _isSaving = true);
    _saveTimer = Timer(const Duration(seconds: 2), _saveNote);
  }
  
  void _saveNote() {
    if (_titleCtrl.text.isEmpty && _contentCtrl.text.isEmpty) {
      if (mounted) setState(() => _isSaving = false);
      return;
    }
    
    final note = NoteModel(
      id: _noteId,
      title: _titleCtrl.text.isEmpty ? "Untitled" : _titleCtrl.text,
      body: _contentCtrl.text,
      noteType: 'plain',
      colorIndex: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    if (_isFirstSave) {
      ref.read(notesProvider.notifier).add(note);
      _isFirstSave = false;
    } else {
      ref.read(notesProvider.notifier).update(note);
    }
    
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _saveNote();
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(widget.existingNote == null ? "New Note" : "Edit Note", style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1E1B33))),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF7C3AED), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text(
                _isSaving ? "Saving..." : "Saved",
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF7C3AED)),
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
              controller: _titleCtrl,
              style: GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B33)),
              decoration: InputDecoration(
                hintText: "Untitled",
                hintStyle: GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF9CA3AF)),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 6),
                Text(DateFormat("MMM d, yyyy").format(DateTime.now()), style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF9CA3AF))),
                const SizedBox(width: 8),
                const Text("•", style: TextStyle(color: Color(0xFF9CA3AF))),
                const SizedBox(width: 8),
                Text("$_wordCount words", style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF9CA3AF))),
              ],
            ),
          ),
          const Divider(color: Color(0xFFF3F4F6), height: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _contentCtrl,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF1E1B33), height: 1.6),
                decoration: InputDecoration(
                  hintText: "Start writing...",
                  hintStyle: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF9CA3AF)),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.only(top: 20, bottom: 20),
                ),
              ),
            ),
          ),
          Container(
            height: 64 + MediaQuery.of(context).padding.bottom,
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
              boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, -4))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_tools.length, (index) {
                final isActive = _activeTool == index;
                final tool = _tools[index];
                return GestureDetector(
                  onTap: () {
                    if (mounted) setState(() => _activeTool = index);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(tool.$1, size: 20, color: isActive ? const Color(0xFF7C3AED) : const Color(0xFF9CA3AF)),
                      const SizedBox(height: 4),
                      Text(tool.$2, style: GoogleFonts.inter(fontSize: 10, fontWeight: isActive ? FontWeight.w600 : FontWeight.w500, color: isActive ? const Color(0xFF7C3AED) : const Color(0xFF9CA3AF))),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
