import '../services/database_service.dart';
import '../services/intelligence_engine.dart';
import '../../models/insight.dart';
import '../../models/reminder.dart';

class AnalyticsRepository {
  final DatabaseService _db;

  AnalyticsRepository({required DatabaseService db}) : _db = db;

  Future<List<Insight>> generateInsights(List<Reminder> reminders) {
    return IntelligenceEngine(db: _db).generateInsights(reminders);
  }
}
