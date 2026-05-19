import 'package:clasificador_archivos/core/models/theme_model.dart';
import 'package:clasificador_archivos/features/collections/screens/theme_selection_screen.dart';
import 'package:flutter/material.dart';
// Ajusta tus rutas de importación según tu estructura
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/theme_service.dart'; // <-- NUEVO IMPORT
import '../../../core/theme/app_colors.dart';
import '../../admin_dashboard/admin_main_screen.dart';
import '../../user_dashboard/user_main_screen.dart';
import '../screens/forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscure = true;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Por favor ingresa tu correo y contraseña', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (result['success']) {
      if (result['rol'] == 'ADMIN') {
        setState(() => _isLoading = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminMainScreen()),
        );
      } else {
        final themeService = ThemeService();
        final themeResult = await themeService.getMyThemes();

        if (!mounted) return;
        setState(
          () => _isLoading = false,
        ); // Apagamos el loader hasta este punto

        if (themeResult['success']) {
          final List<ThemeModel> misTemas = themeResult['data'];

          if (misTemas.isEmpty) {
            // ESCENARIO 1: Usuario Nuevo -> Lo forzamos a elegir temáticas
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ThemeSelectionScreen(),
              ),
            );
          } else {
            // ESCENARIO 2: Usuario Viejo -> Va directo a su Dashboard
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const UserMainScreen()),
            );
          }
        } else {
          // Fallback de seguridad: Si falla el request de temas, lo mandamos al Home de todos modos
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const UserMainScreen()),
          );
        }
      }
    } else {
      setState(() => _isLoading = false);
      _showSnackBar(result['message'], Colors.redAccent);
    }
  }

  // Estandarizamos el SnackBar para que coincida con el del RegisterScreen
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Transparente para ver el degradado
      extendBodyBehindAppBar: true, // El fondo sube hasta la barra de estado
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        // Aplicamos el mismo degradado de la fase de autenticación
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.white,
              Color.fromARGB(255, 255, 255, 255), // Tu azul celeste base
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Inicia sesión',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark, // Color consistente para títulos
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bienvenido de nuevo, por favor ingresa tus datos.',
                  style: TextStyle(
                    color: AppColors.textLight, // Gris suave
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 48),

                // 1. Campo de Email
                CustomTextField(
                  label: 'Correo electrónico',
                  hintText: 'Ingresa tu correo: ',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),

                // 2. Campo de Contraseña
                CustomTextField(
                  label: 'Contraseña',
                  hintText: 'Ingresa tu contraseña: ',
                  controller: _passwordController,
                  isObscure: _isObscure,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                  ),
                ),

                // Enlace de "¿Olvidaste tu contraseña?"
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(
                        color:
                            AppColors.authAccent, // Acento de la fase inicial
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 3. Botón con indicador de carga
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.authAccent,
                        ),
                      )
                    : PrimaryButton(
                        text: 'Iniciar sesión',
                        onPressed: _handleLogin,
                      ),
                const SizedBox(height: 24),

                // Enlace al registro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿No tienes cuenta?',
                      style: TextStyle(color: AppColors.textLight),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Regístrate',
                        style: TextStyle(
                          color: AppColors.authAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
