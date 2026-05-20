import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dispositivo_servicio.dart';

/// Servicio para gestionar autenticación biométrica con refresh tokens.
/// 
/// Flujo:
/// 1. enable() - Después de login normal, crea un refresh token vinculado al dispositivo
/// 2. login() - Usa el refresh token guardado para obtener un nuevo access token
/// 3. disable() - Revoca todos los tokens del usuario
/// 
/// El refresh token se guarda de forma segura en Keychain (iOS) / Keystore (Android)
/// y rota automáticamente en cada uso.
class BiometricoServicio {
  BiometricoServicio._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static const _claveRefreshToken = 'biometric_refresh_token';

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000';
    return 'http://10.0.2.2:8000';
  }

  /// Habilita la autenticación biométrica para el usuario actual.
  /// 
  /// Requiere el access_token del login previo en el header.
  /// Guarda automáticamente el refresh_token en almacenamiento seguro.
  /// 
  /// [accessToken] - Token JWT del login normal
  /// [uid] - UID del usuario
  /// [deviceName] - Nombre legible del dispositivo (opcional)
  /// 
  /// Retorna true si se habilitó correctamente.
  static Future<bool> enable({
    required String accessToken,
    required String uid,
    String? deviceName,
  }) async {
    try {
      final deviceId = await DispositivoServicio.obtenerDeviceId();

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/biometric/enable'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'uid': uid,
          'device_id': deviceId,
          'device_name': deviceName,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final refreshToken = data['refresh_token'];

        if (refreshToken != null) {
          // Guardar refresh token de forma segura
          await _storage.write(key: _claveRefreshToken, value: refreshToken);
        }

        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error habilitando biometría: $e');
      return false;
    }
  }

  /// Realiza login con autenticación biométrica.
  /// 
  /// Usa el refresh token guardado para obtener un nuevo access token.
  /// Rota automáticamente el refresh token (guarda el nuevo).
  /// 
  /// Retorna un mapa con los tokens si es exitoso, null si falla.
  static Future<Map<String, dynamic>?> login() async {
    try {
      final refreshToken = await _storage.read(key: _claveRefreshToken);
      if (refreshToken == null) {
        debugPrint('No hay refresh token guardado');
        return null;
      }

      final deviceId = await DispositivoServicio.obtenerDeviceId();

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/biometric/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refresh_token': refreshToken,
          'device_id': deviceId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final nuevoRefreshToken = data['refresh_token'];
        final accessToken = data['access_token'];
        final usuario = data['usuario'];

        // Rotación: guardar el nuevo refresh token
        if (nuevoRefreshToken != null) {
          await _storage.write(key: _claveRefreshToken, value: nuevoRefreshToken);
        }

        return {
          'access_token': accessToken,
          'refresh_token': nuevoRefreshToken,
          'usuario': usuario,
        };
      }

      // 401 = token inválido, expirado o device_id no coincide
      if (response.statusCode == 401) {
        // Borrar token local inválido
        await _storage.delete(key: _claveRefreshToken);
      }

      return null;
    } catch (e) {
      debugPrint('Error en login biométrico: $e');
      return null;
    }
  }

  /// Deshabilita la autenticación biométrica para el usuario.
  /// 
  /// [uid] - UID del usuario
  /// 
  /// Retorna true si se deshabilitó correctamente.
  static Future<bool> disable({required String uid}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/biometric/disable?uid=$uid'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Borrar token local
        await _storage.delete(key: _claveRefreshToken);
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error deshabilitando biometría: $e');
      return false;
    }
  }

  /// Verifica si existe un refresh token guardado localmente.
  static Future<bool> estaHabilitado() async {
    final token = await _storage.read(key: _claveRefreshToken);
    return token != null;
  }

  /// Obtiene el refresh token guardado (solo para casos especiales).
  /// Preferir usar login() en lugar de acceder directamente al token.
  static Future<String?> obtenerRefreshToken() async {
    return await _storage.read(key: _claveRefreshToken);
  }

  /// Borra el refresh token local (logout biométrico).
  static Future<void> logout() async {
    await _storage.delete(key: _claveRefreshToken);
  }
}
