import 'package:flutter/material.dart';
import '../../../core/services/admin_theme_service.dart';
import '../../../core/models/theme_model.dart';

class ThemeAuditDetailScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const ThemeAuditDetailScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<ThemeAuditDetailScreen> createState() => _ThemeAuditDetailScreenState();
}

class _ThemeAuditDetailScreenState extends State<ThemeAuditDetailScreen> {
  final AdminThemeService _themeService = AdminThemeService();
  List<ThemeModel> _userThemes = []; // Tipado correctamente como ThemeModel
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserThemes();
  }

  Future<void> _loadUserThemes() async {
    setState(() => _isLoading = true);
    final result = await _themeService.getUserThemes(widget.userId);
    if (result['success']) {
      setState(() {
        _userThemes =
            result['data']; // Ya viene convertido por ThemeModel.fromJsonList
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  // MODAL PARA ASIGNAR NUEVA TEMÁTICA
  void _showAddThemeModal() async {
    final catalogResult = await _themeService.getGlobalCatalog();
    if (!catalogResult['success']) return;

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final List<ThemeModel> catalog = catalogResult['data'];
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Asignar Temática',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap:
                      true, // Importante para que ListView funcione dentro de modal
                  itemCount: catalog.length,
                  itemBuilder: (context, index) {
                    final item = catalog[index];
                    final bool alreadyHas = _userThemes.any(
                      (t) => t.id == item.id,
                    );

                    return ListTile(
                      title: Text(item.nombre),
                      trailing: Icon(
                        alreadyHas
                            ? Icons.check_circle
                            : Icons.add_circle_outline,
                        color: alreadyHas ? Colors.green : Colors.indigo,
                      ),
                      onTap: alreadyHas
                          ? null
                          : () async {
                              Navigator.pop(context);
                              await _themeService.assignThemeToUser(
                                widget.userId,
                                item.id,
                              );
                              _loadUserThemes();
                            },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // DIÁLOGO DE PURGA
  Future<void> _confirmForceDelete(String themeId, String themeName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminación Forzada'),
        content: Text(
          '¿Purgar los archivos de "${widget.userName}" en la temática "$themeName" de los 3 nodos?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Purgar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      await _themeService.forceDeleteUserTheme(widget.userId, themeId);
      _loadUserThemes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Temáticas de ${widget.userName}',
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF030D64),
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userThemes.isEmpty
          ? const Center(
              child: Text('El usuario no tiene temáticas asignadas.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _userThemes.length,
              itemBuilder: (context, index) {
                final ThemeModel theme = _userThemes[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.folder, color: Colors.orange),
                    title: Text(theme.nombre), // Acceso correcto con punto
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_forever,
                        color: Colors.redAccent,
                      ),
                      onPressed: () => _confirmForceDelete(
                        theme.id,
                        theme.nombre,
                      ), // Acceso correcto con punto
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddThemeModal,
        label: const Text('Asignar Temática'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF6366F1),
      ),
    );
  }
}
