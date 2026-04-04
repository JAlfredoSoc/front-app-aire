import 'package:latlong2/latlong.dart';
import '../modelos/sensor.dart';

/// Servicio de mediciones de calidad del aire.
/// Cada entrada representa un punto donde el sensor físico tomó una lectura.
/// Para conectar Firebase o API REST, solo reemplaza [mediciones] — la UI no cambia.
class SensorServicio {
  SensorServicio._();

  // ── Historial de mediciones (mock fijo, sin Timer ni Stream) ──────────────
  static final List<Sensor> mediciones = [
    Sensor(
      id: 'centro',
      zona: 'Centro Histórico',
      posicion: const LatLng(10.4637, -73.2528),
      co2: 412,
      temperatura: 27,
      pm25: 18,
      estado: EstadoAire.buena,
    ),
    Sensor(
      id: 'novalito',
      zona: 'Novalito',
      posicion: const LatLng(10.4686, -73.2622),
      co2: 680,
      temperatura: 29,
      pm25: 36,
      estado: EstadoAire.moderada,
    ),
    Sensor(
      id: 'nevada',
      zona: 'La Nevada',
      posicion: const LatLng(10.4552, -73.2465),
      co2: 950,
      temperatura: 31,
      pm25: 58,
      estado: EstadoAire.alta,
    ),
    Sensor(
      id: 'sicarare',
      zona: 'Sicarare',
      posicion: const LatLng(10.4720, -73.2480),
      co2: 520,
      temperatura: 28,
      pm25: 28,
      estado: EstadoAire.moderada,
    ),
    Sensor(
      id: 'villa_del_rio',
      zona: 'Villa del Río',
      posicion: const LatLng(10.4580, -73.2600),
      co2: 380,
      temperatura: 26,
      pm25: 14,
      estado: EstadoAire.buena,
    ),
  ];

  // Alias para compatibilidad con código existente
  static List<Sensor> get sensores => mediciones;

  // ── Promedio de todos los puntos medidos ──────────────────────────────────
  static Sensor get promedio {
    final n = mediciones.length;
    final co2 = mediciones.map((s) => s.co2).reduce((a, b) => a + b) / n;
    final temp =
        mediciones.map((s) => s.temperatura).reduce((a, b) => a + b) / n;
    final pm25 = mediciones.map((s) => s.pm25).reduce((a, b) => a + b) / n;

    EstadoAire estado;
    if (co2 > 800 || pm25 > 50) {
      estado = EstadoAire.alta;
    } else if (co2 > 550 || pm25 > 25) {
      estado = EstadoAire.moderada;
    } else {
      estado = EstadoAire.buena;
    }

    return Sensor(
      id: 'promedio',
      zona: 'Promedio de Valledupar',
      posicion: const LatLng(10.4631, -73.2532),
      co2: co2,
      temperatura: temp,
      pm25: pm25,
      estado: estado,
    );
  }

  // ── Alertas del historial ─────────────────────────────────────────────────
  static const List<AlertaMedicion> alertas = [
    AlertaMedicion(
      zona: 'La Nevada',
      mensaje: 'Alta contaminación detectada (CO₂: 950 ppm)',
      nivel: EstadoAire.alta,
    ),
    AlertaMedicion(
      zona: 'Novalito',
      mensaje: 'Nivel moderado de PM2.5 (36 µg/m³)',
      nivel: EstadoAire.moderada,
    ),
    AlertaMedicion(
      zona: 'Sicarare',
      mensaje: 'Temperatura elevada: 28 °C',
      nivel: EstadoAire.moderada,
    ),
    AlertaMedicion(
      zona: 'Centro Histórico',
      mensaje: 'Calidad del aire en niveles óptimos',
      nivel: EstadoAire.buena,
    ),
  ];
}

/// Alerta generada a partir de una medición
class AlertaMedicion {
  final String zona;
  final String mensaje;
  final EstadoAire nivel;
  const AlertaMedicion({
    required this.zona,
    required this.mensaje,
    required this.nivel,
  });
}
