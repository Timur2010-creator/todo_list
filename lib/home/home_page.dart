import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/home/add/add_page.dart';
import 'package:todo_list/home/settings_page.dart';

class TaskItem { // Модель данных для одной задачи (добавлен ID для точной идентификации)
  final String id;
  String title;
  bool isDone;
  final String time;

  TaskItem({
    required this.id,
    required this.title,
    this.isDone = false,
    required this.time,
  });
}

class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final bool isRussian;
  final ValueChanged<bool> onThemeChanged;
  final VoidCallback onLanguageChanged;

  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.isRussian,
    required this.onThemeChanged,
    required this.onLanguageChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<TaskItem> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTasks = prefs.getStringList('tasks') ?? [];

    setState(() {
      _tasks.clear();
      for (final taskJson in storedTasks) {
        try {
          final decoded = jsonDecode(taskJson) as Map<String, dynamic>;
          _tasks.add(
            TaskItem(
              id: decoded['id']?.toString() ?? DateTime.now().toString(),
              title: decoded['title']?.toString() ?? '',
              isDone: decoded['isDone'] as bool? ?? false,
              time: decoded['time']?.toString() ?? _getCurrentTimeString(),
            ),
          );
        } catch (_) {
          continue;
        }
      }
    });
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedTasks = _tasks.map((task) => jsonEncode({
      'id': task.id,
      'title': task.title,
      'isDone': task.isDone,
      'time': task.time,
    })).toList();

    await prefs.setStringList('tasks', encodedTasks);
  }

  // Вспомогательный метод для получения текущего времени строкой
  String _getCurrentTimeString() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  // 1. Создание новой задачи
  void _addNewTask(String title) {
    setState(() {
      _tasks.add(
        TaskItem(
          id: DateTime.now().toString(),
          title: title,
          isDone: false,
          time: _getCurrentTimeString(),
        ),
      );
    });
    _saveTasks();
  }

  // 2. Удаление задачи по индексу
  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Задача удалена'), duration: Duration(seconds: 2)),
    );
  }

  // 3. Редактирование задачи
  Future<void> _editTask(int index) async {
    // Переходим на ту же страницу, но передаем текущий текст
    final updatedText = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => AddPage(
          initialText: _tasks[index].title, // Передаем текст для редактирования
        ),
      ),
    );

    // Если вернулся текст и он не пустой
    if (updatedText != null && updatedText.trim().isNotEmpty) {
      setState(() {
        _tasks[index].title = updatedText.trim();
      });
      _saveTasks();
    }
  }

  // 4. Очистка всех задач
  Future<void> _clearAllTasks() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить все задачи?'),
        content: const Text('Это удалит все сохранённые задачи с устройства.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Нет'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Да'),
          ),
        ],
      ),
    );

    if (shouldClear == true) { // Если пользователь подтвердил очистку
      setState(() {
        _tasks.clear(); // Очищаем список задач
      });
      await _saveTasks(); // Сохраняем пустой список в SharedPreferences
      if (!mounted) return; // Если виджет был удален из дерева, выходим
      if (Navigator.canPop(context)) { // Проверяем, можно ли вернуться на предыдущий экран
        Navigator.pop(context); // Возвращаемся на предыдущий экран, если возможно
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Все задачи очищены'), duration: Duration(seconds: 2)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRussian = widget.isRussian;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          isRussian ? 'Мои задачи' : 'My tasks',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: widget.onLanguageChanged,
            icon: const Icon(Icons.language, size: 18),
            label: Text(isRussian ? 'Сменить язык' : 'Change language'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: _clearAllTasks,
            tooltip: isRussian ? 'Очистить задачи' : 'Clear tasks',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    isRussian: widget.isRussian,
                    isDarkMode: widget.isDarkMode,
                    onThemeChanged: widget.onThemeChanged,
                    onLanguageChanged: widget.onLanguageChanged,
                    onClearTasks: _clearAllTasks,
                  ),
                ),
              );
            },
            tooltip: isRussian ? 'Настройки' : 'Settings',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: theme.dividerColor, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _tasks.isEmpty
                  ? Center(child: Text(isRussian ? 'Добавьте первую задачу' : 'Add your first task', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(15), // Скругление углов карточек заданий
                    ),
                    child: Stack( // Используем Stack, чтобы кнопка меню была поверх всего
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: task.isDone,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        task.isDone = value ?? false;
                                      });
                                    },
                                    activeColor: theme.colorScheme.onPrimary,
                                    checkColor: theme.colorScheme.primary,
                                    side: BorderSide(color: theme.colorScheme.onPrimary, width: 2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 30), // Отступ для иконки меню
                                    child: Text(
                                      task.title,
                                      style: TextStyle(
                                        color: theme.colorScheme.onPrimary,
                                        fontSize: 15,
                                        decoration: task.isDone
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                        decorationColor: theme.colorScheme.onPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            Text(
                              task.time,
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),

                        Positioned(
                          top: -10, // Сдвигаем вверх, т.к. у PopupMenuButton есть свои отступы
                          right: -10,
                          child: PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert, color: theme.colorScheme.onPrimary),
                            onSelected: (String value) {
                              if (value == 'edit') {
                                _editTask(index);
                              } else if (value == 'delete') {
                                _deleteTask(index);
                              }
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: Colors.black54, size: 20),
                                    SizedBox(width: 8),
                                    Text('Редактировать'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red, size: 20),
                                    SizedBox(width: 8),
                                    Text('Удалить', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    // Переходим на второй экран БЕЗ initialText (режим создания)
                    final newTaskTitle = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(builder: (context) => const AddPage()),
                    );

                    // Если пользователь ввел текст и нажал "Сохранить", добавляем его
                    if (newTaskTitle != null && newTaskTitle.trim().isNotEmpty) {
                      _addNewTask(newTaskTitle.trim());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3B82F6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18), // Скругление углов кнопки "Добавить задачу"
                    ),
                  ),
                  child: Text(
                    isRussian ? '+ Добавить задачу' : '+ Add task',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}