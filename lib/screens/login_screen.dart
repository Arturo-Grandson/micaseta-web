import 'package:flutter/material.dart';
import 'package:micaseta_web/services/auth_service.dart';
import 'package:micaseta_web/utils/app_theme.dart';
import 'package:micaseta_web/widgets/app_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      print('Intentando iniciar sesión...');
      await _authService.login(
        _emailController.text,
        _passwordController.text,
      );
      print('Inicio de sesión exitoso');

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      print('Error durante el inicio de sesión: $e');
      if (!mounted) return;

      String errorMessage = 'Error al intentar iniciar sesión';
      print('Error detallado: $e');

      if (e.toString().contains('Failed to fetch')) {
        errorMessage =
            'No se puede conectar con el servidor (http://127.0.0.1:3000). Verifica que el servidor esté en ejecución y accesible.';
      } else if (e.toString().contains('timeout')) {
        errorMessage =
            'Tiempo de espera agotado. El servidor está tardando demasiado en responder.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo y título
                    Image.asset(
                      'images/logo.png',
                      height: 120,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.storefront,
                        size: 80,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                    Text(
                      'Mi Caseta',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      'Gestiona tu caseta de feria',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacingXL),

                    // Campo de email
                    AppTextField(
                      label: 'Correo electrónico',
                      hint: 'Introduce tu correo electrónico',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, introduce tu correo electrónico';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Introduce un correo electrónico válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTheme.spacingM),

                    // Campo de contraseña
                    AppTextField(
                      label: 'Contraseña',
                      hint: 'Introduce tu contraseña',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, introduce tu contraseña';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTheme.spacingXL),

                    // Botón de login
                    AppButton(
                      text: 'Iniciar sesión',
                      onPressed: _login,
                      isLoading: _isLoading,
                      width: double.infinity,
                      icon: Icons.login,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
