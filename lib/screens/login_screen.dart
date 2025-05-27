import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:micaseta_web/services/auth_service.dart';
import 'package:micaseta_web/models/booth.dart';
import 'package:micaseta_web/utils/app_theme.dart';
import 'package:micaseta_web/widgets/app_widgets.dart';
import 'package:micaseta_web/exceptions/auth_exceptions.dart';

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
  List<Booth> _booths = [];
  Booth? _selectedBooth;

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
      // Intentar login con o sin boothId
      await _authService.login(
        _emailController.text,
        _passwordController.text,
        boothId: _selectedBooth?.id,
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } on UnauthorizedException catch (e) {
      if (!mounted) return;

      print('Booths recibidos: ${e.booths}');
      setState(() {
        _isLoading = false;
        if (e.booths != null && e.booths!.isNotEmpty) {
          try {
            _booths = e.booths!.map((b) => Booth.fromJson(b)).toList();
            print('Booths convertidos: $_booths');
            print('Número de casetas: ${_booths.length}');
          } catch (error) {
            print('Error al convertir casetas: $error');
            print('Datos de casetas recibidos: ${e.booths}');
          }
        } else {
          print('No hay casetas disponibles o la lista está vacía');
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor:
              e.booths != null ? AppTheme.primaryColor : AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
        ),
      );
      return;
    } catch (e) {
      if (!mounted) return;

      String errorMessage;
      print('Error detallado: $e');

      if (e.toString().contains('Failed to fetch')) {
        errorMessage =
            'No se puede conectar con el servidor. Verifica que el servidor esté en ejecución y accesible.';
      } else if (e.toString().contains('timeout')) {
        errorMessage =
            'Tiempo de espera agotado. El servidor está tardando demasiado en responder.';
      } else {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      setState(() => _isLoading = false);

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
                    // Título
                    Text(
                      'Mi Caseta',
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: AppTheme.primaryColor,
                                fontSize: 48,
                                fontWeight: FontWeight.w300,
                              ),
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      'Gestiona tu caseta de feria',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacingL),

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
                    const SizedBox(height: AppTheme.spacingL),

                    // Selector de caseta
                    if (_booths.isNotEmpty) ...[
                      Text(
                        'Selecciona una caseta',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<Booth>(
                          hint: const Text('Selecciona una caseta'),
                          value: _selectedBooth,
                          onChanged: (Booth? booth) {
                            setState(() {
                              _selectedBooth = booth;
                            });
                          },
                          items: _booths.map((booth) {
                            return DropdownMenuItem(
                              value: booth,
                              child: Row(
                                children: [
                                  const Icon(Icons.store_outlined),
                                  const SizedBox(width: 8),
                                  Text(booth.name),
                                ],
                              ),
                            );
                          }).toList(),
                          isExpanded: true,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.arrow_drop_down),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXL),
                    ],

                    // Botón de login
                    AppButton(
                      text: _booths.isEmpty
                          ? 'Continuar'
                          : _selectedBooth == null
                              ? 'Selecciona una caseta'
                              : 'Iniciar sesión',
                      onPressed: _login,
                      isLoading: _isLoading,
                      width: double.infinity,
                      icon: _booths.isEmpty
                          ? Icons.arrow_forward
                          : _selectedBooth == null
                              ? Icons.store
                              : Icons.login,
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
