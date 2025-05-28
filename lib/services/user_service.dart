import 'package:micaseta_web/services/base_api_service.dart';
import 'package:micaseta_web/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService extends BaseApiService {
  Future<List<User>> getUsers() async {
    try {
      // Obtener el boothId actual
      final prefs = await SharedPreferences.getInstance();
      final boothId = prefs.getInt('boothId');

      if (boothId == null) {
        throw Exception('No hay una caseta seleccionada');
      }

      print('Obteniendo usuarios para la caseta: $boothId');
      final response = await httpClient.get('users/booth/$boothId');
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
