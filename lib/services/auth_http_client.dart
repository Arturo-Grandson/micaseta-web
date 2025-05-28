import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:micaseta_web/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:micaseta_web/services/offline_operations_manager.dart';
import 'dart:async';

class AuthHttpClient {
  final AuthService _authService = AuthService();
  final String baseUrl = AuthService.baseUrl;
  final OfflineOperationsManager _offlineManager = OfflineOperationsManager();
  final Connectivity _connectivity = Connectivity();

  // Método genérico para realizar solicitudes HTTP con reintento automático
  Future<http.Response> _request({
    required String method,
    required String path,
    Map<String, String>? headers,
    Object? body,
    bool retry = true,
    bool enableOfflineQueue = true,
  }) async {
    // Verificar conectividad
    final connectivityResult = await _connectivity.checkConnectivity();
    final bool isOffline = connectivityResult == ConnectivityResult.none;

    // Si está offline y la cola está habilitada, poner en cola para ejecutar más tarde
    if (isOffline && enableOfflineQueue && method.toUpperCase() != 'GET') {
      await _offlineManager.addOperation(
        method: method,
        endpoint: path,
        body: body != null ? jsonDecode(jsonEncode(body)) : null,
      );

      // Devolver una respuesta simulada para operaciones offline
      return http.Response(
          '{"message":"Operación puesta en cola para ejecutar cuando se restablezca la conexión"}',
          202);
    }

    // Obtener el token actual, forzando refresh si necesario
    final token = await _authService.getToken(
        forceRefresh: method.toUpperCase() != 'GET');

    // Preparar headers con autenticación si el token existe
    final requestHeaders = {
      'Content-Type': 'application/json',
      ...?headers,
    };

    if (token != null) {
      requestHeaders['Authorization'] = 'Bearer $token';
    }

    // Crear la URL completa
    final url = Uri.parse('$baseUrl/$path');

    // Realizar la solicitud según el método
    http.Response response;
    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: requestHeaders);
          break;
        case 'POST':
          response = await http.post(url,
              headers: requestHeaders,
              body: body != null ? jsonEncode(body) : null);
          break;
        case 'PUT':
          response = await http.put(url,
              headers: requestHeaders,
              body: body != null ? jsonEncode(body) : null);
          break;
        case 'DELETE':
          response = await http.delete(url, headers: requestHeaders);
          break;
        default:
          throw Exception('Método HTTP no soportado: $method');
      }
    } catch (e) {
      // Si hay un error de conexión y la cola está habilitada, poner en cola para ejecutar más tarde
      if (enableOfflineQueue && method.toUpperCase() != 'GET') {
        await _offlineManager.addOperation(
          method: method,
          endpoint: path,
          body: body != null ? jsonDecode(jsonEncode(body)) : null,
        );
        return http.Response(
            '{"message":"Error de conexión. Operación puesta en cola."}', 503);
      }
      rethrow;
    }

    // Verificar si la respuesta indica que el token expiró (401)
    if (response.statusCode == 401 && retry) {
      // Intentar refrescar el token
      final refreshSuccess = await _authService.refreshAccessToken();

      if (refreshSuccess) {
        // Si se refrescó correctamente, reintenta la solicitud original
        return _request(
          method: method,
          path: path,
          headers: headers,
          body: body,
          retry: false, // Evita ciclos infinitos
          enableOfflineQueue: enableOfflineQueue,
        );
      }
    }

    // Verificar si hay nuevo token en la respuesta
    final newToken = response.headers['x-new-token'];
    if (newToken != null && newToken.isNotEmpty) {
      // Guardar el nuevo token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', newToken);
    }

    return response;
  }

  // Métodos específicos para cada tipo de solicitud HTTP
  Future<http.Response> get(String path, {Map<String, String>? headers}) {
    return _request(method: 'GET', path: path, headers: headers);
  }

  Future<http.Response> post(String path,
      {Map<String, String>? headers,
      Object? body,
      bool enableOfflineQueue = true}) {
    return _request(
      method: 'POST',
      path: path,
      headers: headers,
      body: body,
      enableOfflineQueue: enableOfflineQueue,
    );
  }

  Future<http.Response> put(String path,
      {Map<String, String>? headers,
      Object? body,
      bool enableOfflineQueue = true}) {
    return _request(
      method: 'PUT',
      path: path,
      headers: headers,
      body: body,
      enableOfflineQueue: enableOfflineQueue,
    );
  }

  Future<http.Response> delete(String path,
      {Map<String, String>? headers, bool enableOfflineQueue = true}) {
    return _request(
      method: 'DELETE',
      path: path,
      headers: headers,
      enableOfflineQueue: enableOfflineQueue,
    );
  }

  // Inicializar el gestor de operaciones offline
  Future<void> initializeOfflineSupport() async {
    await _offlineManager.initialize();
  }

  // Verificar si hay operaciones pendientes
  Future<bool> hasPendingOperations() {
    return _offlineManager.hasPendingOperations();
  }

  // Obtener el número de operaciones pendientes
  Future<int> getPendingOperationsCount() {
    return _offlineManager.getPendingOperationsCount();
  }

  // Procesar manualmente la cola de operaciones pendientes
  Future<void> processOperationQueue() {
    return _offlineManager.processOperationQueue();
  }
}
