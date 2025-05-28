import 'dart:convert';
import 'package:micaseta_web/services/base_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../utils/product_validator.dart';

class ProductService extends BaseApiService {
  Future<List<Product>> getProducts([int? boothId]) async {
    try {
      // Si no se proporciona boothId, obtenerlo de SharedPreferences
      if (boothId == null) {
        final prefs = await SharedPreferences.getInstance();
        boothId = prefs.getInt('boothId');

        if (boothId == null) {
          return []; // Retornar lista vacía si no hay caseta seleccionada
        }
      }

      print('Obteniendo productos para la caseta: $boothId');
      final String url = 'product/booth/$boothId';
      print('URL de la petición: ${httpClient.baseUrl}$url');

      final response = await httpClient.get(url);

      print('Estado de la respuesta: ${response.statusCode}');
      print('Cuerpo de la respuesta: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Error al cargar productos: ${response.body}');
      }

      print('Verificando productos para caseta $boothId');
      final List<dynamic> responseData = jsonDecode(response.body);

      // Usar el validador para verificar que todos los productos pertenecen a la caseta correcta
      for (var product in responseData) {
        if (!ProductValidator.validateBoothId(product, boothId)) {
          print(
              'Error: Producto ${product['name']} pertenece a la caseta ${product['booth']?['id']}, esperábamos $boothId');
          throw Exception('Error: Se detectaron productos de otra caseta');
        }
      }

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
      if (productData['price'] != null &&
          productData['price'].toString().isNotEmpty) {
        // Asegurarnos de que el precio es un número
        try {
          final price = double.parse(productData['price'].toString());
          body['price'] = {'price': price};
        } catch (e) {
          print('Error al parsear el precio: ${productData['price']}');
          // Si no se puede parsear el precio, no lo incluimos
        }
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
