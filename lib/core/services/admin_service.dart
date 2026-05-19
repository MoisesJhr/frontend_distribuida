import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:clasificador_archivos/core/config/api_constants.dart';
import '../../../core/models/user_model.dart';

class AdminService {
  final _storage = const FlutterSecureStorage();

  final String baseUrl = "${ApiConstants.baseUrl}/admin/users";

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

  Future<Map<String, dynamic>> getAllUsers() async {
    final headers = await _getHeaders();

    if (headers == null) {
      return {'success': false, 'message': 'No autorizado'};
    }

    try {
      print("\n");
      print("========== GET ALL USERS ==========");
      print("REQUEST:");
      print("GET -> $baseUrl");
      print("HEADERS:");
      print(headers);

      final response = await http.get(Uri.parse(baseUrl), headers: headers);

      print("\nRESPONSE:");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY:");
      print(response.body);
      print("==================================");
      print("\n");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return {'success': true, 'data': UserModel.fromJsonList(data)};
      }

      return {
        'success': false,
        'message': 'Error al cargar usuarios. Status: ${response.statusCode}',
      };
    } catch (e) {
      print("\nERROR GET ALL USERS:");
      print(e);
      print("\n");

      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    final headers = await _getHeaders();

    if (headers == null) {
      return {'success': false, 'message': 'No autorizado'};
    }

    try {
      print("\n");
      print("========== Crear Usuario ==========");
      print("REQUEST:");
      print("POST -> $baseUrl");
      print("HEADERS:");
      print(headers);
      print("BODY:");
      print(jsonEncode(userData));

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode(userData),
      );

      print("\nRESPONSE:");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY:");
      print(response.body);
      print("================================");
      print("\n");

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'success': true,
          'message': data['mensaje'] ?? 'Usuario creado correctamente',
          'data': data,
        };
      }

      try {
        final errorBody = jsonDecode(response.body);

        return {
          'success': false,
          'message':
              errorBody['message'] ??
              errorBody['mensaje'] ??
              'Error al crear usuario',
        };
      } catch (e) {
        return {
          'success': false,
          'message': 'Error ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      print("\nERROR CREATE USER:");
      print(e);
      print("\n");

      return {'success': false, 'message': 'Excepción interna: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteUser(String userId) async {
    final headers = await _getHeaders();

    if (headers == null) {
      return {'success': false, 'message': 'No autorizado'};
    }

    try {
      print("\n");
      print("========== Borrar usuario ==========");
      print("REQUEST:");
      print("DELETE -> $baseUrl/$userId");
      print("HEADERS:");
      print(headers);

      final response = await http.delete(
        Uri.parse('$baseUrl/$userId'),
        headers: headers,
      );

      print("\nRESPONSE:");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY:");
      print(response.body);
      print("================================");
      print("\n");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'success': true,
          'message': data['mensaje'] ?? 'Usuario eliminado correctamente',
        };
      }

      final errorBody = jsonDecode(response.body);

      return {
        'success': false,
        'message':
            errorBody['message'] ??
            errorBody['mensaje'] ??
            'Error al eliminar usuario',
      };
    } catch (e) {
      print("\nERROR DELETE USER:");
      print(e);
      print("\n");

      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  Future<Map<String, dynamic>> updateUser(
    String userId,
    Map<String, dynamic> data,
  ) async {
    final headers = await _getHeaders();

    if (headers == null) {
      return {'success': false, 'message': 'No autorizado'};
    }

    try {
      print("\n");
      print("========== Actualizar informacion usuario ==========");
      print("REQUEST:");
      print("PATCH -> $baseUrl/$userId");
      print("HEADERS:");
      print(headers);
      print("BODY:");
      print(jsonEncode(data));

      final response = await http.patch(
        Uri.parse('$baseUrl/$userId'),
        headers: headers,
        body: jsonEncode(data),
      );

      print("\nRESPONSE:");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY:");
      print(response.body);
      print("================================");
      print("\n");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        return {
          'success': true,
          'message':
              responseData['mensaje'] ?? 'Usuario actualizado correctamente',
        };
      }

      final errorBody = jsonDecode(response.body);

      return {
        'success': false,
        'message':
            errorBody['message'] ??
            errorBody['mensaje'] ??
            'Error al actualizar usuario',
      };
    } catch (e) {
      print("\nERROR UPDATE USER:");
      print(e);
      print("\n");

      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  Future<Map<String, dynamic>> updateUserPassword(
    String userId,
    String nuevaPassword,
  ) async {
    final headers = await _getHeaders();

    if (headers == null) {
      return {'success': false, 'message': 'No autorizado'};
    }

    try {
      print("\n");
      print("====== Actualizar contraseña usuario ======");
      print("REQUEST:");
      print("PATCH -> $baseUrl/$userId/password");
      print("HEADERS:");
      print(headers);
      print("BODY:");
      print(jsonEncode({'nuevaPassword': nuevaPassword}));

      final response = await http.patch(
        Uri.parse('$baseUrl/$userId/password'),
        headers: headers,
        body: jsonEncode({'nuevaPassword': nuevaPassword}),
      );

      print("\nRESPONSE:");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY:");
      print(response.body);
      print("==================================");
      print("\n");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'success': true,
          'message': data['mensaje'] ?? 'Contraseña actualizada correctamente',
        };
      }

      final errorBody = jsonDecode(response.body);

      return {
        'success': false,
        'message':
            errorBody['message'] ??
            errorBody['mensaje'] ??
            'Error al actualizar contraseña',
      };
    } catch (e) {
      print("\nERROR UPDATE USER PASSWORD:");
      print(e);
      print("\n");

      return {'success': false, 'message': 'Error de conexión'};
    }
  }
}
