import 'package:micaseta_web/models/common_expense.dart';
import 'package:micaseta_web/services/api_service.dart';

class CommonExpensesService {
  final ApiService _apiService = ApiService();

  Future<bool> addCommonExpense(Map<String, dynamic> commonExpenseData) async {
    final response =
        await _apiService.post('/expenses/common-expense', commonExpenseData);
    return response != null;
  }

  Future<List<CommonExpense>> getCommonExpenses(int boothId, int year) async {
    final response =
        await _apiService.get('/expenses/common-expense/$boothId/$year');

    if (response is List) {
      return response.map((json) => CommonExpense.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los gastos comunes');
    }
  }
}
