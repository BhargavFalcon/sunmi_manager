import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

class PrinterHelper {
  static bool? _isSunmi;

  static Future<bool> isSunmiDevice() async {
    if (_isSunmi == true) return true;
    if (!Platform.isAndroid) {
      _isSunmi = false;
      return false;
    }

    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final manufacturer = androidInfo.manufacturer.toLowerCase();
      final brand = androidInfo.brand.toLowerCase();
      final model = androidInfo.model.toLowerCase();

      final isSunmiHardware = manufacturer.contains('sunmi') ||
          brand.contains('sunmi') ||
          model.contains('sunmi');

      if (isSunmiHardware) {
        try {
          await SunmiPrinterPlus().rebindPrinter();
        } catch (_) {}
        _isSunmi = true;
        return true;
      } else {
        _isSunmi = false;
        return false;
      }
    } catch (_) {
      return false;
    }
  }
}
