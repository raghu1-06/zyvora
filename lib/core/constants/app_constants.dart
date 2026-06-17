class ZyvoraDays {
  static const ordered = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const weekdayNumbers = {
    'Monday': DateTime.monday,
    'Tuesday': DateTime.tuesday,
    'Wednesday': DateTime.wednesday,
    'Thursday': DateTime.thursday,
    'Friday': DateTime.friday,
    'Saturday': DateTime.saturday,
    'Sunday': DateTime.sunday,
  };

  static String fromWeekday(int weekday) {
    return weekdayNumbers.entries
        .firstWhere(
          (entry) => entry.value == weekday,
          orElse: () => const MapEntry('Monday', DateTime.monday),
        )
        .key;
  }

  static String shortName(String day) {
    if (day.length >= 3) return day.substring(0, 3);
    return day;
  }
}

/// Categories for Personal mode reminders.
class PersonalCategories {
  static const medicine = 'Medicine';
  static const gym = 'Gym';
  static const study = 'Study';
  static const water = 'Water';
  static const sleep = 'Sleep';
  static const family = 'Family';
  static const habit = 'Habit';
  static const custom = 'Custom';

  static const all = [
    medicine,
    gym,
    study,
    water,
    sleep,
    family,
    habit,
    custom,
  ];
}

/// Categories for Professional mode reminders, per role.
class ProfessionalCategories {
  static const studentCategories = [
    'Class',
    'Assignment',
    'Exam',
    'Study Session',
    'Lab',
    'Project',
    'Custom',
  ];

  static const employeeCategories = [
    'Meeting',
    'Task',
    'Deadline',
    'Shift',
    'Focus Session',
    'Custom',
  ];

  static const teacherCategories = [
    'Class',
    'Meeting',
    'Exam',
    'Grading',
    'Preparation',
    'Custom',
  ];

  static const freelancerCategories = [
    'Client Meeting',
    'Project Deadline',
    'Invoice',
    'Focus Session',
    'Follow-up',
    'Custom',
  ];
}
