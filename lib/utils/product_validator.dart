class ProductValidator {
  static bool validateBoothId(
      Map<String, dynamic> product, int expectedBoothId) {
    // Verificar que el producto tenga la estructura correcta
    if (!(product['booth'] is Map<String, dynamic>)) {
      print(
          'Error: Producto ${product['name']} no tiene información de caseta');
      return false;
    }

    final productBoothId = product['booth']['id'];
    if (productBoothId == null) {
      print('Error: Producto ${product['name']} no tiene ID de caseta');
      return false;
    }

    if (productBoothId != expectedBoothId) {
      print(
          'Error: Producto ${product['name']} pertenece a la caseta $productBoothId, esperábamos $expectedBoothId');
      return false;
    }

    return true;
  }
}
