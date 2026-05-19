import 'package:flutter/material.dart';
import '../../../core/models/file_model.dart'; // <-- 1. NUEVO IMPORT

class UserHomeView extends StatelessWidget {
  final List<FileModel> files; // <-- 2. AHORA EXIGE LA LISTA DEL MODELO
  final bool isLoading;
  final Function(String, String) onDelete;
  final String userName;

  const UserHomeView({
    super.key,
    required this.files,
    required this.isLoading,
    required this.onDelete,
    this.userName = '',
  });

  static const Color customDeepBlue = Color(0xFF030D64);
  static const Color brandColor = Color(0xFF6366F1);

  Widget _buildStatusChip(String status) {
    final String safeStatus = status.toUpperCase();
    final isCompleted = safeStatus == 'COMPLETADO';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompleted ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isCompleted)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.orange.shade700,
                ),
              ),
            ),
          Icon(
            isCompleted ? Icons.check_circle : Icons.sync,
            size: 14,
            color: isCompleted ? Colors.green.shade700 : Colors.orange.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            safeStatus,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isCompleted
                  ? Colors.green.shade700
                  : Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Saludo y Perfil Dinámico
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola, ${userName.split(' ').first}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: customDeepBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(0xFFE3F2FD),
                  child: Icon(Icons.person, color: brandColor),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 2. Tarjeta de Estado del Sistema
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: brandColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.security_rounded, color: Colors.white, size: 40),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Almacenamiento Protegido',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 3. Notificaciones del Sistema (Dinámicas)
            _buildSectionTitle('Notificaciones'),
            const SizedBox(height: 16),
            _buildNotificationsSection(files),
            const SizedBox(height: 32),

            // 4. Tus Documentos en el Clúster
            _buildSectionTitle('Tus Documentos en el Clúster'),
            const SizedBox(height: 16),

            if (isLoading)
              const Center(child: CircularProgressIndicator(color: brandColor))
            else if (files.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'No has subido documentos aún.',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: files.length,
                itemBuilder: (context, index) {
                  final FileModel file = files[index]; // <-- Usamos el modelo

                  // 3. EXTRACCIÓN SÚPER LIMPIA GRACIAS AL MODELO
                  final String nombreCategoria =
                      file.tematicaNombre ?? 'Pendiente de clasificar';
                  final String nombreArchivo = file.nombre;
                  final String estadoArchivo = file.estado;
                  final String fileId = file.fileId;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.redAccent,
                        ),
                      ),
                      title: Text(
                        nombreArchivo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: customDeepBlue,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.category,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  nombreCategoria,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildStatusChip(estadoArchivo),
                        ],
                      ),
                      trailing: estadoArchivo.toUpperCase() == 'COMPLETADO'
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.download_rounded,
                                    color: Colors.blueAccent,
                                  ),
                                  onPressed: () {
                                    // A FUTURO: Aquí conectarás el _fileService.getDownloadUrl(fileId)
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Descargando archivo...'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () =>
                                      onDelete(fileId, nombreArchivo),
                                ),
                              ],
                            )
                          : null,
                    ),
                  );
                },
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: customDeepBlue,
      ),
    );
  }

  // 4. LÓGICA DE NOTIFICACIONES SIMPLIFICADA
  Widget _buildNotificationsSection(List<FileModel> files) {
    final procesando = files
        .where((f) => f.estado.toUpperCase() == 'PROCESANDO')
        .toList();
    final completados = files
        .where((f) => f.estado.toUpperCase() == 'COMPLETADO')
        .toList();

    if (procesando.isNotEmpty) {
      final file = procesando.first;
      return _buildNotificationCard(
        icon: Icons.auto_awesome,
        iconColor: Colors.orange.shade700,
        bgColor: Colors.orange.shade50,
        borderColor: Colors.orange.shade200,
        title: 'Clasificando documento...',
        subtitle: 'La IA está analizando "${file.nombre}".',
        trailingIcon: Icons.sync,
      );
    } else if (completados.isNotEmpty) {
      final file = completados.first;
      final categoria = file.tematicaNombre ?? 'tu catálogo';

      return _buildNotificationCard(
        icon: Icons.check_circle_outline,
        iconColor: Colors.green.shade700,
        bgColor: Colors.green.shade50,
        borderColor: Colors.green.shade200,
        title: '¡Clasificación exitosa!',
        subtitle: '"${file.nombre}" se guardó en $categoria.',
        trailingIcon: Icons.arrow_forward_ios,
      );
    } else {
      return _buildNotificationCard(
        icon: Icons.notifications_none,
        iconColor: Colors.grey.shade600,
        bgColor: Colors.grey.shade50,
        borderColor: Colors.grey.shade200,
        title: 'Todo al día',
        subtitle: 'No tienes notificaciones pendientes.',
        trailingIcon: null,
      );
    }
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color borderColor,
    required String title,
    required String subtitle,
    IconData? trailingIcon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: iconColor.withOpacity(0.8),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: iconColor.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (trailingIcon != null)
            Icon(trailingIcon, size: 16, color: iconColor.withOpacity(0.5)),
        ],
      ),
    );
  }
}
