// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = 0;

  @override
  TaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskModel(
      id: fields[0] as String,
      title: fields[1] as String,
      notes: fields[2] as String?,
      dueDate: fields[3] as DateTime?,
      dueTime: fields[4] as String?,
      isCompleted: fields[5] as bool,
      category: fields[6] as String,
      priority: fields[7] as String,
      repeat: fields[8] as String,
      subtaskTitles: (fields[9] as List).cast<String>(),
      subtaskDone: (fields[10] as List).cast<bool>(),
      hasReminder: fields[11] as bool,
      createdAt: fields[12] as DateTime,
      blockedBy: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.notes)
      ..writeByte(3)
      ..write(obj.dueDate)
      ..writeByte(4)
      ..write(obj.dueTime)
      ..writeByte(5)
      ..write(obj.isCompleted)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.priority)
      ..writeByte(8)
      ..write(obj.repeat)
      ..writeByte(9)
      ..write(obj.subtaskTitles)
      ..writeByte(10)
      ..write(obj.subtaskDone)
      ..writeByte(11)
      ..write(obj.hasReminder)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.blockedBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
