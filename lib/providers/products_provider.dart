import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micaseta_web/models/product.dart';
import 'package:micaseta_web/services/product_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductsState {
  final List<Product> products;
  final String selectedType;
  final String searchQuery;
  final List<Product> filteredProducts;

  ProductsState({
    required this.products,
    this.selectedType = 'all',
    this.searchQuery = '',
    List<Product>? filteredProducts,
  }) : filteredProducts = filteredProducts ?? products;

  ProductsState copyWith({
    List<Product>? products,
    String? selectedType,
    String? searchQuery,
  }) {
    final newProducts = products ?? this.products;
    final newSelectedType = selectedType ?? this.selectedType;
    final newSearchQuery = searchQuery ?? this.searchQuery;

    List<Product> newFilteredProducts = newProducts;
    if (newSelectedType != 'all') {
      newFilteredProducts = newFilteredProducts
          .where((product) => product.type == newSelectedType)
          .toList();
    }
    if (newSearchQuery.isNotEmpty) {
      newFilteredProducts = newFilteredProducts
          .where((product) =>
              product.name.toLowerCase().contains(newSearchQuery.toLowerCase()))
          .toList();
    }

    return ProductsState(
      products: newProducts,
      selectedType: newSelectedType,
      searchQuery: newSearchQuery,
      filteredProducts: newFilteredProducts,
    );
  }
}

class ProductsNotifier extends StateNotifier<AsyncValue<ProductsState>> {
  final ProductService _productService = ProductService();

  ProductsNotifier() : super(const AsyncValue.loading()) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      state = const AsyncValue.loading();
      final prefs = await SharedPreferences.getInstance();
      final boothId = prefs.getInt('boothId');

      if (boothId == null) {
        throw Exception('No hay boothId asociado al usuario');
      }

      final products = await _productService.getProducts(boothId);
      state = AsyncValue.data(ProductsState(products: products));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void setSelectedType(String type) {
    state.whenData((currentState) {
      state = AsyncValue.data(currentState.copyWith(selectedType: type));
    });
  }

  void setSearchQuery(String query) {
    state.whenData((currentState) {
      state = AsyncValue.data(currentState.copyWith(searchQuery: query));
    });
  }

  Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final boothId = prefs.getInt('boothId');

      if (boothId == null) {
        throw Exception('No hay boothId asociado al usuario');
      }

      final success = await _productService.addProduct({
        ...productData,
        'boothId': boothId,
      });

      if (success) {
        await loadProducts();
      } else {
        throw Exception('Error al añadir el producto');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editProduct(int productId, String name, double price) async {
    try {
      final success = await _productService.editProduct(productId, name, price);
      if (success) {
        await loadProducts();
      } else {
        throw Exception('Error al editar el producto');
      }
    } catch (e) {
      rethrow;
    }
  }
}

final productsProvider =
    StateNotifierProvider<ProductsNotifier, AsyncValue<ProductsState>>((ref) {
  return ProductsNotifier();
}); 