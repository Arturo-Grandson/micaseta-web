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

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/login');
      final response = await http
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

      final responseData = jsonDecode(response.body);

      // Guardar los tokens si están disponibles, independientemente del código de estado
      if (responseData['access_token'] != null &&
          responseData['refresh_token'] != null) {
        print('Guardando tokens de la respuesta del login');
        await _saveSessionData(
          responseData['access_token'],
          responseData['refresh_token'],
          responseData['user'] ?? {},
          null, // No guardamos boothId en el login
        );

        // Verificar que se guardaron correctamente
        final prefs = await SharedPreferences.getInstance();
        final savedToken = prefs.getString(_tokenKey);
        final savedRefreshToken = prefs.getString(_refreshTokenKey);
        if (savedToken == null || savedRefreshToken == null) {
          throw Exception('Error al guardar los tokens de autenticación');
        }
      }

      if (response.statusCode == 401) {
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('booths') &&
            responseData['booths'] is List) {
          // Si la respuesta 401 contiene una lista de casetas, es el flujo esperado
          throw UnauthorizedException(
            message: responseData['message'] ??
                'Por favor, selecciona una caseta para continuar',
            booths: List<Map<String, dynamic>>.from(responseData['booths']),
          );
        } else {
          // Si no hay casetas, son credenciales inválidas
          throw UnauthorizedException(
            message: 'Credenciales inválidas',
            booths: [],
          );
        }
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'token': responseData['access_token'],
          'refresh_token': responseData['refresh_token'],
          'user': responseData['user'],
          'booths': responseData['booths'] ?? [],
        };
      } else {
        throw Exception(responseData['message'] ??
            'Error en el login: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en login: $e');
      if (e is UnauthorizedException) {
        throw e;
      }
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  Future<Map<String, dynamic>> selectBooth(int boothId) async {
    try {
      if (boothId <= 0) {
        throw Exception('ID de caseta inválido');
      }

      final token = await getToken(forceRefresh: true);
      if (token == null) {
        throw UnauthorizedException(
          message: 'No hay sesión activa',
          booths: [],
        );
      }

      final uri = Uri.parse('$baseUrl/users/booth/select');
      final response = await http
          .post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'boothId': boothId,
        }),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception(
              'Tiempo de espera agotado al intentar conectar con el servidor');
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Verificar que el token y el boothId están presentes en la respuesta
        final newToken = responseData['access_token'] ?? token;
        if (newToken == null || newToken.isEmpty) {
          throw Exception('Token inválido en la respuesta del servidor');
        }

        // Guardar la nueva sesión con el token actualizado
        await _saveSessionData(
          newToken,
          await getRefreshToken() ?? '',
          await getUser() ?? {},
          boothId,
        );

        // Verificar que se guardó correctamente
        final prefs = await SharedPreferences.getInstance();
        final savedBoothId = prefs.getInt(_boothIdKey);
        if (savedBoothId != boothId) {
          throw Exception('Error al guardar la caseta seleccionada');
        }

        print('Caseta $boothId seleccionada exitosamente');
        return {'boothId': boothId};
      } else if (response.statusCode == 401) {
        // Intentar refrescar el token una vez más
        final newToken = await getToken(forceRefresh: true);
        if (newToken == null) {
          throw UnauthorizedException(
            message: 'Sesión expirada',
            booths: [],
          );
        }

        // Reintentar con el nuevo token
        final retryResponse = await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $newToken',
          },
          body: jsonEncode({
            'boothId': boothId,
          }),
        );

        if (retryResponse.statusCode == 200) {
          final responseData = jsonDecode(retryResponse.body);
          final finalToken = responseData['access_token'] ?? newToken;

          await _saveSessionData(
            finalToken,
            await getRefreshToken() ?? '',
            await getUser() ?? {},
            boothId,
          );

          // Verificar que se guardó correctamente
          final prefs = await SharedPreferences.getInstance();
          final savedBoothId = prefs.getInt(_boothIdKey);
          if (savedBoothId != boothId) {
            throw Exception('Error al guardar la caseta seleccionada');
          }

          print(
              'Caseta $boothId seleccionada exitosamente después de refrescar token');
          return {'boothId': boothId};
        }

        throw UnauthorizedException(
          message: 'Error de autenticación',
          booths: [],
        );
      } else {
        final responseData = jsonDecode(response.body);
        String errorMessage =
            responseData['message'] ?? 'Error al seleccionar la caseta';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error en selectBooth: $e');
      if (e is UnauthorizedException) {
        throw e;
      }
      throw Exception('Error al seleccionar la caseta: $e');
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

  Future<String?> getToken({bool forceRefresh = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(_tokenKey);

      if (token == null && !forceRefresh) {
        print('No hay token almacenado');
        return null;
      }

      if (forceRefresh) {
        print('Intentando refrescar token...');
        final refreshSuccess = await refreshAccessToken();
        if (refreshSuccess) {
          token = prefs.getString(_tokenKey);
          print('Token refrescado exitosamente');
        } else {
          print('No se pudo refrescar el token');
          return null;
        }
      }

      return token;
    } catch (e) {
      print('Error en getToken: $e');
      return null;
    }
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
      if (refreshToken == null || refreshToken.isEmpty) {
        print('No hay refresh token disponible');
        return false;
      }

      print('Intentando refrescar token con refresh token existente');
      final response = await http
          .post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode({
          'refreshToken': refreshToken,
        }),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception(
              'Tiempo de espera agotado al intentar refrescar el token');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Validar que los tokens están presentes
        if (data['access_token'] == null || data['access_token'].isEmpty) {
          print('Error: El servidor no devolvió un token válido');
          return false;
        }

        // Mantener el refresh token anterior si no se proporciona uno nuevo
        final newRefreshToken = data['refresh_token'] ?? refreshToken;

        // Guardar los nuevos tokens
        await _saveSessionData(
          data['access_token'],
          newRefreshToken,
          await getUser() ?? {},
          await getBoothId(),
        );

        print('Token refrescado y guardado exitosamente');
        return true;
      } else {
        final responseData = jsonDecode(response.body);
        print(
            'Error al refrescar token: ${responseData['message'] ?? 'Error desconocido'}');
        return false;
      }
    } catch (e) {
      print('Error en refreshAccessToken: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAvailableBooths() async {
    try {
      final token = await getToken(forceRefresh: true);
      if (token == null) {
        throw UnauthorizedException(
          message: 'No hay sesión activa',
          booths: [],
        );
      }

      final response = await http.get(
        Uri.parse('$baseUrl/users/me/booths'),
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

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((booth) => booth as Map<String, dynamic>).toList();
      } else if (response.statusCode == 401) {
        // Intentar refrescar el token una vez más
        final newToken = await getToken(forceRefresh: true);
        if (newToken == null) {
          throw UnauthorizedException(
            message: 'Sesión expirada',
            booths: [],
          );
        }

        // Reintentar con el nuevo token
        final retryResponse = await http.get(
          Uri.parse('$baseUrl/users/me/booths'),
          headers: {
            'Authorization': 'Bearer $newToken',
            'Accept': 'application/json',
          },
        );

        if (retryResponse.statusCode == 200) {
          final List<dynamic> data = jsonDecode(retryResponse.body);
          return data.map((booth) => booth as Map<String, dynamic>).toList();
        }

        throw UnauthorizedException(
          message: 'Error de autenticación',
          booths: [],
        );
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['message'] ??
            'Error al obtener las casetas del usuario');
      }
    } catch (e) {
      print('Error en getAvailableBooths: $e');
      if (e is UnauthorizedException) {
        throw e;
      }
      throw Exception('Error al conectar con el servidor: $e');
    }
  }
}
