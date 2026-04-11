import 'package:flutter/material.dart';
import '../../modulos/educacion/vistas/educacion_contenido.dart';
import '../../modulos/estadisticas/vistas/estadisticas_contenido.dart';
import '../../modulos/mapa/vistas/mapa_contenido.dart';

/// Shell principal de la app.
/// Mantiene el header y la navbar SIEMPRE visibles.
/// El contenido cambia con IndexedStack (sin recargar widgets).
class AppShell extends StatefulWidget {
  final int tabInicial;
  const AppShell({super.key, this.tabInicial = 0});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _tabActual;

  static const _titulos = ['Calidad del Aire', 'Mapa', 'Estadísticas'];
  static const _subtitulo = 'Valledupar, Cesar';

  @override
  void initState() {
    super.initState();
    _tabActual = widget.tabInicial;
  }

  void _cambiarTab(int index) {
    if (_tabActual == index) return;
    setState(() => _tabActual = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header global persistente ───────────────────────────────
            _Header(titulo: _titulos[_tabActual], subtitulo: _subtitulo),

            // ── Contenido del tab activo ────────────────────────────────
            Expanded(
              child: IndexedStack(
                index: _tabActual,
                children: const [
                  _ContenidoInicio(),
                  _ContenidoMapa(),
                  _ContenidoEstadisticas(),
                ],
              ),
            ),
          ],
        ),
      ),
      // ── Navbar global persistente ─────────────────────────────────────
      bottomNavigationBar: _Navbar(
        tabActual: _tabActual,
        onTabChanged: _cambiarTab,
      ),
    );
  }
}

// ── Wrappers de contenido (sin header ni navbar propios) ──────────────────────

class _ContenidoInicio extends StatelessWidget {
  const _ContenidoInicio();
  @override
  Widget build(BuildContext context) => const EducacionContenido();
}

class _ContenidoMapa extends StatelessWidget {
  const _ContenidoMapa();
  @override
  Widget build(BuildContext context) => const MapaContenido();
}

class _ContenidoEstadisticas extends StatelessWidget {
  const _ContenidoEstadisticas();
  @override
  Widget build(BuildContext context) => const EstadisticasContenido();
}

// ── Header global ─────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  const _Header({required this.titulo, required this.subtitulo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Align(
                key: ValueKey(titulo),
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
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
            ),
          ),
          // Notificaciones
          _BotonHeader(
            icono: Icons.notifications_none_rounded,
            badge: true,
            onTap: () => _mostrarNotificaciones(context),
          ),
          const SizedBox(width: 8),
          // Perfil
          _BotonHeader(
            icono: Icons.person_outline_rounded,
            onTap: () => _mostrarPerfil(context),
          ),
        ],
      ),
    );
  }

  void _mostrarNotificaciones(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _ModalNotificaciones(),
    );
  }

  void _mostrarPerfil(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _ModalPerfil(),
    );
  }
}

class _BotonHeader extends StatelessWidget {
  final IconData icono;
  final VoidCallback onTap;
  final bool badge;
  const _BotonHeader({
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
                top: 9,
                right: 9,
                child: Container(
                  width: 7,
                  height: 7,
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

// ── Navbar global ─────────────────────────────────────────────────────────────

class _Navbar extends StatelessWidget {
  final int tabActual;
  final ValueChanged<int> onTabChanged;
  const _Navbar({required this.tabActual, required this.onTabChanged});

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
            _ItemNav(
              icono: Icons.home_rounded,
              texto: 'Inicio',
              activo: tabActual == 0,
              onTap: () => onTabChanged(0),
            ),
            _ItemNav(
              icono: Icons.map_outlined,
              texto: 'Mapa',
              activo: tabActual == 1,
              onTap: () => onTabChanged(1),
            ),
            _ItemNav(
              icono: Icons.bar_chart_rounded,
              texto: 'Estadísticas',
              activo: tabActual == 2,
              onTap: () => onTabChanged(2),
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
  final VoidCallback onTap;
  const _ItemNav({
    required this.icono,
    required this.texto,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = activo ? const Color(0xFF00C9A7) : Colors.white60;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
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

// ── Modales (notificaciones y perfil) ─────────────────────────────────────────

class _ModalNotificaciones extends StatelessWidget {
  const _ModalNotificaciones();

  @override
  Widget build(BuildContext context) {
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
          const Row(
            children: [
              Icon(
                Icons.notifications_rounded,
                color: Color(0xFF00C9A7),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Notificaciones',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ItemAlerta(
            icono: Icons.warning_rounded,
            color: const Color(0xFFFF6B6B),
            zona: 'La Nevada',
            mensaje: 'Alta contaminación detectada (CO₂: 950 ppm)',
          ),
          _ItemAlerta(
            icono: Icons.info_outline_rounded,
            color: const Color(0xFFFFC857),
            zona: 'Novalito',
            mensaje: 'Nivel moderado de PM2.5 (36 µg/m³)',
          ),
          _ItemAlerta(
            icono: Icons.check_circle_outline_rounded,
            color: const Color(0xFF00C9A7),
            zona: 'Centro Histórico',
            mensaje: 'Calidad del aire en niveles óptimos',
          ),
        ],
      ),
    );
  }
}

class _ItemAlerta extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String zona;
  final String mensaje;
  const _ItemAlerta({
    required this.icono,
    required this.color,
    required this.zona,
    required this.mensaje,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icono, color: color, size: 17),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zona,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  mensaje,
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

class _ModalPerfil extends StatelessWidget {
  const _ModalPerfil();

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
          Container(
            width: 70,
            height: 70,
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
              size: 34,
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
          const SizedBox(height: 18),

          // ── Info adicional ──────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: const Column(
              children: [
                _FilaInfoPerfil(
                  icono: Icons.location_on_outlined,
                  texto: 'Valledupar, Cesar',
                  color: Color(0xFF00C9A7),
                ),
                SizedBox(height: 10),
                _FilaInfoPerfil(
                  icono: Icons.access_time_rounded,
                  texto: 'Última conexión: Hoy, 10:30 AM',
                  color: Color(0xFF7CC6FE),
                ),
                SizedBox(height: 10),
                _FilaInfoPerfil(
                  icono: Icons.circle,
                  texto: 'Usuario activo',
                  color: Color(0xFF00C9A7),
                  esBadge: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
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
                texto: '5 mediciones',
              ),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/');
              },
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

class _FilaInfoPerfil extends StatelessWidget {
  final IconData icono;
  final String texto;
  final Color color;
  final bool esBadge;

  const _FilaInfoPerfil({
    required this.icono,
    required this.texto,
    required this.color,
    this.esBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, color: color, size: esBadge ? 10 : 15),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
        if (esBadge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF00C9A7).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF00C9A7).withValues(alpha: 0.35),
              ),
            ),
            child: const Text(
              'Activo',
              style: TextStyle(
                color: Color(0xFF00C9A7),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
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
