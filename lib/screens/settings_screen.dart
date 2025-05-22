import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micaseta_web/providers/connectivity_provider.dart';
import 'package:micaseta_web/utils/app_theme.dart';
import 'package:micaseta_web/widgets/app_card.dart';
import 'package:micaseta_web/widgets/connectivity_status_widget.dart';
import 'package:micaseta_web/widgets/theme_settings_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityState = ref.watch(connectivityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de Apariencia
            Text(
              'Apariencia',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppTheme.spacingM),

            // Agregar el nuevo widget de configuración de tema
            const ThemeSettingsCard(),

            const SizedBox(height: AppTheme.spacingL),

            // Sección de Conectividad
            Text(
              'Conectividad',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppTheme.spacingM),
            AppCard(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(AppTheme.spacingM),
                    child: ConnectivityStatusWidget(showPendingCount: true),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.cloud_sync,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text('Operaciones pendientes'),
                    subtitle: Text(
                      connectivityState.pendingOperationsCount == 0
                          ? 'No hay operaciones pendientes'
                          : '${connectivityState.pendingOperationsCount} operaciones pendientes',
                    ),
                    trailing: connectivityState.pendingOperationsCount > 0
                        ? ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(connectivityProvider.notifier)
                                  .processOperationQueue();
                            },
                            child: const Text('Sincronizar'),
                          )
                        : null,
                  ),
                  ListTile(
                    leading: Icon(
                      connectivityState.isConnected
                          ? Icons.wifi
                          : Icons.wifi_off,
                      color: connectivityState.isConnected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.error,
                    ),
                    title: Text('Estado de conexión'),
                    subtitle: Text(
                      connectivityState.isConnected
                          ? 'Conectado'
                          : 'Sin conexión',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingL),

            // Sección de Cuenta
            Text(
              'Cuenta',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppTheme.spacingM),
            AppCard(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Información del usuario'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navegar a la pantalla de perfil
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.logout,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: const Text('Cerrar sesión'),
                    onTap: () => _showLogoutDialog(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingL),

            // Sección de Información
            Text(
              'Información',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppTheme.spacingM),
            AppCard(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.info,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Acerca de'),
                    subtitle: const Text('Versión 1.0.0'),
                    onTap: () {
                      // Mostrar información de la app
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');
              await prefs.remove('refreshToken');
              await prefs.remove('user');
              await prefs.remove('boothId');

              if (!context.mounted) return;
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
