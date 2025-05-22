import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:micaseta_web/widgets/connectivity_status_widget.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final bool showConnectivity;

  const MainLayout(
      {required this.child, this.showConnectivity = true, super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('refreshToken');
    await prefs.remove('user');
    await prefs.remove('boothId');
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Caseta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configuración',
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Column(
        children: [
          if (showConnectivity) const ConnectivityStatusWidget(),
          Expanded(child: child),
        ],
      ),
    );
  }
}
