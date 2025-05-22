class Product {
  final int id;
  final String name;
  final String type;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null) throw Exception('El ID del producto es requerido');
    if (json['name'] == null)
      throw Exception('El nombre del producto es requerido');
    if (json['type'] == null)
      throw Exception('El tipo de producto es requerido');

    double parsePrice(dynamic price) {
      if (price == null) return 0.0;
      if (price is Map) {
        return double.tryParse(price['price']?.toString() ?? '0') ?? 0.0;
      }
      return double.tryParse(price.toString()) ?? 0.0;
    }

    return Product(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      price: parsePrice(json['price']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'price': {
        'price': price,
      },
    };
  }
}
