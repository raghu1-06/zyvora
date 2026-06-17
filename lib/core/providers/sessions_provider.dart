import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/session_model.dart';

class SessionsNotifier extends StateNotifier<List<SessionModel>> {
  final Box<SessionModel> box;

  SessionsNotifier(this.box) : super(box.values.toList()..sort((a,b) => b.date.compareTo(a.date)));

  void add(SessionModel s) {
    box.put(s.id, s);
    state = [...state, s]..sort((a,b) => b.date.compareTo(a.date));
  }

  void delete(String id) {
    box.delete(id);
    state = state.where((s) => s.id != id).toList();
  }

  List<SessionModel> getForSubject(String subjectId) {
    return state.where((s) => s.subjectId == subjectId).toList();
  }

  double getPercent(String subjectId) {
    final list = getForSubject(subjectId);
    if (list.isEmpty) return 0.0;
    final present = list.where((s) => s.isPresent).length;
    return (present / list.length) * 100;
  }

  int getSafeBunks(String subjectId, double target) {
    final list = getForSubject(subjectId);
    if (list.isEmpty) return 0;
    final present = list.where((s) => s.isPresent).length;
    int maxTotal = (present / (target / 100)).floor();
    int safe = maxTotal - list.length;
    return safe > 0 ? safe : 0;
  }

  int getClassesNeeded(String subjectId, double target) {
    final list = getForSubject(subjectId);
    final total = list.length;
    final present = list.where((s) => s.isPresent).length;
    
    if (total > 0 && (present / total * 100) >= target) return 0;
    
    double t = target / 100;
    if (t >= 1.0) return 999; 
    
    double x = (t * total - present) / (1 - t);
    return x.ceil() > 0 ? x.ceil() : 0;
  }

  String getStatus(double pct) {
    if (pct >= 75) return "On Track";
    if (pct >= 60) return "Caution";
    return "Attention";
  }
}

final sessionsProvider = StateNotifierProvider<SessionsNotifier, List<SessionModel>>(
  (ref) => SessionsNotifier(Hive.box<SessionModel>('sessions'))
);
