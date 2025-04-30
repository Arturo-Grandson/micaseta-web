class CommonExpense {
  final int id;
  final String festiveType;
  final int year;
  final String description;
  final double totalAmount;
  final String date;

  CommonExpense({
    required this.id,
    required this.festiveType,
    required this.year,
    required this.description,
    required this.totalAmount,
    required this.date,
  });

  factory CommonExpense.fromJson(Map<String, dynamic> json) {
    return CommonExpense(
      id: json['id'],
      festiveType: json['festiveType'],
      year: json['year'],
      description: json['description'],
      totalAmount: double.tryParse(json['totalAmount'].toString()) ?? 0.0,
      date: DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'festiveType': festiveType,
      'year': year,
      'description': description,
      'totalAmount': totalAmount,
      'date': date,
    };
  }
}
