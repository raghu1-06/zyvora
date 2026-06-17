import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/task_model.dart';
import '../services/notification_service.dart';

class TasksNotifier extends StateNotifier<List<TaskModel>> {
  final Box<TaskModel> box;
  
  TasksNotifier(this.box) : super(box.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt)));

  void add(TaskModel t) { 
    box.put(t.id, t); 
    state = [...state, t]; 
    _checkReminder(t);
  }
  
  void toggleComplete(String id) {
    final i = state.indexWhere((t) => t.id == id);
    if (i == -1) return;
    final updated = state[i]..isCompleted = !state[i].isCompleted;
    box.put(id, updated);
    state = [...state];
  }
  
  void delete(String id) { 
    box.delete(id); 
    state = state.where((t) => t.id != id).toList(); 
  }
  
  void update(TaskModel t) { 
    box.put(t.id, t); 
    state = [...state.where((x) => x.id != t.id), t]; 
    _checkReminder(t);
  }
  
  void updateTask(String id, {String? dueTime}) {
    final i = state.indexWhere((t) => t.id == id);
    if (i == -1) return;
    final t = state[i];
    if (dueTime != null) t.dueTime = dueTime;
    box.put(id, t);
    state = [...state];
    _checkReminder(t);
  }
  
  void _checkReminder(TaskModel t) {
    if (t.hasReminder && t.dueDate != null && t.dueTime != null && !t.isCompleted) {
      final parts = t.dueTime!.split(':');
      if (parts.length == 2) {
        final dt = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day, int.parse(parts[0]), int.parse(parts[1]));
        if (dt.isAfter(DateTime.now())) {
          NotificationService().scheduleTaskReminder(t.id.hashCode, "Task Reminder", t.title, dt);
        }
      }
    }
  }
  
  void toggleSubtask(String taskId, int subtaskIndex) { 
    final i = state.indexWhere((t) => t.id == taskId);
    if (i == -1) return;
    final updated = state[i];
    if (subtaskIndex >= 0 && subtaskIndex < updated.subtaskDone.length) {
      updated.subtaskDone[subtaskIndex] = !updated.subtaskDone[subtaskIndex];
      box.put(taskId, updated);
      state = [...state];
    }
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  List<TaskModel> get todayTasks => state.where((t) =>
      t.dueDate != null && _isSameDay(t.dueDate!, DateTime.now()) && !t.isCompleted).toList();
      
  List<TaskModel> get overdueTasks => state.where((t) => t.isOverdue).toList();
  
  List<TaskModel> get pendingTasks => state.where((t) => !t.isCompleted).toList();
}

final tasksProvider = StateNotifierProvider<TasksNotifier, List<TaskModel>>(
  (ref) => TasksNotifier(Hive.box<TaskModel>('tasks'))
);
