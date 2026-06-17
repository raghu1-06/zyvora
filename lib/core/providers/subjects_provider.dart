import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/subject_model.dart';

class SubjectsNotifier extends StateNotifier<List<SubjectModel>> {
  final Box<SubjectModel> box;

  SubjectsNotifier(this.box) : super(box.values.toList());

  void add(SubjectModel s) {
    box.put(s.id, s);
    state = [...state, s];
  }

  void update(SubjectModel s) {
    box.put(s.id, s);
    state = [...state.where((x) => x.id != s.id), s];
  }

  void delete(String id) {
    box.delete(id);
    state = state.where((s) => s.id != id).toList();
  }
}

final subjectsProvider = StateNotifierProvider<SubjectsNotifier, List<SubjectModel>>(
  (ref) => SubjectsNotifier(Hive.box<SubjectModel>('subjects'))
);
