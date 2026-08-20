import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/database/app_database.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('AppDatabase inserts, updates and deletes Todo', () async {
    final database = AppDatabase();
    final todo = Todo(id: '1', title: 'Первый заголовок', time: '12:00:00');

    await database.insertTodo(todo);
    expect((await database.getTodos()).single.title, 'Первый заголовок');

    todo.title = 'Обновлённый заголовок';
    await database.updateTodo(todo);
    expect((await database.getTodos()).single.title, 'Обновлённый заголовок');

    await database.deleteTodo(todo);
    expect(await database.getTodos(), isEmpty);
  });
}
