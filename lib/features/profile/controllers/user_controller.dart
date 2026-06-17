import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/safe_notifier.dart';
import '../../../models/zyvora_role.dart';

class UserController extends ChangeNotifier with SafeNotifier {
  LifeMode? _lifeMode;
  ZyvoraRole? _role;
  bool _isDarkMode = false;
  bool _isReady = false;
  bool _isLoading = false;
  String? _errorMessage;
  String _userName = '';

  LifeMode? get lifeMode => _lifeMode;
  ZyvoraRole? get role => _role;
  bool get isDarkMode => _isDarkMode;
  bool get isReady => _isReady;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get userName => _userName.isEmpty ? 'there' : _userName;
  String get storedUserName => _userName;
  bool get isFirstLaunch => _lifeMode == null;
  String get todayName => ZyvoraDays.fromWeekday(DateTime.now().weekday);

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> initialize() async {
    if (_isReady || _isLoading) return;
    _setLoading(true);

    try {
      final prefs = await SharedPreferences.getInstance();
      _lifeMode = LifeMode.fromStorage(prefs.getString('zyvora.lifeMode'));
      _role = ZyvoraRole.fromStorage(prefs.getString('zyvora.role'));
      _isDarkMode = prefs.getBool('zyvora.darkMode') ?? false;
      _userName = prefs.getString('zyvora.userName') ?? '';
      _errorMessage = null;
    } catch (e) {
      debugPrint('Preference startup failed: $e');
      _errorMessage = 'Could not load preferences.';
    } finally {
      _isReady = true;
      _setLoading(false);
    }
  }

  Future<void> setLifeMode(LifeMode mode) async {
    _lifeMode = mode;
    _role = mode == LifeMode.personal ? null : _role;
    _errorMessage = null;
    notifySafely();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('zyvora.lifeMode', mode.storageValue);
    if (mode == LifeMode.personal) {
      await prefs.remove('zyvora.role');
    }
  }

  Future<void> setRole(ZyvoraRole role) async {
    _lifeMode = LifeMode.professional;
    _role = role;
    _errorMessage = null;
    notifySafely();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('zyvora.lifeMode', LifeMode.professional.storageValue);
    await prefs.setString('zyvora.role', role.storageValue);
  }

  Future<void> setDarkMode(bool dark) async {
    _isDarkMode = dark;
    notifySafely();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('zyvora.darkMode', dark);
  }

  Future<void> setUserName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw Exception('Name cannot be empty');
    }
    if (trimmed.length > 100) {
      throw Exception('Name cannot exceed 100 characters');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('zyvora.userName', trimmed);
      _userName = trimmed;
      _errorMessage = null;
      notifySafely();
    } catch (e) {
      debugPrint('Error saving user name: $e');
      rethrow;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifySafely();
  }
}
