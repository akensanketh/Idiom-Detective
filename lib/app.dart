import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/theme_provider.dart';
import 'screens/main_shell.dart';
import 'screens/settings/settings_screen.dart';

/// The root widget — wires up theme, providers, and routing.
class IdiomDetectiveApp extends StatelessWidget {
  const IdiomDetectiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Idiom Detective',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const MainShell(),
      routes: {
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
