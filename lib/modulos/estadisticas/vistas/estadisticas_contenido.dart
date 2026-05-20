import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../modelos/sensor.dart';
import '../../../servicios/sensor_servicio.dart';
import '../../../servicios/prediccion_servicio.dart';

/// Contenido puro de estadísticas. Sin header ni navbar — los provee AppShell.
class EstadisticasContenido extends StatefulWidget {
  const EstadisticasContenido({super.key});

  @override
  State<EstadisticasContenido> createState() => _EstadisticasContenidoState();
}

class _EstadisticasContenidoState extends State<EstadisticasContenido> {
  List<Sensor> _datos = [];
  Map<String, dynamic> _statsIA = {'efectividad_ia': 0.0, 'total_predicciones': 0};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final datos = await SensorServicio.obtenerTodos();
    final stats = await PrediccionServicio.obtenerEstadisticasGlobales();
    
    if (mounted) {
      setState(() {
        _datos = datos;
        _statsIA = stats;
        _cargando = false;
      });
    }
  }

  Sensor get _promedio => SensorServicio.promedio;
  Sensor get _maximo => _datos.isNotEmpty 
      ? _datos.reduce((a, b) => a.co2 > b.co2 ? a : b)
      : Sensor(id: '0', zona: '-', posicion: const LatLng(0,0), co2: 0, temperatura: 0, pm25: 0, estado: EstadoAire.buena);
  
  Sensor get _minimo => _datos.isNotEmpty 
      ? _datos.reduce((a, b) => a.co2 < b.co2 ? a : b)
      : Sensor(id: '0', zona: '-', posicion: const LatLng(0,0), co2: 0, temperatura: 0, pm25: 0, estado: EstadoAire.buena);

  int get _totalBuena => _datos.where((s) => s.estado == EstadoAire.buena).length;
  int get _totalModerada => _datos.where((s) => s.estado == EstadoAire.moderada).length;
  int get _totalAlta => _datos.where((s) => s.estado == EstadoAire.alta).length;

  static const List<_PuntoTendencia> _tendencia = [
    _PuntoTendencia('6am', 380),
    _PuntoTendencia('9am', 450),
    _PuntoTendencia('12pm', 620),
    _PuntoTendencia('3pm', 710),
    _PuntoTendencia('6pm', 680),
    _PuntoTendencia('9pm', 540),
  ];

  @override
  Widget build(BuildContext context) {
    if (_cargando && _datos.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00C9A7)),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _cargarDatos,
      color: const Color(0xFF00C9A7),
      backgroundColor: const Color(0xFF1A1F25),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        children: [
          _TarjetaResumen(promedio: _promedio),
          const SizedBox(height: 16),
          _SeccionTitulo(
            icono: Icons.psychology_outlined,
            titulo: 'Rendimiento de la IA',
            color: const Color(0xFF9C27B0),
          ),
          const SizedBox(height: 10),
          _TarjetaIARendimiento(stats: _statsIA),
          const SizedBox(height: 16),
          _SeccionTitulo(
            icono: Icons.show_chart_rounded,
            titulo: 'Tendencia del día',
            color: const Color(0xFF7CC6FE),
          ),
          const SizedBox(height: 10),
          _TarjetaTendencia(puntos: _tendencia),
          const SizedBox(height: 16),
          _SeccionTitulo(
            icono: Icons.compare_arrows_rounded,
            titulo: 'Máximo y mínimo registrado',
            color: const Color(0xFFFFC857),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _TarjetaExtremo(sensor: _maximo, esMaximo: true)),
              const SizedBox(width: 12),
              Expanded(child: _TarjetaExtremo(sensor: _minimo, esMaximo: false)),
            ],
          ),
          const SizedBox(height: 16),
          _SeccionTitulo(
            icono: Icons.pin_drop_outlined,
            titulo: 'Promedio por zonas',
            color: const Color(0xFF00C9A7),
          ),
          const SizedBox(height: 10),
          ..._datos.map((s) => _FilaZona(sensor: s)),
          const SizedBox(height: 16),
          _SeccionTitulo(
            icono: Icons.donut_small_rounded,
            titulo: 'Distribución de calidad',
            color: const Color(0xFF00C9A7),
          ),
          const SizedBox(height: 10),
          _TarjetaDistribucion(
            buena: _totalBuena,
            moderada: _totalModerada,
            alta: _totalAlta,
            total: _datos.length,
          ),
          const SizedBox(height: 16),
          _SeccionTitulo(
            icono: Icons.tips_and_updates_outlined,
            titulo: 'Recomendaciones',
            color: const Color(0xFF7CC6FE),
          ),
          const SizedBox(height: 10),
          const _TarjetaConsejos(),
        ],
      ),
    );
  }
}

