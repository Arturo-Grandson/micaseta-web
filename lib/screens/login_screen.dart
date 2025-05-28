import 'package:flutter/material.dart';
import 'package:micaseta_web/services/auth_service.dart';
import 'package:micaseta_web/utils/app_theme.dart';
import 'package:micaseta_web/exceptions/auth_exceptions.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = AuthService();
      final response = await authService.login(
          _emailController.text, _passwordController.text);

      if (!mounted) return;

      if (response.containsKey('booths') &&
          response['booths'] is List<dynamic>) {
        final List<dynamic> boothsList = response['booths'] as List<dynamic>;
        final List<Map<String, dynamic>> typedBooths =
            boothsList.map((item) => Map<String, dynamic>.from(item)).toList();

        // Si hay casetas disponibles, navegamos a la pantalla de selección
        Navigator.of(context).pushReplacementNamed(
          '/booth-selection',
          arguments: {'booths': typedBooths},
        );
      } else {
        // Si no hay casetas, vamos directamente a home
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (e is UnauthorizedException && (e.booths?.isNotEmpty ?? false)) {
        if (!mounted) return;
        // Si el error es por selección de caseta, navegamos a la pantalla de selección
        final List<Map<String, dynamic>> typedBooths =
            e.booths!.map((item) => Map<String, dynamic>.from(item)).toList();
        Navigator.of(context).pushReplacementNamed(
          '/booth-selection',
          arguments: {'booths': typedBooths},
        );
      } else {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const FlutterLogo(size: 100),
                const SizedBox(height: AppTheme.spacingXL),
                Text(
                  'Bienvenido a Mi Caseta',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  'Inicia sesión para continuar',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingXL),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu email';
                    }
                    if (!value.contains('@')) {
                      return 'Por favor ingresa un email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacingM),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu contraseña';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacingL),
                if (_error != null) ...[
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                ],
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Iniciar sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
