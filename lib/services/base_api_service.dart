import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:micaseta_web/services/auth_http_client.dart';

// Clase abstracta base para los servicios de API
abstract class BaseApiService {
  final AuthHttpClient httpClient = AuthHttpClient();

  // Método para parsear la respuesta JSON
  T parseResponse<T>(
      http.Response response, T Function(Map<String, dynamic>) fromJson) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return fromJson(jsonDecode(response.body));
    } else {
      // Manejar diferentes códigos de error
      switch (response.statusCode) {
        case 400:
          throw Exception(
              'Solicitud inválida: ${jsonDecode(response.body)['message']}');
        case 401:
          throw Exception('No autorizado: Por favor inicie sesión de nuevo');
        case 403:
          throw Exception(
              'Prohibido: No tiene permiso para acceder a este recurso');
        case 404:
          throw Exception('Recurso no encontrado');
        case 429:
          throw Exception(
              'Demasiadas solicitudes: Por favor intente más tarde');
        case 500:
        case 502:
        case 503:
        case 504:
          throw Exception('Error del servidor: Por favor intente más tarde');
        default:
          throw Exception('Error inesperado: ${response.statusCode}');
      }
    }
  }

  // Método para parsear la respuesta JSON a una lista
  List<T> parseResponseList<T>(
      http.Response response, T Function(Map<String, dynamic>) fromJson) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> responseData = jsonDecode(response.body);
      return responseData.map((data) => fromJson(data)).toList();
    } else {
      // Usar el mismo manejo de errores que el método anterior
      switch (response.statusCode) {
        case 400:
          throw Exception(
              'Solicitud inválida: ${jsonDecode(response.body)['message']}');
        case 401:
          throw Exception('No autorizado: Por favor inicie sesión de nuevo');
        case 403:
          throw Exception(
              'Prohibido: No tiene permiso para acceder a este recurso');
        case 404:
          throw Exception('Recurso no encontrado');
        case 429:
          throw Exception(
              'Demasiadas solicitudes: Por favor intente más tarde');
        case 500:
        case 502:
        case 503:
        case 504:
          throw Exception('Error del servidor: Por favor intente más tarde');
        default:
          throw Exception('Error inesperado: ${response.statusCode}');
      }
    }
  }
}
