import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/note_model.dart';
import '../../../core/providers/notes_provider.dart';
import 'new_note_screen.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final List<Color> _borderColors = const [
    Color(0xFF06B6D4), Color(0xFFEC4899), Color(0xFF10B981),
    Color(0xFFF59E0B), Color(0xFF7C3AED), Color(0xFFEF4444)
  ];



  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final notes = ref.watch(notesProvider);
    
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
                child: notes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.note_outlined, size: 64, color: AppColors.textMuted),
                            const SizedBox(height: 16),
                            Text("No notes yet", style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                            const SizedBox(height: 8),
                            Text("Tap + to create your first note", style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
                          ],
                        ),
                      )
                    : MasonryGridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          final note = notes[index];
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
        Navigator.push(context, MaterialPageRoute(builder: (_) => NewNoteScreen(existingNote: note)));
      
  }
}

class _NoteCard extends ConsumerWidget {
  final NoteModel note;
  final Color borderColor;

  const _NoteCard({required this.note, required this.borderColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {},
      onLongPress: () {
        ref.read(notesProvider.notifier).delete(note.id);
      },
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
            if (note.body.contains('- [ ]') || note.body.contains('- [x]'))
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
                    child: Text(note.body.replaceAll('- [ ]', '').replaceAll('- [x]', '').trim(), style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280)), maxLines: 3, overflow: TextOverflow.ellipsis),
                  ),
                ],
              )
            else
              Text(note.body, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6B7280)), maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Text(note.createdAt.toString().substring(0, 10), style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF9CA3AF))),
          ],
        ),
      ),
    );
  }
}
