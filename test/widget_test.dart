import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:todo_list/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferences.getInstance();
  });

  testWidgets('opens settings and switches theme to dark', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Мои задачи'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.text('Тема приложения'), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.dark);
  });

  testWidgets('switches the app language from the home page', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Мои задачи'), findsOneWidget);
    expect(find.text('Сменить язык'), findsOneWidget);

    await tester.tap(find.text('Сменить язык'));
    await tester.pumpAndSettle();

    expect(find.text('My tasks'), findsOneWidget);
  });

  testWidgets('clears all saved tasks from settings', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'tasks': [
        jsonEncode({
          'id': '1',
          'title': 'Проверка очистки',
          'isDone': false,
          'time': '12:00:00',
        }),
      ],
    });

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Проверка очистки'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Очистить все задачи'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Да'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance(); // Получаем экземпляр SharedPreferences после очистки задач
    expect(prefs.getStringList('tasks'), isEmpty);
  });
}
