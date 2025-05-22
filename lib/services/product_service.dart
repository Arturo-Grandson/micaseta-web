import 'package:micaseta_web/services/base_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class ProductService extends BaseApiService {
  Future<List<Product>> getProducts(int boothId) async {
    try {
      final response = await httpClient.get('product/booth/$boothId');
      return parseResponseList(response, (json) => Product.fromJson(json));
    } catch (e) {
      throw Exception('Error al cargar los productos: $e');
    }
  }

  Future<Product> getProductById(int id) async {
    try {
      final response = await httpClient.get('products/$id');
      return parseResponse(response, (json) => Product.fromJson(json));
    } catch (e) {
      throw Exception('Error al cargar el producto: $e');
    }
  }

  Future<bool> addProduct(Map<String, dynamic> productData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final boothId = prefs.getInt('boothId');
      if (boothId == null) throw Exception('No hay boothId asociado');

      final body = {
        ...productData,
        'boothId': boothId,
        'price': {
          'price': productData['price'],
          'year': DateTime.now().year,
        },
      };

      final response = await httpClient.post('product', body: body);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Error al añadir el producto: $e');
    }
  }

  Future<bool> editProduct(int id, String name, double price) async {
    try {
      final response = await httpClient.put(
        'product/$id',
        body: {
          'name': name,
          'price': {
            'price': price,
            'year': DateTime.now().year,
          },
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error al editar el producto: $e');
    }
  }

  Future<bool> addPenalty(Map<String, dynamic> penaltyData) async {
    try {
      final response = await httpClient.post('penalty', body: penaltyData);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Error al añadir la sanción: $e');
    }
  }

  Future<List<dynamic>> getPenalties(int userId, int boothId) async {
    try {
      final response =
          await httpClient.get('penalty/user/$userId/booth/$boothId');
      return parseResponseList(response, (json) => json);
    } catch (e) {
      throw Exception('Error al cargar las sanciones: $e');
    }
  }

  Future<bool> deletePenalty(int penaltyId) async {
    try {
      final response = await httpClient.delete('penalty/$penaltyId');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Error al eliminar la sanción: $e');
    }
  }

  Future<List<dynamic>> getConsumptions(int userId, int boothId) async {
    try {
      final response =
          await httpClient.get('consumption/user/$userId/booth/$boothId');
      return parseResponseList(response, (json) => json);
    } catch (e) {
      throw Exception('Error al cargar las consumiciones: $e');
    }
  }

  Future<bool> sendConsumptionsEmail(
      int userId, int boothId, String festiveType) async {
    try {
      final response = await httpClient.post('consumption/send-email', body: {
        'userId': userId,
        'boothId': boothId,
        'festiveType': festiveType,
      });
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error al enviar el email de consumiciones: $e');
    }
  }
}
