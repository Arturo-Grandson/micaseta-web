import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:micaseta_web/models/booth.dart';
import 'package:micaseta_web/services/auth_service.dart';
import 'package:micaseta_web/utils/app_theme.dart';
import 'package:micaseta_web/widgets/app_widgets.dart';

class BoothSelectionScreen extends StatefulWidget {
  final List<Map<String, dynamic>> booths;
  const BoothSelectionScreen({Key? key, required this.booths})
      : super(key: key);

  @override
  State<BoothSelectionScreen> createState() => _BoothSelectionScreenState();
}

class _BoothSelectionScreenState extends State<BoothSelectionScreen> {
  final _authService = AuthService();
  bool _isLoading = false;
  Booth? _selectedBooth;
  late List<Booth> _boothList;

  @override
  void initState() {
    super.initState();
    _boothList = widget.booths.map((json) => Booth.fromJson(json)).toList();
  }

  Future<void> _selectBooth() async {
    if (_selectedBooth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona una caseta'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('Seleccionando caseta: ${_selectedBooth!.id}');
      final result = await _authService.selectBooth(_selectedBooth!.id);

      if (!mounted) return;

      print('Resultado de selección de caseta: $result');

      // Si tenemos un boothId en la respuesta, consideramos que fue exitoso
      if (result.containsKey('boothId')) {
        // Mostrar mensaje de éxito si está presente
        if (result.containsKey('message')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        print(
            'Navegando a home después de seleccionar caseta ${_selectedBooth!.id}');
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (route) => false);
      } else {
        throw Exception(
            'La respuesta del servidor no contiene el ID de la caseta');
      }
    } catch (e) {
      print('Error al seleccionar caseta: $e');
      if (!mounted) return;

      String errorMessage = 'Error al seleccionar la caseta';
      if (e is Exception) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Selecciona tu Caseta',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: AppTheme.primaryColor,
                        fontSize: 32,
                        fontWeight: FontWeight.w300,
                      ),
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  'Por favor, selecciona la caseta a la que deseas acceder',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXL),
                ..._boothList.map((booth) => GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedBooth = booth;
                        });
                      },
                      child: Container(
                        margin:
                            const EdgeInsets.only(bottom: AppTheme.spacingM),
                        padding: const EdgeInsets.all(AppTheme.spacingM),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedBooth?.id == booth.id
                                ? AppTheme.primaryColor
                                : Colors.grey[300]!,
                            width: _selectedBooth?.id == booth.id ? 2 : 1,
                          ),
                          borderRadius:
                              BorderRadius.circular(AppTheme.borderRadius),
                          color: _selectedBooth?.id == booth.id
                              ? AppTheme.primaryColor.withOpacity(0.1)
                              : Colors.white,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.store_outlined,
                              color: _selectedBooth?.id == booth.id
                                  ? AppTheme.primaryColor
                                  : Colors.grey[600],
                            ),
                            const SizedBox(width: AppTheme.spacingS),
                            Text(
                              booth.name,
                              style: TextStyle(
                                fontSize: 16,
                                color: _selectedBooth?.id == booth.id
                                    ? AppTheme.primaryColor
                                    : Colors.black87,
                                fontWeight: _selectedBooth?.id == booth.id
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: AppTheme.spacingL),
                AppButton(
                  text: 'Continuar',
                  onPressed: (_isLoading || _selectedBooth == null)
                      ? null
                      : () {
                          _selectBooth();
                        },
                  isLoading: _isLoading,
                  width: double.infinity,
                  icon: Icons.arrow_forward,
                ),
                if (_selectedBooth != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppTheme.spacingM),
                    child: Text(
                      'Caseta seleccionada: ${_selectedBooth!.name}',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
