import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

class PrinterHelper {
  static bool? _isSunmi;

  static Future<bool> isSunmiDevice() async {
    if (_isSunmi != null) return _isSunmi!;
    try {
      _isSunmi = await SunmiPrinter.bindingPrinter() ?? false;
    } catch (_) {
      _isSunmi = false;
    }
    return _isSunmi!;
  }
}
