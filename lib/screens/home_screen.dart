import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micaseta_web/screens/common_expense_screen.dart';
import 'package:micaseta_web/screens/partners_screen.dart';
import 'package:micaseta_web/screens/products_screen.dart';
import 'package:micaseta_web/utils/app_theme.dart';
import 'package:micaseta_web/widgets/app_widgets.dart';
import 'package:micaseta_web/widgets/theme_toggle_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Widget> _screens = [
    const PartnersScreen(),
    const ProductsScreen(),
    const CommonExpenseScreen(),
  ];

  final List<String> _titles = [
    'Socios',
    'Productos',
    'Gastos comunes',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppTheme.mediumDuration,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('boothId');
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  void _showLogoutDialog() {
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
            onPressed: () {
              Navigator.of(context).pop();
              _logout();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Header personalizado con degradado
            Container(
              padding: const EdgeInsets.fromLTRB(AppTheme.spacingL,
                  AppTheme.spacingXL, AppTheme.spacingL, AppTheme.spacingL),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppTheme.cardRadius),
                  bottomRight: Radius.circular(AppTheme.cardRadius),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mi Caseta',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Row(
                          children: [
                            const ThemeToggleWidget(
                              showText: false,
                              iconSize: 28,
                              lightModeColor: Colors.white,
                              darkModeColor: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.settings,
                                  color: Colors.white),
                              onPressed: () =>
                                  Navigator.of(context).pushNamed('/settings'),
                              tooltip: 'Configuración',
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon:
                                  const Icon(Icons.logout, color: Colors.white),
                              onPressed: () => _showLogoutDialog(),
                              tooltip: 'Cerrar sesión',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      _titles[_selectedIndex],
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // Contenido principal
            Expanded(
              child: _screens[_selectedIndex],
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'Socios',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag),
            label: 'Productos',
          ),
          NavigationDestination(
            icon: Icon(Icons.money),
            label: 'Gastos Comunes',
          ),
        ],
      ),
    );
  }
}
