import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:micaseta_web/services/auth_service.dart';
import 'package:micaseta_web/screens/booth_selection_screen.dart';
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

  Future<void> _showBoothSelectionDialog(BuildContext context) async {
    try {
      final authService = AuthService();
      final booths = await authService.getAvailableBooths();
      if (!context.mounted) return;

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BoothSelectionScreen(booths: booths),
        ),
      );

      // Si el usuario seleccionó una caseta exitosamente, recargamos la aplicación
      if (result == true && context.mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar las casetas: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Caseta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.store),
            tooltip: 'Cambiar caseta',
            onPressed: () => _showBoothSelectionDialog(context),
          ),
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
