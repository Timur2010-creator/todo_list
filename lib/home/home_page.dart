import 'package:flutter/material.dart';
import 'package:todo_list/home/add/add_page.dart';

class TaskItem {// Модель данных для одной задачи (добавлен ID для точной идентификации)
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
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<TaskItem> _tasks = [  // Список задач (теперь с ID)
    TaskItem(id: '1', title: 'Сделать домашнее задание', isDone: false, time: '14:02:26'),
    TaskItem(id: '2', title: 'Помыть посуду', isDone: true, time: '14:05:10'),
    TaskItem(id: '3', title: 'Купить продукты', isDone: false, time: '15:10:00'),
  ];

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
          id: DateTime.now().toString(), // Генерируем уникальный ID
          title: title,
          isDone: false,
          time: _getCurrentTimeString(),
        ),
      );
    });
  }

  // 2. Удаление задачи по индексу
  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(  // Добавил уведомление внизу экрана
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Мои задачи',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade300, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _tasks.isEmpty
                  ? const Center(child: Text("Задач пока нет. Добавьте первую!", style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(10),
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
                                    activeColor: Colors.white,
                                    checkColor: const Color(0xFF3B82F6),
                                    side: const BorderSide(color: Colors.white, width: 2),
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
                                        color: Colors.white,
                                        fontSize: 15,
                                        decoration: task.isDone
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                        decorationColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            Text(
                              task.time,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),

                        Positioned(
                          top: -10, // Сдвигаем вверх, т.к. у PopupMenuButton есть свои отступы
                          right: -10,
                          child: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: Colors.white),
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
                    backgroundColor: const Color(0xFF3B82F6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    '+ Добавить задачу',
                    style: TextStyle(
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