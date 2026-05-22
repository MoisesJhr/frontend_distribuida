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

  void _printRequest({
    required String service,
    required String method,
    required String url,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) {
    print('================ REQUEST [$service] ================');
    print('HTTP METHOD: $method');
    print('URL: $url');

    if (headers != null) {
      print('HEADERS: ${jsonEncode(headers)}');
    }

    if (body != null) {
      print('BODY: ${jsonEncode(body)}');
    }

    print('====================================================');
  }

  void _printResponse({
    required String service,
    required int statusCode,
    required dynamic body,
  }) {
    print('================ RESPONSE [$service] ================');
    print('STATUS CODE: $statusCode');
    print('BODY: ${jsonEncode(body)}');
    print('=====================================================');
  }

  void _printError({required String service, required dynamic error}) {
    print('================ ERROR [$service] ===================');
    print(error.toString());
    print('=====================================================');
  }

  Future<Map<String, dynamic>> uploadFile(
    String filePath,
    String fileName,
  ) async {
    if (!fileName.toLowerCase().endsWith('.pdf')) {
      final errorResponse = {
        'success': false,
        'message': 'Formato inválido. Solo se admiten documentos PDF.',
      };

      _printResponse(
        service: 'uploadFile',
        statusCode: 400,
        body: errorResponse,
      );

      return errorResponse;
    }

    final token = await _getToken();

    if (token == null) {
      final errorResponse = {
        'success': false,
        'message': 'No hay sesión activa',
      };

      _printResponse(
        service: 'uploadFile',
        statusCode: 401,
        body: errorResponse,
      );

      return errorResponse;
    }

    try {
      final url = '$baseUrl/upload';

      _printRequest(
        service: 'uploadFile',
        method: 'POST',
        url: url,
        headers: {'Authorization': 'Bearer $token'},
        body: {'filePath': filePath, 'fileName': fileName},
      );

      final request = http.MultipartRequest('POST', Uri.parse(url));

      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      dynamic responseBody;

      try {
        responseBody = jsonDecode(response.body);
      } catch (_) {
        responseBody = response.body;
      }

      _printResponse(
        service: 'uploadFile',
        statusCode: response.statusCode,
        body: responseBody,
      );

      if (response.statusCode == 202 || response.statusCode == 200) {
        return {
          'success': true,
          'message': responseBody['mensaje'] ?? 'Archivo enviado correctamente',
          'data': FileModel.fromJson(responseBody),
        };
      }

      if (response.statusCode == 400) {
        return {
          'success': false,
          'message':
              responseBody['Error'] ??
              responseBody['message'] ??
              'Archivo rechazado',
        };
      }

      return {
        'success': false,
        'message': 'Error ${response.statusCode} al subir archivo',
      };
    } catch (e) {
      _printError(service: 'uploadFile', error: e);

      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  Future<Map<String, dynamic>> getMyFiles() async {
    final headers = await _getHeaders();

    if (headers == null) {
      final errorResponse = {
        'success': false,
        'message': 'No hay sesión activa',
      };

      _printResponse(
        service: 'getMyFiles',
        statusCode: 401,
        body: errorResponse,
      );

      return errorResponse;
    }

    try {
      _printRequest(
        service: 'getMyFiles',
        method: 'GET',
        url: baseUrl,
        headers: headers,
      );

      final response = await http.get(Uri.parse(baseUrl), headers: headers);

      dynamic responseBody;

      try {
        responseBody = jsonDecode(response.body);
      } catch (_) {
        responseBody = response.body;
      }

      _printResponse(
        service: 'getMyFiles',
        statusCode: response.statusCode,
        body: responseBody,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = responseBody;

        return {'success': true, 'data': FileModel.fromJsonList(data)};
      }

      return {
        'success': false,
        'message':
            responseBody['message'] ?? 'No se pudieron cargar los archivos',
      };
    } catch (e) {
      _printError(service: 'getMyFiles', error: e);

      return {'success': false, 'message': 'Error de red'};
    }
  }

  Future<Map<String, dynamic>> deleteFile(String fileId) async {
    final headers = await _getHeaders();

    if (headers == null) {
      final errorResponse = {
        'success': false,
        'message': 'No hay sesión activa',
      };

      _printResponse(
        service: 'deleteFile',
        statusCode: 401,
        body: errorResponse,
      );

      return errorResponse;
    }

    try {
      final url = '$baseUrl/$fileId';

      _printRequest(
        service: 'deleteFile',
        method: 'DELETE',
        url: url,
        headers: headers,
      );

      final response = await http.delete(Uri.parse(url), headers: headers);

      dynamic responseBody;

      try {
        responseBody = jsonDecode(response.body);
      } catch (_) {
        responseBody = response.body;
      }

      _printResponse(
        service: 'deleteFile',
        statusCode: response.statusCode,
        body: responseBody,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message':
              responseBody['mensaje'] ?? 'Archivo eliminado correctamente',
        };
      }

      return {
        'success': false,
        'message': responseBody['message'] ?? 'Error al eliminar archivo',
      };
    } catch (e) {
      _printError(service: 'deleteFile', error: e);

      return {'success': false, 'message': 'Error de red'};
    }
  }

  Future<String> checkStatus(String fileId) async {
    final headers = await _getHeaders();

    if (headers == null) {
      _printResponse(
        service: 'checkStatus',
        statusCode: 401,
        body: {'success': false, 'message': 'No hay sesión activa'},
      );

      return 'ERROR';
    }

    try {
      final url = '$baseUrl/$fileId/status';

      _printRequest(
        service: 'checkStatus',
        method: 'GET',
        url: url,
        headers: headers,
      );

      final response = await http.get(Uri.parse(url), headers: headers);

      dynamic responseBody;

      try {
        responseBody = jsonDecode(response.body);
      } catch (_) {
        responseBody = response.body;
      }

      _printResponse(
        service: 'checkStatus',
        statusCode: response.statusCode,
        body: responseBody,
      );

      if (response.statusCode == 200) {
        return responseBody['estado']?.toString() ??
            responseBody['Estado']?.toString() ??
            'ERROR';
      }

      return 'ERROR';
    } catch (e) {
      _printError(service: 'checkStatus', error: e);

      return 'ERROR';
    }
  }

  Future<Map<String, dynamic>> getDownloadUrl(String fileId) async {
    final headers = await _getHeaders();

    if (headers == null) {
      final errorResponse = {
        'success': false,
        'message': 'No hay sesión activa',
      };

      _printResponse(
        service: 'getDownloadUrl',
        statusCode: 401,
        body: errorResponse,
      );

      return errorResponse;
    }

    try {
      final url = '$baseUrl/$fileId/download-url';

      _printRequest(
        service: 'getDownloadUrl',
        method: 'GET',
        url: url,
        headers: headers,
      );

      final response = await http.get(Uri.parse(url), headers: headers);

      dynamic responseBody;

      try {
        responseBody = jsonDecode(response.body);
      } catch (_) {
        responseBody = response.body;
      }

      _printResponse(
        service: 'getDownloadUrl',
        statusCode: response.statusCode,
        body: responseBody,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'url':
              responseBody['downloadUrl'] ??
              responseBody['DownloadUrl'] ??
              responseBody['url'],
        };
      }

      return {
        'success': false,
        'message':
            responseBody['message'] ?? 'Error al obtener URL de descarga',
      };
    } catch (e) {
      _printError(service: 'getDownloadUrl', error: e);

      return {'success': false, 'message': 'Error de red'};
    }
  }
}
