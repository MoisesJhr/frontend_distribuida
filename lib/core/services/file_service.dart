import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:clasificador_archivos/core/config/api_constants.dart';
import '../../../core/models/file_model.dart';

class FileService {
  final _storage = const FlutterSecureStorage();

  final String baseUrl = "${ApiConstants.baseUrl}/files";

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

  Future<Map<String, dynamic>> uploadFile(
    String filePath,
    String fileName,
  ) async {
    if (!fileName.toLowerCase().endsWith('.pdf')) {
      return {
        'success': false,
        'message': 'Formato inválido. Solo se admiten documentos PDF.',
      };
    }

    final token = await _getToken();

    if (token == null) {
      return {'success': false, 'message': 'No hay sesión activa'};
    }

    try {
      final url = '$baseUrl/upload';

      print("\n");
      print("=============== Cargar archivo ===============");
      print("REQUEST:");
      print("POST -> $url");
      print("FILE PATH:");
      print(filePath);
      print("FILE NAME:");
      print(fileName);

      final request = http.MultipartRequest('POST', Uri.parse(url));

      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      print("\nRESPONSE:");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY:");
      print(response.body);
      print("===========================================");
      print("\n");

      if (response.statusCode == 202 || response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'success': true,
          'message': data['mensaje'] ?? 'Archivo enviado correctamente',
          'data': FileModel.fromJson(data),
        };
      }

      if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);

        return {
          'success': false,
          'message':
              errorData['Error'] ?? errorData['message'] ?? 'Archivo rechazado',
        };
      }

      return {
        'success': false,
        'message': 'Error ${response.statusCode} al subir archivo',
      };
    } catch (e) {
      print("\nERROR UPLOAD FILE:");
      print(e);
      print("\n");

      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  Future<Map<String, dynamic>> getMyFiles() async {
    final headers = await _getHeaders();

    if (headers == null) {
      return {'success': false, 'message': 'No hay sesión activa'};
    }

    try {
      print("\n");
      print("=============== Obtener mis archivos ===============");
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
        final List<dynamic> data = jsonDecode(response.body);

        return {'success': true, 'data': FileModel.fromJsonList(data)};
      }

      final errorBody = jsonDecode(response.body);

      return {
        'success': false,
        'message': errorBody['message'] ?? 'No se pudieron cargar los archivos',
      };
    } catch (e) {
      print("\nERROR GET MY FILES:");
      print(e);
      print("\n");

      return {'success': false, 'message': 'Error de red'};
    }
  }

  Future<Map<String, dynamic>> deleteFile(String fileId) async {
    final headers = await _getHeaders();

    if (headers == null) {
      return {'success': false, 'message': 'No hay sesión activa'};
    }

    try {
      final url = '$baseUrl/$fileId';

      print("\n");
      print("=============== Eliminar archivos ===============");
      print("REQUEST:");
      print("DELETE -> $url");
      print("HEADERS:");
      print(headers);

      final response = await http.delete(Uri.parse(url), headers: headers);

      print("\nRESPONSE:");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY:");
      print(response.body);
      print("===========================================");
      print("\n");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'success': true,
          'message': data['mensaje'] ?? 'Archivo eliminado correctamente',
        };
      }

      final errorBody = jsonDecode(response.body);

      return {
        'success': false,
        'message': errorBody['message'] ?? 'Error al eliminar archivo',
      };
    } catch (e) {
      print("\nERROR DELETE FILE:");
      print(e);
      print("\n");

      return {'success': false, 'message': 'Error de red'};
    }
  }

  Future<String> checkStatus(String fileId) async {
    final headers = await _getHeaders();

    if (headers == null) return 'ERROR';

    try {
      final url = '$baseUrl/$fileId/status';

      print("\n");
      print("=============== Revisar estatus ===============");
      print("REQUEST:");
      print("GET -> $url");
      print("HEADERS:");
      print(headers);

      final response = await http.get(Uri.parse(url), headers: headers);

      print("\nRESPONSE:");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY:");
      print(response.body);
      print("============================================");
      print("\n");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data['estado'] ?? data['Estado'] ?? 'ERROR';
      }

      return 'ERROR';
    } catch (e) {
      print("\nERROR CHECK STATUS:");
      print(e);
      print("\n");

      return 'ERROR';
    }
  }

  Future<Map<String, dynamic>> getDownloadUrl(String fileId) async {
    final headers = await _getHeaders();

    if (headers == null) {
      return {'success': false, 'message': 'No hay sesión activa'};
    }

    try {
      final url = '$baseUrl/$fileId/download-url';

      print("\n");
      print("============= Obtener link de descarga =============");
      print("REQUEST:");
      print("GET -> $url");
      print("HEADERS:");
      print(headers);

      final response = await http.get(Uri.parse(url), headers: headers);

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
          'url': data['downloadUrl'] ?? data['DownloadUrl'] ?? data['url'],
        };
      }

      final errorBody = jsonDecode(response.body);

      return {
        'success': false,
        'message': errorBody['message'] ?? 'Error al obtener URL de descarga',
      };
    } catch (e) {
      print("\nERROR GET DOWNLOAD URL:");
      print(e);
      print("\n");

      return {'success': false, 'message': 'Error de red'};
    }
  }
}
