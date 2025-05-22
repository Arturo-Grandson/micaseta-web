import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/app_theme.dart';

class ErrorHandler {
  // Analiza la respuesta HTTP y devuelve un mensaje de error amigable
  static String handleError(dynamic error) {
    if (error is http.Response) {
      try {
        final Map<String, dynamic> errorData = json.decode(error.body);
        final String message = errorData['message'] ?? 'Error desconocido';
        return message;
      } catch (e) {
        return 'Error de servidor: ${error.statusCode}';
      }
    } else if (error is SocketException) {
      return 'No se pudo conectar al servidor. Verifica tu conexión a internet.';
    } else if (error is FormatException) {
      return 'Formato de respuesta incorrecto. Contacta con soporte.';
    } else if (error is Exception) {
      return 'Error: ${error.toString()}';
    }
    return 'Error desconocido';
  }

  // Muestra un SnackBar con el mensaje de error
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
      ),
    );
  }

  // Muestra un SnackBar con mensaje de éxito
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
      ),
    );
  }

  // Muestra un diálogo de error
  static Future<void> showErrorDialog(
      BuildContext context, String title, String message) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}
