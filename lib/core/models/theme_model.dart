class ThemeModel {
  final String id;
  final String nombre;
  final String? nombreArea; // <-- 1. Nueva propiedad

  ThemeModel({required this.id, required this.nombre, this.nombreArea});

  factory ThemeModel.fromJson(Map<String, dynamic> json) {
    return ThemeModel(
      id: json['id']?.toString() ?? '',
      nombre:
          json['nombreMostrar'] ??
          json['nombre'] ??
          json['tematicaNombre'] ??
          'Sin categoría',
      // 2. Leemos el área padre si viene en el JSON
      nombreArea: json['nombreArea'],
    );
  }

  static List<ThemeModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => ThemeModel.fromJson(json)).toList();
  }
}
