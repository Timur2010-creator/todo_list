import 'package:flutter/material.dart';

class AddPage extends StatefulWidget {
  final String?
  initialText; // Параметр для редактирования. Если null -> создаем новую, если есть текст -> редактируем
  final bool isRussian;

  const AddPage({super.key, this.initialText, required this.isRussian});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  late final TextEditingController _taskController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.initialText != null;
    // Инициализируем контроллер текстом, если он передан (для редактирования)
    _taskController = TextEditingController(text: widget.initialText ?? '');
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _saveTask() {
    final text = _taskController.text;
    if (text.trim().isNotEmpty) {
      // Закрываем экран и передаем текст назад в HomePage (неважно, создание это или редактирование)
      Navigator.pop(context, text);
    } else {
      // Если поле пустое, можно показать предупреждение или просто вернуться назад
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: theme.colorScheme.onSurface,
            size: 18,
          ),
          onPressed: () =>
              Navigator.pop(context), // Просто возвращаемся ничего не сохраняя
        ),
        title: Text(
          widget.isRussian
              ? (_isEditing ? 'Редактировать' : 'Новая задача')
              : (_isEditing ? 'Edit task' : 'New task'),
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.isRussian
                      ? 'Сформулируй следующий шаг'
                      : 'Define your next step',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _taskController,
                maxLines: 5,
                minLines: 3,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: widget.isRussian
                      ? 'Например: закончить презентацию'
                      : 'For example: finish the presentation',
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
                  onPressed: _saveTask,
                  icon: const Icon(Icons.check_rounded),
                  label: Text(
                    widget.isRussian
                        ? (_isEditing ? 'Обновить' : 'Сохранить')
                        : (_isEditing ? 'Update' : 'Save'),
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
