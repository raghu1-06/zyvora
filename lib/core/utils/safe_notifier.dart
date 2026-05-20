import 'package:flutter/foundation.dart';

/// Skips [ChangeNotifier.notifyListeners] when nothing is listening, which
/// avoids framework asserts during route teardown / async completion races.
mixin SafeNotifier on ChangeNotifier {
  bool _isDisposed = false;

  bool get isNotifierDisposed => _isDisposed;

  void notifySafely() {
    if (_isDisposed || !hasListeners) return;
    super.notifyListeners();
  }

  @override
  void notifyListeners() {
    if (_isDisposed || !hasListeners) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
