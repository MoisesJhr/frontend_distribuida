import 'package:flutter/material.dart';
import '../../../core/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();

  // 1. FORZAMOS EL TIPADO ESTRICTO QUE DEVUELVE EL SERVICIO
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final result = await _notificationService.getMyNotifications();

    if (result['success']) {
      setState(() {
        // Hacemos el cast seguro a la lista de mapas
        _notifications = List<Map<String, dynamic>>.from(result['data']);
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudieron sincronizar las notificaciones'),
          ),
        );
      }
    }
  }

  Future<void> _marcarTodasComoLeidas() async {
    final success = await _notificationService.markAllAsRead();
    if (success) {
      _loadNotifications(); // Recarga la lista para actualizar la UI
    }
  }

  Future<void> _marcarUnaComoLeida(String id) async {
    final success = await _notificationService.markAsRead(id);
    if (success) {
      _loadNotifications();
    }
  }

  // Define el estilo visual según el estado del proceso en el clúster
  Map<String, dynamic> _getStyleByTipo(String tipo) {
    switch (tipo) {
      case 'PROCESANDO':
        return {
          'icon': Icons.sync,
          'color': Colors.orange.shade600,
          'bg': Colors.orange.shade50,
        };
      case 'COMPLETADO':
        return {
          'icon': Icons.check_circle_outline,
          'color': Colors.green.shade600,
          'bg': Colors.green.shade50,
        };
      case 'ERROR':
        return {
          'icon': Icons.error_outline,
          'color': Colors.red.shade600,
          'bg': Colors.red.shade50,
        };
      default:
        return {
          'icon': Icons.notifications_none,
          'color': const Color(0xFF6366F1),
          'bg': const Color(0xFFEEF2FF),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final nuevas = _notifications.where((n) => n['leido'] == false).toList();
    final anteriores = _notifications.where((n) => n['leido'] == true).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF6366F1)),
              )
            : RefreshIndicator(
                onRefresh: _loadNotifications,
                color: const Color(0xFF6366F1),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // --- CABECERA ---
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Notificaciones',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF030D64),
                              ),
                            ),
                            if (nuevas.isNotEmpty)
                              TextButton(
                                onPressed: _marcarTodasComoLeidas,
                                child: const Text(
                                  'Marcar leídas',
                                  style: TextStyle(
                                    color: Color(0xFF6366F1),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // --- LISTADO VACÍO ---
                    if (_notifications.isEmpty)
                      SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 100),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.notifications_none,
                                  size: 64,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No tienes avisos por ahora',
                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // --- SECCIÓN: NUEVAS ---
                    if (nuevas.isNotEmpty) ...[
                      _buildSectionHeader('NUEVAS'),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              _buildNotificationCard(nuevas[index]),
                          childCount: nuevas.length,
                        ),
                      ),
                    ],

                    // --- SECCIÓN: ANTERIORES ---
                    if (anteriores.isNotEmpty) ...[
                      _buildSectionHeader('ANTERIORES'),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              _buildNotificationCard(anteriores[index]),
                          childCount: anteriores.length,
                        ),
                      ),
                    ],

                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade500,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notif) {
    final style = _getStyleByTipo(notif['tipo']);
    final bool unread = !notif['leido'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: unread
              ? style['color'].withOpacity(0.2)
              : Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _marcarUnaComoLeida(notif['id']),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono con fondo circular
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: style['bg'],
                  shape: BoxShape.circle,
                ),
                child: Icon(style['icon'], color: style['color'], size: 22),
              ),
              const SizedBox(width: 16),

              // Contenido de texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          notif['titulo'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF030D64),
                          ),
                        ),
                        Text(
                          notif['tiempo'],
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif['mensaje'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              // Punto indicador de no leído
              if (unread)
                Container(
                  margin: const EdgeInsets.only(left: 8, top: 4),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6366F1),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
