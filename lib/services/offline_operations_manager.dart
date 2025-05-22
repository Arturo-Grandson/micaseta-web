import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:micaseta_web/services/auth_service.dart';

/// Clase para manejar operaciones pendientes cuando la aplicación está offline
class OfflineOperationsManager {
  static const String _pendingOperationsKey = 'pending_operations';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isProcessingQueue = false;

  // Instancia singleton
  static final OfflineOperationsManager _instance =
      OfflineOperationsManager._internal();
  factory OfflineOperationsManager() => _instance;
  OfflineOperationsManager._internal();

  // Inicializar el administrador y comenzar a escuchar cambios de conectividad
  Future<void> initialize() async {
    // Escuchar cambios de conectividad
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);

    // Verificar conexión al inicio
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      await processOperationQueue();
    }
  }

  // Manejar cambios en la conectividad
  Future<void> _handleConnectivityChange(ConnectivityResult result) async {
    if (result != ConnectivityResult.none) {
      // Se ha recuperado la conectividad
      await processOperationQueue();
    }
  }

  // Añadir una operación a la cola
  Future<void> addOperation({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> operations =
        prefs.getStringList(_pendingOperationsKey) ?? [];

    final operation = {
      'method': method,
      'endpoint': endpoint,
      'body': body,
      'timestamp': DateTime.now().toIso8601String(),
    };

    operations.add(jsonEncode(operation));
    await prefs.setStringList(_pendingOperationsKey, operations);
  }

  // Procesar la cola de operaciones pendientes
  Future<void> processOperationQueue() async {
    if (_isProcessingQueue) return;

    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) return;

    _isProcessingQueue = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> operations =
          prefs.getStringList(_pendingOperationsKey) ?? [];

      if (operations.isEmpty) {
        _isProcessingQueue = false;
        return;
      }

      final List<String> remainingOperations = [];

      for (final operationJson in operations) {
        final operation = jsonDecode(operationJson) as Map<String, dynamic>;

        try {
          await _executeOperation(
            method: operation['method'],
            endpoint: operation['endpoint'],
            body: operation['body'],
          );
        } catch (e) {
          // Si falla, mantener la operación en la cola
          remainingOperations.add(operationJson);
        }
      }

      // Actualizar la lista de operaciones pendientes
      await prefs.setStringList(_pendingOperationsKey, remainingOperations);
    } finally {
      _isProcessingQueue = false;
    }
  }

  // Ejecutar una operación HTTP específica
  Future<http.Response> _executeOperation({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
  }) async {
    final baseUrl = AuthService.baseUrl;
    final url = Uri.parse('$baseUrl/$endpoint');

    // Obtener token actual
    final authService = AuthService();
    final token = await authService.getToken();

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    switch (method.toUpperCase()) {
      case 'GET':
        return await http.get(url, headers: headers);
      case 'POST':
        return await http.post(
          url,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'PUT':
        return await http.put(
          url,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'DELETE':
        return await http.delete(url, headers: headers);
      default:
        throw Exception('Método HTTP no soportado: $method');
    }
  }

  // Verificar si hay operaciones pendientes
  Future<bool> hasPendingOperations() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> operations =
        prefs.getStringList(_pendingOperationsKey) ?? [];
    return operations.isNotEmpty;
  }

  // Obtener el número de operaciones pendientes
  Future<int> getPendingOperationsCount() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> operations =
        prefs.getStringList(_pendingOperationsKey) ?? [];
    return operations.length;
  }

  // Limpiar todas las operaciones pendientes
  Future<void> clearPendingOperations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingOperationsKey);
  }

  // Liberar recursos
  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
