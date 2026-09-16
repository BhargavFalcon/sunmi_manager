import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class DeviceUtils {
  static const _batteryChannel = MethodChannel(
    'com.dinemetrics.manager/battery',
  );

  static const _notificationChannel = MethodChannel(
    'com.dinemetrics.manager/notifications',
  );

  static Future<bool> isIgnoringBatteryOptimizations() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;
    try {
      final bool? result = await _batteryChannel.invokeMethod(
        'isIgnoringBatteryOptimizations',
      );
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> requestIgnoreBatteryOptimizations() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;
    try {
      final bool? result = await _batteryChannel.invokeMethod(
        'requestIgnoreBatteryOptimizations',
      );
      return result ?? true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> requestNotificationPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;
    try {
      final bool? result = await _notificationChannel.invokeMethod(
        'requestNotificationPermission',
      );
      return result ?? true;
    } catch (_) {
      return false;
    }
  }
}
