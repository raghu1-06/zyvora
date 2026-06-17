import 'package:hive/hive.dart';
part 'note_model.g.dart';

@HiveType(typeId: 3)
class NoteModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String title;
  @HiveField(2) String body;
  @HiveField(3) String noteType;
  @HiveField(4) int colorIndex;
  @HiveField(5) DateTime createdAt;
  @HiveField(6) DateTime updatedAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.body,
    required this.noteType,
    required this.colorIndex,
    required this.createdAt,
    required this.updatedAt,
  });
}
