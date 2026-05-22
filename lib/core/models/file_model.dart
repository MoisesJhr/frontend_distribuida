class FileModel {
  final String fileId;
  final String nombre;
  final String estado;
  final String? tematicaId;
  final String? tematicaNombre;

  FileModel({
    required this.fileId,
    required this.nombre,
    required this.estado,
    this.tematicaId,
    this.tematicaNombre,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    // 1. TRADUCTOR DE ESTADOS
    String parseEstado(dynamic valorEstado) {
      if (valorEstado == 0) return 'PROCESANDO';
      if (valorEstado == 1) return 'COMPLETADO';
      if (valorEstado == 2) return 'ERROR';
      if (valorEstado is String) return valorEstado.toUpperCase();
      return 'PROCESANDO';
    }

    String extractId(dynamic id1, dynamic id2) {
      if (id1 != null) return id1.toString();
      if (id2 != null) return id2.toString();
      return '';
    }

    String? extractNullableId(dynamic id1, dynamic id2) {
      if (id1 != null) return id1.toString();
      if (id2 != null) return id2.toString();
      return null;
    }

    return FileModel(
      fileId: extractId(json['id'], json['fileId']),
      nombre:
          json['nombreOriginal'] ?? json['nombre'] ?? 'Documento sin nombre',
      estado: parseEstado(json['estado']),

      // 🚨 LA CORRECCIÓN ESTÁ AQUÍ 🚨
      // Ahora lee primero "subcategoriaId", y si no existe (por si acaso), lee "areaId"
      tematicaId: extractNullableId(
        json['tematicaId'],
        json['clasificacion']?['subcategoriaId'] ??
            json['clasificacion']?['areaId'],
      ),

      // Igual con el nombre, priorizamos el nombre de la subcategoría
      tematicaNombre:
          json['tematicaNombre'] ??
          json['clasificacion']?['nombreSubcategoria'] ??
          json['clasificacion']?['nombreArea'],
    );
  }

  static List<FileModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => FileModel.fromJson(json)).toList();
  }
}
