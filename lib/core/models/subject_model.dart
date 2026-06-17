import 'package:hive/hive.dart';
part 'subject_model.g.dart';

@HiveType(typeId: 1)
class SubjectModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String name;
  @HiveField(2) double targetAttendance;

  SubjectModel({
    required this.id,
    required this.name,
    this.targetAttendance = 75.0,
  });
}
