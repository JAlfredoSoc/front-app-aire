import 'package:flutter/material.dart';
import '../../core/rutas/app_rutas.dart';
import '../../widgets/botones/boton_principal.dart';
import '../../widgets/inputs/input_texto.dart';

class FormularioRegistro extends StatelessWidget {
  const FormularioRegistro({super.key});

  @override
  Widget build(BuildContext context) {
    final nombreController = TextEditingController();
    final correoController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmarPasswordController = TextEditingController();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                Center(
                  child: Column(
                    children: const [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Color(0xFF00C9A7),
                        child: Icon(Icons.air, color: Colors.white),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'AirMonitor',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Monitoreo de Calidad del Aire',
                        style: TextStyle(color: Colors.white60),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Crear cuenta',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Regístrate para comenzar a monitorear la calidad del aire',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                InputTexto(
                  controller: nombreController,
                  hint: 'Nombre completo',
                ),
                const SizedBox(height: 14),
                InputTexto(
                  controller: correoController,
                  hint: 'Correo electrónico',
                ),
                const SizedBox(height: 14),
                InputTexto(
                  controller: passwordController,
                  hint: 'Contraseña',
                  esPassword: true,
                ),
                const SizedBox(height: 14),
                InputTexto(
                  controller: confirmarPasswordController,
                  hint: 'Confirmar contraseña',
                  esPassword: true,
                ),
                const SizedBox(height: 22),
                BotonPrincipal(
                  texto: 'Registrarse',
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRutas.inicio,
                      (route) => false,
                    );
                  },
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
                      text: const TextSpan(
                        style: TextStyle(fontSize: 14),
                        children: [
                          TextSpan(
                            text: '¿Ya tienes cuenta? ',
                            style: TextStyle(color: Colors.white70),
                          ),
                          TextSpan(
                            text: 'Iniciar sesión',
                            style: TextStyle(
                              color: Color(0xFF00C9A7),
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
        );
      },
    );
  }
}
