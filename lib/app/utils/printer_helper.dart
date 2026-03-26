import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

class PrinterHelper {
  static bool? _isSunmi;

  static Future<bool> isSunmiDevice() async {
    if (_isSunmi != null) return _isSunmi!;
    if (!Platform.isAndroid) {
      _isSunmi = false;
      return false;
    }

    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final manufacturer = androidInfo.manufacturer.toLowerCase();

      if (manufacturer.contains('sunmi')) {
        final sunmiPrinterPlus = SunmiPrinterPlus();
        final result = await sunmiPrinterPlus.rebindPrinter();
        _isSunmi = result == true;
      } else {
        _isSunmi = false;
      }
      return _isSunmi!;
    } catch (_) {
      _isSunmi = false;
      return false;
    }
  }
}
