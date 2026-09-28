import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/daily_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/idiom_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/theme_provider.dart';

/// Entry point for Idiom Detective.
///
/// Initializes providers and sets system UI overlay style for
/// the immersive detective noir look.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prefer dark status bar icons for light theme, light for dark
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0B1120),
    ),
  );

  // Lock to portrait for mobile-first design
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize providers before runApp
  final themeProvider = ThemeProvider();
  await themeProvider.initialize();

  final quizProvider = QuizProvider();
  await quizProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) {
          final provider = IdiomProvider();
          provider.initialize();
          return provider;
        }),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) {
          final provider = DailyProvider();
          provider.initialize();
          return provider;
        }),
        ChangeNotifierProvider.value(value: quizProvider),
      ],
      child: const IdiomDetectiveApp(),
    ),
  );
}
