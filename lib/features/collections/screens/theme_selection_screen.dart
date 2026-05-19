import 'package:flutter/material.dart';

import 'package:clasificador_archivos/core/services/theme_service.dart';
import 'package:clasificador_archivos/features/user_dashboard/user_main_screen.dart';
import '../../../core/models/theme_model.dart'; // <-- 1. IMPORTAMOS EL MODELO

class ThemeSelectionScreen extends StatefulWidget {
  const ThemeSelectionScreen({super.key});

  @override
  State<ThemeSelectionScreen> createState() => _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends State<ThemeSelectionScreen> {
  final ThemeService _themeService = ThemeService();

  // 2. FORZAMOS EL TIPADO A THEME MODEL
  List<ThemeModel> _catalog = [];
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
        // Hacemos el cast seguro a la lista de modelos
        _catalog = List<ThemeModel>.from(result['data']);
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSave() async {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona al menos una temática.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _themeService.saveMyThemes(_selectedIds.toList());

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
          SnackBar(content: Text(result['message'] ?? 'Error al guardar')),
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
            ? const Center(child: CircularProgressIndicator())
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
                    Expanded(
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _catalog.map((ThemeModel theme) {
                          // <-- 3. EXTRAEMOS COMO MODELO
                          // 4. USAMOS LA NOTACIÓN DE PUNTO
                          final isSelected = _selectedIds.contains(theme.id);

                          return FilterChip(
                            label: Text(theme.nombre),
                            selected: isSelected,
                            onSelected: (val) {
                              setState(() {
                                val
                                    ? _selectedIds.add(theme.id)
                                    : _selectedIds.remove(theme.id);
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
                    ),
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
