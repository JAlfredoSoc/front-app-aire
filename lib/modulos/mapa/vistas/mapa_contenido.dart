import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../modelos/sensor.dart';
import '../../../servicios/sensor_servicio.dart';
import '../../../widgets/comunes/tarjeta_medicion.dart';
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
  final List<Sensor> _mediciones = SensorServicio.mediciones;
  Sensor? _seleccionado;

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
                seleccionado: _seleccionado,
                onSeleccionar: _seleccionar,
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
  final Sensor? seleccionado;
  final ValueChanged<Sensor> onSeleccionar;

  const _MapaPrincipal({
    required this.mapController,
    required this.mediciones,
    required this.seleccionado,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
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
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
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
                // Marcadores
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
              ),
            ),

            // Chip puntos — esquina superior derecha
            Positioned(
              top: 14,
              right: 14,
              child: _ChipMapa(
                icono: Icons.pin_drop_outlined,
                texto: '${mediciones.length} puntos',
                fondo: const Color(0xCC103746),
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
                      const Color(0xFF0F2027).withValues(alpha: 0.85),
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
    final promedio = SensorServicio.promedio;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F2027),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                color: Colors.white.withValues(alpha: 0.20),
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
                          const Text(
                            'Punto seleccionado',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: onCerrar,
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white38,
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
                  color: Colors.white.withValues(alpha: 0.30),
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
  final Color fondo;
  const _ChipMapa({
    required this.icono,
    required this.texto,
    this.fondo = const Color(0xCC0B1821),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 13, color: const Color(0xFF00C9A7)),
          const SizedBox(width: 5),
          Text(
            texto,
            style: const TextStyle(
              color: Colors.white70,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xCC0B1821),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icono, color: Colors.white, size: 20),
      ),
    );
  }
}
