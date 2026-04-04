import 'package:flutter/material.dart';

import '../../../core/rutas/app_rutas.dart';
import '../../../modelos/sensor.dart';
import '../../../servicios/sensor_servicio.dart';
import '../../../widgets/layout/contenedor_base.dart';
import '../widgets/mapa_widget.dart';
import '../widgets/tarjeta_indicador.dart';

class InicioVista extends StatefulWidget {
  const InicioVista({super.key});

  @override
  State<InicioVista> createState() => _InicioVistaState();
}

class _InicioVistaState extends State<InicioVista> {
  // null = mostrar promedio general; distinto de null = sensor seleccionado
  Sensor? _sensorSeleccionado;

  // Lista fija de sensores (sin Timer, sin Stream)
  final List<Sensor> _sensores = SensorServicio.sensores;

  void _onSensorTap(Sensor sensor) {
    setState(() {
      _sensorSeleccionado = _sensorSeleccionado?.id == sensor.id
          ? null
          : sensor;
    });
  }

  // ── Modal de notificaciones ───────────────────────────────────────────────
  void _mostrarNotificaciones() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _ModalNotificaciones(),
    );
  }

  // ── Modal de perfil ───────────────────────────────────────────────────────
  void _mostrarPerfil() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ModalPerfil(
        onCerrarSesion: () {
          Navigator.pop(context); // cierra el modal
          Navigator.pushReplacementNamed(context, AppRutas.login);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Datos a mostrar: sensor seleccionado o promedio general
    final datos = _sensorSeleccionado ?? SensorServicio.promedio;

    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      body: ContenedorBase(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Encabezado ──────────────────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Calidad del Aire',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  height: 1.1,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Valledupar, Cesar',
                                style: TextStyle(
                                  color: Color(0xFF00C9A7),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Botón notificaciones
                        _BotonEncabezado(
                          icono: Icons.notifications_none_rounded,
                          badge: true,
                          onTap: _mostrarNotificaciones,
                        ),
                        const SizedBox(width: 8),
                        // Botón perfil
                        _BotonEncabezado(
                          icono: Icons.person_outline_rounded,
                          onTap: _mostrarPerfil,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Mapa ────────────────────────────────────────────
                    MapaWidget(
                      sensores: _sensores,
                      sensorSeleccionado: _sensorSeleccionado,
                      onSensorTap: _onSensorTap,
                    ),

                    const SizedBox(height: 14),

                    // ── Leyenda ─────────────────────────────────────────
                    _Leyenda(totalPuntos: _sensores.length),

                    const SizedBox(height: 20),

                    // ── Título dinámico ─────────────────────────────────
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: Align(
                        key: ValueKey(_sensorSeleccionado?.id ?? 'general'),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _sensorSeleccionado != null
                                  ? _sensorSeleccionado!.zona
                                  : 'Indicadores generales',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _sensorSeleccionado != null
                                  ? 'Toca el punto de nuevo para deseleccionar'
                                  : 'Promedio de ${_sensores.length} puntos medidos',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.45),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Tarjetas dinámicas ───────────────────────────────
                    _TarjetasDinamicas(datos: datos),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const _BarraInferior(),
    );
  }
}

// ── Tarjetas reactivas ────────────────────────────────────────────────────────

class _TarjetasDinamicas extends StatelessWidget {
  final Sensor datos;
  const _TarjetasDinamicas({required this.datos});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOut,
      child: LayoutBuilder(
        key: ValueKey(datos.id),
        builder: (context, c) {
          final w = (c.maxWidth - 12) / 2;
          final dos = c.maxWidth >= 360;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: dos ? w : c.maxWidth,
                child: TarjetaIndicador(
                  icono: Icons.co2_rounded,
                  etiqueta: 'CO₂',
                  valor: '${datos.co2.toStringAsFixed(0)} ppm',
                  descripcion: datos.zona,
                  color: datos.colorEstado,
                ),
              ),
              SizedBox(
                width: dos ? w : c.maxWidth,
                child: TarjetaIndicador(
                  icono: Icons.blur_on_rounded,
                  etiqueta: 'PM2.5',
                  valor: '${datos.pm25.toStringAsFixed(1)} µg/m³',
                  descripcion: 'Estado: ${datos.etiquetaEstado}',
                  color: const Color(0xFFFFC857),
                ),
              ),
              SizedBox(
                width: c.maxWidth,
                child: TarjetaIndicador(
                  icono: Icons.thermostat_rounded,
                  etiqueta: 'Temperatura',
                  valor: '${datos.temperatura.toStringAsFixed(1)} °C',
                  descripcion: 'Zona: ${datos.zona}',
                  color: const Color(0xFF7CC6FE),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Leyenda de estados ────────────────────────────────────────────────────────

class _Leyenda extends StatelessWidget {
  final int totalPuntos;
  const _Leyenda({required this.totalPuntos});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Wrap(
        spacing: 14,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _ItemLeyenda(color: const Color(0xFF00C9A7), texto: 'Buena'),
          _ItemLeyenda(color: const Color(0xFFFFC857), texto: 'Moderada'),
          _ItemLeyenda(color: const Color(0xFFFF6B6B), texto: 'Alta'),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.pin_drop_outlined,
                color: Color(0xFF00C9A7),
                size: 13,
              ),
              const SizedBox(width: 4),
              Text(
                '$totalPuntos datos recolectados',
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemLeyenda extends StatelessWidget {
  final Color color;
  final String texto;
  const _ItemLeyenda({required this.color, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          texto,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Botón del encabezado ──────────────────────────────────────────────────────

class _BotonEncabezado extends StatelessWidget {
  final IconData icono;
  final VoidCallback onTap;
  final bool badge;

  const _BotonEncabezado({
    required this.icono,
    required this.onTap,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icono, color: Colors.white, size: 22),
            if (badge)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6B6B),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Modal de notificaciones ───────────────────────────────────────────────────

class _ModalNotificaciones extends StatelessWidget {
  const _ModalNotificaciones();

  @override
  Widget build(BuildContext context) {
    final alertas = SensorServicio.alertas;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF112A34),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(
                Icons.notifications_rounded,
                color: Color(0xFF00C9A7),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Notificaciones',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${alertas.length}',
                  style: const TextStyle(
                    color: Color(0xFFFF6B6B),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...alertas.map((a) => _ItemAlerta(alerta: a)),
        ],
      ),
    );
  }
}

class _ItemAlerta extends StatelessWidget {
  final dynamic alerta;
  const _ItemAlerta({required this.alerta});

  @override
  Widget build(BuildContext context) {
    final color = alerta.nivel == EstadoAire.alta
        ? const Color(0xFFFF6B6B)
        : alerta.nivel == EstadoAire.moderada
        ? const Color(0xFFFFC857)
        : const Color(0xFF00C9A7);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              alerta.nivel == EstadoAire.alta
                  ? Icons.warning_rounded
                  : alerta.nivel == EstadoAire.moderada
                  ? Icons.info_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alerta.zona,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alerta.mensaje,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Modal de perfil ───────────────────────────────────────────────────────────

class _ModalPerfil extends StatelessWidget {
  final VoidCallback onCerrarSesion;
  const _ModalPerfil({required this.onCerrarSesion});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF112A34),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Avatar
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF00C9A7).withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF00C9A7).withValues(alpha: 0.40),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFF00C9A7),
              size: 36,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'José Maestre',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'jose.maestre@correo.com',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 24),
          // Info chips
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ChipPerfil(
                icono: Icons.location_city_rounded,
                texto: 'Valledupar',
              ),
              const SizedBox(width: 10),
              _ChipPerfil(
                icono: Icons.pin_drop_outlined,
                texto: '${SensorServicio.mediciones.length} mediciones',
              ),
            ],
          ),
          const SizedBox(height: 28),
          // Botón cerrar sesión
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: onCerrarSesion,
              icon: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFFF6B6B),
                size: 18,
              ),
              label: const Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: Color(0xFFFF6B6B),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: const Color(
                  0xFFFF6B6B,
                ).withValues(alpha: 0.10),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.25),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipPerfil extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _ChipPerfil({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, color: const Color(0xFF00C9A7), size: 14),
          const SizedBox(width: 6),
          Text(
            texto,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ── Barra de navegación inferior ─────────────────────────────────────────────

class _BarraInferior extends StatelessWidget {
  const _BarraInferior();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF112A34),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            const _ItemNav(
              icono: Icons.home_rounded,
              texto: 'Inicio',
              activo: true,
            ),
            _ItemNav(
              icono: Icons.map_outlined,
              texto: 'Mapa',
              onTap: () => Navigator.pushNamed(context, AppRutas.mapa),
            ),
            const _ItemNav(
              icono: Icons.bar_chart_rounded,
              texto: 'Estadísticas',
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemNav extends StatelessWidget {
  final IconData icono;
  final String texto;
  final bool activo;
  final VoidCallback? onTap;

  const _ItemNav({
    required this.icono,
    required this.texto,
    this.activo = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = activo ? const Color(0xFF00C9A7) : Colors.white60;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: activo ? const Color(0x1400C9A7) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                texto,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
