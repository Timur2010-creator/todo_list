import 'dart:async';
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
  late Timer _clockTimer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
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

  String _formatClockTime() {
    final now = _currentTime.toLocal();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String _formatClockDate() {
    final now = _currentTime.toLocal();
    return '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';
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
      SnackBar(
        content: Text(widget.isRussian ? 'Задача удалена' : 'Task deleted'),
        duration: const Duration(seconds: 2),
      ),
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
          isRussian: widget.isRussian,
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
        title: Text(widget.isRussian ? 'Очистить все задачи?' : 'Clear all tasks?'),
        content: Text(
          widget.isRussian
              ? 'Это удалит все сохранённые задачи с устройства.'
              : 'This will delete all saved tasks from the device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(widget.isRussian ? 'Нет' : 'No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(widget.isRussian ? 'Да' : 'Yes'),
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
        SnackBar(
          content: Text(widget.isRussian ? 'Все задачи очищены' : 'All tasks cleared'),
          duration: const Duration(seconds: 2),
        ),
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
        leadingWidth: 112,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
          child: Container(
            width: 100,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary, // Цвет градиента (синий)
                  theme.colorScheme.primary.withValues(alpha: 0.9), // Более светлый оттенок синего
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _formatClockTime(),
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 2),
                
                Text(
                  _formatClockDate(),
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.95),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        title: Text(
          isRussian ? 'Мои задачи' : 'My tasks', // Название приложения меняется в зависимости от выбранного языка
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [

          // Кнопка смены языка 
          IconButton(
            onPressed: widget.onLanguageChanged,
            icon: const Icon(Icons.language, size: 18),
            color: theme.colorScheme.primary,
            tooltip: isRussian ? 'Сменить язык' : 'Change language', // Чтобы менялись текста подсказок при смене языка
          ),

          // Кнопка очистки всех задач
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: _clearAllTasks,
            tooltip: isRussian ? 'Очистить задачи' : 'Clear tasks', // Чтобы менялись текста подсказок при смене языка
          ),

          // Кнопка перехода в настройки
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
            tooltip: isRussian ? 'Настройки' : 'Settings', // Чтобы менялись текста подсказок при смене языка
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
                      color: Color(0xFF3B82F6), // Цвет карточки заданий (светло-голубой)
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
                                    activeColor: theme.colorScheme.onPrimary, // Цвет галочки в чекбоксе (прозрачный - цвет карточки)
                                    checkColor: theme.colorScheme.primary, // Цвет фона галочки (белый)
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
                                      task.title, // Название задачи
                                      maxLines: 3,
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
                              task.time, // Время создания задачи
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
                              PopupMenuItem<String>(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    const Icon(Icons.edit, color: Colors.black54, size: 20),
                                    const SizedBox(width: 8),
                                    Text(widget.isRussian ? 'Редактировать' : 'Edit'),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    const Icon(Icons.delete, color: Colors.red, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      widget.isRussian ? 'Удалить' : 'Delete',
                                      style: const TextStyle(color: Colors.red),
                                    ),
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
                      MaterialPageRoute(
                        builder: (context) => AddPage(isRussian: widget.isRussian),
                      ),
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