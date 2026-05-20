// Main entry point for the Zyvora application.
// 
// This file initializes the Flutter engine, preserves the native splash screen
// during initialization, configures system UI overlays, and runs the application
// wrapped in a Riverpod [ProviderScope].

import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/navigation/app_router.dart';
import 'core/providers.dart';
import 'core/theme/app_theme.dart';

/// The main entry point of the application.
///
/// It ensures Flutter widget bindings are initialized, configures the
/// splash screen and system overlays, and starts the app.
void main() {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: ZyvoraColors.background,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const ProviderScope(child: ZyvoraApp()));
}

/// The root widget of the Zyvora application.
///
/// It configures the [MaterialApp] with the application's theme, routing
/// (using GoRouter), and listens to the user's theme preferences using Riverpod.
class ZyvoraApp extends ConsumerWidget {
  /// Creates the [ZyvoraApp] widget.
  const ZyvoraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final isDarkMode = ref.watch(
      userControllerProvider.select((user) => user.isDarkMode),
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Zyvora',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
