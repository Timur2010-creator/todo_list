import 'package:flutter/material.dart';
import 'package:todo_list/home/home_page.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  bool _isRussian = true;

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
      home: HomePage(
        isRussian: _isRussian,
        isDarkMode: _themeMode == ThemeMode.dark,
        onThemeChanged: _toggleTheme,
        onLanguageChanged: _toggleLanguage,
      ),
    );
  }
}