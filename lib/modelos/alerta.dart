import 'package:latlong2/latlong.dart';

/// Tipo de alerta de calidad del aire
enum TipoAlerta {
  medicionActual,
  prediccionFutura,
}

/// Estado de calidad del aire
enum EstadoAire {
  buena,
  moderada,
  alta,
}

/// Modelo de alerta de calidad del aire
class Alerta {
  final TipoAlerta tipo;
  final String idSensor;
  final String zona;
  final LatLng posicion;
  final double co2;
  final double pm25;
  final double temperatura;
  final EstadoAire estado;
  final DateTime timestamp;
  final int? horasFutura;

  Alerta({
    required this.tipo,
    required this.idSensor,
    required this.zona,
    required this.posicion,
    required this.co2,
    required this.pm25,
    required this.temperatura,
    required this.estado,
    required this.timestamp,
    this.horasFutura,
  });

  /// Crea una Alerta desde un mapa JSON del backend
  factory Alerta.fromMap(Map<String, dynamic> json) {
    return Alerta(
      tipo: json['tipo'] == 'medicion_actual'
          ? TipoAlerta.medicionActual
          : TipoAlerta.prediccionFutura,
      idSensor: json['id_sensor'] ?? '',
      zona: json['zona'] ?? '',
      posicion: LatLng(
        json['lat'] ?? 0.0,
        json['lng'] ?? 0.0,
      ),
      co2: (json['co2'] ?? 0.0).toDouble(),
      pm25: (json['pm25'] ?? 0.0).toDouble(),
      temperatura: (json['temperatura'] ?? 0.0).toDouble(),
      estado: _parseEstado(json['estado']),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      horasFutura: json['horas_futura'],
    );
  }

  static EstadoAire _parseEstado(String? estado) {
    switch (estado) {
      case 'buena':
        return EstadoAire.buena;
      case 'moderada':
        return EstadoAire.moderada;
      case 'alta':
        return EstadoAire.alta;
      default:
        return EstadoAire.buena;
    }
  }

  /// Etiqueta legible del estado
  String get etiquetaEstado {
    switch (estado) {
      case EstadoAire.buena:
        return 'Buena';
      case EstadoAire.moderada:
        return 'Moderada';
      case EstadoAire.alta:
        return 'Alta';
    }
  }

  /// Retorna true si la alerta es de alta prioridad
  bool get esAltaPrioridad => estado == EstadoAire.alta;

  /// Mensaje descriptivo de la alerta
  String get mensaje {
    final tipoStr = tipo == TipoAlerta.medicionActual ? 'Actual' : 'Predicción';
    return '$tipoStr: CO₂ ${co2.toInt()} ppm, PM2.5 ${pm25.toInt()} µg/m³';
  }
}
