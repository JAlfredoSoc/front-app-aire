import 'package:flutter/material.dart';
import '../../core/rutas/app_rutas.dart';
import '../../widgets/botones/boton_principal.dart';
import '../../widgets/inputs/input_texto.dart';

class FormularioLogin extends StatelessWidget {
  const FormularioLogin({super.key});

  @override
  Widget build(BuildContext context) {
    final correoController = TextEditingController();
    final passwordController = TextEditingController();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 12),

                /// LOGO
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

                const SizedBox(height: 40),

                const Text(
                  'Bienvenido de nuevo',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),

                const SizedBox(height: 20),

                InputTexto(
                  controller: correoController,
                  hint: 'Correo electrónico',
                ),

                const SizedBox(height: 15),

                InputTexto(
                  controller: passwordController,
                  hint: 'Contraseña',
                  esPassword: true,
                ),

                const SizedBox(height: 10),

                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(color: Color(0xFF00C9A7)),
                  ),
                ),

                const SizedBox(height: 20),

                BotonPrincipal(texto: 'Iniciar sesión', onPressed: () {}),

                const SizedBox(height: 10),

                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRutas.registro);
                    },
                    child: const Text(
                      'Registrarse',
                      style: TextStyle(color: Colors.white70),
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
