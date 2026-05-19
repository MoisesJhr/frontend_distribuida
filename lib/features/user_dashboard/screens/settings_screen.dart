import 'package:flutter/material.dart';

import 'package:clasificador_archivos/core/widgets/custom_dropdown_field.dart';
import 'package:clasificador_archivos/features/auth/screens/welcome_screen.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';

import '../../../core/services/user_service.dart';
import '../../../core/models/user_model.dart'; // <-- 1. IMPORTAMOS EL MODELO

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserService _userService = UserService();

  // 2. AHORA USAMOS NUESTRO MODELO EN LUGAR DE UN MAPA CRUDO
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    final result = await _userService.getUserProfile();

    if (mounted) {
      if (result['success']) {
        setState(() {
          _user = result['data']; // El servicio ya nos devuelve un UserModel
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showEditCareerModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext modalContext) {
        final List<String> careers = [
          'Ingeniería en Ciencias de la Computación',
        ];

        // 3. OBTENEMOS LA CARRERA DIRECTAMENTE DESDE EL MODELO
        String? selectedCareer = _user?.carrera;

        if (!careers.contains(selectedCareer)) {
          selectedCareer = null;
        }

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Modificar Carrera',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF030D64),
                    ),
                  ),
                  const SizedBox(height: 16),

                  CustomDropdownField(
                    label: 'Carrera o Departamento',
                    hintText: 'Selecciona tu carrera',
                    value: selectedCareer,
                    items: careers,
                    onChanged: (String? newValue) {
                      setModalState(() {
                        selectedCareer = newValue;
                      });
                    },
                  ),

                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'Guardar cambios',
                    onPressed: () async {
                      if (selectedCareer == null) return;

                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(context);

                      final result = await _userService.updateProfile({
                        'carrera': selectedCareer,
                      });

                      navigator.pop();

                      if (result['success']) {
                        _loadUserData();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(result['message']),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(result['message']),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showChangePasswordModal() {
    final TextEditingController currentPassController = TextEditingController();
    final TextEditingController newPassController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext modalContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Actualizar Contraseña',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF030D64),
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Contraseña Actual',
                hintText: 'Ingresa tu contraseña actual',
                controller: currentPassController,
                isObscure: true,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Nueva Contraseña',
                hintText: 'Crea una contraseña segura',
                controller: newPassController,
                isObscure: true,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Actualizar contraseña',
                onPressed: () async {
                  if (currentPassController.text.isEmpty ||
                      newPassController.text.isEmpty) {
                    return;
                  }

                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);

                  final result = await _userService.updatePassword(
                    currentPassController.text.trim(),
                    newPassController.text.trim(),
                  );

                  navigator.pop();

                  Color color = result['success']
                      ? Colors.green
                      : Colors.redAccent;
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(result['message']),
                      backgroundColor: color,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6366F1)),
      );
    }

    // Ya sabemos que _user es de tipo UserModel
    final user = _user;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ajustes',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF030D64),
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: const Color(0xFFE3F2FD),
                    // 4. USAMOS EL MODELO PARA VALIDAR LA FOTO
                    backgroundImage: user?.fotoUrl != null
                        ? NetworkImage(user!.fotoUrl!)
                        : null,
                    child: user?.fotoUrl == null
                        ? const Icon(
                            Icons.person,
                            size: 36,
                            color: Color(0xFF6366F1),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          // 5. ATRIBUTOS DIRECTOS DEL MODELO
                          user?.nombre ?? 'Usuario',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF030D64),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E7FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user?.rol == 'ADMIN'
                                ? 'Administrador'
                                : 'Estudiante',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'Configuración de Cuenta',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.school, color: Colors.orange.shade700),
              ),
              title: const Text('Carrera o Departamento'),
              subtitle: Text(
                user?.carrera ?? 'No especificada', // Atributo directo
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.edit, size: 20),
              onTap: _showEditCareerModal,
            ),

            const Divider(),

            const SizedBox(height: 16),
            const Text(
              'Seguridad',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.lock_outline, color: Colors.blue.shade700),
              ),
              title: const Text('Actualizar contraseña'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _showChangePasswordModal,
            ),

            const Divider(),

            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.logout, color: Colors.red.shade700),
              ),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
