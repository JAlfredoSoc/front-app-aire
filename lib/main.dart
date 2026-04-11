import 'package:flutter/material.dart';
import 'core/rutas/app_rutas.dart';
import 'core/tema/tema_app.dart';

void main() {
  runApp(const AirMonitorApp());
}

class AirMonitorApp extends StatelessWidget {
  const AirMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AirMonitor',
      theme: TemaApp.oscuro,
      initialRoute: AppRutas.login,
      routes: AppRutas.rutas,
    );
  }
}
