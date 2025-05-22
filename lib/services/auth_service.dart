import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // En desarrollo, asegúrate de usar la URL correcta
  static const String baseUrl = 'http://127.0.0.1:3000';
  static const String _tokenKey = 'token';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _userKey = 'user';
  static const String _boothIdKey = 'boothId';

  Future<Map<String, dynamic>> login(String email, String password) async {
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
        }),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception(
              'Tiempo de espera agotado al intentar conectar con el servidor');
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveSessionData(
          data['access_token'],
          data['refresh_token'],
          data['user'],
          data['user']['boothId'],
        );
        return {
          'token': data['access_token'],
          'refresh_token': data['refresh_token'],
          'user': data['user'],
          'boothId': data['user']['boothId'],
        };
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
            error['message'] ?? 'Error en el login: ${response.statusCode}');
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
