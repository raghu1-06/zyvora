import 'package:hive/hive.dart';
part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String title;
  @HiveField(2) String? notes;
  @HiveField(3) DateTime? dueDate;
  @HiveField(4) String? dueTime;
  @HiveField(5) bool isCompleted;
  @HiveField(6) String category;
  @HiveField(7) String priority;
  @HiveField(8) String repeat;
  @HiveField(9) List<String> subtaskTitles;
  @HiveField(10) List<bool> subtaskDone;
  @HiveField(11) bool hasReminder;
  @HiveField(12) DateTime createdAt;
  @HiveField(13) String? blockedBy;

  TaskModel({
    required this.id,
    required this.title,
    this.notes,
    this.dueDate,
    this.dueTime,
    this.isCompleted = false,
    required this.category,
    required this.priority,
    this.repeat = 'Once',
    this.subtaskTitles = const [],
    this.subtaskDone = const [],
    this.hasReminder = false,
    required this.createdAt,
    this.blockedBy,
  });

  bool get isOverdue {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return due.isBefore(today) && !isCompleted;
  }
}
