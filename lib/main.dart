import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micaseta_web/providers/theme_provider.dart' as theme_provider;
import 'package:micaseta_web/screens/booth_selection_screen.dart';
import 'package:micaseta_web/screens/home_screen.dart';
import 'package:micaseta_web/screens/login_screen.dart';
import 'package:micaseta_web/screens/settings_screen.dart';
import 'package:micaseta_web/services/auth_service.dart';
import 'package:micaseta_web/services/auth_http_client.dart';
import 'package:micaseta_web/utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configura la orientación preferida
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configura el estilo de la barra de estado
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Inicializa soporte offline
  final httpClient = AuthHttpClient();
  await httpClient.initializeOfflineSupport();

  final authService = AuthService();
  final isLoggedIn = await authService.isLoggedIn();
  final hasBoothSelected = isLoggedIn && await authService.getBoothId() != null;

  runApp(
    ProviderScope(
      child: MyApp(initialRoute: hasBoothSelected ? '/home' : '/login'),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final themeMode = ref.watch(theme_provider.themeProvider);

        // Determinar el ThemeMode basado en el enum personalizado
        ThemeMode actualThemeMode;
        switch (themeMode) {
          case theme_provider.ThemeMode.light:
            actualThemeMode = ThemeMode.light;
            break;
          case theme_provider.ThemeMode.dark:
            actualThemeMode = ThemeMode.dark;
            break;
          case theme_provider.ThemeMode.system:
            actualThemeMode = ThemeMode.system;
            break;
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Mi Caseta',
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: actualThemeMode,
          initialRoute: initialRoute,
          onGenerateRoute: (settings) {
            if (settings.name == '/booth-selection') {
              final args = settings.arguments as Map<String, dynamic>?;
              final dynamicList = args?['booths'] as List<dynamic>? ?? [];
              final booths = dynamicList
                  .map((item) => Map<String, dynamic>.from(item))
                  .toList();
              return MaterialPageRoute(
                builder: (context) => BoothSelectionScreen(booths: booths),
              );
            }
            return null;
          },
          routes: {
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
            '/settings': (context) => const SettingsScreen(),
          },
        );
      },
    );
  }
}
