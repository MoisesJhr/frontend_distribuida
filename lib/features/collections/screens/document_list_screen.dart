import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/file_service.dart';
import '../../../core/models/file_model.dart'; // <-- 1. IMPORTAMOS EL MODELO

class DocumentListScreen extends StatefulWidget {
  final String themeId;
  final String themeName;

  const DocumentListScreen({
    super.key,
    required this.themeId,
    required this.themeName,
  });

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  final FileService _fileService = FileService();

  // 2. FORZAMOS EL TIPADO ESTRICTO
  List<FileModel> _themeDocuments = [];
  bool _isLoading = true;
  final Set<String> _selectedIds = {};

  bool get _isSelectionMode => _selectedIds.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadDocumentsForThisTheme();
  }

  Future<void> _loadDocumentsForThisTheme() async {
    setState(() => _isLoading = true);
    final result = await _fileService.getMyFiles();

    if (result['success']) {
      // El servicio ya nos devuelve una lista de FileModel
      final List<FileModel> allFiles = result['data'];

      setState(() {
        // 3. FILTRO INTELIGENTE PARA LA CARPETA "GENERAL"
        _themeDocuments = allFiles.where((file) {
          // Si es la carpeta General (t-000), agrupamos los archivos sin clasificar (nulos)
          if (widget.themeId == 't-000' && file.tematicaId == null) {
            return true;
          }
          // Para el resto de carpetas, coincidencia exacta de ID
          return file.tematicaId == widget.themeId;
        }).toList();

        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _toggleSelection(String fileId) {
    setState(() {
      if (_selectedIds.contains(fileId)) {
        _selectedIds.remove(fileId);
      } else {
        _selectedIds.add(fileId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF030D64)),
        title: Text(
          widget.themeName,
          style: const TextStyle(
            color: Color(0xFF030D64),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _themeDocuments.isEmpty
          ? Center(child: Text('No hay documentos en ${widget.themeName}'))
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _themeDocuments.length,
              itemBuilder: (context, index) {
                final FileModel file =
                    _themeDocuments[index]; // 4. USO DEL MODELO
                final isSelected = _selectedIds.contains(file.fileId);

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 8,
                  ),
                  leading: isSelected
                      ? const Icon(
                          Icons.check_circle,
                          color: Color(0xFF6366F1),
                          size: 32,
                        )
                      : Icon(
                          Icons.picture_as_pdf,
                          color: Colors.redAccent.shade400,
                          size: 32,
                        ),
                  title: Text(
                    file.nombre, // <-- PROPIEDAD DIRECTA
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    file.estado ==
                            'COMPLETADO' // <-- PROPIEDAD DIRECTA
                        ? 'Clasificado por IA'
                        : 'Procesando...',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  onLongPress: () => _toggleSelection(file.fileId),
                  onTap: () async {
                    if (_isSelectionMode) {
                      _toggleSelection(file.fileId);
                    } else {
                      // === FLUJO DE VISUALIZACIÓN ===
                      if (file.estado != 'COMPLETADO') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'El archivo aún se está procesando en el clúster.',
                            ),
                          ),
                        );
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Obteniendo documento del clúster...'),
                          duration: Duration(seconds: 1),
                        ),
                      );

                      final result = await _fileService.getDownloadUrl(
                        file.fileId,
                      );

                      if (result['success']) {
                        final url = Uri.parse(result['url']);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'No se pudo abrir el visor de PDFs.',
                                ),
                              ),
                            );
                          }
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result['message'] ?? 'Error desconocido',
                              ),
                            ),
                          );
                        }
                      }
                    }
                  },
                );
              },
            ),
    );
  }
}
