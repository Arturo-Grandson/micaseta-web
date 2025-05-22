import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micaseta_web/providers/theme_provider.dart' as app_theme;
import 'package:micaseta_web/utils/app_theme.dart';

class ThemeSettingsSimple extends ConsumerWidget {
  const ThemeSettingsSimple({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(app_theme.themeProvider.notifier);
    final isDarkMode = themeNotifier.isDarkMode(context);
    final currentTheme = ref.watch(app_theme.themeProvider);

    // Convertir el enum personalizado a una representación de string
    String themeModeText = 'Sistema';
    if (currentTheme == app_theme.ThemeMode.light) {
      themeModeText = 'Claro';
    } else if (currentTheme == app_theme.ThemeMode.dark) {
      themeModeText = 'Oscuro';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingL),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tema de la aplicación',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spacingM),

            // Opción para cambiar entre tema claro y oscuro
            ListTile(
              title: const Text('Tema actual'),
              subtitle: Text(themeModeText),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botón para cambiar a tema claro
                  IconButton(
                    icon: const Icon(Icons.light_mode),
                    tooltip: 'Tema claro',
                    onPressed: () =>
                        themeNotifier.setTheme(app_theme.ThemeMode.light),
                    style: IconButton.styleFrom(
                      backgroundColor: currentTheme == app_theme.ThemeMode.light
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Botón para cambiar a tema oscuro
                  IconButton(
                    icon: const Icon(Icons.dark_mode),
                    tooltip: 'Tema oscuro',
                    onPressed: () =>
                        themeNotifier.setTheme(app_theme.ThemeMode.dark),
                    style: IconButton.styleFrom(
                      backgroundColor: currentTheme == app_theme.ThemeMode.dark
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Botón para usar tema del sistema
                  IconButton(
                    icon: const Icon(Icons.settings_suggest),
                    tooltip: 'Usar tema del sistema',
                    onPressed: () =>
                        themeNotifier.setTheme(app_theme.ThemeMode.system),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          currentTheme == app_theme.ThemeMode.system
                              ? Theme.of(context).colorScheme.primaryContainer
                              : null,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Interruptor para alternar entre tema claro y oscuro
            SwitchListTile(
              title: const Text('Modo oscuro'),
              subtitle: Text(isDarkMode ? 'Activado' : 'Desactivado'),
              value: isDarkMode,
              onChanged: (value) {
                themeNotifier.setTheme(value
                    ? app_theme.ThemeMode.dark
                    : app_theme.ThemeMode.light);
              },
              secondary: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: isDarkMode ? Colors.amber : Colors.orangeAccent,
              ),
            ),

            // Usar tema del sistema
            SwitchListTile(
              title: const Text('Usar tema del sistema'),
              subtitle: const Text('Se ajustará automáticamente'),
              value: currentTheme == app_theme.ThemeMode.system,
              onChanged: (value) {
                if (value) {
                  themeNotifier.setTheme(app_theme.ThemeMode.system);
                } else {
                  themeNotifier.setTheme(isDarkMode
                      ? app_theme.ThemeMode.dark
                      : app_theme.ThemeMode.light);
                }
              },
              secondary: const Icon(Icons.settings_suggest),
            ),
          ],
        ),
      ),
    );
  }
}
