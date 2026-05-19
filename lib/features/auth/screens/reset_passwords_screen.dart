import 'package:flutter/material.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthService _authService = AuthService();

  bool _isObscurePass = true;
  bool _isObscureConfirm = true;
  bool _isLoading = false;

  void _handleResetPassword() async {
    // Validaciones
    if (_codeController.text.isEmpty || _newPasswordController.text.isEmpty) {
      _showSnackBar('Por favor, llena todos los campos.', Colors.orange);
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackBar('Las contraseñas no coinciden.', Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);

    // TIPADO ESTRICTO AQUÍ
    final Map<String, dynamic> result = await _authService.resetPassword(
      _codeController.text.trim(),
      _newPasswordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success']) {
      _showSnackBar(result['message'], Colors.green);
      // Regresa al Login limpiando la pila de navegación
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      _showSnackBar(result['message'], Colors.redAccent);
    }
  }

  // MÉTODO ESTANDARIZADO PARA ALERTAS
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
        iconTheme: const IconThemeData(color: Color(0xFF09144D)),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 142, 195, 235),
              Color.fromARGB(255, 160, 207, 223),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- SECCIÓN SUPERIOR ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Restablecer contraseña',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF09144D),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFF09144D).withOpacity(0.75),
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: 'Hemos enviado un código a '),
                          TextSpan(
                            text: widget.email,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF09144D),
                            ),
                          ),
                          const TextSpan(
                            text:
                                '.\nPor favor, introdúcelo a continuación junto con tu nueva contraseña.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- SECCIÓN INFERIOR ---
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
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
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
                      child: SafeArea(
                        top: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CustomTextField(
                              label: 'Código de recuperación',
                              hintText: 'Ingresa tu código: ',
                              controller: _codeController,
                            ),
                            const SizedBox(height: 24),

                            CustomTextField(
                              label: 'Nueva contraseña',
                              hintText: 'Crea tu nueva contraseña',
                              controller: _newPasswordController,
                              isObscure: _isObscurePass,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isObscurePass
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey.shade400,
                                ),
                                onPressed: () => setState(
                                  () => _isObscurePass = !_isObscurePass,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            CustomTextField(
                              label: 'Confirmar nueva contraseña',
                              hintText: 'Repite tu nueva contraseña',
                              controller: _confirmPasswordController,
                              isObscure: _isObscureConfirm,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isObscureConfirm
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey.shade400,
                                ),
                                onPressed: () => setState(
                                  () => _isObscureConfirm = !_isObscureConfirm,
                                ),
                              ),
                            ),
                            const SizedBox(height: 48),

                            _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF6B66FF),
                                    ),
                                  )
                                : PrimaryButton(
                                    text: 'Guardar contraseña',
                                    onPressed: _handleResetPassword,
                                  ),
                          ],
                        ),
                      ),
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
