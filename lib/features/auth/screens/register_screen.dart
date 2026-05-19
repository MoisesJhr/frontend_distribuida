import 'package:flutter/material.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_dropdown_field.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isObscurePass = true;
  bool _isObscureConfirm = true;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final AuthService _authService = AuthService();

  String? _selectedRole;
  final List<String> _roles = ['Estudiante'];

  String? _selectedCareer;
  final List<String> _careers = ['Ingeniería en Ciencias de la Computación'];

  void _handleRegister() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showSnackBar('Por favor llena todos los campos', Colors.orange);
      return;
    }

    if (_selectedCareer == null) {
      _showSnackBar('Por favor selecciona una carrera', Colors.orange);
      return;
    }

    if (_selectedRole == null) {
      _showSnackBar('Por favor selecciona un rol', Colors.orange);
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Las contraseñas no coinciden', Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);

    String backendRole = _selectedRole == 'Administrativo' ? 'ADMIN' : 'USER';

    // TIPADO ESTRICTO AQUÍ
    final Map<String, dynamic> result = await _authService.register(
      nombre: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      carrera: _selectedCareer!,
      rol: backendRole,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success']) {
      _showSnackBar(result['message'] ?? 'Registro exitoso', Colors.green);
      Navigator.pop(context);
    } else {
      _showSnackBar(result['message'], Colors.redAccent);
    }
  }

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
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppColors.textDark,
        ), // Icono de retroceso oscuro
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.white, Color.fromARGB(255, 247, 247, 247)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 10.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Crear cuenta',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark, // Título en azul muy oscuro
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Únete para organizar tus documentos académicos.',
                  style: TextStyle(color: AppColors.textLight, fontSize: 16),
                ),
                const SizedBox(height: 32),

                CustomTextField(
                  label: 'Nombre completo',
                  hintText: 'Ingrese su nombre: ',
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  label: 'Correo electrónico institucional',
                  hintText: 'Ingrese su correo: ',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                CustomDropdownField(
                  label: 'Carrera',
                  hintText: 'Selecciona tu carrera',
                  value: _selectedCareer,
                  items: _careers,
                  onChanged: (String? newValue) =>
                      setState(() => _selectedCareer = newValue),
                ),
                const SizedBox(height: 20),

                CustomDropdownField(
                  label: 'Rol en la plataforma',
                  hintText: 'Selecciona tu rol',
                  value: _selectedRole,
                  items: _roles,
                  onChanged: (String? newValue) =>
                      setState(() => _selectedRole = newValue),
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  label: 'Contraseña',
                  hintText: 'Con número, mayúscula y signos',
                  controller: _passwordController,
                  isObscure: _isObscurePass,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscurePass ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () =>
                        setState(() => _isObscurePass = !_isObscurePass),
                  ),
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  label: 'Confirmar contraseña',
                  hintText: 'Con número, mayúscula y signos',
                  controller: _confirmPasswordController,
                  isObscure: _isObscureConfirm,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscureConfirm
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () =>
                        setState(() => _isObscureConfirm = !_isObscureConfirm),
                  ),
                ),
                const SizedBox(height: 40),

                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.authAccent,
                        ),
                      )
                    : PrimaryButton(
                        text: 'Registrarse',
                        onPressed: _handleRegister,
                      ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿Ya tienes cuenta?',
                      style: TextStyle(color: AppColors.textLight),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Inicia sesión',
                        style: TextStyle(
                          color: AppColors.authAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
