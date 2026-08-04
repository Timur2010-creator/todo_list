import 'package:flutter/material.dart';

class AddPage extends StatefulWidget {
  final String? initialText;  // Параметр для редактирования. Если null -> создаем новую, если есть текст -> редактируем

  const AddPage({super.key, this.initialText});

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
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.onSurface, size: 18),
          onPressed: () => Navigator.pop(context), // Просто возвращаемся ничего не сохраняя
        ),
        title: Text(
          _isEditing ? 'Редактировать' : 'Новая задача',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 18,
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [

              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: TextField(
                  controller: _taskController,
                  maxLines: 3,
                  minLines: 1,
                  autofocus: true, // Сразу ставим фокус на поле ввода
                  decoration: InputDecoration(
                    hintText: 'Введите название задачи',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const Spacer(),
              
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    _isEditing ? 'Обновить' : 'Сохранить', // Меняем текст кнопки
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
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