import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../core/utils/safe_notifier.dart';
import '../../../data/repositories/alarm_repository.dart';
import '../../../models/alarm.dart';

class AlarmController extends ChangeNotifier with SafeNotifier {
  final AlarmRepository _repo;
  bool _isLoading = false;
  String? _errorMessage;

  AlarmController({required AlarmRepository repo}) : _repo = repo;

  List<Alarm> get alarms => _repo.alarms;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void attachPlugin(FlutterLocalNotificationsPlugin plugin) {
    _repo.service.attachPlugin(plugin);
  }

  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _repo.initialize();
      _errorMessage = null;
    } catch (e) {
      debugPrint('Alarm init failed: $e');
      _errorMessage = 'Could not initialize alarms.';
    } finally {
      _setLoading(false);
    }
  }

  Future<Alarm> add({
    required String label,
    required int hour,
    required int minute,
    Set<int> repeatDays = const {},
    String sound = 'default',
    bool vibrate = true,
  }) {
    return _repo.add(
      label: label,
      hour: hour,
      minute: minute,
      repeatDays: repeatDays,
      sound: sound,
      vibrate: vibrate,
    );
  }

  Future<void> update(Alarm alarm) => _repo.update(alarm);

  Future<void> toggle(int id, bool enabled) => _repo.toggle(id, enabled);

  Future<void> remove(int id) => _repo.remove(id);

  void _setLoading(bool value) {
    _isLoading = value;
    notifySafely();
  }
}
