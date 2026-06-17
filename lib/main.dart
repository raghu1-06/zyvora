import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'startup/zyvora_startup_overlay.dart';
import 'core/navigation/app_router.dart';
import 'core/models/task_model.dart';
import 'core/models/subject_model.dart';
import 'core/models/session_model.dart';
import 'core/models/note_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(SubjectModelAdapter());
  Hive.registerAdapter(SessionModelAdapter());
  Hive.registerAdapter(NoteModelAdapter());
  
  await Future.wait([
    Hive.openBox<TaskModel>('tasks'),
    Hive.openBox<SubjectModel>('subjects'),
    Hive.openBox<SessionModel>('sessions'),
    Hive.openBox<NoteModel>('notes'),
  ]);
  
  await _seedIfEmpty();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const ProviderScope(child: ZyvoraApp()));
}

Future<void> _seedIfEmpty() async {
  final subjectsBox = Hive.box<SubjectModel>('subjects');
  final tasksBox = Hive.box<TaskModel>('tasks');
  final notesBox = Hive.box<NoteModel>('notes');

  if (subjectsBox.isEmpty) {
    subjectsBox.put('1', SubjectModel(id: '1', name: 'Mathematics', targetAttendance: 75.0));
    subjectsBox.put('2', SubjectModel(id: '2', name: 'Physics', targetAttendance: 75.0));
    subjectsBox.put('3', SubjectModel(id: '3', name: 'English', targetAttendance: 75.0));
    subjectsBox.put('4', SubjectModel(id: '4', name: 'DBMS', targetAttendance: 75.0));
  }

  if (tasksBox.isEmpty) {
    final now = DateTime.now();
    tasksBox.put('t1', TaskModel(
      id: 't1', title: 'Finish Physics Lab Report', 
      dueDate: now.subtract(const Duration(days: 1)),
      dueTime: '11:59 PM', priority: 'High', category: 'Study',
      createdAt: now.subtract(const Duration(days: 2))
    ));
    tasksBox.put('t2', TaskModel(
      id: 't2', title: 'Review App Architecture', 
      dueDate: now, dueTime: '4:00 PM', priority: 'Medium', category: 'Work',
      createdAt: now.subtract(const Duration(hours: 10))
    ));
  }

  if (notesBox.isEmpty) {
    final now = DateTime.now();
    notesBox.put('n1', NoteModel(
      id: 'n1', title: 'Project Ideas', body: 'Build a new Flutter app\nAdd AI features', noteType: 'todo', colorIndex: 0,
      createdAt: now, updatedAt: now,
    ));
    notesBox.put('n2', NoteModel(
      id: 'n2', title: 'Meeting Notes', body: 'Discussed new UI design.', noteType: 'plain', colorIndex: 2,
      createdAt: now.subtract(const Duration(days: 1)), updatedAt: now.subtract(const Duration(days: 1)),
    ));
  }
}

class ZyvoraApp extends ConsumerStatefulWidget {
  const ZyvoraApp({super.key});

  @override
  ConsumerState<ZyvoraApp> createState() => _ZyvoraAppState();
}

class _ZyvoraAppState extends ConsumerState<ZyvoraApp> {
  bool _showStartup = true;

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp.router(
      title: 'Zyvora',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            if (_showStartup)
              ZyvoraStartupOverlay(
                onComplete: () {
                  setState(() => _showStartup = false);
                },
              ),
          ],
        );
      },
    );
  }
}
