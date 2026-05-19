import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:clasificador_archivos/core/config/api_constants.dart';
import '../../../core/models/user_model.dart';

class UserService {
  final _storage = const FlutterSecureStorage();

  final String baseUrl = "${ApiConstants.baseUrl}/users/me";

  Future<String?> _getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<Map<String, String>?> _getHeaders() async {
    final token = await _getToken();

    if (token == null) return null;

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final headers = await _getHeaders();

    if (headers == null) {
      return {'success': false, 'message': 'No autorizado'};
    }

    try {
      print("\n");
      print("============= Obtener perfil de usuario =============");
      print("REQUEST:");
      print("GET -> $baseUrl");
      print("HEADERS:");
      print(headers);

      final response = await http.get(Uri.parse(baseUrl), headers: headers);

      print("\nRESPONSE:");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY:");
      print(response.body);
      print("============================================");
      print("\n");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {'success': true, 'data': UserModel.fromJson(data)};
      }

      final errorBody = jsonDecode(response.body);

      return {
        'success': false,
        'message':
            errorBody['message'] ??
            errorBody['mensaje'] ??
            'Error al cargar tu perfil',
      };
    } catch (e) {
      print("\nERROR GET USER PROFILE:");
      print(e);
      print("\n");

      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final headers = await _getHeaders();

    if (headers == null) {
      return {'success': false, 'message': 'No autorizado'};
    }

    try {
      print("\n");
      print("=============== Actualizar perfil =============");
      print("REQUEST:");
      print("PATCH -> $baseUrl");
      print("HEADERS:");
      print(headers);
      print("BODY:");
      print(jsonEncode(data));

      final response = await http.patch(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode(data),
      );

      print("\nRESPONSE:");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY:");
      print(response.body);
      print("============================================");
      print("\n");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['usuarioActualizado'] != null &&
            responseData['usuarioActualizado']['nombre'] != null) {
          await _storage.write(
            key: 'user_name',
            value: responseData['usuarioActualizado']['nombre'],
          );
        }

        return {
          'success': true,
          'message':
              responseData['mensaje'] ?? 'Perfil actualizado correctamente',
        };
      }

      final errorBody = jsonDecode(response.body);

      return {
        'success': false,
        'message':
            errorBody['message'] ??
            errorBody['mensaje'] ??
            'Error al actualizar perfil',
      };
    } catch (e) {
      print("\nERROR UPDATE PROFILE:");
      print(e);
      print("\n");

      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  Future<Map<String, dynamic>> updatePassword(
    String passwordActual,
    String nuevaPassword,
  ) async {
    final headers = await _getHeaders();

    if (headers == null) {
      return {'success': false, 'message': 'No autorizado'};
    }

    try {
      final url = '$baseUrl/password';

      final requestBody = {
        'passwordActual': passwordActual,
        'nuevaPassword': nuevaPassword,
      };

      print("\n");
      print("============== Actualizar contraseña =============");
      print("REQUEST:");
      print("PATCH -> $url");
      print("HEADERS:");
      print(headers);
      print("BODY:");
      print(jsonEncode(requestBody));

      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print("\nRESPONSE:");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY:");
      print(response.body);
      print("============================================");
      print("\n");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'success': true,
          'message': data['mensaje'] ?? 'Contraseña actualizada correctamente',
        };
      }

      final errorBody = jsonDecode(response.body);

      if (response.statusCode == 400 || response.statusCode == 403) {
        return {
          'success': false,
          'message':
              errorBody['error'] ??
              errorBody['message'] ??
              'Error al actualizar contraseña',
        };
      }

      return {
        'success': false,
        'message':
            errorBody['message'] ??
            errorBody['mensaje'] ??
            'Error al actualizar contraseña',
      };
    } catch (e) {
      print("\nERROR UPDATE PASSWORD:");
      print(e);
      print("\n");

      return {'success': false, 'message': 'Error de conexión'};
    }
  }
}
