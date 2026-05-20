import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import '../../servicios/biometrico_servicio.dart';
import '../../servicios/dispositivo_servicio.dart';

/// Diálogo para habilitar autenticación biométrica.
///
/// Este widget se muestra después de un login exitoso con email/password
/// para ofrecer al usuario habilitar el acceso con huella digital.
///
/// Flujo:
/// 1. Verifica que el dispositivo soporta biometría
/// 2. Solicita huella para confirmar que el usuario la tiene configurada
/// 3. Llama al backend para crear el refresh token
/// 4. Guarda el refresh token de forma segura
class BiometricoDialogo {
  /// Muestra el diálogo de ofrecimiento para habilitar huella.
  ///
  /// [context] - BuildContext para mostrar el diálogo
  /// [accessToken] - Token JWT del login recién completado
  /// [uid] - UID del usuario
  ///
  /// Retorna true si el usuario habilitó la biometría, false si canceló o falló.
  static Future<bool> mostrarOfrecimiento({
    required BuildContext context,
    required String accessToken,
    required String uid,
  }) async {
    // Primero verificar si el dispositivo soporta biometría
    final auth = LocalAuthentication();
    final puedeVerificar = await auth.canCheckBiometrics;
    final biometrias = await auth.getAvailableBiometrics();

    debugPrint('🔐 Biometría Debug:');
    debugPrint('  - Puede verificar: $puedeVerificar');
    debugPrint('  - Biometrías disponibles: $biometrias');

    if (!puedeVerificar || biometrias.isEmpty) {
      // No soporta biometría, no mostrar diálogo
      debugPrint('  - ❌ No se puede mostrar diálogo (no soporta biometría)');
      return false;
    }

    if (!context.mounted) return false;

    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _DialogoOfrecimiento(
        onHabilitar: () => _habilitarBiometria(
          context: context,
          accessToken: accessToken,
          uid: uid,
        ),
      ),
    );

    return resultado ?? false;
  }

  /// Proceso de habilitación de biometría.
  static Future<bool> _habilitarBiometria({
    required BuildContext context,
    required String accessToken,
    required String uid,
  }) async {
    final auth = LocalAuthentication();

    // Solicitar huella para confirmar que el usuario la tiene configurada
    final huellaCorrecta = await auth.authenticate(
      localizedReason: 'Configura el acceso con huella para futuros inicios de sesión',
      authMessages: const [
        AndroidAuthMessages(
          signInTitle: 'Configurar huella digital',
          cancelButton: 'Cancelar',
          biometricHint: 'Coloca tu dedo en el sensor',
          biometricNotRecognized: 'Huella no reconocida',
          biometricSuccess: 'Huella verificada',
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
        biometricOnly: false,
      ),
    );

    if (!huellaCorrecta) {
      return false;
    }

    if (!context.mounted) return false;

    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Llamar al backend para crear el refresh token
    final deviceName = await DispositivoServicio.obtenerDeviceName();
    final exito = await BiometricoServicio.enable(
      accessToken: accessToken,
      uid: uid,
      deviceName: deviceName,
    );

    // Cerrar indicador de carga
    if (context.mounted) {
      Navigator.of(context).pop();
    }

    if (exito && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Acceso con huella habilitado exitosamente'),
          backgroundColor: Color(0xFF00C9A7),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No se pudo habilitar el acceso con huella'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    return exito;
  }

  /// Muestra diálogo para deshabilitar biometría.
  static Future<bool> mostrarDeshabilitar({
    required BuildContext context,
    required String uid,
  }) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deshabilitar huella digital'),
        content: const Text(
          '¿Estás seguro de que quieres deshabilitar el acceso con huella digital? '
          'Tendrás que usar tu email y contraseña para iniciar sesión.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Deshabilitar',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return false;

    final exito = await BiometricoServicio.disable(uid: uid);

    if (exito && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Acceso con huella deshabilitado'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    return exito;
  }
}

/// Diálogo de ofrecimiento para habilitar biometría.
class _DialogoOfrecimiento extends StatelessWidget {
  final Future<bool> Function() onHabilitar;

  const _DialogoOfrecimiento({required this.onHabilitar});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Column(
        children: [
          Icon(
            Icons.fingerprint,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          const Text('Acceso más rápido'),
        ],
      ),
      content: const Text(
        'Habilita el acceso con huella digital para iniciar sesión más rápido la próxima vez. '
        'Tu huella nunca se envía al servidor, solo se usa localmente en tu dispositivo.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Ahora no'),
        ),
        ElevatedButton(
          onPressed: () async {
            final exito = await onHabilitar();
            if (context.mounted) {
              Navigator.of(context).pop(exito);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00C9A7),
            foregroundColor: Colors.white,
          ),
          child: const Text('Habilitar'),
        ),
      ],
    );
  }
}
