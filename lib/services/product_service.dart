import 'package:micaseta_web/services/base_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class ProductService extends BaseApiService {
  Future<List<Product>> getProducts([int? boothId]) async {
    try {
      // Si no se proporciona boothId, obtenerlo de SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final selectedBoothId = boothId ?? prefs.getInt('boothId');

      if (selectedBoothId == null) {
        return []; // Retornar lista vacía si no hay caseta seleccionada
      }

      print('Obteniendo productos para la caseta: $selectedBoothId');
      final response = await httpClient.get('product/booth/$selectedBoothId');

      print('Estado de la respuesta: ${response.statusCode}');
      print('Respuesta: ${response.body}');

      // Parsear respuesta y manejar caso vacío
      final products =
          await parseResponseList(response, (json) => Product.fromJson(json));
      print('Productos parseados: ${products.length}');
      return products;
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

      print('Enviando producto con datos: $productData');
      final body = {
        'name': productData['name'],
        'type': productData['type'],
        'boothId': boothId,
      };

      // Añadir precio solo si se proporciona
      if (productData['price'] != null) {
        // Asegurarnos de que el precio es un número
        final price = double.parse(productData['price'].toString());
        body['price'] = {'price': price};
      }
      print('Body formateado: $body');

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
