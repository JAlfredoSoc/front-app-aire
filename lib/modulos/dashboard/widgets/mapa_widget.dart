import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../modelos/sensor.dart';

/// Widget del mapa. Muestra puntos donde el sensor físico tomó mediciones.
/// Al tocar un punto se notifica al padre vía [onSensorTap] — sin navegación.
class MapaWidget extends StatefulWidget {
  final List<Sensor> sensores;
  final Sensor? sensorSeleccionado;
  final ValueChanged<Sensor> onSensorTap;

  const MapaWidget({
    super.key,
    required this.sensores,
    required this.sensorSeleccionado,
    required this.onSensorTap,
  });

  @override
  State<MapaWidget> createState() => _MapaWidgetState();
}

class _MapaWidgetState extends State<MapaWidget> {
  static const _centro = LatLng(10.46314, -73.25322);
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _zoom(double delta) => _mapController.move(
    _mapController.camera.center,
    _mapController.camera.zoom + delta,
  );

  @override
  Widget build(BuildContext context) {
    final sel = widget.sensorSeleccionado;

    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: _centro,
                initialZoom: 13.2,
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
                // Círculo de área alrededor del punto seleccionado
                if (sel != null)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: sel.posicion,
                        radius: 300,
                        useRadiusInMeter: true,
                        color: sel.colorEstado.withValues(alpha: 0.15),
                        borderColor: sel.colorEstado.withValues(alpha: 0.50),
                        borderStrokeWidth: 1.5,
                      ),
                    ],
                  ),
                // Puntos de medición
                MarkerLayer(
                  markers: widget.sensores
                      .map(
                        (s) => Marker(
                          point: s.posicion,
                          width: 100,
                          height: 56,
                          alignment: Alignment.topCenter,
                          child: _MarcadorPunto(
                            sensor: s,
                            seleccionado: sel?.id == s.id,
                            onTap: () => widget.onSensorTap(s),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),

            // Chip: ubicación
            Positioned(
              top: 12,
              left: 12,
              child: _Chip(
                icono: Icons.location_on_outlined,
                texto: 'Valledupar · Cesar',
              ),
            ),

            // Chip: puntos medidos (concepto correcto)
            Positioned(
              top: 12,
              right: 12,
              child: _Chip(
                icono: Icons.pin_drop_outlined,
                texto: '${widget.sensores.length} puntos medidos',
                fondo: const Color(0xCC103746),
              ),
            ),

            // Botones de zoom
            Positioned(
              bottom: 16,
              right: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ZoomBtn(icono: Icons.add, onTap: () => _zoom(1)),
                  const SizedBox(height: 8),
                  _ZoomBtn(icono: Icons.remove, onTap: () => _zoom(-1)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Marcador de punto de medición ─────────────────────────────────────────────

class _MarcadorPunto extends StatelessWidget {
  final Sensor sensor;
  final bool seleccionado;
  final VoidCallback onTap;

  const _MarcadorPunto({
    required this.sensor,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: seleccionado
              ? sensor.colorEstado.withValues(alpha: 0.22)
              : const Color(0xEE0B1821),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: sensor.colorEstado.withValues(
              alpha: seleccionado ? 1.0 : 0.65,
            ),
            width: seleccionado ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: sensor.colorEstado.withValues(
                alpha: seleccionado ? 0.40 : 0.18,
              ),
              blurRadius: seleccionado ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.pin_drop_outlined,
                  size: 12,
                  color: sensor.colorEstado,
                ),
                const SizedBox(width: 4),
                Text(
                  '${sensor.co2.toStringAsFixed(0)} ppm',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              sensor.zona,
              style: const TextStyle(color: Colors.white60, fontSize: 9),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final IconData icono;
  final String texto;
  final Color fondo;

  const _Chip({
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

class _ZoomBtn extends StatelessWidget {
  final IconData icono;
  final VoidCallback onTap;
  const _ZoomBtn({required this.icono, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xCC0B1821),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Icon(icono, color: Colors.white, size: 20),
      ),
    );
  }
}
