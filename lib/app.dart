import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/home/home_page.dart';
import 'package:todo_list/onboarding_page.dart';

class MyApp extends StatefulWidget {
  final bool initialOnboardingSeen;

  const MyApp({super.key, this.initialOnboardingSeen = false});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  bool _isRussian = true;
  late bool _isOnboardingSeen;

  @override
  void initState() {
    super.initState();
    _isOnboardingSeen = widget.initialOnboardingSeen;
  }

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _toggleLanguage() {
    setState(() {
      _isRussian = !_isRussian;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingSeen', true);

    setState(() {
      _isOnboardingSeen = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _isRussian ? 'Мои задачи' : 'My tasks',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B82F6)),
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF111827),
      ),
      home: _isOnboardingSeen
          ? HomePage(
              isRussian: _isRussian,
              isDarkMode: _themeMode == ThemeMode.dark,
              onThemeChanged: _toggleTheme,
              onLanguageChanged: _toggleLanguage,
            )
          : OnboardingPage(
              isRussian: _isRussian,
              onComplete: _completeOnboarding,
            ),
    );
  }
}
