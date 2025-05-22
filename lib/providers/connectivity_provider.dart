import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:micaseta_web/services/auth_http_client.dart';

/// Estado para el proveedor de conectividad
class ConnectivityState {
  final ConnectivityResult connectivityStatus;
  final int pendingOperationsCount;
  final bool isProcessingQueue;

  ConnectivityState({
    required this.connectivityStatus,
    required this.pendingOperationsCount,
    required this.isProcessingQueue,
  });

  bool get isConnected => connectivityStatus != ConnectivityResult.none;

  ConnectivityState copyWith({
    ConnectivityResult? connectivityStatus,
    int? pendingOperationsCount,
    bool? isProcessingQueue,
  }) {
    return ConnectivityState(
      connectivityStatus: connectivityStatus ?? this.connectivityStatus,
      pendingOperationsCount:
          pendingOperationsCount ?? this.pendingOperationsCount,
      isProcessingQueue: isProcessingQueue ?? this.isProcessingQueue,
    );
  }
}

/// Clase NotifierProvider para gestionar la conectividad y operaciones pendientes
class ConnectivityNotifier extends StateNotifier<ConnectivityState> {
  final Connectivity _connectivity = Connectivity();
  final AuthHttpClient _httpClient = AuthHttpClient();

  ConnectivityNotifier()
      : super(ConnectivityState(
          connectivityStatus: ConnectivityResult.none,
          pendingOperationsCount: 0,
          isProcessingQueue: false,
        )) {
    _init();
  }

  Future<void> _init() async {
    // Obtener estado inicial de conectividad
    final initialStatus = await _connectivity.checkConnectivity();
    final pendingCount = await _httpClient.getPendingOperationsCount();

    state = ConnectivityState(
      connectivityStatus: initialStatus,
      pendingOperationsCount: pendingCount,
      isProcessingQueue: false,
    );

    // Escuchar cambios de conectividad
    _connectivity.onConnectivityChanged.listen(_updateConnectivityStatus);
  }

  Future<void> _updateConnectivityStatus(ConnectivityResult result) async {
    final pendingCount = await _httpClient.getPendingOperationsCount();

    state = state.copyWith(
      connectivityStatus: result,
      pendingOperationsCount: pendingCount,
    );

    // Si se recuperó la conexión y hay operaciones pendientes, procesarlas
    if (result != ConnectivityResult.none &&
        pendingCount > 0 &&
        !state.isProcessingQueue) {
      await processOperationQueue();
    }
  }

  Future<void> processOperationQueue() async {
    if (state.isProcessingQueue || !state.isConnected) return;

    state = state.copyWith(isProcessingQueue: true);

    try {
      await _httpClient.processOperationQueue();
      final pendingCount = await _httpClient.getPendingOperationsCount();
      state = state.copyWith(
        pendingOperationsCount: pendingCount,
        isProcessingQueue: false,
      );
    } catch (e) {
      state = state.copyWith(isProcessingQueue: false);
    }
  }

  Future<void> refreshPendingCount() async {
    final pendingCount = await _httpClient.getPendingOperationsCount();
    state = state.copyWith(pendingOperationsCount: pendingCount);
  }
}

/// Proveedor para gestionar la conectividad
final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, ConnectivityState>((ref) {
  return ConnectivityNotifier();
});

/// Proveedor simple para verificar si hay conexión
final isConnectedProvider = Provider<bool>((ref) {
  final connectivityState = ref.watch(connectivityProvider);
  return connectivityState.isConnected;
});

/// Proveedor para contar operaciones pendientes
final pendingOperationsCountProvider = Provider<int>((ref) {
  final connectivityState = ref.watch(connectivityProvider);
  return connectivityState.pendingOperationsCount;
});
