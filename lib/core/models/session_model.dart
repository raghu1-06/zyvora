import 'package:hive/hive.dart';
part 'session_model.g.dart';

@HiveType(typeId: 2)
class SessionModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String subjectId;
  @HiveField(2) DateTime date;
  @HiveField(3) bool isPresent;
  @HiveField(4) String sessionType;

  SessionModel({
    required this.id,
    required this.subjectId,
    required this.date,
    required this.isPresent,
    this.sessionType = 'Regular',
  });
}
