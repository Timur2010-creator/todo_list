import 'dart:async';
import 'package:flutter/material.dart';
import 'package:todo_list/database/app_database.dart';
import 'package:todo_list/home/add/add_page.dart';
import 'package:todo_list/home/details/todo_details_page.dart';
import 'package:todo_list/home/settings/settings_page.dart';

typedef TaskItem = Todo;

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
  final AppDatabase _database = AppDatabase();
  late Timer _clockTimer;
  DateTime _currentTime = DateTime.now();
  bool _showCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final todos = await _database.getTodos();
    if (!mounted) return;
    setState(() {
      _tasks
        ..clear()
        ..addAll(todos);
    });
  }

  String _getCurrentTimeString() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  String _formatDate() {
    const months = [
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря',
    ];
    return widget.isRussian
        ? '${_currentTime.day} ${months[_currentTime.month - 1]}'
        : '${_currentTime.month}/${_currentTime.day}/${_currentTime.year}';
  }

  Future<void> _openEditor({TaskItem? task}) async {
    final title = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddPage(initialText: task?.title, isRussian: widget.isRussian),
      ),
    );
    if (title == null || title.trim().isEmpty) return;
    setState(() {
      if (task == null) {
        _tasks.insert(
          0,
          TaskItem(
            id: DateTime.now().toString(),
            title: title.trim(),
            time: _getCurrentTimeString(),
          ),
        );
      } else {
        task.title = title.trim();
      }
    });
    if (task == null) {
      await _database.insertTodo(_tasks.first);
    } else {
      await _database.updateTodo(task);
    }
  }

  void _toggleTask(TaskItem task, bool value) {
    setState(() => task.isDone = value);
    _database.updateTodo(task);
  }

  Future<void> _deleteTask(TaskItem task) async {
    setState(() => _tasks.removeWhere((item) => item.id == task.id));
    await _database.deleteTodo(task);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isRussian ? 'Задача удалена' : 'Task deleted'),
        ),
      );
    }
  }

  Future<void> _openDetails(TaskItem task) async {
    final result = await Navigator.push<TodoDetailsResult>(
      context,
      MaterialPageRoute(
        builder: (_) => TodoDetailsPage(
          todo: task,
          database: _database,
          isRussian: widget.isRussian,
        ),
      ),
    );
    if (!mounted || result == null) return;
    if (result.deleted) {
      setState(() => _tasks.removeWhere((item) => item.id == task.id));
    } else if (result.todo != null) {
      setState(() {
        final index = _tasks.indexWhere((item) => item.id == result.todo!.id);
        if (index != -1) _tasks[index] = result.todo!;
      });
    }
  }

  Future<void> _clearAllTasks() async {
    if (_tasks.isEmpty) return;
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          widget.isRussian ? 'Очистить все задачи?' : 'Clear all tasks?',
        ),
        content: Text(
          widget.isRussian
              ? 'Все задачи будут удалены с устройства.'
              : 'All tasks will be removed from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(widget.isRussian ? 'Отмена' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(widget.isRussian ? 'Очистить' : 'Clear'),
          ),
        ],
      ),
    );
    if (shouldClear != true) return;
    setState(_tasks.clear);
    await _database.deleteAllTodos();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completed = _tasks.where((task) => task.isDone).length;
    final visibleTasks = _tasks
        .where((task) => task.isDone == _showCompleted)
        .toList();
    final progress = _tasks.isEmpty ? 0.0 : completed / _tasks.length;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (widget.isRussian
                                    ? 'С возвращением'
                                    : 'Welcome back')
                                .toUpperCase(),
                            style: theme.textTheme.labelMedium?.copyWith(
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _formatDate(),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: widget.onLanguageChanged,
                      icon: const Icon(Icons.language_rounded),
                      tooltip: widget.isRussian
                          ? 'Сменить язык'
                          : 'Change language',
                    ),
                    const SizedBox(width: 6),
                    IconButton.filledTonal(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SettingsPage(
                            isRussian: widget.isRussian,
                            isDarkMode: widget.isDarkMode,
                            onThemeChanged: widget.onThemeChanged,
                            onLanguageChanged: widget.onLanguageChanged,
                            onClearTasks: _clearAllTasks,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.tune_rounded),
                      tooltip: widget.isRussian ? 'Настройки' : 'Settings',
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        const Color(0xFF174E63),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: .22),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.isRussian
                                  ? 'Фокус на сегодня'
                                  : 'Focus for today',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            '$completed/${_tasks.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.isRussian
                            ? (completed == _tasks.length && _tasks.isNotEmpty
                                  ? 'Отлично. Всё выполнено.'
                                  : 'Маленькие шаги складываются в большой результат.')
                            : (completed == _tasks.length && _tasks.isNotEmpty
                                  ? 'Great. Everything is complete.'
                                  : 'Small steps make a big difference.'),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .78),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 9,
                          backgroundColor: Colors.white.withValues(alpha: .18),
                          valueColor: const AlwaysStoppedAnimation(
                            Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Text(
                      widget.isRussian ? 'Твои задачи' : 'Your tasks',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    SegmentedButton<bool>(
                      segments: [
                        ButtonSegment(
                          value: false,
                          label: Text(widget.isRussian ? 'Активные' : 'Open'),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text(widget.isRussian ? 'Готово' : 'Done'),
                        ),
                      ],
                      selected: {_showCompleted},
                      onSelectionChanged: (value) =>
                          setState(() => _showCompleted = value.first),
                    ),
                  ],
                ),
              ),
            ),
            if (visibleTasks.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(
                  isRussian: widget.isRussian,
                  completed: _showCompleted,
                  onAdd: () => _openEditor(),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                sliver: SliverList.builder(
                  itemCount: visibleTasks.length,
                  itemBuilder: (_, index) => _TaskCard(
                    task: visibleTasks[index],
                    isRussian: widget.isRussian,
                    onToggle: (value) =>
                        _toggleTask(visibleTasks[index], value),
                    onOpen: () => _openDetails(visibleTasks[index]),
                    onEdit: () => _openEditor(task: visibleTasks[index]),
                    onDelete: () => _deleteTask(visibleTasks[index]),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add_rounded),
        label: Text(widget.isRussian ? 'Новая задача' : 'New task'), 
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskItem task;
  final bool isRussian;
  final ValueChanged<bool> onToggle;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    required this.isRussian,
    required this.onToggle,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final time = task.time.length > 5 ? task.time.substring(0, 5) : task.time;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .42),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
            child: Row(
              children: [
                Checkbox(
                  value: task.isDone,
                  onChanged: (value) => onToggle(value ?? false),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          decoration: task.isDone
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.isDone
                              ? theme.colorScheme.onSurfaceVariant
                              : null,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${isRussian ? 'добавлено' : 'added'}  $time',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) =>
                      value == 'edit' ? onEdit() : onDelete(),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(isRussian ? 'Изменить' : 'Edit'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(isRussian ? 'Удалить' : 'Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isRussian;
  final bool completed;
  final VoidCallback onAdd;

  const _EmptyState({
    required this.isRussian,
    required this.completed,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            completed ? Icons.celebration_rounded : Icons.bolt_rounded,
            size: 54,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 14),
          Text(
            completed
                ? (isRussian
                      ? 'Пока ничего не выполнено'
                      : 'Nothing completed yet')
                : (isRussian
                      ? 'День начинается с одной задачи'
                      : 'Start your day with one task'),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (!completed) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: Text(isRussian ? 'Добавить задачу' : 'Add a task'),
            ),
          ],
        ],
      ),
    ),
  );
}
