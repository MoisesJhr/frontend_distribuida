import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:clasificador_archivos/core/config/api_constants.dart';
import '../../../core/models/theme_model.dart';

class AdminThemeService {
  final _storage = const FlutterSecureStorage();

  final String baseUrl = "${ApiConstants.baseUrl}/files/admin";

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

  Future<Map<String, dynamic>> getGlobalCatalog() async {
    final headers = await _getHeaders();

    if (headers == null) {
      return {'success': false, 'message': 'No autorizado'};
    }

    try {
      final url = '${ApiConstants.baseUrl}/files/themes';

      print("\n");
      print("========== Obtener todas las tematicas generales ==========");
      print("REQUEST:");
      print("GET -> $url");
      print("HEADERS:");
      print(headers);

      final response = await http.get(Uri.parse(url), headers: headers);

      print("\nRESPONSE:");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY:");
      print(response.body);
      print("=======================================");
      print("\n");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return {'success': true, 'data': ThemeModel.fromJsonList(data)};
      }

      final errorBody = jsonDecode(response.body);

      return {
        'success': false,
        'message': errorBody['message'] ?? 'Error al cargar el catálogo global',
      };
    } catch (e) {
      print("\nERROR GET GLOBAL THEMES:");
      print(e);
      print("\n");

      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  Future<Map<String, dynamic>> getUserThemes(String userId) async {
    final headers = await _getHeaders();

    if (headers == null) {
      return {'success': false, 'message': 'No autorizado'};
    }

    try {
      final url = '$baseUrl/users/$userId/themes';

      print("\n");
      print("========== Obtener tematicas de usuario ==========");
      print("REQUEST:");
      print("GET -> $url");
      print("HEADERS:");
      print(headers);

      final response = await http.get(Uri.parse(url), headers: headers);

      print("\nRESPONSE:");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY:");
      print(response.body);
      print("=====================================");
      print("\n");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return {'success': true, 'data': ThemeModel.fromJsonList(data)};
      }

      final errorBody = jsonDecode(response.body);

      return {
        'success': false,
        'message':
            errorBody['message'] ?? 'Error al cargar las temáticas del usuario',
      };
    } catch (e) {
      print("\nERROR GET USER THEMES:");
      print(e);
      print("\n");

      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  Future<Map<String, dynamic>> assignThemeToUser(
    String userId,
    String themeId,
  ) async {
    final headers = await _getHeaders();

    if (headers == null) {
      return {'success': false, 'message': 'No autorizado'};
    }

    try {
      final url = '$baseUrl/users/$userId/themes';

      final requestBody = {
        'tematicasIds': [themeId],
      };

      print("\n");
      print("========== Asignar una tematica ==========");
      print("REQUEST:");
      print("POST -> $url");
      print("HEADERS:");
      print(headers);
      print("BODY:");
      print(jsonEncode(requestBody));

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print("\nRESPONSE:");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY:");
      print(response.body);
      print("==================================");
      print("\n");

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'success': true,
          'message': data['mensaje'] ?? 'Temática asignada correctamente',
        };
      }

      final errorBody = jsonDecode(response.body);

      return {
        'success': false,
        'message': errorBody['message'] ?? 'Error al asignar la temática',
      };
    } catch (e) {
      print("\nERROR ASSIGN THEME:");
      print(e);
      print("\n");

      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  Future<Map<String, dynamic>> forceDeleteUserTheme(
    String userId,
    String themeId,
  ) async {
    final headers = await _getHeaders();

    if (headers == null) {
      return {'success': false, 'message': 'No autorizado'};
    }

    try {
      final url = '$baseUrl/users/$userId/themes/$themeId';

      print("\n");
      print("========== Eliminar tematica de usuario ==========");
      print("REQUEST:");
      print("DELETE -> $url");
      print("HEADERS:");
      print(headers);

      final response = await http.delete(Uri.parse(url), headers: headers);

      print("\nRESPONSE:");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY:");
      print(response.body);
      print("=======================================");
      print("\n");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'success': true,
          'message': data['mensaje'] ?? 'Temática eliminada correctamente',
        };
      }

      final errorBody = jsonDecode(response.body);

      return {
        'success': false,
        'message': errorBody['message'] ?? 'Error al eliminar la temática',
      };
    } catch (e) {
      print("\nERROR DELETE USER THEME:");
      print(e);
      print("\n");

      return {'success': false, 'message': 'Error de conexión'};
    }
  }
}
