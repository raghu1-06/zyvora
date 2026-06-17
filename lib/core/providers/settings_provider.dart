import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);
final targetAttendanceProvider = StateProvider<double>((ref) => 75.0);
final notificationsProvider = StateProvider<bool>((ref) => true);
final focusModeProvider = StateProvider<bool>((ref) => true);
final hapticProvider = StateProvider<bool>((ref) => true);
final adaptiveProvider = StateProvider<bool>((ref) => true);
final darkThemeProvider = StateProvider<bool>((ref) => false);
final syncProvider = StateProvider<bool>((ref) => true);
