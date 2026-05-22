import 'package:flutter/material.dart';

import 'package:clasificador_archivos/core/services/theme_service.dart';
import 'package:clasificador_archivos/features/user_dashboard/user_main_screen.dart';

class ThemeSelectionScreen extends StatefulWidget {
  const ThemeSelectionScreen({super.key});

  @override
  State<ThemeSelectionScreen> createState() => _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends State<ThemeSelectionScreen> {
  final ThemeService _themeService = ThemeService();

  // Almacenamos el catálogo original anidado tal como viene del backend
  List<dynamic> _catalog = [];

  // Seguimos guardando solo los IDs que el usuario toca
  final Set<String> _selectedIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    final result = await _themeService.getGlobalThemes();
    if (result['success']) {
      setState(() {
        final rawData = result['data'];

        if (rawData is Map<String, dynamic>) {
          _catalog = rawData['areas'] ?? rawData['subcategorias'] ?? [];
        } else if (rawData is List) {
          _catalog = rawData;
        } else {
          _catalog = [];
        }

        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  // === MAGIA AQUÍ: Reconstruimos el árbol solo con lo seleccionado ===
  List<Map<String, dynamic>> _buildPayload() {
    List<Map<String, dynamic>> payload = [];

    for (var area in _catalog) {
      List<dynamic> subcategorias = area['subcategorias'] ?? [];
      List<Map<String, dynamic>> selectedSubs = [];

      // Filtramos las subcategorías de esta área
      for (var sub in subcategorias) {
        if (_selectedIds.contains(sub['id'])) {
          selectedSubs.add({
            "id": sub['id'],
            "nombre": sub['nombre'],
            "nombreMostrar": sub['nombreMostrar'],
          });
        }
      }

      // Si el usuario seleccionó al menos una subcategoría de esta área, la agregamos
      if (selectedSubs.isNotEmpty) {
        payload.add({
          "areaId": area['areaId'],
          "nombreArea": area['nombreArea'],
          "subcategorias": selectedSubs,
        });
      }
    }
    return payload;
  }

  Future<void> _handleSave() async {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona al menos una temática.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 1. Armamos el JSON exacto que exige C#
    final payload = _buildPayload();

    // 2. Lo enviamos al servicio
    final result = await _themeService.saveMyThemes(payload);

    if (result['success']) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserMainScreen()),
        );
      }
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Error al guardar'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF030D64)),
              )
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personaliza tu Clúster',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF030D64),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Selecciona las temáticas de interés para clasificar tus archivos académicos.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 32),

                    // === RENDERIZADO POR CATEGORÍAS ===
                    Expanded(
                      child: ListView.builder(
                        itemCount: _catalog.length,
                        itemBuilder: (context, index) {
                          final area = _catalog[index];
                          final List<dynamic> subs =
                              area['subcategorias'] ?? [];

                          if (subs.isEmpty) return const SizedBox();

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Título del Área (Ej: Ciencias de la Computación)
                                Text(
                                  area['nombreArea'] ?? 'Área',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF030D64),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Chips de esa área
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: subs.map((sub) {
                                    final String id = sub['id'];
                                    // Usamos nombreMostrar si existe, sino el nombre en inglés
                                    final String nombreAMostrar =
                                        sub['nombreMostrar'] ?? sub['nombre'];
                                    final isSelected = _selectedIds.contains(
                                      id,
                                    );

                                    return FilterChip(
                                      label: Text(nombreAMostrar),
                                      selected: isSelected,
                                      onSelected: (val) {
                                        setState(() {
                                          val
                                              ? _selectedIds.add(id)
                                              : _selectedIds.remove(id);
                                        });
                                      },
                                      selectedColor: const Color(
                                        0xFF6366F1,
                                      ).withOpacity(0.2),
                                      checkmarkColor: const Color(0xFF6366F1),
                                      labelStyle: TextStyle(
                                        color: isSelected
                                            ? const Color(0xFF6366F1)
                                            : Colors.black87,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF030D64),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Comenzar ahora',
                          style: TextStyle(color: Colors.white, fontSize: 16),
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
