import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Todo {
  final String id;
  String title;
  bool isDone;
  final String time;

  Todo({
    required this.id,
    required this.title,
    this.isDone = false,
    required this.time,
  });

  factory Todo.fromJson(String value) {
    final json = jsonDecode(value) as Map<String, dynamic>;
    return Todo(
      id: json['id']?.toString() ?? DateTime.now().toString(),
      title: json['title']?.toString() ?? '',
      isDone: json['isDone'] as bool? ?? false,
      time: json['time']?.toString() ?? '',
    );
  }

  String toJson() =>
      jsonEncode({'id': id, 'title': title, 'isDone': isDone, 'time': time});
}

class AppDatabase {
  static const _tasksKey = 'tasks';

  Future<List<Todo>> getTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTodos = prefs.getStringList(_tasksKey) ?? [];
    return storedTodos
        .map((value) {
          try {
            return Todo.fromJson(value);
          } catch (_) {
            return null;
          }
        })
        .whereType<Todo>()
        .toList();
  }

  Future<void> insertTodo(Todo todo) async {
    final todos = await getTodos();
    todos.insert(0, todo);
    await _saveTodos(todos);
  }

  Future<void> updateTodo(Todo todo) async {
    final todos = await getTodos();
    final index = todos.indexWhere((item) => item.id == todo.id);
    if (index == -1) return;
    todos[index] = todo;
    await _saveTodos(todos);
  }

  Future<void> deleteTodo(Todo todo) async {
    final todos = await getTodos();
    todos.removeWhere((item) => item.id == todo.id);
    await _saveTodos(todos);
  }

  Future<void> deleteAllTodos() async {
    await _saveTodos([]);
  }

  Future<void> _saveTodos(List<Todo> todos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _tasksKey,
      todos.map((todo) => todo.toJson()).toList(),
    );
  }
}
