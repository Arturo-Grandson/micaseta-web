import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class BoothService {
  static const String baseUrl = AuthService.baseUrl;

  Future<List<Map<String, dynamic>>> getUserBooths(
      String email, String password) async {
    try {
      // Primero obtener un token temporal
      final loginUri = Uri.parse('$baseUrl/auth/login');
      final loginResponse = await http
          .post(
        loginUri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception(
              'Tiempo de espera agotado al intentar conectar con el servidor');
        },
      );

      if (loginResponse.statusCode != 200 && loginResponse.statusCode != 201) {
        throw Exception('Error de autenticación');
      }

      final loginData = jsonDecode(loginResponse.body);
      final token = loginData['access_token'];

      // Ahora obtener las casetas con el token
      final boothsUri = Uri.parse('$baseUrl/users/me/booths');
      final boothsResponse = await http.get(
        boothsUri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception(
              'Tiempo de espera agotado al intentar conectar con el servidor');
        },
      );

      if (boothsResponse.statusCode == 200) {
        final List<dynamic> data = jsonDecode(boothsResponse.body);
        return data.map((booth) => booth as Map<String, dynamic>).toList();
      } else {
        throw Exception('Error al obtener las casetas del usuario');
      }
    } catch (e) {
      rethrow;
    }
  }
}
