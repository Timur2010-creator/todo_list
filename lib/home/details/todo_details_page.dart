import 'package:flutter/material.dart';
import 'package:todo_list/database/app_database.dart';

class TodoDetailsResult {
  final Todo? todo;
  final bool deleted;

  const TodoDetailsResult({this.todo, this.deleted = false});
}

class TodoDetailsPage extends StatefulWidget {
  final Todo todo;
  final AppDatabase database;
  final bool isRussian;

  const TodoDetailsPage({
    super.key,
    required this.todo,
    required this.database,
    required this.isRussian,
  });

  @override
  State<TodoDetailsPage> createState() => _TodoDetailsPageState();
}

class _TodoDetailsPageState extends State<TodoDetailsPage> {
  late final TextEditingController _titleController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _updateTodo() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    setState(() => _isSaving = true);
    widget.todo.title = title;
    await widget.database.updateTodo(widget.todo);
    if (!mounted) return;
    Navigator.pop(context, TodoDetailsResult(todo: widget.todo));
  }

  Future<void> _deleteTodo() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(widget.isRussian ? 'Удалить задачу?' : 'Delete task?'),
        content: Text(widget.todo.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(widget.isRussian ? 'Отмена' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(widget.isRussian ? 'Удалить' : 'Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.database.deleteTodo(widget.todo);
    if (!mounted) return;
    Navigator.pop(context, const TodoDetailsResult(deleted: true));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isRussian ? 'Детали задачи' : 'Task details'),
        actions: [
          IconButton(
            onPressed: _deleteTodo,
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: widget.isRussian ? 'Удалить' : 'Delete',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isRussian ? 'Название' : 'Title',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _titleController,
                autofocus: true,
                maxLines: 5,
                minLines: 3,
                decoration: InputDecoration(
                  hintText: widget.isRussian
                      ? 'Введите название задачи'
                      : 'Enter task title',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: .45),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(18),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _updateTodo,
                  icon: const Icon(Icons.save_rounded),
                  label: Text(
                    widget.isRussian ? 'Сохранить изменения' : 'Save changes',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
