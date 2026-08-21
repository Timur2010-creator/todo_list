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
          final primary = theme.colorScheme.primary;

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Text(isRussian ? 'Настройки' : 'Settings'),
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                Text(
                  isRussian ? 'Персонализируйте приложение' : 'Make it yours',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isRussian
                      ? 'Выберите язык и внешний вид для комфортной работы.'
                      : 'Choose the language and appearance that work best for you.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(
                  icon: Icons.translate_rounded,
                  title: isRussian ? 'Язык' : 'Language',
                  color: primary,
                ),
                const SizedBox(height: 10),
                Card(
                  margin: EdgeInsets.zero,
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'ru', label: Text('Русский')),
                        ButtonSegment(value: 'en', label: Text('English')),
                      ],
                      selected: {isRussian ? 'ru' : 'en'},
                      onSelectionChanged: (_) => onLanguageChanged(),
                      showSelectedIcon: false,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(
                  icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  title: isRussian ? 'Внешний вид' : 'Appearance',
                  color: primary,
                ),
                const SizedBox(height: 10),
                Card(
                  margin: EdgeInsets.zero,
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: SwitchListTile.adaptive(
                    value: isDark,
                    onChanged: (value) {
                      context.read<SettingCubit>().setTheme(value);
                      onThemeChanged(value);
                    },
                    title: Text(isRussian ? 'Тёмная тема' : 'Dark theme'),
                    subtitle: Text(
                      isRussian ? 'Бережёт глаза в темноте' : 'Easier on the eyes at night',
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    activeColor: primary,
                  ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(
                  icon: Icons.storage_rounded,
                  title: isRussian ? 'Данные' : 'Data',
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 10),
                Card(
                  margin: EdgeInsets.zero,
                  elevation: 0,
                  color: theme.colorScheme.errorContainer.withValues(alpha: .42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.delete_sweep_outlined, color: theme.colorScheme.error),
                    title: Text(isRussian ? 'Очистить все задачи' : 'Clear all tasks'),
                    subtitle: Text(isRussian ? 'Удалить задачи с устройства' : 'Remove tasks from this device'),
                    trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.error),
                    onTap: onClearTasks,
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

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionLabel({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
        ),
      ],
    );
  }
}
