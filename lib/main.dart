import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'features/auth/screens/welcome_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const FileGuardApp());
  });
}

class FileGuardApp extends StatelessWidget {
  const FileGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FileGuard BUAP',
      debugShowCheckedModeBanner:
          false, // Esto quita la etiqueta roja de "DEBUG"
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        fontFamily: 'Roboto', // O la fuente que prefieras usar
      ),
      // Aquí le decimos que arranque directamente en tu pantalla de bienvenida
      home: const WelcomeScreen(),
    );
  }
}
