import 'package:flutter/material.dart';
import 'core/rutas/app_rutas.dart';
import 'core/tema/tema_app.dart';
import 'servicios/tema_servicio.dart';
import 'servicios/notificacion_local_servicio.dart';
import 'servicios/alerta_servicio.dart';

void main() {
  runApp(const AirMonitorApp());
}

class AirMonitorApp extends StatefulWidget {
  const AirMonitorApp({super.key});

  @override
  State<AirMonitorApp> createState() => AirMonitorAppState();
}

class AirMonitorAppState extends State<AirMonitorApp> with WidgetsBindingObserver {
  ThemeData _temaActual = TemaApp.oscuro;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _inicializarServicios();
    _cargarTema();
  }

  Future<void> _inicializarServicios() async {
    await NotificacionLocalServicio.inicializar();
    AlertaServicio.iniciarPolling();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App volvió a foreground - reanudar polling
      AlertaServicio.iniciarPolling();
    } else {
      // App fue a background - detener polling
      AlertaServicio.detenerPolling();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AlertaServicio.detenerPolling();
    super.dispose();
  }

  Future<void> _cargarTema() async {
    final tema = await TemaServicio.temaActual();
    if (mounted) {
      setState(() {
        _temaActual = tema;
      });
    }
  }

  void actualizarTema() {
    _cargarTema();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AirMonitor',
      theme: _temaActual,
      initialRoute: AppRutas.login,
      routes: AppRutas.rutas,
    );
  }
}
