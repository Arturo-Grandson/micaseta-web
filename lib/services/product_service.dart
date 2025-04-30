import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:micaseta_web/services/api_service.dart';
import '../models/product.dart';
import 'package:flutter/material.dart';

class ProductService {
  final ApiService _apiService = ApiService();

  static const String baseUrl = 'http://localhost:3000';

  Future<List<Product>> getProducts(int boothId) async {
    final response = await _apiService.get('/product/booth/$boothId');
    if (response is List) {
      return response.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los productos');
    }
  }

  Future<Product> getProductById(int id) async {
    final response = await _apiService.get('/products/$id');
    if (response is Map<String, dynamic>) {
      return Product.fromJson(response);
    } else {
      throw Exception('Error al cargar el producto');
    }
  }

  Future<bool> addProduct(Map<String, dynamic> productData) async {
    final response = await _apiService.post('/product', productData);
    return response != null;
  }

  Future<bool> editProduct(int id, String name, double price) async {
    final response = await _apiService.put(
      '/product/$id',
      {
        'name': name,
        'price': {'price': price},
      },
    );
    return response != null;
  }

  Future<bool> addPenalty(Map<String, dynamic> penaltyData) async {
    final response = await _apiService.post('/penalty', penaltyData);
    return response != null;
  }

  Future<List<dynamic>> getPenalties(int userId, int boothId) async {
    final response =
        await _apiService.get('/penalty/user/$userId/booth/$boothId');
    if (response is List) {
      return response;
    } else {
      throw Exception('Error al cargar las sanciones');
    }
  }

  Future<bool> deletePenalty(int penaltyId) async {
    final response = await _apiService.delete('/penalty/$penaltyId');
    return response != null;
  }

  Future<List<dynamic>> getConsumptions(int userId, int boothId) async {
    final response =
        await _apiService.get('/consumption/user/$userId/booth/$boothId');
    if (response is List) {
      return response;
    } else {
      throw Exception('Error al cargar las consumiciones');
    }
  }

  Future<bool> sendConsumptionsEmail(
      int userId, int boothId, String festiveType) async {
    final response = await _apiService.post('/consumption/send-email', {
      'userId': userId,
      'boothId': boothId,
      'festiveType': festiveType,
    });
    return response != null;
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('boothId');
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}

class MainLayout extends StatelessWidget {
  final Widget child;
  const MainLayout({required this.child, super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('boothId');
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Caseta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: child,
    );
  }
}
