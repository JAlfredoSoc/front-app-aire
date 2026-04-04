import 'package:flutter/material.dart';
import '../../auth/vistas/login_vista.dart';
import '../../auth/vistas/registro_vista.dart';
import '../../modulos/dashboard/vistas/inicio_vista.dart';
import '../../modulos/mapa/vistas/mapa_vista.dart';

class AppRutas {
  static const String login = "/";
  static const String registro = "/registro";
  static const String inicio = "/inicio";
  static const String mapa = "/mapa";

  static Map<String, WidgetBuilder> rutas = {
    login: (context) => const LoginVista(),
    registro: (context) => const RegistroVista(),
    inicio: (context) => const InicioVista(),
    mapa: (context) => const MapaVista(),
  };
}
