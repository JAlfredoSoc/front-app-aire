import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../modelos/alerta.dart' as alerta_model;
import '../../servicios/alerta_servicio.dart';
import '../../servicios/auth_servicio.dart';
import '../../servicios/tema_servicio.dart';
import '../../servicios/biometrico_servicio.dart';
import '../../auth/widgets/biometrico_dialogo.dart';
import '../../modulos/educacion/vistas/educacion_contenido.dart';
import '../../modulos/estadisticas/vistas/estadisticas_contenido.dart';
import '../../modulos/mapa/vistas/mapa_contenido.dart';
import '../../servicios/prediccion_servicio.dart';
import '../../main.dart' show AirMonitorAppState;
import '../../core/tema/colores.dart';

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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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

class _Header extends StatefulWidget {
  final String titulo;
  final String subtitulo;
  const _Header({required this.titulo, required this.subtitulo});

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  bool _esOscuro = true;

  @override
  void initState() {
    super.initState();
    _cargarEstadoTema();
  }

  Future<void> _cargarEstadoTema() async {
    final oscuro = await TemaServicio.esOscuro();
    if (mounted) {
      setState(() {
        _esOscuro = oscuro;
      });
    }
  }

  Future<void> _alternarTema() async {
    final nuevoEstado = !_esOscuro;
    await TemaServicio.cambiarTema(nuevoEstado);
    if (mounted) {
      setState(() {
        _esOscuro = nuevoEstado;
      });
      // Notificar al AirMonitorApp que el tema cambió
      final appState = context.findAncestorStateOfType<AirMonitorAppState>();
      appState?.actualizarTema();
    }
  }

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
                key: ValueKey(widget.titulo),
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.titulo,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Valledupar, Cesar',
                      style: TextStyle(
                        color: AppColores.verde,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Toggle tema
          _BotonHeader(
            icono: _esOscuro ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            onTap: _alternarTema,
          ),
          const SizedBox(width: 8),
          // Notificaciones
          _BotonHeader(
            icono: Icons.notifications_none_rounded,
            badge: AlertaServicio.hayAlertasNuevas,
            onTap: () {
              _mostrarNotificaciones(context);
              // Refrescar UI para quitar el badge
              if (mounted) setState(() {});
            },
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
    // Marcar alertas como leídas (quita el badge rojo)
    AlertaServicio.marcarAlertasLeidas();

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark 
                ? Colors.white.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.10),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icono, color: theme.colorScheme.onSurface, size: 22),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF112A34) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark 
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.08),
          ),
          boxShadow: isDark ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ] : [],
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
    final theme = Theme.of(context);
    final color = activo ? AppColores.verde : theme.colorScheme.onSurface.withValues(alpha: 0.6);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: activo ? AppColores.verde.withValues(alpha: 0.12) : Colors.transparent,
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
    // Alertas del polling (backend)
    final alertas = AlertaServicio.alertas;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF112A34) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                color: isDark 
                    ? Colors.white.withValues(alpha: 0.20)
                    : Colors.black.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(
                Icons.notifications_rounded,
                color: AppColores.verde,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Notificaciones',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Alertas del sistema (backend)
          if (alertas.isNotEmpty)
            ...alertas.map((a) => _ItemAlerta(
                  icono: a.estado == alerta_model.EstadoAire.alta
                      ? Icons.warning_rounded
                      : Icons.info_outline_rounded,
                  color: a.estado == alerta_model.EstadoAire.alta
                      ? const Color(0xFFFF6B6B)
                      : const Color(0xFFFFC857),
                  zona: a.zona,
                  mensaje: a.mensaje,
                ))
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No hay alertas activas en este momento',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
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
    final theme = Theme.of(context);
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
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  mensaje,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
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

class _ModalPerfil extends StatefulWidget {
  const _ModalPerfil();

  @override
  State<_ModalPerfil> createState() => _ModalPerfilState();
}

class _ModalPerfilState extends State<_ModalPerfil> {
  String _nombre = 'Cargando...';
  String _email = '...';
  String _ultimaConexion = '...';

  bool _entrenando = false;
  bool _tieneHuella = false;
  bool _cargandoHuella = false;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
    _verificarHuella();
  }

  Future<void> _cargarPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _nombre = prefs.getString('user_nombre') ?? 'Usuario';
        _email = prefs.getString('user_email') ?? 'sin-correo@app.com';
        _ultimaConexion = _formatearUltimaConexion(
          prefs.getString('user_ultima_conexion'),
        );
      });
    }
  }

  String _formatearUltimaConexion(String? isoTimestamp) {
    if (isoTimestamp == null || isoTimestamp.isEmpty) {
      return 'No disponible';
    }
    try {
      final fecha = DateTime.parse(isoTimestamp);
      final ahora = DateTime.now();
      final diferencia = ahora.difference(fecha);

      if (diferencia.inMinutes < 1) {
        return 'Hace un momento';
      } else if (diferencia.inHours < 1) {
        return 'Hace ${diferencia.inMinutes} min';
      } else if (diferencia.inDays < 1) {
        return 'Hoy, ${_formatearHora(fecha)}';
      } else if (diferencia.inDays == 1) {
        return 'Ayer, ${_formatearHora(fecha)}';
      } else {
        return '${fecha.day}/${fecha.month}/${fecha.year}, ${_formatearHora(fecha)}';
      }
    } catch (e) {
      return 'No disponible';
    }
  }

  String _formatearHora(DateTime fecha) {
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');
    return '$hora:$minuto';
  }

  Future<void> _verificarHuella() async {
    final tieneHuella = await BiometricoServicio.estaHabilitado();
    if (mounted) {
      setState(() {
        _tieneHuella = tieneHuella;
      });
    }
  }

  Future<void> _toggleHuella() async {
    if (_cargandoHuella) return;

    setState(() => _cargandoHuella = true);

    if (_tieneHuella) {
      // Deshabilitar huella
      final uid = await AuthServicio.obtenerUid();
      if (uid != null && mounted) {
        final exito = await BiometricoDialogo.mostrarDeshabilitar(
          context: context,
          uid: uid,
        );
        if (exito && mounted) {
          setState(() => _tieneHuella = false);
        }
      }
    } else {
      // Habilitar huella
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('jwt_token');
      final uid = prefs.getString('user_uid');

      if (accessToken != null && uid != null && mounted) {
        final exito = await BiometricoDialogo.mostrarOfrecimiento(
          context: context,
          accessToken: accessToken,
          uid: uid,
        );
        if (exito && mounted) {
          setState(() => _tieneHuella = true);
        }
      }
    }

    setState(() => _cargandoHuella = false);
  }

  Future<void> _ejecutarEntrenamiento() async {
    setState(() => _entrenando = true);
    final resultado = await PrediccionServicio.entrenarModelo();
    if (mounted) {
      setState(() => _entrenando = false);
      
      String mensaje = resultado['mensaje'] ?? 'Error al entrenar';
      if (resultado.containsKey('error')) mensaje = resultado['error'];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: resultado.containsKey('error') ? Colors.redAccent : const Color(0xFF00C9A7),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF112A34) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                color: isDark 
                    ? Colors.white.withValues(alpha: 0.20)
                    : Colors.black.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColores.verde.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColores.verde.withValues(alpha: 0.40),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.person_rounded,
              color: AppColores.verde,
              size: 34,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _nombre,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _email,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          
          // --- BOTÓN DE ENTRENAMIENTO IA ---
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _entrenando ? null : _ejecutarEntrenamiento,
              icon: _entrenando 
                  ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColores.verde))
                  : Icon(Icons.auto_awesome_rounded, color: AppColores.verde, size: 18),
              label: Text(
                _entrenando ? 'Entrenando Cerebro...' : 'Actualizar IA con datos reales',
                style: TextStyle(color: AppColores.verde, fontSize: 14),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: AppColores.verde.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // --- BOTÓN DE HUELLA DIGITAL ---
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _cargandoHuella ? null : _toggleHuella,
              icon: _cargandoHuella
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(
                      _tieneHuella ? Icons.fingerprint : Icons.fingerprint_outlined,
                      size: 18,
                    ),
              label: Text(
                _tieneHuella ? 'Desactivar huella digital' : 'Activar huella digital',
                style: const TextStyle(fontSize: 14),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          Divider(color: isDark ? Colors.white10 : Colors.black12),
          const SizedBox(height: 12),

          // ── Info adicional ──────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark 
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark 
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              children: [
                _FilaInfoPerfil(
                  icono: Icons.location_on_outlined,
                  texto: 'Valledupar, Cesar',
                  color: AppColores.verde,
                ),
                const SizedBox(height: 10),
                _FilaInfoPerfil(
                  icono: Icons.access_time_rounded,
                  texto: 'Última conexión: $_ultimaConexion',
                  color: AppColores.azul,
                ),
                const SizedBox(height: 10),
                _FilaInfoPerfil(
                  icono: Icons.circle,
                  texto: 'Usuario activo',
                  color: AppColores.verde,
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
              onPressed: () async {
                await AuthServicio.logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                }
              },
              icon: Icon(
                Icons.logout_rounded,
                color: AppColores.rojo,
                size: 18,
              ),
              label: Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: AppColores.rojo,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppColores.rojo.withValues(alpha: 0.10),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: AppColores.rojo.withValues(alpha: 0.25),
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
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icono, color: color, size: esBadge ? 10 : 15),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texto,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
        ),
        if (esBadge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: AppColores.verde.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColores.verde.withValues(alpha: 0.35),
              ),
            ),
            child: Text(
              'Activo',
              style: TextStyle(
                color: AppColores.verde,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.white.withValues(alpha: 0.07)
            : Colors.black.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.black.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, color: AppColores.verde, size: 14),
          const SizedBox(width: 6),
          Text(
            texto,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
