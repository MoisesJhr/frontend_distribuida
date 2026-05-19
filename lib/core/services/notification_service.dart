import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:clasificador_archivos/core/config/api_constants.dart';
import '../../../core/models/file_model.dart';

class NotificationService {
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

  Future<List<String>> _getReadIds() async {
    final idsString = await _storage.read(key: 'leidos_ids') ?? '';

    return idsString.split(',').where((id) => id.isNotEmpty).toList();
  }

  Future<Map<String, dynamic>> getMyNotifications() async {
    final headers = await _getHeaders();

    if (headers == null) {
      return {'success': false, 'message': 'No hay sesión activa'};
    }

    try {
      print("\n");
      print("============ Obtener notificacion ============");
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

        final List<FileModel> archivos = FileModel.fromJsonList(data);

        final List<String> leidos = await _getReadIds();

        List<Map<String, dynamic>> notificacionesDinamicas = [];

        for (var archivo in archivos) {
          final String tipo = archivo.estado;

          String titulo = '';
          String mensaje = '';

          if (tipo == 'PROCESANDO') {
            titulo = 'Clasificando documento';

            mensaje = 'La IA está analizando "${archivo.nombre}".';
          } else if (tipo == 'COMPLETADO') {
            titulo = '¡Clasificación exitosa!';

            final tema = archivo.tematicaNombre ?? 'tu unidad';

            mensaje = '"${archivo.nombre}" se guardó en $tema.';
          } else if (tipo == 'ERROR') {
            titulo = 'Error de procesamiento';

            mensaje = 'No se pudo procesar "${archivo.nombre}".';
          } else {
            titulo = 'Notificación';

            mensaje = 'Hay una actualización en "${archivo.nombre}".';
          }

          notificacionesDinamicas.add({
            'id': archivo.fileId,
            'tipo': tipo,
            'titulo': titulo,
            'mensaje': mensaje,
            'tiempo': 'Reciente',
            'leido': leidos.contains(archivo.fileId),
          });
        }

        return {'success': true, 'data': notificacionesDinamicas};
      }

      final errorBody = jsonDecode(response.body);

      return {
        'success': false,
        'message':
            errorBody['message'] ??
            errorBody['mensaje'] ??
            'Error al cargar notificaciones',
      };
    } catch (e) {
      print("\nERROR GET NOTIFICATIONS:");
      print(e);
      print("\n");

      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  Future<bool> markAsRead(String id) async {
    try {
      print("\n");
      print("=============== Marcar como leído===============");
      print("NOTIFICATION ID:");
      print(id);

      final leidos = await _getReadIds();

      print("\nIDS LEÍDOS ANTES:");
      print(leidos);

      if (!leidos.contains(id)) {
        leidos.add(id);

        await _storage.write(key: 'leidos_ids', value: leidos.join(','));
      }

      print("\nIDS LEÍDOS DESPUÉS:");
      print(leidos);

      print("============================================");
      print("\n");

      return true;
    } catch (e) {
      print("\nERROR MARK AS READ:");
      print(e);
      print("\n");

      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    final headers = await _getHeaders();

    if (headers == null) return false;

    try {
      print("\n");
      print("============= Marcar todo como leido =============");
      print("REQUEST:");
      print("GET -> $baseUrl");
      print("HEADERS:");
      print(headers);

      final response = await http.get(Uri.parse(baseUrl), headers: headers);

      print("\nRESPONSE:");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY:");
      print(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        final List<FileModel> archivos = FileModel.fromJsonList(data);

        final todosLosIds = archivos.map((a) => a.fileId).toList();

        await _storage.write(key: 'leidos_ids', value: todosLosIds.join(','));

        print("\nNOTIFICACIONES MARCADAS:");
        print(todosLosIds);

        print("============================================");
        print("\n");

        return true;
      }

      print("\nERROR AL MARCAR TODAS COMO LEÍDAS");
      print("============================================");
      print("\n");

      return false;
    } catch (e) {
      print("\nERROR MARK ALL AS READ:");
      print(e);
      print("\n");

      return false;
    }
  }
}
