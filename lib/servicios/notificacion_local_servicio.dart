import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Servicio para mostrar notificaciones locales en el dispositivo.
/// 
/// Inicializa el plugin de notificaciones y proporciona métodos
/// para mostrar notificaciones de alertas de calidad del aire.
class NotificacionLocalServicio {
  NotificacionLocalServicio._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _inicializado = false;

  /// Inicializa el servicio de notificaciones locales.
  /// 
  /// Debe llamarse al iniciar la app.
  static Future<void> inicializar() async {
    if (_inicializado) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _inicializado = true;
    debugPrint('✅ Notificaciones locales inicializadas');
  }

  /// Callback cuando el usuario toca una notificación
  static void _onNotificationTap(NotificationResponse response) {
    debugPrint('🔔 Notificación tocada: ${response.payload}');
    // Aquí podrías navegar a una pantalla específica
  }

  /// Muestra una notificación de alerta de calidad del aire.
  /// 
  /// [id] - ID único de la notificación
  /// [titulo] - Título de la notificación
  /// [cuerpo] - Cuerpo del mensaje
  /// [payload] - Datos opcionales para manejar el tap
  static Future<void> mostrar({
    required int id,
    required String titulo,
    required String cuerpo,
    String? payload,
  }) async {
    if (!_inicializado) {
      debugPrint('⚠️ Notificaciones no inicializadas');
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'alertas_calidad_aire',
      'Alertas de Calidad del Aire',
      channelDescription: 'Notificaciones de alertas de calidad del aire',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id,
      titulo,
      cuerpo,
      notificationDetails,
      payload: payload,
    );

    debugPrint('🔔 Notificación mostrada: $titulo');
  }

  /// Muestra una notificación agrupando múltiples alertas.
  /// 
  /// [cantidad] - Número de alertas
  /// [payload] - Datos opcionales
  static Future<void> mostrarAgrupada({
    required int cantidad,
    String? payload,
  }) async {
    await mostrar(
      id: 0,
      titulo: 'Alertas de Calidad del Aire',
      cuerpo: 'Tienes $cantidad alerta(s) nueva(s)',
      payload: payload,
    );
  }

  /// Cancela todas las notificaciones activas.
  static Future<void> cancelarTodas() async {
    await _plugin.cancelAll();
    debugPrint('🔔 Todas las notificaciones canceladas');
  }

  /// Cancela una notificación específica por ID.
  static Future<void> cancelar(int id) async {
    await _plugin.cancel(id);
    debugPrint('🔔 Notificación $id cancelada');
  }
}
