import 'package:flutter/material.dart';
import '../../auth/vistas/login_vista.dart';
import '../../auth/vistas/registro_vista.dart';

class AppRutas {
  static const String login = "/";
  static const String registro = "/registro";

  static Map<String, WidgetBuilder> rutas = {
    login: (context) => const LoginVista(),
    registro: (context) => const RegistroVista(),
  };
}