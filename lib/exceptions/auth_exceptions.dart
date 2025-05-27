class UnauthorizedException implements Exception {
  final String message;
  final List<Map<String, dynamic>>? booths;

  UnauthorizedException({
    required this.message,
    this.booths,
  });

  @override
  String toString() {
    if (booths != null) {
      return message;
    }
    return 'UnauthorizedException: $message';
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      if (booths != null) 'booths': booths,
    };
  }
}
