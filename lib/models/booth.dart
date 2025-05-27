class Booth {
  final int id;
  final String name;

  Booth({required this.id, required this.name});

  factory Booth.fromJson(Map<String, dynamic> json) {
    return Booth(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
