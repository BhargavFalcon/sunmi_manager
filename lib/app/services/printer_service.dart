import 'package:get/get.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/api_constants.dart';

class PrinterService extends GetxService {
  final box = GetStorage();
  final isConnected = false.obs;
  BluetoothInfo? connectedDevice;

  @override
  void onInit() {
    super.onInit();
    _loadSavedPrinter();
    _checkConnection();
  }

  void _loadSavedPrinter() {
    try {
      final savedDeviceJson = box.read(ArgumentConstant.savedPrinterDeviceKey);
      if (savedDeviceJson != null && savedDeviceJson is Map) {
        final macAddress = savedDeviceJson['macAddress'] as String?;
        final name = savedDeviceJson['name'] as String?;
        if (macAddress != null && name != null) {
          connectedDevice = BluetoothInfo(name: name, macAdress: macAddress);
          isConnected.value = true;
        }
      }
    } catch (e) {
      print('Error loading saved printer: $e');
    }
  }

  Future<void> _checkConnection() async {
    try {
      if (connectedDevice != null) {
        final isPaired = await PrintBluetoothThermal.connectionStatus;
        if (!isPaired) {
          // Try to reconnect if not connected
          final result = await PrintBluetoothThermal.connect(
            macPrinterAddress: connectedDevice!.macAdress,
          );
          isConnected.value = result ?? false;
        } else {
          isConnected.value = true;
        }
      }
    } catch (e) {
      print('Error checking connection: $e');
      isConnected.value = false;
    }
  }

  Future<void> saveConnectedDevice(BluetoothInfo device) async {
    connectedDevice = device;
    isConnected.value = true;
    box.write(ArgumentConstant.savedPrinterDeviceKey, {
      'name': device.name,
      'macAddress': device.macAdress,
    });
  }

  Future<void> clearConnectedDevice() async {
    connectedDevice = null;
    isConnected.value = false;
    box.remove(ArgumentConstant.savedPrinterDeviceKey);
  }

  Future<void> printTestReceipt() async {
    if (!isConnected.value || connectedDevice == null) {
      print('⚠️ Printer not connected, cannot print');
      return;
    }

    try {
      // Create ESC/POS commands
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);

      List<int> bytes = [];

      // Header
      bytes += generator.text(
        'Test Print',
        styles: PosStyles(align: PosAlign.center, bold: true),
      );
      bytes += generator.text(
        'DineMatrics Manager',
        styles: PosStyles(align: PosAlign.center),
      );
      bytes += generator.hr();

      // Test content
      bytes += generator.text(
        'This is a test print',
        styles: PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        'Date: ${DateTime.now().toString().split('.')[0]}',
        styles: PosStyles(align: PosAlign.center),
      );
      bytes += generator.hr();

      // Footer
      bytes += generator.text(
        'Thank you!',
        styles: PosStyles(align: PosAlign.center),
      );
      bytes += generator.feed(2);
      bytes += generator.cut();

      // Print
      final result = await PrintBluetoothThermal.writeBytes(bytes);

      if (result == true) {
        print('✅ Test print sent successfully');
      } else {
        print('❌ Failed to send print');
      }
    } catch (e) {
      print('❌ Print error: $e');
    }
  }
}
