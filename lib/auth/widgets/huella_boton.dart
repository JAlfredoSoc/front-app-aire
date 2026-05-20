import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../servicios/biometrico_servicio.dart';
import '../../core/rutas/app_rutas.dart';

/// Botón de login con huella digital.
/// 
/// Este widget:
/// 1. Verifica si existe un refresh token guardado
/// 2. Si existe, muestra el botón de huella
/// 3. Al tocar, solicita autenticación biométrica local
/// 4. Si la huella es correcta, llama al backend para obtener access token
/// 5. Navega al inicio si todo es exitoso
///
/// Usar en la pantalla de login cuando hay huella configurada.
class HuellaBoton extends StatefulWidget {
  const HuellaBoton({super.key});

  @override
  State<HuellaBoton> createState() => _HuellaBotonState();
}

class _HuellaBotonState extends State<HuellaBoton> {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _cargando = false;
  bool _hayToken = false;

  @override
  void initState() {
    super.initState();
    _verificarToken();
  }

  /// Verifica si existe un refresh token guardado
  Future<void> _verificarToken() async {
    final hayToken = await BiometricoServicio.estaHabilitado();
    if (mounted) {
      setState(() {
        _hayToken = hayToken;
      });
    }
  }

  /// Solicita huella y realiza login biométrico
  Future<void> _loginConHuella() async {
    if (_cargando) return;

    setState(() {
      _cargando = true;
    });

    try {
      // 1. Verificar que el dispositivo tiene biometría disponible
      final bool puedeVerificar = await _auth.canCheckBiometrics;
      if (!puedeVerificar) {
        _mostrarError('Este dispositivo no soporta autenticación biométrica');
        return;
      }

      // 2. Verificar si hay biometrías registradas
      final List<BiometricType> biometrias = await _auth.getAvailableBiometrics();
      if (biometrias.isEmpty) {
        _mostrarError('No hay huellas o Face ID configurados en este dispositivo');
        return;
      }

      // 3. Solicitar huella al usuario (LOCAL, no se envía al servidor)
      final bool huellaCorrecta = await _auth.authenticate(
        localizedReason: 'Autentícate para acceder a AirMonitor',
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Autenticación requerida',
            cancelButton: 'Cancelar',
            biometricHint: 'Verifica tu identidad',
            biometricNotRecognized: 'No reconocido, intenta de nuevo',
            biometricSuccess: 'Éxito',
            deviceCredentialsRequiredTitle: 'Credenciales requeridas',
            deviceCredentialsSetupDescription: 'Configura tu huella o PIN',
            goToSettingsButton: 'Ir a configuración',
            goToSettingsDescription: 'Configura tu huella en ajustes del dispositivo',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancelar',
            goToSettingsButton: 'Ir a configuración',
            goToSettingsDescription: 'Configura Face ID o Touch ID en ajustes',
            lockOut: 'Demasiados intentos fallidos. Usa contraseña.',
          ),
        ],
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: false, // Permitir PIN como fallback
        ),
      );

      if (!huellaCorrecta) {
        // Usuario canceló o falló
        return;
      }

      // 4. Huella correcta - llamar al backend
      final resultado = await BiometricoServicio.login();

      if (resultado == null) {
        _mostrarError('No se pudo iniciar sesión. Intenta con email y contraseña.');
        return;
      }

      // 5. Guardar tokens en AuthServicio (para compatibilidad con flujo existente)
      final accessToken = resultado['access_token'];
      final usuario = resultado['usuario'];

      if (accessToken != null && usuario != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', accessToken);
        await prefs.setString('user_email', usuario['email'] ?? '');
        await prefs.setString('user_nombre', usuario['nombre'] ?? 'Usuario');
        if (usuario['uid'] != null) {
          await prefs.setString('user_uid', usuario['uid']);
        }
        if (usuario['ultima_conexion'] != null) {
          await prefs.setString('user_ultima_conexion', usuario['ultima_conexion']);
        }

        // 6. Navegar al inicio
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRutas.inicio);
        }
      }

    } catch (e) {
      debugPrint('Error en login con huella: $e');
      _mostrarError('Error al autenticar con huella');
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hayToken) {
      return const SizedBox.shrink(); // No mostrar nada si no hay huella configurada
    }

    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          'o accede con',
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _cargando ? null : _loginConHuella,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: _cargando
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : Icon(
                    Icons.fingerprint,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Huella digital',
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
