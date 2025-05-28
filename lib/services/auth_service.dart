import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:micaseta_web/exceptions/auth_exceptions.dart';

class AuthService {
  // En desarrollo, asegúrate de usar la URL correcta
  static const String baseUrl = 'http://127.0.0.1:3000';
  static const String _tokenKey = 'token';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _userKey = 'user';
  static const String _boothIdKey = 'boothId';

  Future<Map<String, dynamic>> login(String email, String password,
      {int? boothId}) async {
    try {
      print('Iniciando solicitud de login a: $baseUrl/auth/login');
      final client = http.Client();
      final uri = Uri.parse('$baseUrl/auth/login');
      print('URI construida: $uri');

      final response = await client
          .post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          if (boothId != null) 'boothId': boothId,
        }),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception(
              'Tiempo de espera agotado al intentar conectar con el servidor');
        },
      );

      final responseData = jsonDecode(response.body);

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 401) {
        final errorData = jsonDecode(response.body);
        print('Error data completa: $errorData');

        // Verificar si hay casetas en la respuesta
        if (errorData is Map<String, dynamic>) {
          throw UnauthorizedException(
            message: errorData['message'] ??
                'Por favor, selecciona una caseta para continuar',
            booths: (errorData['booths'] as List<dynamic>?)
                    ?.map((b) => b as Map<String, dynamic>)
                    .toList() ??
                [],
          );
        }
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Usamos el boothId que el usuario seleccionó, no el que viene por defecto
        final selectedBoothId = boothId ?? responseData['user']['boothId'];

        await _saveSessionData(
          responseData['access_token'],
          responseData['refresh_token'],
          responseData['user'],
          selectedBoothId,
        );
        return {
          'token': responseData['access_token'],
          'refresh_token': responseData['refresh_token'],
          'user': responseData['user'],
          'boothId': selectedBoothId,
        };
      } else {
        throw Exception(responseData['message'] ??
            'Error en el login: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        throw e;
      }
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  Future<void> _saveSessionData(String token, String refreshToken,
      Map<String, dynamic> user, dynamic boothId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_userKey, jsonEncode(user));
    if (boothId != null) {
      await prefs.setInt(_boothIdKey, boothId);
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey) != null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_boothIdKey);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return jsonDecode(userJson);
    }
    return null;
  }

  Future<int?> getBoothId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_boothIdKey);
  }

  Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'refreshToken': refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, data['access_token']);
        return true;
      } else {
        // Si el refresh token ha expirado o es inválido, cerrar sesión
        await logout();
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
