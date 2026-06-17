import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/note_model.dart';

class NotesNotifier extends StateNotifier<List<NoteModel>> {
  final Box<NoteModel> box;

  NotesNotifier(this.box) : super(box.values.toList()..sort((a,b) => b.updatedAt.compareTo(a.updatedAt)));

  void add(NoteModel n) {
    box.put(n.id, n);
    state = [...state, n]..sort((a,b) => b.updatedAt.compareTo(a.updatedAt));
  }

  void update(NoteModel n) {
    box.put(n.id, n);
    state = [...state.where((x) => x.id != n.id), n]..sort((a,b) => b.updatedAt.compareTo(a.updatedAt));
  }

  void delete(String id) {
    box.delete(id);
    state = state.where((n) => n.id != id).toList();
  }
}

final notesProvider = StateNotifierProvider<NotesNotifier, List<NoteModel>>(
  (ref) => NotesNotifier(Hive.box<NoteModel>('notes'))
);
