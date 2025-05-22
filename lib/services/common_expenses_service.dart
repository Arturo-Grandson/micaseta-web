import 'package:micaseta_web/models/common_expense.dart';
import 'package:micaseta_web/services/base_api_service.dart';

class CommonExpensesService extends BaseApiService {
  Future<bool> addCommonExpense(Map<String, dynamic> commonExpenseData) async {
    try {
      final response = await httpClient.post('expenses/common-expense',
          body: commonExpenseData);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Error al añadir el gasto común: $e');
    }
  }

  Future<List<CommonExpense>> getCommonExpenses(int boothId, int year) async {
    try {
      final response =
          await httpClient.get('expenses/common-expense/$boothId/$year');
      return parseResponseList(
          response, (json) => CommonExpense.fromJson(json));
    } catch (e) {
      throw Exception('Error al cargar los gastos comunes: $e');
    }
  }
}
