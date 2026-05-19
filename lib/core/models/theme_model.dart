class ThemeModel {
  final String id;
  final String nombre;

  ThemeModel({required this.id, required this.nombre});

  factory ThemeModel.fromJson(Map<String, dynamic> json) {
    return ThemeModel(
      id: json['id'] ?? json['Id'] ?? '',
      nombre: json['nombre'] ?? json['Nombre'] ?? 'Sin nombre',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nombre': nombre};
  }

  static List<ThemeModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((item) => ThemeModel.fromJson(item)).toList();
  }
}
