import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:clasificador_archivos/core/config/api_constants.dart';
import '../../../core/models/theme_model.dart';

class ThemeService {
  final _storage = const FlutterSecureStorage();

  final String baseUrl = "${ApiConstants.baseUrl}/files/themes";

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

  Future<Map<String, dynamic>> getGlobalThemes() async {
    final headers = await _getHeaders();

    if (headers == null) {
      return {'success': false, 'message': 'No autorizado'};
    }

    try {
      print("\n");
      print("============ Obtener tematicas globales ============");
      print("REQUEST:");
      print("GET -> $baseUrl");
      print("HEADERS:");
      print(headers);

      final response = await http.get(Uri.parse(baseUrl), headers: headers);

      print("\nRESPONSE:");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY:");
      print(response.body);
      print("===========================================");
      print("\n");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return {'success': true, 'data': ThemeModel.fromJsonList(data)};
      }

      final errorBody = jsonDecode(response.body);

      return {
        'success': false,
        'message':
            errorBody['message'] ??
            errorBody['mensaje'] ??
            'Error al cargar catálogo',
      };
    } catch (e) {
      print("\nERROR GET GLOBAL THEMES:");
      print(e);
      print("\n");

      return {'success': false, 'message': 'Error de red'};
    }
  }

  Future<Map<String, dynamic>> getMyThemes() async {
    final headers = await _getHeaders();

    if (headers == null) {
      return {'success': false, 'message': 'No autorizado'};
    }

    try {
      final url = '$baseUrl/me';

      print("\n");
      print("============== Obtener mis tematicas ==============");
      print("REQUEST:");
      print("GET -> $url");
      print("HEADERS:");
      print(headers);

      final response = await http.get(Uri.parse(url), headers: headers);

      print("\nRESPONSE:");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY:");
      print(response.body);
      print("===========================================");
      print("\n");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return {'success': true, 'data': ThemeModel.fromJsonList(data)};
      }

      try {
        final errorBody = jsonDecode(response.body);

        return {
          'success': false,
          'message':
              errorBody['message'] ??
              errorBody['mensaje'] ??
              'Error al cargar tus temáticas',
        };
      } catch (_) {
        return {
          'success': false,
          'message': 'Error ${response.statusCode}. Body: ${response.body}',
        };
      }
    } catch (e) {
      print("\nERROR GET MY THEMES:");
      print(e);
      print("\n");

      return {'success': false, 'message': 'Error de red'};
    }
  }

  Future<Map<String, dynamic>> saveMyThemes(List<String> themeIds) async {
    final headers = await _getHeaders();

    if (headers == null) {
      return {'success': false, 'message': 'No autorizado'};
    }

    try {
      final url = '$baseUrl/me';

      final requestBody = {"tematicasIds": themeIds};

      print("\n");
      print("============ Guardar mis tematicas ==============");
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
      print("===========================================");
      print("\n");

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'success': true,
          'message': data['mensaje'] ?? 'Temáticas guardadas correctamente',
        };
      }

      final errorBody = jsonDecode(response.body);

      if (response.statusCode == 409) {
        return {
          'success': false,
          'message':
              errorBody['message'] ??
              errorBody['mensaje'] ??
              'Ya existen temáticas registradas',
        };
      }

      return {
        'success': false,
        'message':
            errorBody['message'] ??
            errorBody['mensaje'] ??
            'Error al guardar temáticas',
      };
    } catch (e) {
      print("\nERROR SAVE MY THEMES:");
      print(e);
      print("\n");

      return {'success': false, 'message': 'Error de red'};
    }
  }
}
