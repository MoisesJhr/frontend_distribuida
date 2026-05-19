import 'package:flutter/material.dart';
import '../../../core/services/theme_service.dart';
import '../../../core/models/theme_model.dart'; // <-- 1. IMPORTAMOS EL MODELO
import 'document_list_screen.dart';

class ThemesScreen extends StatefulWidget {
  const ThemesScreen({super.key});

  @override
  State<ThemesScreen> createState() => _ThemesScreenState();
}

class _ThemesScreenState extends State<ThemesScreen> {
  static const Color customDeepBlue = Color(0xFF030D64);
  static const Color searchBg = Color(0xFFF3F4F6);
  static const Color folderBg = Color(0xFFFEF7E5);

  final ThemeService _themeService = ThemeService();

  // 2. FORZAMOS EL TIPADO A THEME MODEL
  List<ThemeModel> _myFolders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThemes();
  }

  Future<void> _loadThemes() async {
    setState(() => _isLoading = true);
    final result = await _themeService.getMyThemes();

    if (result['success']) {
      setState(() {
        // Hacemos el cast seguro a la lista de modelos
        _myFolders = List<ThemeModel>.from(result['data']);

        // 3. AGREGAMOS "GENERAL" INSTANCIANDO EL MODELO, NO UN MAPA
        _myFolders.insert(0, ThemeModel(id: "t-000", nombre: "General"));

        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: customDeepBlue),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildSearchBar(),
                  const SizedBox(height: 32),
                  const Text(
                    'Tus Colecciones',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: customDeepBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFolderGrid(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Colecciones',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: customDeepBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: searchBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar temáticas...',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildFolderGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
        childAspectRatio: 0.85,
      ),
      itemCount: _myFolders.length,
      itemBuilder: (context, index) {
        final ThemeModel folder = _myFolders[index]; // Extraemos el modelo

        // 4. USAMOS LA PROPIEDAD .id
        final icon = folder.id == 't-000'
            ? Icons.folder_copy_rounded
            : Icons.folder_shared_rounded;

        return GestureDetector(
          onTap: () {
            // Saltamos directo a los documentos usando las propiedades del modelo
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DocumentListScreen(
                  themeId: folder.id,
                  themeName: folder.nombre,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: folderBg,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(icon, size: 64, color: Colors.orange.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                folder.nombre, // 4. USAMOS LA PROPIEDAD .nombre
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: customDeepBlue,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
