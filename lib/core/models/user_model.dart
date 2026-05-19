class UserModel {
  final String id;
  final String nombre;
  final String email;
  final String carrera;
  final String rol;
  final String? fotoUrl;

  UserModel({
    required this.id,
    required this.nombre,
    required this.email,
    required this.carrera,
    required this.rol,
    this.fotoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['Id'] ?? '',
      nombre: json['nombre'] ?? json['Nombre'] ?? 'Sin nombre',
      email: json['email'] ?? json['Email'] ?? '',
      carrera: json['carrera'] ?? json['Carrera'] ?? 'No especificada',
      rol: json['rol'] ?? json['Rol'] ?? 'USER',
      fotoUrl:
          json['fotoUrl'] ?? json['FotoUrl'], // Si no viene, se queda como null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'carrera': carrera,
      'rol': rol,
      if (fotoUrl != null) 'fotoUrl': fotoUrl,
    };
  }

  static List<UserModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((item) => UserModel.fromJson(item)).toList();
  }
}
