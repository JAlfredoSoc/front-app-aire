import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/rutas/app_rutas.dart';
import '../../core/tema/colores.dart';
import '../../core/tema/tema_app.dart';
import '../../main.dart';
import '../../servicios/auth_servicio.dart';
import '../../servicios/biometrico_servicio.dart';
import '../../servicios/tema_servicio.dart';
import '../../widgets/botones/boton_principal.dart';
import '../../widgets/inputs/input_texto.dart';
import 'huella_boton.dart';
import 'biometrico_dialogo.dart';

class FormularioLogin extends StatefulWidget {
  const FormularioLogin({super.key});

  @override
  State<FormularioLogin> createState() => _FormularioLoginState();
}

class _FormularioLoginState extends State<FormularioLogin> {
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _cargando = false;
  bool _esOscuro = true;

  @override
  void initState() {
    super.initState();
    _cargarTema();
  }

  Future<void> _cargarTema() async {
    final tema = await TemaServicio.temaActual();
    if (mounted) {
      setState(() {
        _esOscuro = tema == TemaApp.oscuro;
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

  Future<void> _intentoLogin() async {
    final email = _correoController.text.trim();
    final pass = _passwordController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      _mostrarError('Por favor, llena todos los campos');
      return;
    }

    setState(() => _cargando = true);

    final exito = await AuthServicio.login(email, pass);

    if (mounted) {
      setState(() => _cargando = false);
      if (exito) {
        // Obtener token y uid para posible configuración de huella
        final prefs = await SharedPreferences.getInstance();
        final accessToken = prefs.getString('jwt_token');
        final uid = prefs.getString('user_uid');

        // Verificar si ya tiene huella habilitada
        final tieneHuella = await BiometricoServicio.estaHabilitado();

        // Verificar si ya mostramos el diálogo hoy (una vez por día)
        final hoy = DateTime.now();
        final ultimaFechaStr = prefs.getString('biometrico_ofrecimiento_fecha');
        final yaMostroHoy = ultimaFechaStr != null &&
            DateTime.parse(ultimaFechaStr).day == hoy.day &&
            DateTime.parse(ultimaFechaStr).month == hoy.month &&
            DateTime.parse(ultimaFechaStr).year == hoy.year;

        if (!tieneHuella && accessToken != null && uid != null && mounted && !yaMostroHoy) {
          // Mostrar ofrecimiento de huella ANTES de navegar
          await BiometricoDialogo.mostrarOfrecimiento(
            context: context,
            accessToken: accessToken,
            uid: uid,
          );

          // Guardar fecha de ofrecimiento (aunque cancele, no volver a mostrar hoy)
          await prefs.setString('biometrico_ofrecimiento_fecha', hoy.toIso8601String());

          // Navegar al inicio (incluso si canceló la huella)
          if (mounted) {
            Navigator.pushReplacementNamed(context, AppRutas.inicio);
          }
        } else {
          // Ya tiene huella o no hay datos, navegar directamente
          if (mounted) {
            Navigator.pushReplacementNamed(context, AppRutas.inicio);
          }
        }
      } else {
        _mostrarError('Credenciales incorrectas o error de conexión');
      }
    }
  }

  void _mostrarError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColores.rojo,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight > 48 ? constraints.maxHeight - 48 : 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),

                    /// LOGO
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColores.verde,
                            child: const Icon(Icons.air, color: Colors.white),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'AirMonitor',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Monitoreo de Calidad del Aire',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    Text(
                      'Bienvenido de nuevo',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 20,
                      ),
                    ),

                    const SizedBox(height: 20),

                    InputTexto(
                      controller: _correoController,
                      hint: 'Correo electrónico',
                    ),

                    const SizedBox(height: 15),

                    InputTexto(
                      controller: _passwordController,
                      hint: 'Contraseña',
                      esPassword: true,
                    ),

                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(color: AppColores.verde),
                      ),
                    ),

                    const SizedBox(height: 20),

                    BotonPrincipal(
                      texto: 'Iniciar sesión',
                      cargando: _cargando,
                      onPressed: () => _intentoLogin(),
                    ),

                    const SizedBox(height: 10),

                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRutas.registro);
                        },
                        child: Text(
                          '¿No tienes cuenta? Regístrate',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ),

                    // Botón de huella digital (solo si está configurado)
                    const Center(
                      child: HuellaBoton(),
                    ),
                  ],
                ),
              ),
            ),
            // Botón de cambio de tema
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: _alternarTema,
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
                  child: Icon(
                    _esOscuro ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                    color: theme.colorScheme.onSurface,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
