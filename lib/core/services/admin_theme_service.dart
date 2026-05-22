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
    if (headers == null) return {'success': false, 'message': 'No autorizado'};

    try {
      final url = '${ApiConstants.baseUrl}/files/themes';
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        // 1. Decodificamos como Map, no como List
        final Map<String, dynamic> body = jsonDecode(response.body);

        // 2. Extraemos la lista desde la llave "areas"
        final List<dynamic> areas = body['areas'] ?? [];

        // 3. Aplanamos igual que en los otros servicios
        List<dynamic> subcategoriasPlanas = [];
        for (var area in areas) {
          final String nombreDelArea = area['nombreArea'] ?? '';
          final subs = area['subcategorias'] ?? [];
          for (var sub in subs) {
            final subMap = Map<String, dynamic>.from(sub);
            subMap['nombreArea'] = nombreDelArea;
            subcategoriasPlanas.add(subMap);
          }
        }

        return {
          'success': true,
          'data': ThemeModel.fromJsonList(subcategoriasPlanas),
        };
      }

      return {'success': false, 'message': 'Error al cargar catálogo'};
    } catch (e) {
      print("ERROR GET GLOBAL THEMES: $e");
      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  Future<Map<String, dynamic>> getUserThemes(String userId) async {
    final headers = await _getHeaders();
    if (headers == null) return {'success': false, 'message': 'No autorizado'};

    try {
      final url = '$baseUrl/users/$userId/themes';
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> decodedBody = jsonDecode(response.body);
        List<dynamic> subcategoriasPlanas = [];

        // Aplanamiento: Extraemos solo las subcategorías del documento de MongoDB
        for (var doc in decodedBody) {
          final List<dynamic> areas =
              doc['areasInteres'] ?? doc['AreasInteres'] ?? [];
          for (var area in areas) {
            final String nombreDelArea =
                area['nombreArea'] ?? area['NombreArea'] ?? '';
            final subs = area['subcategorias'] ?? area['Subcategorias'] ?? [];

            for (var sub in subs) {
              final subMap = Map<String, dynamic>.from(sub);
              subMap['nombreArea'] =
                  nombreDelArea; // Inyectamos el nombre del área
              subcategoriasPlanas.add(subMap);
            }
          }
        }

        // Ahora ThemeModel.fromJsonList recibirá la lista plana que sí sabe procesar
        return {
          'success': true,
          'data': ThemeModel.fromJsonList(subcategoriasPlanas),
        };
      }

      return {
        'success': false,
        'message':
            'Error ${response.statusCode}: No se pudieron obtener temáticas.',
      };
    } catch (e) {
      print("ERROR: $e");
      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  Future<Map<String, dynamic>> assignThemeToUser(
    String userId,
    String themeId,
  ) async {
    final headers = await _getHeaders();
    if (headers == null) return {'success': false, 'message': 'No autorizado'};

    try {
      final url = '$baseUrl/users/$userId/themes';

      // ENVIAMOS LA LISTA DIRECTA (sin llaves adicionales)
      // Ajusta las llaves 'areaId', 'nombreArea', etc., según lo que tenga tu clase AreaInteres en C#
      final List<dynamic> requestBody = [
        {
          "areaId":
              "cs", // Debes asegurarte de enviar el areaId correcto del catálogo
          "nombreArea": "Ciencias de la Computación",
          "subcategorias": [
            {
              "id": themeId,
              "nombre":
                  "Nombre de la subcategoría", // Verifica si el backend valida este campo
            },
          ],
        },
      ];

      print("BODY ENVIADO: ${jsonEncode(requestBody)}");

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody), // Pasamos la lista directa
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'message': 'Temática asignada correctamente'};
      }

      return {
        'success': false,
        'message': 'Error ${response.statusCode}: ${response.body}',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
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
