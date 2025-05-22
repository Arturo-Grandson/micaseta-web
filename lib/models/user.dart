class User {
  final int id;
  final String name;
  final String lastname;
  final String email;
  final String? phone;
  final int? boothId;
  final bool isAdmin;
  final String? avatarUrl;

  User({
    required this.id,
    required this.name,
    required this.lastname,
    required this.email,
    this.phone,
    this.boothId,
    required this.isAdmin,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      lastname: json['lastname'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      boothId: json['boothId'],
      isAdmin: json['isAdmin'] ?? false,
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'boothId': boothId,
      'isAdmin': isAdmin,
      'avatarUrl': avatarUrl,
    };
  }
}
