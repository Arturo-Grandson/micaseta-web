import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:micaseta_web/providers/connectivity_provider.dart';

class ConnectivityStatusWidget extends ConsumerWidget {
  final bool showPendingCount;

  const ConnectivityStatusWidget({
    Key? key,
    this.showPendingCount = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityState = ref.watch(connectivityProvider);

    // Si está conectado y no hay operaciones pendientes, no mostrar nada
    if (connectivityState.isConnected &&
        connectivityState.pendingOperationsCount == 0) {
      return const SizedBox.shrink();
    }

    // Determinar el color y mensaje según el estado
    Color color;
    String message;
    IconData icon;

    if (!connectivityState.isConnected) {
      color = Colors.red.shade700;
      message = 'Sin conexión';
      icon = Icons.cloud_off;
    } else if (connectivityState.isProcessingQueue) {
      color = Colors.orange;
      message = 'Sincronizando...';
      icon = Icons.sync;
    } else if (connectivityState.pendingOperationsCount > 0) {
      color = Colors.amber.shade700;
      message = 'Pendiente de sincronizar';
      icon = Icons.warning;
    } else {
      // No debería llegar aquí según la condición inicial
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          if (showPendingCount &&
              connectivityState.pendingOperationsCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${connectivityState.pendingOperationsCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          if (connectivityState.isConnected &&
              connectivityState.pendingOperationsCount > 0) ...[
            const Spacer(),
            GestureDetector(
              onTap: () {
                ref.read(connectivityProvider.notifier).processOperationQueue();
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.sync,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
