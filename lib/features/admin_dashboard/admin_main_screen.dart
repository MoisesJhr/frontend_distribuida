import 'package:clasificador_archivos/core/models/user_model.dart';
import 'package:clasificador_archivos/features/admin_dashboard/screens/theme_audit_detail_screen.dart';
import 'package:clasificador_archivos/features/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_dropdown_field.dart';
import '../../../core/widgets/primary_button.dart';

// Asegúrate de importar tu modelo aquí si está en otro archivo
// import 'ruta/a/tu/user_model.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  final AdminService _adminService = AdminService();

  // TIPADO FUERTE: Ahora Flutter sabe que esta lista solo contiene UserModels
  List<UserModel> _users = [];
  bool _isLoading = true;

  // Catálogo de carreras para consistencia
  final List<String> _carreras = ['Ingeniería en Ciencias de la Computación'];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final result = await _adminService.getAllUsers();
    if (result['success']) {
      setState(() {
        // Aseguramos que la lista se parsee correctamente al modelo
        _users = List<UserModel>.from(result['data']);
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteUser(String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmar baja'),
        content: const Text(
          '¿Estás seguro de eliminar este usuario permanentemente?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final messenger = ScaffoldMessenger.of(context);
      final result = await _adminService.deleteUser(userId);
      if (result['success']) {
        _loadUsers();
        messenger.showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // --- MODAL: DAR DE ALTA (Incluye Carrera) ---
  void _showAddUserModal() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String? selectedCareer;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
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
                'Dar de Alta Usuario',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF030D64),
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Nombre',
                hintText: 'Ej. Juan Pérez',
                controller: nameController,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Correo',
                hintText: 'usuario@buap.mx',
                controller: emailController,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Contraseña',
                hintText: '********',
                controller: passwordController,
                isObscure: true,
              ),
              const SizedBox(height: 12),
              CustomDropdownField(
                label: 'Carrera',
                hintText: 'Selecciona la carrera',
                value: selectedCareer,
                items: _carreras,
                onChanged: (val) => setModalState(() => selectedCareer = val),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Crear Usuario',
                onPressed: () async {
                  if (selectedCareer == null) return;
                  final messenger = ScaffoldMessenger.of(context);
                  final result = await _adminService.createUser({
                    'nombre': nameController.text.trim(),
                    'email': emailController.text.trim(),
                    'password': passwordController.text.trim(),
                    'rol': 'USER',
                    'carrera': selectedCareer,
                  });
                  Navigator.pop(context);
                  _loadUsers();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(result['message']),
                      backgroundColor: result['success']
                          ? Colors.green
                          : Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // --- MODAL: EDITAR DATOS ---
  // CORRECCIÓN: Ahora recibe un UserModel, no un Map
  void _showEditUserModal(UserModel user) {
    final nameController = TextEditingController(text: user.nombre);
    final emailController = TextEditingController(text: user.email);
    String? selectedCareer = user.carrera;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
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
                'Modificar Información',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF030D64),
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Nombre completo',
                hintText: 'Ej. Juan Pérez',
                controller: nameController,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Correo electrónico',
                hintText: 'usuario@buap.mx',
                controller: emailController,
              ),
              const SizedBox(height: 12),
              CustomDropdownField(
                label: 'Carrera',
                hintText: 'Selecciona la carrera',
                value: selectedCareer,
                items: _carreras,
                onChanged: (val) => setModalState(() => selectedCareer = val),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Actualizar Datos',
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final result = await _adminService.updateUser(user.id, {
                    'nombre': nameController.text.trim(),
                    'email': emailController.text.trim(),
                    'carrera': selectedCareer,
                  });
                  Navigator.pop(context);
                  _loadUsers();
                  if (result['success']) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(result['message']),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // --- MODAL: CAMBIAR CONTRASEÑA ---
  void _showChangePasswordModal(String userId) {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
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
              'Sobrescribir Contraseña',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF030D64),
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Nueva Contraseña',
              hintText: 'Ingresa la nueva contraseña',
              controller: passwordController,
              isObscure: true,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Confirmar Contraseña',
              hintText: 'Repite la contraseña',
              controller: confirmController,
              isObscure: true,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Actualizar Contraseña',
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);

                if (passwordController.text != confirmController.text) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Las contraseñas no coinciden'),
                      backgroundColor: Colors.orange,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                final result = await _adminService.updateUserPassword(
                  userId,
                  passwordController.text.trim(),
                );
                Navigator.pop(context);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(result['message']),
                    backgroundColor: result['success']
                        ? Colors.green
                        : Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Panel de Administración',
          style: TextStyle(
            color: Color(0xFF030D64),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Text(
              'Usuarios del Sistema',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF030D64),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6366F1)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      // CORRECCIÓN: Notación de punto para el rol
                      final bool isAdmin = user.rol == 'ADMIN';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: isAdmin
                                          ? Colors.deepPurple.shade50
                                          : const Color(0xFFE3F2FD),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      isAdmin
                                          ? Icons.admin_panel_settings
                                          : Icons.person,
                                      color: isAdmin
                                          ? Colors.deepPurple
                                          : Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // CORRECCIÓN: Notación de punto
                                        Text(
                                          user.nombre,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Color(0xFF030D64),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        // CORRECCIÓN: Notación de punto
                                        Text(
                                          user.email,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 13,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isAdmin
                                          ? Colors.deepPurple.shade50
                                          : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      // CORRECCIÓN: Notación de punto
                                      user.rol,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isAdmin
                                            ? Colors.deepPurple
                                            : Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(height: 1, color: Colors.grey.shade100),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton.icon(
                                    icon: const Icon(
                                      Icons.folder_shared_outlined,
                                      size: 18,
                                    ),
                                    label: const Text('Auditar Temáticas'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF6366F1),
                                    ),
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ThemeAuditDetailScreen(
                                              // CORRECCIÓN: Notación de punto
                                              userId: user.id,
                                              userName: user.nombre,
                                            ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          color: Colors.blueAccent,
                                          size: 20,
                                        ),
                                        // CORRECCIÓN: Se pasa el objeto user directamente
                                        onPressed: () =>
                                            _showEditUserModal(user),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.key_outlined,
                                          color: Colors.orangeAccent,
                                          size: 20,
                                        ),
                                        // CORRECCIÓN: Notación de punto
                                        onPressed: () =>
                                            _showChangePasswordModal(user.id),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.redAccent,
                                          size: 20,
                                        ),
                                        // CORRECCIÓN: Notación de punto
                                        onPressed: () => _deleteUser(user.id),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddUserModal,
        backgroundColor: const Color(0xFF6366F1),
        label: const Text(
          'Nuevo Usuario',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}
