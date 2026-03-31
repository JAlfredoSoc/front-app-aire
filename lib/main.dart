import 'package:flutter/material.dart';
import 'core/rutas/app_rutas.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AirMonitor',

      initialRoute: AppRutas.login,
      routes: AppRutas.rutas,
    );
  }
}