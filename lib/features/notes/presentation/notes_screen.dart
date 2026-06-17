import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../core/theme/app_colors.dart';
import 'new_note_screen.dart';

class Note {
  final String title;
  final String preview;
  final bool hasCheckboxes;
  final String timeAgo;

  Note({required this.title, required this.preview, required this.timeAgo, this.hasCheckboxes = false});
}

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final List<Color> _borderColors = const [
    Color(0xFF06B6D4), Color(0xFFEC4899), Color(0xFF10B981),
    Color(0xFFF59E0B), Color(0xFF7C3AED), Color(0xFFEF4444)
  ];

  final List<Note> _notes = [
    Note(title: "Project Ideas", preview: "Build a new Flutter app\nAdd AI features\nRefactor navigation", timeAgo: "2 hours ago", hasCheckboxes: true),
    Note(title: "Grocery List", preview: "Milk\nEggs\nBread", timeAgo: "Yesterday", hasCheckboxes: true),
    Note(title: "Meeting Notes", preview: "Discussed the new UI design. Need to ensure that the masonry grid view works correctly on all device sizes.", timeAgo: "2 days ago"),
    Note(title: "Random Thoughts", preview: "Why is the sky blue? I need to look that up later.", timeAgo: "Last week"),
    Note(title: "Books to Read", preview: "1. The Pragmatic Programmer\n2. Clean Code", timeAgo: "Last month"),
    Note(title: "Workout Plan", preview: "Push\nPull\nLegs\nRest", timeAgo: "Last month"),
  ];

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: topPadding + 16, left: 20, right: 20, bottom: 8),
                child: Row(
                  children: [
                    Text("Notes", style: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B33))),
                  ],
                ),
              ),
              Expanded(
                child: MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    final color = _borderColors[index % _borderColors.length];
                    return _NoteCard(note: note, borderColor: color);
                  },
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 100, // Account for custom floating dock nav bar
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NewNoteScreen()));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: const [BoxShadow(color: Color(0x337C3AED), blurRadius: 12, offset: Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add, color: Colors.white, size: 20),
                    const SizedBox(width: 6),
                    Text("New Note", style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final Color borderColor;

  const _NoteCard({required this.note, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left: BorderSide(color: borderColor, width: 4),
            top: const BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
            right: const BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
            bottom: const BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(note.title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1E1B33)), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            if (note.hasCheckboxes)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD1D5DB)),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(note.preview, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280)), maxLines: 3, overflow: TextOverflow.ellipsis),
                  ),
                ],
              )
            else
              Text(note.preview, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6B7280)), maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Text(note.timeAgo, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF9CA3AF))),
          ],
        ),
      ),
    );
  }
}
