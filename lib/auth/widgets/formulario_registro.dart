import 'package:flutter/material.dart';
import '../../core/rutas/app_rutas.dart';
import '../../core/tema/colores.dart';
import '../../core/tema/tema_app.dart';
import '../../servicios/auth_servicio.dart';
import '../../servicios/tema_servicio.dart';
import '../../main.dart';
import '../../widgets/botones/boton_principal.dart';
import '../../widgets/inputs/input_texto.dart';

class FormularioRegistro extends StatefulWidget {
  const FormularioRegistro({super.key});

  @override
  State<FormularioRegistro> createState() => _FormularioRegistroState();
}

class _FormularioRegistroState extends State<FormularioRegistro> {
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmarPasswordController = TextEditingController();
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

  Future<void> _intentoRegistro() async {
    final nombre = _nombreController.text.trim();
    final email = _correoController.text.trim();
    final pass = _passwordController.text.trim();
    final confirm = _confirmarPasswordController.text.trim();

    if (nombre.isEmpty || email.isEmpty || pass.isEmpty) {
      _mostrarError('Por favor, llena todos los campos');
      return;
    }

    if (pass != confirm) {
      _mostrarError('Las contraseñas no coinciden');
      return;
    }

    setState(() => _cargando = true);

    final exito = await AuthServicio.registro(nombre, email, pass);

    if (mounted) {
      setState(() => _cargando = false);
      if (exito) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRutas.inicio,
          (route) => false,
        );
      } else {
        _mostrarError('Error al crear cuenta. El usuario podría ya existir.');
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
        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight > 40 ? constraints.maxHeight - 40 : 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
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
                    const SizedBox(height: 28),
                    Text(
                      'Crear cuenta',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Regístrate para comenzar a monitorear la calidad del aire',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    InputTexto(
                      controller: _nombreController,
                      hint: 'Nombre completo',
                    ),
                    const SizedBox(height: 14),
                    InputTexto(
                      controller: _correoController,
                      hint: 'Correo electrónico',
                    ),
                    const SizedBox(height: 14),
                    InputTexto(
                      controller: _passwordController,
                      hint: 'Contraseña',
                      esPassword: true,
                    ),
                    const SizedBox(height: 14),
                    InputTexto(
                      controller: _confirmarPasswordController,
                      hint: 'Confirmar contraseña',
                      esPassword: true,
                    ),
                    const SizedBox(height: 22),
                    BotonPrincipal(
                      texto: 'Registrarse',
                      cargando: _cargando,
                      onPressed: () => _intentoRegistro(),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRutas.login,
                            (route) => false,
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
                            children: [
                              TextSpan(
                                text: '¿Ya tienes cuenta? ',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                              TextSpan(
                                text: 'Iniciar sesión',
                                style: TextStyle(
                                  color: AppColores.verde,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Icon(
                    _esOscuro ? Icons.wb_sunny : Icons.nights_stay,
                    color: theme.colorScheme.onSurface,
                    size: 20,
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
