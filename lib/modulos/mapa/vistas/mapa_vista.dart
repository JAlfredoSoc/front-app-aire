import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../modelos/sensor.dart';
import '../../../servicios/sensor_servicio.dart';
import '../widgets/marcador_sensor.dart';
import '../widgets/tarjetas_sensor.dart';

/// Vista del historial de mediciones en mapa.
/// Cada punto representa una medición realizada por el sensor físico.
class MapaVista extends StatefulWidget {
  const MapaVista({super.key});

  @override
  State<MapaVista> createState() => _MapaVistaState();
}

class _MapaVistaState extends State<MapaVista> {
  static const _centro = LatLng(10.46314, -73.25322);
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
    final datos = _seleccionado ?? SensorServicio.promedio;

    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      body: SafeArea(
        child: Column(
          children: [
            // ── Encabezado ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Historial de Mediciones',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Valledupar, Cesar',
                          style: TextStyle(
                            color: Color(0xFF00C9A7),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _ChipEncabezado(
                    icono: Icons.pin_drop_outlined,
                    texto: '${_mediciones.length} puntos',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Mapa ────────────────────────────────────────────────────
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: const MapOptions(
                          initialCenter: _centro,
                          initialZoom: 13,
                          interactionOptions: InteractionOptions(
                            flags:
                                InteractiveFlag.drag |
                                InteractiveFlag.pinchZoom |
                                InteractiveFlag.doubleTapZoom,
                          ),
                        ),
                        children: [
                          // Proveedor HOT — más estable, evita bloqueos de OSM
                          TileLayer(
                            urlTemplate:
                                'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
                            subdomains: const ['a', 'b', 'c'],
                            userAgentPackageName: 'com.calidadaire.valledupar',
                            maxZoom: 19,
                          ),
                          // Círculo alrededor del punto seleccionado
                          if (_seleccionado != null)
                            CircleLayer(
                              circles: [
                                CircleMarker(
                                  point: _seleccionado!.posicion,
                                  radius: 300,
                                  useRadiusInMeter: true,
                                  color: _seleccionado!.colorEstado.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderColor: _seleccionado!.colorEstado
                                      .withValues(alpha: 0.50),
                                  borderStrokeWidth: 1.5,
                                ),
                              ],
                            ),
                          // Puntos de medición interactivos
                          MarkerLayer(
                            markers: _mediciones
                                .map(
                                  (s) => Marker(
                                    point: s.posicion,
                                    width: 100,
                                    height: 60,
                                    alignment: Alignment.topCenter,
                                    child: MarcadorSensor(
                                      sensor: s,
                                      seleccionado: _seleccionado?.id == s.id,
                                      onTap: () => _seleccionar(s),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                      // Chip ubicación
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: _ChipMapa(
                          icono: Icons.location_on_outlined,
                          texto: 'Valledupar · Cesar',
                        ),
                      ),
                      // Botones de zoom
                      Positioned(
                        right: 12,
                        bottom: 60,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _BotonZoom(
                              icono: Icons.add,
                              onTap: () => _mapController.move(
                                _mapController.camera.center,
                                _mapController.camera.zoom + 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _BotonZoom(
                              icono: Icons.remove,
                              onTap: () => _mapController.move(
                                _mapController.camera.center,
                                _mapController.camera.zoom - 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Tarjetas dinámicas ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: TarjetasSensor(
                sensor: datos,
                esSensorSeleccionado: _seleccionado != null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _ChipEncabezado extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _ChipEncabezado({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, color: const Color(0xFF00C9A7), size: 14),
          const SizedBox(width: 5),
          Text(
            texto,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipMapa extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _ChipMapa({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xCC0B1821),
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
              fontWeight: FontWeight.w500,
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
