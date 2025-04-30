import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micaseta_web/models/penalty.dart';
import 'package:micaseta_web/services/product_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final penaltiesProvider =
    AsyncNotifierProvider<PenaltiesNotifier, List<Penalty>>(() {
  return PenaltiesNotifier();
});

class PenaltiesNotifier extends AsyncNotifier<List<Penalty>> {
  @override
  Future<List<Penalty>> build() async {
    return [];
  }

  Future<void> loadPenalties(int userId) async {
    state = const AsyncValue.loading();
    try {
      final prefs = await SharedPreferences.getInstance();
      final boothId = prefs.getInt('boothId');
      if (boothId == null) throw Exception('No hay boothId asociado');

      final penalties = await ProductService().getPenalties(userId, boothId);
      state = AsyncValue.data(
        penalties.map((p) {
          // Log para depuración
          print('Procesando sanción: $p');
          return Penalty(
            id: p['id'] is String ? int.parse(p['id']) : p['id'] as int,
            festiveType: p['festiveType'] as String,
            year: p['year'] is String ? int.parse(p['year']) : p['year'] as int,
            amount: p['amount'] is String
                ? double.parse(p['amount'])
                : p['amount'] is int
                    ? (p['amount'] as int).toDouble()
                    : p['amount'] as double,
            reason: p['reason'] ?? '',
            date: p['date'] as String,
            userId: userId,
            boothId: boothId,
          );
        }).toList(),
      );
    } catch (e, st) {
      print('Error cargando sanciones: $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addPenalty(Map<String, dynamic> penaltyData) async {
    try {
      final success = await ProductService().addPenalty(penaltyData);
      if (success) {
        // Recargar las sanciones después de añadir una nueva
        loadPenalties(penaltyData['userId'] as int);
      } else {
        throw Exception('Error al añadir la sanción');
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deletePenalty(int penaltyId, int userId) async {
    try {
      final success = await ProductService().deletePenalty(penaltyId);
      if (success) {
        // Recargar las sanciones después de eliminar una
        loadPenalties(userId);
      } else {
        throw Exception('Error al eliminar la sanción');
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