// ── Tarjeta resumen ───────────────────────────────────────────────────────────

class _TarjetaResumen extends StatelessWidget {
  final Sensor promedio;
  const _TarjetaResumen({required this.promedio});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            promedio.colorEstado.withValues(alpha: 0.18),
            isDark 
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: promedio.colorEstado.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: promedio.colorEstado.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.public_rounded,
                  color: promedio.colorEstado,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen general',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Promedio de todos los puntos',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.54),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              _ChipEstado(sensor: promedio),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _DatoResumen(
                icono: Icons.co2_rounded,
                etiqueta: 'CO₂ prom.',
                valor: '${promedio.co2.toStringAsFixed(0)} ppm',
                color: promedio.colorEstado,
              ),
              const SizedBox(width: 10),
              _DatoResumen(
                icono: Icons.blur_on_rounded,
                etiqueta: 'PM2.5 prom.',
                valor: '${promedio.pm25.toStringAsFixed(1)} µg/m³',
                color: const Color(0xFFFFC857),
              ),
              const SizedBox(width: 10),
              _DatoResumen(
                icono: Icons.thermostat_rounded,
                etiqueta: 'Temp. prom.',
                valor: '${promedio.temperatura.toStringAsFixed(1)} °C',
                color: const Color(0xFF7CC6FE),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DatoResumen extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;
  final Color color;
  const _DatoResumen({
    required this.icono,
    required this.etiqueta,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icono, color: color, size: 16),
            const SizedBox(height: 6),
            Text(
              valor,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              etiqueta,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.54),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tendencia — overflow corregido ────────────────────────────────────────────

class _TarjetaTendencia extends StatelessWidget {
  final List<_PuntoTendencia> puntos;
  const _TarjetaTendencia({required this.puntos});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final maxVal = puntos.map((p) => p.valor).reduce((a, b) => a > b ? a : b);
    final minVal = puntos.map((p) => p.valor).reduce((a, b) => a < b ? a : b);
    final subio = puntos.last.valor > puntos[puntos.length - 2].valor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.white.withValues(alpha: 0.055)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.09)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                subio ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                color: subio
                    ? const Color(0xFFFF6B6B)
                    : const Color(0xFF00C9A7),
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  subio
                      ? 'La contaminación ha aumentado al final del día'
                      : 'La contaminación ha disminuido al final del día',
                  style: TextStyle(
                    color: subio
                        ? const Color(0xFFFF6B6B)
                        : const Color(0xFF00C9A7),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Gráfico — altura intrínseca, sin SizedBox fijo que cause overflow
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: puntos.map((p) {
                final ratio = (p.valor - minVal + 50) / (maxVal - minVal + 50);
                final barHeight = 56 * ratio; // máx 56px, sin overflow
                final color = p.valor > 700
                    ? const Color(0xFFFF6B6B)
                    : p.valor > 500
                    ? const Color(0xFFFFC857)
                    : const Color(0xFF00C9A7);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${p.valor.toInt()}',
                          style: TextStyle(
                            color: color,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.80),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          p.hora,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.54),
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Resto de widgets ──────────────────────────────────────────────────────────

class _TarjetaExtremo extends StatelessWidget {
  final Sensor sensor;
  final bool esMaximo;
  const _TarjetaExtremo({required this.sensor, required this.esMaximo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = esMaximo ? const Color(0xFFFF6B6B) : const Color(0xFF00C9A7);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                esMaximo
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 5),
              Text(
                esMaximo ? 'Máximo' : 'Mínimo',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${sensor.co2.toStringAsFixed(0)} ppm',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            sensor.zona,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.54),
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _FilaZona extends StatelessWidget {
  final Sensor sensor;
  const _FilaZona({required this.sensor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.white.withValues(alpha: 0.055)
            : Colors.black.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: sensor.colorEstado,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              sensor.zona,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (sensor.co2 / 1000).clamp(0.0, 1.0),
                backgroundColor: sensor.colorEstado.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(sensor.colorEstado),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            sensor.co2.toStringAsFixed(0),
            style: TextStyle(
              color: sensor.colorEstado,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            'ppm',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaDistribucion extends StatelessWidget {
  final int buena, moderada, alta, total;
  const _TarjetaDistribucion({
    required this.buena,
    required this.moderada,
    required this.alta,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.white.withValues(alpha: 0.055)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.09)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 14,
              child: Row(
                children: [
                  if (buena > 0)
                    Expanded(
                      flex: (buena * 100 ~/ total),
                      child: Container(color: const Color(0xFF00C9A7)),
                    ),
                  if (moderada > 0)
                    Expanded(
                      flex: (moderada * 100 ~/ total),
                      child: Container(color: const Color(0xFFFFC857)),
                    ),
                  if (alta > 0)
                    Expanded(
                      flex: (alta * 100 ~/ total),
                      child: Container(color: const Color(0xFFFF6B6B)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ItemDist(
                color: const Color(0xFF00C9A7),
                etiqueta: 'Buena',
                cantidad: buena,
                total: total,
              ),
              _ItemDist(
                color: const Color(0xFFFFC857),
                etiqueta: 'Moderada',
                cantidad: moderada,
                total: total,
              ),
              _ItemDist(
                color: const Color(0xFFFF6B6B),
                etiqueta: 'Alta',
                cantidad: alta,
                total: total,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemDist extends StatelessWidget {
  final Color color;
  final String etiqueta;
  final int cantidad, total;
  const _ItemDist({
    required this.color,
    required this.etiqueta,
    required this.cantidad,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = ((cantidad / total) * 100).round();
    return Column(
      children: [
        Text(
          '$pct%',
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(
              etiqueta,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 11,
              ),
            ),
          ],
        ),
        Text(
          '$cantidad zona${cantidad != 1 ? 's' : ''}',
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _TarjetaConsejos extends StatelessWidget {
  const _TarjetaConsejos();

  static const _items = [
    (
      Icons.directions_run_rounded,
      Color(0xFFFFC857),
      'Evita actividad física',
      'En zonas con contaminación alta o moderada.',
    ),
    (
      Icons.water_drop_outlined,
      Color(0xFF7CC6FE),
      'Mantente hidratado',
      'El calor y el polvo aumentan la deshidratación.',
    ),
    (
      Icons.masks_outlined,
      Color(0xFFFF6B6B),
      'Usa protección',
      'Una mascarilla N95 reduce la exposición a PM2.5.',
    ),
    (
      Icons.notifications_active_outlined,
      Color(0xFF00C9A7),
      'Mantente informado',
      'Revisa la app antes de salir al exterior.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.white.withValues(alpha: 0.055)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.09)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: _items
            .map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: c.$2.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(c.$1, color: c.$2, size: 17),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.$3,
                            style: TextStyle(
                              color: c.$2,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            c.$4,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SeccionTitulo extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final Color color;
  const _SeccionTitulo({
    required this.icono,
    required this.titulo,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icono, color: color, size: 16),
        const SizedBox(width: 7),
        Text(
          titulo,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ── Tarjeta de Rendimiento IA ───────────────────────────────────────────────

class _TarjetaIARendimiento extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _TarjetaIARendimiento({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final efectividad = stats['efectividad_ia'] ?? 0.0;
    final total = stats['total_predicciones'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF9C27B0).withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF9C27B0).withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Efectividad del Entrenamiento',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.54),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${efectividad is double ? efectividad.toStringAsFixed(1) : efectividad}%',
                  style: TextStyle(
                    color: isDark ? const Color(0xFFE1BEE7) : const Color(0xFF7B1FA2),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  efectividad > 90 ? 'Excelente precisión dinámica' : 'Modelo en aprendizaje continuo',
                  style: TextStyle(
                    color: const Color(0xFF9C27B0).withValues(alpha: 0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Predicciones Totales',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.54),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$total',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Desde el mapa',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipEstado extends StatelessWidget {
  final Sensor sensor;
  const _ChipEstado({required this.sensor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: sensor.colorEstado.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: sensor.colorEstado.withValues(alpha: 0.38)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: sensor.colorEstado,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            sensor.etiquetaEstado,
            style: TextStyle(
              color: sensor.colorEstado,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PuntoTendencia {
  final String hora;
  final double valor;
  const _PuntoTendencia(this.hora, this.valor);
}
