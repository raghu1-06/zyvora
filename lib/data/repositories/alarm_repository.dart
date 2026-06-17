import '../services/alarm_service.dart';
import '../../models/alarm.dart';

class AlarmRepository {
  final AlarmService _service;

  AlarmRepository({required AlarmService service}) : _service = service;

  AlarmService get service => _service;

  List<Alarm> get alarms => _service.alarms;

  Future<void> initialize() => _service.initialize();

  Future<Alarm> add({
    required String label,
    required int hour,
    required int minute,
    Set<int> repeatDays = const {},
    String sound = 'default',
    bool vibrate = true,
  }) {
    return _service.add(
      label: label,
      hour: hour,
      minute: minute,
      repeatDays: repeatDays,
      sound: sound,
      vibrate: vibrate,
    );
  }

  Future<void> update(Alarm alarm) => _service.update(alarm);

  Future<void> toggle(int id, bool enabled) => _service.toggle(id, enabled);

  Future<void> remove(int id) => _service.remove(id);
}
