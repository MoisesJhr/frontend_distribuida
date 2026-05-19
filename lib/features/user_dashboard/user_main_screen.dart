import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:clasificador_archivos/features/user_dashboard/screens/notifications_screen.dart';
import 'package:clasificador_archivos/features/user_dashboard/screens/settings_screen.dart';
import 'package:clasificador_archivos/features/collections/screens/themes_screen.dart';
import 'user_home_view.dart';

import '../../../core/services/file_service.dart';
import '../../../core/services/user_service.dart';
// --- NUEVOS IMPORTS DE MODELOS ---
import '../../../core/models/file_model.dart';
import '../../../core/models/user_model.dart';

class UserMainScreen extends StatefulWidget {
  const UserMainScreen({super.key});

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  int _selectedIndex = 0;

  // --- SERVICIOS ---
  final FileService _fileService = FileService();
  final UserService _userService = UserService();

  // --- ESTADO FUERTEMENTE TIPADO ---
  List<FileModel> _files = []; // <-- Ahora exige que todo sea un FileModel
  bool _isLoadingFiles = true;
  bool _isUploading = false;
  String _userName = 'Cargando...';

  // --- VARIABLE PARA EL POLLING ---
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadFiles().then((_) {
      _startPolling();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  // --- MÉTODO PARA OBTENER EL PERFIL (ACTUALIZADO A MODELO) ---
  Future<void> _loadUserProfile() async {
    final result = await _userService.getUserProfile();
    if (result['success'] && mounted) {
      final UserModel user = result['data']; // Extraemos el objeto
      setState(() {
        _userName = user.nombre; // Usamos el atributo de la clase
      });
    } else if (mounted) {
      setState(() {
        _userName = 'Usuario';
      });
    }
  }

  // --- POLLING (ACTUALIZADO A MODELO) ---
  void _startPolling() {
    _pollingTimer?.cancel();
    // Accedemos con .estado en lugar de ['estado']
    bool hayProcesando = _files.any((f) => f.estado == 'PROCESANDO');

    if (hayProcesando) {
      _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
        final result = await _fileService.getMyFiles();
        if (result['success']) {
          if (mounted) {
            setState(() {
              _files = result['data'];
            });
          }
          // Revisión usando la propiedad .estado
          bool siguenProcesando = _files.any((f) => f.estado == 'PROCESANDO');
          if (!siguenProcesando) {
            timer.cancel();
          }
        }
      });
    }
  }

  Future<void> _loadFiles() async {
    setState(() => _isLoadingFiles = true);
    final result = await _fileService.getMyFiles();
    if (result['success']) {
      setState(() {
        _files = result['data']; // El servicio ya devuelve List<FileModel>
        _isLoadingFiles = false;
      });
    } else {
      setState(() => _isLoadingFiles = false);
    }
  }

  Future<void> _pickAndUploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() => _isUploading = true);

        String fileName = result.files.single.name;
        String filePath = result.files.single.path!;
        final messenger = ScaffoldMessenger.of(context);

        final uploadResult = await _fileService.uploadFile(filePath, fileName);
        setState(() => _isUploading = false);

        if (uploadResult['success']) {
          await _loadFiles();
          _startPolling();

          if (mounted) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(uploadResult['message']),
                backgroundColor: Colors.blueAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          if (mounted) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(uploadResult['message']),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al seleccionar el archivo.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteFile(String fileId, String fileName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar Documento'),
        content: Text('¿Seguro que deseas eliminar "$fileName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await _fileService.deleteFile(fileId);
      if (result['success']) {
        _loadFiles();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return UserHomeView(
          files: _files,
          isLoading: _isLoadingFiles,
          onDelete: _deleteFile,
          userName: _userName,
        );
      case 1:
        return const NotificationsScreen();
      case 2:
        return const NotificationsScreen();
      case 3:
        return const ThemesScreen();
      case 4:
        return const SettingsScreen();
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getSelectedScreen(),
      floatingActionButton: FloatingActionButton(
        onPressed: _isUploading ? null : _pickAndUploadFile,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF6366F1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
        ),
        child: _isUploading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Color(0xFF6366F1),
                  strokeWidth: 2.5,
                ),
              )
            : const Icon(Icons.upload_file, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF6366F1),
        unselectedItemColor: Colors.grey.shade400,
        onTap: (index) {
          if (index != 2) setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notification_add_rounded),
            label: 'Notify',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add, color: Colors.transparent),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Colecciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
