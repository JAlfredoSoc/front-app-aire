import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../modelos/alerta.dart';
import 'notificacion_local_servicio.dart';

/// Servicio para consultar alertas de calidad del aire del backend.
/// 
/// Realiza polling periódico para verificar alertas nuevas y
/// muestra notificaciones locales cuando hay alertas activas.
class AlertaServicio {
  AlertaServicio._();

  static const String _baseUrl = 'http://10.0.2.2:8000';
  static const String _claveTimestamp = 'ultima_alerta_timestamp';
  static const Duration _intervaloPolling = Duration(minutes: 5);

  static Timer? _pollingTimer;
  static bool _estaActivo = false;

  /// Lista de alertas activas obtenidas del último polling.
  /// Accesible para mostrar en el modal de notificaciones.
  static List<Alerta> alertas = [];

  /// Indica si hay alertas nuevas sin leer (para mostrar el badge rojo).
  static bool hayAlertasNuevas = false;

  /// Inicia el polling de alertas.
  /// 
  /// [intervalo] - Frecuencia del polling (default: 5 minutos)
  static void iniciarPolling({Duration? intervalo}) {
    if (_estaActivo) {
      debugPrint('⚠️ Polling ya está activo');
      return;
    }

    _estaActivo = true;
    final interval = intervalo ?? _intervaloPolling;

    // Primera verificación inmediata
    verificarAlertas();

    // Iniciar timer periódico
    _pollingTimer = Timer.periodic(interval, (_) {
      verificarAlertas();
    });

    debugPrint('✅ Polling de alertas iniciado (cada ${interval.inMinutes} min)');
  }

  /// Detiene el polling de alertas.
  static void detenerPolling() {
    if (!_estaActivo) return;

    _pollingTimer?.cancel();
    _pollingTimer = null;
    _estaActivo = false;

    debugPrint('⏹️ Polling de alertas detenido');
  }

  /// Verifica si hay alertas nuevas en el backend.
  static Future<void> verificarAlertas() async {
    try {
      final ultimaTimestamp = await _obtenerTimestamp();
      final url = ultimaTimestamp != null
          ? '$_baseUrl/api/notificaciones/alertas-calidad?desde=$ultimaTimestamp'
          : '$_baseUrl/api/notificaciones/alertas-calidad';

      debugPrint('🔍 Consultando alertas: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final totalAlertas = data['total_alertas'] ?? 0;

        if (totalAlertas > 0) {
          final nuevasAlertas = (data['alertas'] as List)
              .map((json) => Alerta.fromMap(json))
              .toList();

          // Guardar alertas para mostrar en el modal
          alertas = nuevasAlertas;
          hayAlertasNuevas = true;

          await _procesarAlertas(nuevasAlertas);
        } else {
          // Limpiar alertas si no hay nuevas
          alertas = [];
          hayAlertasNuevas = false;
        }

        // Guardar timestamp más reciente (incluso si no hay alertas)
        final nuevaTimestamp = data['ultima_alerta_timestamp'];
        if (nuevaTimestamp != null) {
          await _guardarTimestamp(nuevaTimestamp);
        }
      } else {
        debugPrint('⚠️ Error en respuesta del backend: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error verificando alertas: $e');
    }
  }

  /// Procesa las alertas recibidas y muestra notificaciones.
  static Future<void> _procesarAlertas(List<Alerta> alertas) async {
    if (alertas.isEmpty) return;

    debugPrint('🚨 ${alertas.length} alerta(s) nueva(s)');

    // Agrupar alertas por zona
    final alertasPorZona = <String, List<Alerta>>{};
    for (final alerta in alertas) {
      alertasPorZona.putIfAbsent(alerta.zona, () => []).add(alerta);
    }

    // Mostrar notificación por zona
    var notificacionId = 1;
    for (final entry in alertasPorZona.entries) {
      final zona = entry.key;
      final alertasZona = entry.value;
      final alertaPrincipal = alertasZona.first;

      final titulo = alertaPrincipal.esAltaPrioridad
          ? '⚠️ Alerta: $zona'
          : 'ℹ️ Calidad del aire: $zona';

      final cuerpo = alertasZona.length == 1
          ? alertaPrincipal.mensaje
          : '${alertasZona.length} alertas en $zona';

      await NotificacionLocalServicio.mostrar(
        id: notificacionId++,
        titulo: titulo,
        cuerpo: cuerpo,
        payload: jsonEncode({'zona': zona}),
      );
    }

    // Si hay muchas alertas, mostrar notificación agrupada
    if (alertas.length > 3) {
      await NotificacionLocalServicio.mostrarAgrupada(
        cantidad: alertas.length,
      );
    }
  }

  /// Guarda el timestamp de la última alerta recibida.
  static Future<void> _guardarTimestamp(String timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_claveTimestamp, timestamp);
    debugPrint('💾 Timestamp guardado: $timestamp');
  }

  /// Obtiene el timestamp de la última alerta recibida.
  static Future<String?> _obtenerTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_claveTimestamp);
  }

  /// Limpia el timestamp guardado (útil para resetear el estado).
  static Future<void> limpiarTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_claveTimestamp);
    debugPrint('🗑️ Timestamp limpiado');
  }

  /// Retorna true si el polling está activo.
  static bool get estaActivo => _estaActivo;

  /// Marca las alertas como leídas (quita el badge rojo).
  static void marcarAlertasLeidas() {
    hayAlertasNuevas = false;
    debugPrint('📖 Alertas marcadas como leídas');
  }
}
