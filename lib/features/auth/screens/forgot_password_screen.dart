import 'package:flutter/material.dart';

import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import 'reset_passwords_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _handleSendCode() async {
    if (_emailController.text.isEmpty) {
      _showSnackBar(
        'Por favor, ingresa tu correo institucional.',
        Colors.orange,
      );
      return;
    }

    setState(() => _isLoading = true);

    // TIPADO ESTRICTO AQUÍ: Explicitamente pedimos el mapa en lugar de dejarlo en dynamic
    final Map<String, dynamic> result = await _authService.forgotPassword(
      _emailController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success']) {
      // Usamos color verde para el éxito, consistente con el registro
      _showSnackBar(result['message'], Colors.green);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ResetPasswordScreen(email: _emailController.text.trim()),
        ),
      );
    } else {
      _showSnackBar(result['message'], Colors.redAccent);
    }
  }

  // Método estandarizado para los mensajes flotantes
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Icono oscuro usando la paleta para contrastar con el fondo claro
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          // Degradado idéntico al de Login y Registro
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 253, 253, 253),
              Color.fromARGB(255, 9, 13, 84),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- SECCIÓN SUPERIOR (Títulos) ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recuperar contraseña',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors
                            .textDark, // Aplicamos el color oscuro de la paleta
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Ingresa el correo electrónico asociado a tu cuenta y te enviaremos un código con las instrucciones.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textLight, // Gris suave de la paleta
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- SECCIÓN INFERIOR (Tarjeta Blanca con el formulario) ---
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                  decoration: const BoxDecoration(
                    color: AppColors.white, // Blanco puro
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        CustomTextField(
                          label: 'Correo electrónico',
                          hintText: 'Ingresa tu correo',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 100),
                        Center(
                          child: SizedBox(
                            height: 170,
                            child: Image.asset(
                              'assets/images/message.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const Spacer(),
                        _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.authAccent,
                                ),
                              )
                            : PrimaryButton(
                                text: 'Enviar código',
                                onPressed: _handleSendCode,
                              ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
