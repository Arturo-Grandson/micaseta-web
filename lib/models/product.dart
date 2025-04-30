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
    return Product(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      price: double.tryParse(json['price']['price'].toString()) ?? 0.0,
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
