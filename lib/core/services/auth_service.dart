import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:clasificador_archivos/core/config/api_constants.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final url = '${ApiConstants.baseUrl}/auth/login';

      final requestBody = {'email': email, 'password': password};

      print("\n");
      print("=============== Iniciar sesion ===============");
      print("REQUEST:");
      print("POST -> $url");
      print("HEADERS:");
      print({'Content-Type': 'application/json'});
      print("BODY:");
      print(jsonEncode(requestBody));

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print("\nRESPONSE:");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY:");
      print(response.body);
      print("=====================================");
      print("\n");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        await _storage.write(key: 'jwt_token', value: data['token']);

        await _storage.write(key: 'user_role', value: data['usuario']['rol']);

        final String nombreUsuario = data['usuario']['nombre'] ?? 'Usuario';

        await _storage.write(key: 'user_name', value: nombreUsuario);

        return {'success': true, 'rol': data['usuario']['rol']};
      }

      try {
        final errorBody = jsonDecode(response.body);

        return {
          'success': false,
          'message':
              errorBody['error'] ??
              errorBody['message'] ??
              'Credenciales incorrectas',
        };
      } catch (_) {
        return {
          'success': false,
          'message': 'Credenciales incorrectas o Error ${response.statusCode}',
        };
      }
    } catch (e) {
      print("\nERROR LOGIN:");
      print(e);
      print("\n");

      return {'success': false, 'message': 'Error de conexión de red'};
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<void> logout() async {
    print("\n");
    print("=============== Cerrar sesión ===============");
    print("ELIMINANDO TOKENS Y STORAGE");
    print("======================================");
    print("\n");

    await _storage.deleteAll();
  }

  Future<Map<String, dynamic>> register({
    required String nombre,
    required String email,
    required String password,
    required String carrera,
    required String rol,
  }) async {
    try {
      final url = '${ApiConstants.baseUrl}/auth/register';

      final requestBody = {
        'nombre': nombre,
        'email': email,
        'password': password,
        'carrera': carrera,
        'rol': rol,
      };

      print("\n");
      print("============== Registrarse ==============");
      print("REQUEST:");
      print("POST -> $url");
      print("HEADERS:");
      print({'Content-Type': 'application/json'});
      print("BODY:");
      print(jsonEncode(requestBody));

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print("\nRESPONSE:");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY:");
      print(response.body);
      print("======================================");
      print("\n");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        return {
          'success': true,
          'message': data['mensaje'],
          'id': data['id'] ?? '',
        };
      }

      try {
        final errorBody = jsonDecode(response.body);

        return {
          'success': false,
          'message':
              errorBody['mensaje'] ??
              errorBody['error'] ??
              'Error al registrar usuario',
        };
      } catch (_) {
        return {
          'success': false,
          'message':
              'Error al registrar usuario. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("\nERROR REGISTER:");
      print(e);
      print("\n");

      return {'success': false, 'message': 'Error de conexión con el servidor'};
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final url = '${ApiConstants.baseUrl}/auth/forgot-password';

      final requestBody = {'email': email};

      print("\n");
      print("=========== Olvidar contraseña ==========");
      print("REQUEST:");
      print("POST -> $url");
      print("HEADERS:");
      print({'Content-Type': 'application/json'});
      print("BODY:");
      print(jsonEncode(requestBody));

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print("\nRESPONSE:");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY:");
      print(response.body);
      print("======================================");
      print("\n");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        return {
          'success': true,
          'message': data['mensaje'] ?? 'Código enviado si el correo existe.',
        };
      }

      try {
        final errorBody = jsonDecode(response.body);

        return {
          'success': false,
          'message':
              errorBody['mensaje'] ??
              'Ocurrió un error al procesar la solicitud.',
        };
      } catch (_) {
        return {
          'success': false,
          'message': 'Ocurrió un error al procesar la solicitud.',
        };
      }
    } catch (e) {
      print("\nERROR FORGOT PASSWORD:");
      print(e);
      print("\n");

      return {
        'success': false,
        'message': 'Error de conexión con el servidor.',
      };
    }
  }

  Future<Map<String, dynamic>> resetPassword(
    String token,
    String nuevaPassword,
  ) async {
    try {
      final url = '${ApiConstants.baseUrl}/auth/reset-password';

      final requestBody = {
        'tokenTemporal': token,
        'nuevaPassword': nuevaPassword,
      };

      print("\n");
      print("============ Restablecer la contraseña ==========");
      print("REQUEST:");
      print("POST -> $url");
      print("HEADERS:");
      print({'Content-Type': 'application/json'});
      print("BODY:");
      print(jsonEncode(requestBody));

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print("\nRESPONSE:");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY:");
      print(response.body);
      print("======================================");
      print("\n");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Contraseña restablecida con éxito.',
        };
      }

      try {
        final errorBody = jsonDecode(response.body);

        return {
          'success': false,
          'message':
              errorBody['mensaje'] ??
              errorBody['error'] ??
              'El código es inválido o ha expirado.',
        };
      } catch (_) {
        return {
          'success': false,
          'message': 'El código es inválido o ha expirado.',
        };
      }
    } catch (e) {
      print("\nERROR RESET PASSWORD:");
      print(e);
      print("\n");

      return {
        'success': false,
        'message': 'Error de conexión con el servidor.',
      };
    }
  }
}
