import 'package:flutter/material.dart';
import '../../auth/vistas/login_vista.dart';
import '../../auth/vistas/registro_vista.dart';
import '../shell/app_shell.dart';

class AppRutas {
  static const String login = "/";
  static const String registro = "/registro";
  static const String inicio = "/inicio";
  static const String mapa = "/mapa";
  static const String estadisticas = "/estadisticas";

  static Map<String, WidgetBuilder> rutas = {
    login: (context) => const LoginVista(),
    registro: (context) => const RegistroVista(),
    inicio: (context) => const AppShell(tabInicial: 0),
    mapa: (context) => const AppShell(tabInicial: 1),
    estadisticas: (context) => const AppShell(tabInicial: 2),
  };
}
