import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../modelos/sensor.dart';
import '../../../servicios/sensor_servicio.dart';
import '../../../widgets/comunes/tarjeta_medicion.dart';
import '../../../servicios/mapa_calor_servicio.dart';
import '../../../servicios/prediccion_servicio.dart';
import '../widgets/marcador_sensor.dart';

/// Contenido del mapa — el mapa ocupa el 65% de la altura disponible.
/// Sin header ni navbar propios (los provee AppShell).
class MapaContenido extends StatefulWidget {
  const MapaContenido({super.key});

  @override
  State<MapaContenido> createState() => _MapaContenidoState();
}

class _MapaContenidoState extends State<MapaContenido> {
  final _mapController = MapController();
  List<Sensor> _mediciones = [];
  List<Map<String, dynamic>> _puntosCalor = [];
  Sensor? _seleccionado;
  bool _cargando = true;
  bool _mostrarMapaCalor = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final datos = await SensorServicio.obtenerTodos();
    final heatmap = await MapaCalorServicio.obtenerPuntos('co2');
    if (mounted) {
      setState(() {
        _mediciones = datos;
        _puntosCalor = heatmap;
        _cargando = false;
      });
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _seleccionar(Sensor s) {
    setState(() {
      _seleccionado = _seleccionado?.id == s.id ? null : s;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    if (_cargando && _mediciones.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00C9A7)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // El mapa ocupa el 65% del espacio disponible
        final alturaTotal = constraints.maxHeight;
        final alturaMapaBase = alturaTotal * 0.65;

        return Stack(
          children: [
            // ── Mapa dominante ───────────────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: alturaMapaBase,
              child: _MapaPrincipal(
                mapController: _mapController,
                mediciones: _mediciones,
                puntosCalor: _puntosCalor,
                mostrarCalor: _mostrarMapaCalor,
                seleccionado: _seleccionado,
                onSeleccionar: _seleccionar,
                isDark: isDark,
              ),
            ),

            // ── Switch Superior Mapa Calor ──────────────────────────────
            Positioned(
              top: 14,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.topCenter,
                child: GestureDetector(
                  onTap: () => setState(() => _mostrarMapaCalor = !_mostrarMapaCalor),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _mostrarMapaCalor ? const Color(0xFF00C9A7) : (isDark ? const Color(0xCC0B1821) : Colors.black.withValues(alpha: 0.06)),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _mostrarMapaCalor ? Colors.transparent : (isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.1))),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.whatshot, size: 16, color: _mostrarMapaCalor ? Colors.white : const Color(0xFF00C9A7)),
                        const SizedBox(width: 6),
                        Text(
                          'Mapa de Calor CO₂',
                          style: TextStyle(
                            color: _mostrarMapaCalor ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Panel inferior deslizable ────────────────────────────────
            Positioned(
              top: alturaMapaBase - 24, // se superpone ligeramente al mapa
              left: 0,
              right: 0,
              bottom: 0,
              child: _PanelInferior(
                seleccionado: _seleccionado,
                onCerrar: () => setState(() => _seleccionado = null),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Mapa principal ────────────────────────────────────────────────────────────

class _MapaPrincipal extends StatelessWidget {
  final MapController mapController;
  final List<Sensor> mediciones;
  final List<Map<String, dynamic>> puntosCalor;
  final bool mostrarCalor;
  final Sensor? seleccionado;
  final ValueChanged<Sensor> onSeleccionar;
  final bool isDark;

  const _MapaPrincipal({
    required this.mapController,
    required this.mediciones,
    required this.puntosCalor,
    required this.mostrarCalor,
    required this.seleccionado,
    required this.onSeleccionar,
    required this.isDark,
  });

  Color _obtenerColorCalor(double valor) {
    // Escala verde-amarillo-rojo según calidad del aire
    // Verde (bueno) -> Amarillo (moderado) -> Rojo (malo)
    if (valor <= 400) return const Color(0xFF00C9A7); // Verde
    if (valor <= 700) {
      double t = (valor - 400) / 300;
      // Transición de Verde a Amarillo
      return Color.lerp(const Color(0xFF00C9A7), const Color(0xFFFFC857), t)!;
    }
    // >700: Transición de Amarillo a Rojo (sin límite superior)
    double t = (valor - 700) / 400;
    // Saturar en 1.0 para valores muy altos
    if (t > 1.0) t = 1.0;
    return Color.lerp(const Color(0xFFFFC857), const Color(0xFFFF6B6B), t)!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(28)),
        child: Stack(
          children: [
            // Mapa
            FlutterMap(
              mapController: mapController,
              options: const MapOptions(
                initialCenter: LatLng(10.46314, -73.25322),
                initialZoom: 13,
                interactionOptions: InteractionOptions(
                  flags:
                      InteractiveFlag.drag |
                      InteractiveFlag.pinchZoom |
                      InteractiveFlag.doubleTapZoom,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.calidadaire.valledupar',
                  maxZoom: 19,
                ),
                // Círculo alrededor del punto seleccionado
                if (seleccionado != null)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: seleccionado!.posicion,
                        radius: 350,
                        useRadiusInMeter: true,
                        color: seleccionado!.colorEstado.withValues(
                          alpha: 0.15,
                        ),
                        borderColor: seleccionado!.colorEstado.withValues(
                          alpha: 0.55,
                        ),
                        borderStrokeWidth: 1.5,
                      ),
                    ],
                  ),
                // Capa de Mapa de Calor
                if (mostrarCalor)
                  CircleLayer(
                    circles: puntosCalor.expand((pt) {
                      final val = (pt['valor'] as num).toDouble();
                      final peso = (pt['peso'] as num).toDouble();
                      final color = _obtenerColorCalor(val);
                      final radioBase = peso == 1.0 ? 400.0 : 550.0;
                      final baseAlpha = peso == 1.0 ? 0.20 : 0.08;

                      return [
                        // Capa exterior para efecto de resplandor (Glow) muy tenue
                        CircleMarker(
                          point: LatLng(pt['lat'] as double, pt['lng'] as double),
                          radius: radioBase * 2.2,
                          useRadiusInMeter: true,
                          color: color.withValues(alpha: baseAlpha * 0.3),
                          borderColor: Colors.transparent,
                          borderStrokeWidth: 0,
                        ),
                        // Núcleo del calor con opacidad reducida
                        CircleMarker(
                          point: LatLng(pt['lat'] as double, pt['lng'] as double),
                          radius: radioBase,
                          useRadiusInMeter: true,
                          color: color.withValues(alpha: baseAlpha),
                          borderColor: Colors.transparent,
                          borderStrokeWidth: 0,
                        ),
                      ];
                    }).toList(),
                  ),
                // Marcadores Regulares
                if (!mostrarCalor)
                  MarkerLayer(
                    markers: mediciones
                      .map(
                        (s) => Marker(
                          point: s.posicion,
                          width: 110,
                          height: 62,
                          alignment: Alignment.topCenter,
                          child: MarcadorSensor(
                            sensor: s,
                            seleccionado: seleccionado?.id == s.id,
                            onTap: () => onSeleccionar(s),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),

            // Chip ubicación — esquina superior izquierda
            Positioned(
              top: 14,
              left: 14,
              child: _ChipMapa(
                icono: Icons.location_on_outlined,
                texto: 'Valledupar · Cesar',
                isDark: isDark,
              ),
            ),

            // Chip puntos — esquina superior derecha
            Positioned(
              top: 14,
              right: 14,
              child: _ChipMapa(
                icono: Icons.pin_drop_outlined,
                texto: '${mediciones.length} puntos',
                fondo: isDark ? const Color(0xCC103746) : Colors.black.withValues(alpha: 0.06),
                isDark: isDark,
              ),
            ),

            // Botones zoom — esquina inferior derecha
            Positioned(
              right: 14,
              bottom: 48,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _BotonZoom(
                    icono: Icons.add,
                    onTap: () => mapController.move(
                      mapController.camera.center,
                      mapController.camera.zoom + 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _BotonZoom(
                    icono: Icons.remove,
                    onTap: () => mapController.move(
                      mapController.camera.center,
                      mapController.camera.zoom - 1,
                    ),
                  ),
                ],
              ),
            ),

            // Degradado inferior para transición suave al panel
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 48,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      isDark 
                          ? const Color(0xFF0F2027).withValues(alpha: 0.85)
                          : theme.scaffoldBackgroundColor.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Panel inferior con tarjetas ───────────────────────────────────────────────

class _PanelInferior extends StatelessWidget {
  final Sensor? seleccionado;
  final VoidCallback onCerrar;

  const _PanelInferior({required this.seleccionado, required this.onCerrar});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final promedio = SensorServicio.promedio;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        physics: const BouncingScrollPhysics(),
        children: [
          // Handle visual
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Tarjeta fija de promedio
          TarjetaMedicion(
            sensor: promedio,
            etiquetaSecundaria: 'Basado en todos los puntos medidos',
            icono: Icons.public_rounded,
          ),

          // Tarjeta dinámica del punto seleccionado
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: seleccionado != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Container(
                            width: 3,
                            height: 16,
                            decoration: BoxDecoration(
                              color: seleccionado!.colorEstado,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Punto seleccionado',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: onCerrar,
                            child: Icon(
                              Icons.close_rounded,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: TarjetaMedicion(
                          key: ValueKey(seleccionado!.id),
                          sensor: seleccionado!,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SeccionIA(idSensor: seleccionado!.id),
                    ],
                  )
                : const SizedBox.shrink(),
          ),

          if (seleccionado == null) ...[
            const SizedBox(height: 14),
            Center(
              child: Text(
                'Toca un punto del mapa para ver sus datos',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Widgets auxiliares del mapa ───────────────────────────────────────────────

class _ChipMapa extends StatelessWidget {
  final IconData icono;
  final String texto;
  final Color? fondo;
  final bool isDark;
  const _ChipMapa({
    required this.icono,
    required this.texto,
    this.fondo,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: fondo ?? (isDark ? const Color(0xCC0B1821) : Colors.black.withValues(alpha: 0.06)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 13, color: const Color(0xFF00C9A7)),
          const SizedBox(width: 5),
          Text(
            texto,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BotonZoom extends StatelessWidget {
  final IconData icono;
  final VoidCallback onTap;
  const _BotonZoom({required this.icono, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xEE0B1821) : Colors.black.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.12)),
          boxShadow: isDark ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ] : [],
        ),
        child: Icon(icono, color: theme.colorScheme.onSurface, size: 20),
      ),
    );
  }
}

class _SeccionIA extends StatefulWidget {
  final String idSensor;
  const _SeccionIA({required this.idSensor});

  @override
  State<_SeccionIA> createState() => _SeccionIAState();
}

class _SeccionIAState extends State<_SeccionIA> {
  Map<String, dynamic>? _prediccion;
  bool _cargando = false;

  Future<void> _obtenerPrediccion() async {
    setState(() => _cargando = true);
    final res = await PrediccionServicio.predecir(widget.idSensor);
    if (mounted) {
      setState(() {
        _prediccion = res;
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF00C9A7).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF00C9A7).withValues(alpha: 0.20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_outlined, color: Color(0xFF00C9A7), size: 20),
              const SizedBox(width: 8),
              Text(
                'Análisis Predictivo (IA)',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (_prediccion == null && !_cargando)
                GestureDetector(
                  onTap: _obtenerPrediccion,
                  child: const Text(
                    'Calcular',
                    style: TextStyle(
                      color: Color(0xFF00C9A7),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          if (_cargando)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                color: Color(0xFF00C9A7),
              ),
            ),
          if (_prediccion != null) ...[
            const SizedBox(height: 12),
            Text(
              'En las próximas horas el nivel de CO₂ podría ser:',
              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _prediccion!['valor_predicho'] != null
                      ? '${(_prediccion!['valor_predicho'] as num).toStringAsFixed(0)} ppm'
                      : 'No disponible',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _prediccion!['nivel_riesgo'] == 'Bajo'
                        ? Colors.green.withValues(alpha: 0.2)
                        : _prediccion!['nivel_riesgo'] == null
                            ? Colors.grey.withValues(alpha: 0.2)
                            : Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _prediccion!['nivel_riesgo'] != null
                        ? 'Riesgo ${_prediccion!['nivel_riesgo']}'
                        : 'Sin datos',
                    style: TextStyle(
                      color: _prediccion!['nivel_riesgo'] == 'Bajo'
                          ? Colors.greenAccent
                          : _prediccion!['nivel_riesgo'] == null
                              ? Colors.grey
                              : Colors.orangeAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (_prediccion!['valor_predicho'] == null || _prediccion!['nivel_riesgo'] == null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 12,
                    color: Colors.orange.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Datos insuficientes. Entrena el modelo para mejorar predicciones.',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}
