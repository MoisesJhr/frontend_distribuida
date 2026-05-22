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

  // --- SISTEMA DE LOGS ---
  void _printRequest(
    String service,
    String method,
    String url, [
    Map<String, String>? headers,
  ]) {
    print('================ REQUEST [$service] ================');
    print('HTTP METHOD: $method');
    print('URL: $url');
    print('====================================================');
  }

  void _printResponse(String service, int statusCode, dynamic body) {
    print('================ RESPONSE [$service] ================');
    print('STATUS CODE: $statusCode');
    print('BODY: ${jsonEncode(body)}');
    print('=====================================================');
  }

  // ==========================================================================
  // OBTENER CATÁLOGO GLOBAL (GET)
  // ==========================================================================
  Future<Map<String, dynamic>> getGlobalThemes() async {
    final headers = await _getHeaders();
    if (headers == null) return {'success': false, 'message': 'No autorizado'};

    try {
      _printRequest('getGlobalThemes', 'GET', baseUrl);
      final response = await http.get(Uri.parse(baseUrl), headers: headers);

      dynamic decodedBody;
      try {
        decodedBody = jsonDecode(response.body);
      } catch (_) {
        decodedBody = response.body;
      }

      _printResponse('getGlobalThemes', response.statusCode, decodedBody);

      if (response.statusCode == 200) {
        return {'success': true, 'data': decodedBody};
      }
      return {
        'success': false,
        'message': decodedBody['message'] ?? 'Error al cargar catálogo',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de red'};
    }
  }

  // ==========================================================================
  // OBTENER MIS TEMÁTICAS (GET) - Para el Dashboard
  // ==========================================================================
  Future<Map<String, dynamic>> getMyThemes() async {
    final headers = await _getHeaders();
    if (headers == null) return {'success': false, 'message': 'No autorizado'};

    try {
      final url = '$baseUrl/me';
      _printRequest('getMyThemes', 'GET', url);

      final response = await http.get(Uri.parse(url), headers: headers);

      dynamic decodedBody;
      try {
        decodedBody = jsonDecode(response.body);
      } catch (_) {
        decodedBody = response.body;
      }

      _printResponse('getMyThemes', response.statusCode, decodedBody);

      if (response.statusCode == 200) {
        List<dynamic> subcategoriasPlanas = [];

        // Extraemos de la estructura de MongoDB: [ { "areasInteres": [ { "subcategorias": [...] } ] } ]
        if (decodedBody is List && decodedBody.isNotEmpty) {
          final documentoPreferencia = decodedBody[0];

          final List<dynamic> areas =
              documentoPreferencia['areasInteres'] ??
              documentoPreferencia['AreasInteres'] ??
              [];

          for (var area in areas) {
            // 1. Rescatamos el nombre del área principal (Ej: "Matemáticas")
            final String nombreDelArea =
                area['nombreArea'] ?? area['NombreArea'] ?? '';
            final subs = area['subcategorias'] ?? area['Subcategorias'] ?? [];

            // 2. Le inyectamos el área a cada subcategoría antes de aplanarla
            for (var sub in subs) {
              final subMap = Map<String, dynamic>.from(sub);
              subMap['nombreArea'] = nombreDelArea;
              subcategoriasPlanas.add(subMap);
            }
          }
        }

        return {
          'success': true,
          'data': ThemeModel.fromJsonList(subcategoriasPlanas),
        };
      }

      return {
        'success': false,
        'message': decodedBody['message'] ?? 'Error al cargar tus temáticas',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de red'};
    }
  }

  Future<Map<String, dynamic>> saveMyThemes(
    List<Map<String, dynamic>> payload,
  ) async {
    final headers = await _getHeaders();
    if (headers == null) return {'success': false, 'message': 'No autorizado'};

    try {
      final url = '$baseUrl/me';
      _printRequest('saveMyThemes', 'POST', url);

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(payload),
      );

      dynamic decodedBody;
      try {
        decodedBody = jsonDecode(response.body);
      } catch (_) {
        decodedBody = response.body;
      }

      _printResponse('saveMyThemes', response.statusCode, decodedBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Temáticas guardadas'};
      }
      return {'success': false, 'message': 'Error al guardar temáticas'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión'};
    }
  }
}
