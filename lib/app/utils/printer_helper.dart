import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

class PrinterHelper {
  static bool? _isSunmi;

  static Future<bool> isSunmiDevice() async {
    if (_isSunmi == true) return true;
    try {
      final sunmiPrinterPlus = SunmiPrinterPlus();
      final result = await sunmiPrinterPlus.rebindPrinter();
      if (result == true) {
        _isSunmi = true;
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
