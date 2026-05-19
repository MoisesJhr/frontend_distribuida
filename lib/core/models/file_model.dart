class FileModel {
  final String fileId;
  final String nombre;
  final String estado; // PROCESANDO, COMPLETADO, ERROR
  final String? tematicaId;
  final String? tematicaNombre;
  final DateTime? fechaSubida;

  FileModel({
    required this.fileId,
    required this.nombre,
    required this.estado,
    this.tematicaId,
    this.tematicaNombre,
    this.fechaSubida,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    // Manejo seguro de la fecha
    DateTime? parsedDate;
    if (json['fechaSubida'] != null) {
      try {
        parsedDate = DateTime.parse(json['fechaSubida']);
      } catch (e) {
        parsedDate = null;
      }
    }

    return FileModel(
      fileId: json['fileId'] ?? json['FileId'] ?? '',
      nombre: json['nombre'] ?? json['Nombre'] ?? 'Documento sin nombre',
      estado: json['estado'] ?? json['Estado'] ?? 'DESCONOCIDO',
      tematicaId: json['tematicaId'] ?? json['TematicaId'],
      tematicaNombre: json['tematicaNombre'] ?? json['TematicaNombre'],
      fechaSubida: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileId': fileId,
      'nombre': nombre,
      'estado': estado,
      if (tematicaId != null) 'tematicaId': tematicaId,
      if (tematicaNombre != null) 'tematicaNombre': tematicaNombre,
      if (fechaSubida != null) 'fechaSubida': fechaSubida!.toIso8601String(),
    };
  }

  static List<FileModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((item) => FileModel.fromJson(item)).toList();
  }
}
