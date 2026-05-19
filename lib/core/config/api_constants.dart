import 'dart:io' show Platform;

class ApiConstants {
  static const bool isProduction = false;

  static const String ngrokUrl =
      'https://tu-url-generada.ngrok-free.app/api/v1';

  static String get baseUrl {
    if (isProduction) {
      return ngrokUrl;
    }

    // Entorno de desarrollo local
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api/v1'; // Emulador Android
    } else {
      return 'http://localhost:8080/api/v1'; // iOS / Web
    }
  }
}
