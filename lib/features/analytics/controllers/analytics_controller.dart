import 'package:flutter/foundation.dart';

import '../../../core/utils/safe_notifier.dart';
import '../../../data/repositories/analytics_repository.dart';
import '../../../models/insight.dart';
import '../../../models/reminder.dart';

class AnalyticsController extends ChangeNotifier with SafeNotifier {
  final AnalyticsRepository _repo;

  AnalyticsController({required AnalyticsRepository repo}) : _repo = repo;

  List<Insight> _insights = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _loadVersion = 0;

  List<Insight> get insights => List.unmodifiable(_insights);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadInsights(List<Reminder> reminders) async {
    final version = ++_loadVersion;
    _setLoading(true);
    try {
      final list = await _repo.generateInsights(reminders);
      if (version != _loadVersion) return;
      _insights = list;
      _errorMessage = null;
    } catch (e) {
      debugPrint('Could not load insights: $e');
      if (version != _loadVersion) return;
      _insights = [];
      _errorMessage = 'Could not load insights.';
    } finally {
      if (version == _loadVersion) {
        _setLoading(false);
      }
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifySafely();
  }
}
