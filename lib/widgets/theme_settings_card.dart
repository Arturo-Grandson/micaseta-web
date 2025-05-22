import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micaseta_web/providers/theme_provider.dart' as app_theme;
import 'package:micaseta_web/utils/app_theme.dart';

class ThemeSettingsCard extends ConsumerWidget {
  const ThemeSettingsCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(app_theme.themeProvider);
    final themeNotifier = ref.read(app_theme.themeProvider.notifier);
    final isDarkMode = themeNotifier.isDarkMode(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingL),
      elevation: AppTheme.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ajustes de tema',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spacingM),

            // Selector de tema con estilo visual
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Opción de modo claro
                  RadioListTile<app_theme.ThemeMode>(
                    title: const Text('Modo claro'),
                    secondary:
                        const Icon(Icons.light_mode, color: Colors.amber),
                    value: app_theme.ThemeMode.light,
                    groupValue: themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        themeNotifier.setTheme(value);
                      }
                    },
                  ),

                  // Opción de modo oscuro
                  RadioListTile<app_theme.ThemeMode>(
                    title: const Text('Modo oscuro'),
                    secondary:
                        const Icon(Icons.dark_mode, color: Colors.indigo),
                    value: app_theme.ThemeMode.dark,
                    groupValue: themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        themeNotifier.setTheme(value);
                      }
                    },
                  ),

                  // Opción de modo del sistema
                  RadioListTile<app_theme.ThemeMode>(
                    title: const Text('Usar tema del sistema'),
                    secondary: const Icon(Icons.settings_suggest,
                        color: Colors.blueGrey),
                    value: app_theme.ThemeMode.system,
                    groupValue: themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        themeNotifier.setTheme(value);
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingM),

            // Vista previa del tema
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vista previa',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          isDarkMode ? Colors.white : AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Text(
                    'Así es como se verá la aplicación con el tema seleccionado.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode
                          ? Colors.white70
                          : AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Botón principal'),
                      ),
                      const SizedBox(width: AppTheme.spacingM),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('Botón secundario'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
