import 'package:micaseta_web/services/base_api_service.dart';
import 'package:micaseta_web/models/user.dart';

class UserService extends BaseApiService {
  Future<List<User>> getUsers() async {
    try {
      final response = await httpClient.get('users');
      return parseResponseList(response, (json) => User.fromJson(json));
    } catch (e) {
      throw Exception('Error al obtener usuarios: $e');
    }
  }

  Future<User> getUserById(int id) async {
    try {
      final response = await httpClient.get('users/$id');
      return parseResponse(response, (json) => User.fromJson(json));
    } catch (e) {
      throw Exception('Error al obtener usuario: $e');
    }
  }
}
