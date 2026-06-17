import 'package:flutter/material.dart';

/// Life mode: the top-level split in the app.
enum LifeMode {
  personal,
  professional;

  String get label {
    switch (this) {
      case LifeMode.personal:
        return 'Personal';
      case LifeMode.professional:
        return 'Professional';
    }
  }

  String get subtitle {
    switch (this) {
      case LifeMode.personal:
        return 'Habits, routines & self-care';
      case LifeMode.professional:
        return 'Work, studies & career';
    }
  }

  IconData get icon {
    switch (this) {
      case LifeMode.personal:
        return Icons.favorite_outline;
      case LifeMode.professional:
        return Icons.work_outline;
    }
  }

  String get storageValue => name;

  static LifeMode? fromStorage(String? value) {
    for (final mode in LifeMode.values) {
      if (mode.storageValue == value) return mode;
    }
    return null;
  }
}

/// Professional roles.
enum ZyvoraRole {
  student,
  employee,
  teacher,
  freelancer;

  String get label {
    switch (this) {
      case ZyvoraRole.student:
        return 'Student';
      case ZyvoraRole.employee:
        return 'Employee';
      case ZyvoraRole.teacher:
        return 'Teacher';
      case ZyvoraRole.freelancer:
        return 'Freelancer';
    }
  }

  String get headline {
    switch (this) {
      case ZyvoraRole.student:
        return 'Student Mode';
      case ZyvoraRole.employee:
        return 'Employee Mode';
      case ZyvoraRole.teacher:
        return 'Teacher Mode';
      case ZyvoraRole.freelancer:
        return 'Freelancer Mode';
    }
  }

  String get description {
    switch (this) {
      case ZyvoraRole.student:
        return 'Attendance, classes, exams & study sessions';
      case ZyvoraRole.employee:
        return 'Meetings, shifts, tasks & focus sessions';
      case ZyvoraRole.teacher:
        return 'Classes, students, exams & scheduling';
      case ZyvoraRole.freelancer:
        return 'Projects, clients, invoices & deadlines';
    }
  }

  IconData get icon {
    switch (this) {
      case ZyvoraRole.student:
        return Icons.school_outlined;
      case ZyvoraRole.employee:
        return Icons.work_outline;
      case ZyvoraRole.teacher:
        return Icons.menu_book_outlined;
      case ZyvoraRole.freelancer:
        return Icons.rocket_launch_outlined;
    }
  }

  List<String> get categories {
    switch (this) {
      case ZyvoraRole.student:
        return const [
          'Class',
          'Assignment',
          'Exam',
          'Study Session',
          'Lab',
          'Project',
          'Custom',
        ];
      case ZyvoraRole.employee:
        return const [
          'Meeting',
          'Task',
          'Deadline',
          'Shift',
          'Focus Session',
          'Custom',
        ];
      case ZyvoraRole.teacher:
        return const [
          'Class',
          'Meeting',
          'Exam',
          'Grading',
          'Preparation',
          'Custom',
        ];
      case ZyvoraRole.freelancer:
        return const [
          'Client Meeting',
          'Project Deadline',
          'Invoice',
          'Focus Session',
          'Follow-up',
          'Custom',
        ];
    }
  }

  String get defaultCategory => categories.first;

  String get storageValue => name;

  static ZyvoraRole? fromStorage(String? value) {
    for (final role in ZyvoraRole.values) {
      if (role.storageValue == value) return role;
    }
    return null;
  }
}
