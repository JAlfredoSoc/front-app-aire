import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para obtener información del dispositivo.
/// 
/// Genera y mantiene un device_id único y persistente por dispositivo.
/// Este ID se usa para vincular los refresh tokens biométricos al hardware.
class DispositivoServicio {
  DispositivoServicio._();

  static const _claveDeviceId = 'device_id';
  static String? _cacheDeviceId;

  /// Obtiene un identificador único y persistente para este dispositivo.
  /// 
  /// El ID se genera una vez y se guarda en SharedPreferences.
  /// Si no existe, se crea usando información del hardware + UUID aleatorio.
  /// 
  /// Este ID debe ser estable entre sesiones de la app.
  static Future<String> obtenerDeviceId() async {
    // Retornar cache si existe
    if (_cacheDeviceId != null) {
      return _cacheDeviceId!;
    }

    final prefs = await SharedPreferences.getInstance();
    
    // Intentar leer ID guardado
    var deviceId = prefs.getString(_claveDeviceId);
    
    if (deviceId != null && deviceId.isNotEmpty) {
      _cacheDeviceId = deviceId;
      return deviceId;
    }

    // Generar nuevo ID basado en información del dispositivo
    deviceId = await _generarDeviceId();
    
    // Guardar para futuras sesiones
    await prefs.setString(_claveDeviceId, deviceId);
    _cacheDeviceId = deviceId;
    
    return deviceId;
  }

  /// Genera un ID único combinando info del hardware.
  static Future<String> _generarDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      
      if (kIsWeb) {
        // Para web, usar un identificador basado en navegador + random
        return 'web_${DateTime.now().millisecondsSinceEpoch}_${_randomString(8)}';
      }
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        // Combinar ID del dispositivo con modelo para unicidad
        final id = androidInfo.id;
        final model = androidInfo.model;
        return 'android_${id}_$model'.replaceAll(' ', '_');
      }
      
      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        // Usar identifierForProvider en iOS (es único por app en este dispositivo)
        final id = iosInfo.identifierForVendor;
        return 'ios_$id';
      }
      
      if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        return 'win_${windowsInfo.computerName}_${_randomString(6)}';
      }
      
      if (Platform.isMacOS) {
        final macInfo = await deviceInfo.macOsInfo;
        return 'mac_${macInfo.systemGUID ?? _randomString(12)}';
      }
      
      if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        return 'linux_${linuxInfo.machineId ?? _randomString(12)}';
      }
      
      // Fallback para otras plataformas
      return 'unknown_${DateTime.now().millisecondsSinceEpoch}_${_randomString(8)}';
      
    } catch (e) {
      debugPrint('Error obtenendo device info: $e');
      // Fallback seguro si falla la lectura de hardware
      return 'fallback_${DateTime.now().millisecondsSinceEpoch}_${_randomString(12)}';
    }
  }

  /// Genera un string aleatorio de longitud dada.
  static String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    var result = '';
    for (var i = 0; i < length; i++) {
      result += chars[(random + i) % chars.length];
    }
    return result;
  }

  /// Obtiene un nombre legible del dispositivo para mostrar al usuario.
  static Future<String> obtenerDeviceName() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      
      if (kIsWeb) {
        return 'Web Browser';
      }
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return '${androidInfo.brand} ${androidInfo.model}';
      }
      
      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.name;
      }

      if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        return windowsInfo.computerName;
      }

      if (Platform.isMacOS) {
        final macInfo = await deviceInfo.macOsInfo;
        return macInfo.computerName;
      }
      
      if (Platform.isLinux) {
        return 'Linux PC';
      }
      
      return 'Dispositivo';
      
    } catch (e) {
      return 'Mi Dispositivo';
    }
  }
}
