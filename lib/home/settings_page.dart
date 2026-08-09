import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'setting_cubit.dart';

class SettingsPage extends StatelessWidget {
  final bool isDarkMode;
  final bool isRussian;
  final ValueChanged<bool> onThemeChanged;
  final VoidCallback onLanguageChanged;
  final Future<void> Function()? onClearTasks;

  const SettingsPage({
    super.key,
    required this.isDarkMode,
    required this.isRussian,
    required this.onThemeChanged,
    required this.onLanguageChanged,
    this.onClearTasks,
  });

  @override
  Widget build(BuildContext context) {
    final isRussian = this.isRussian;

    return BlocProvider(
      create: (_) => SettingCubit(isDarkMode),
      child: BlocBuilder<SettingCubit, bool>(
        builder: (context, isDark) {
          final theme = Theme.of(context);

          return Scaffold(
            backgroundColor: isDark ? Colors.black : theme.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Text(
                isRussian ? 'Настройки' : 'Settings',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRussian ? 'Язык приложения' : 'App language',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ChoiceChip(
                              label: const Text('Русский'),
                              selected: isRussian,
                              onSelected: (_) => onLanguageChanged(),
                            ),
                            ChoiceChip(
                              label: const Text('English'),
                              selected: !isRussian,
                              onSelected: (_) => onLanguageChanged(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SwitchListTile(
                    value: isDark,
                    onChanged: (val) {
                      context.read<SettingCubit>().setTheme(val);
                      onThemeChanged(val);
                    },
                    title: Text(isRussian ? 'Тема приложения' : 'App theme'),
                    subtitle: Text(
                      isRussian
                          ? 'Переключает светлую и темную тему по всему приложению'
                          : 'Switches light and dark theme throughout the app',
                    ),
                    secondary: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.delete_sweep_outlined, color: Color(0xFF3B82F6)),
                    title: Text(isRussian ? 'Очистить все задачи' : 'Clear all tasks'),
                    subtitle: Text(
                      isRussian
                          ? 'Удаляет все сохранённые задачи с устройства'
                          : 'Deletes all saved tasks from the device',
                    ),
                    onTap: () {
                      onClearTasks?.call();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
