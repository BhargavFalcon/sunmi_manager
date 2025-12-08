import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/main.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import '../../../services/printer_service.dart';
import '../../../constants/api_constants.dart';
import '../../../constants/sizeConstant.dart';

class PrinterScreenController extends GetxController {
  late PrinterService printerService;
  final isLoading = false.obs;
  final isScanning = false.obs;
  final connectedDevice = Rxn<BluetoothInfo>();
  final availableDevices = <BluetoothInfo>[].obs;
  final isConnected = false.obs;

  // Printer Settings
  final autoPrint = true.obs;
  final numberOfCopies = 1.obs;
  final printerWidth = '80mm'.obs;
  final printerWidthOptions = ['58mm', '72mm', '80mm'];

  @override
  void onInit() {
    super.onInit();
    printerService = Get.find<PrinterService>();
    _loadSavedPrinter();
    _loadSettings();
    _checkConnection();
    _syncWithService();
    _checkBluetoothStatus();
    _autoScan();
  }

  Future<void> _autoScan() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await scanForDevices();
  }

  Future<void> _checkBluetoothStatus() async {
    try {
      final bool bluetoothEnabled =
          await PrintBluetoothThermal.bluetoothEnabled;
      if (bluetoothEnabled == false) {
        isConnected.value = false;
        connectedDevice.value = null;
        printerService.isConnected.value = false;
        safeGetSnackbar(
          'Bluetooth Disabled',
          'Please enable Bluetooth to use printer features',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        await _checkConnection();
      }
    } catch (e) {
      isConnected.value = false;
      connectedDevice.value = null;
      printerService.isConnected.value = false;
    }
  }

  void _loadSettings() {
    try {
      autoPrint.value = box.read(ArgumentConstant.printerAutoPrintKey) ?? true;
      numberOfCopies.value =
          box.read(ArgumentConstant.printerNumberOfCopiesKey) ?? 1;
      printerWidth.value = box.read(ArgumentConstant.printerWidthKey) ?? '80mm';
    } catch (e) {
      print('Error loading printer settings: $e');
    }
  }

  void saveSettings() {
    try {
      box.write(ArgumentConstant.printerAutoPrintKey, autoPrint.value);
      box.write(
        ArgumentConstant.printerNumberOfCopiesKey,
        numberOfCopies.value,
      );
      box.write(ArgumentConstant.printerWidthKey, printerWidth.value);
    } catch (e) {
      print('Error saving printer settings: $e');
    }
  }

  void toggleAutoPrint() {
    autoPrint.value = !autoPrint.value;
    saveSettings();
  }

  void incrementCopies() {
    if (numberOfCopies.value < 5) {
      numberOfCopies.value++;
      saveSettings();
    }
  }

  void decrementCopies() {
    if (numberOfCopies.value > 1) {
      numberOfCopies.value--;
      saveSettings();
    }
  }

  void setPrinterWidth(String width) {
    printerWidth.value = width;
    saveSettings();
  }

  void _syncWithService() {
    // Listen to service changes
    ever(printerService.isConnected, (connected) {
      isConnected.value = connected;
      if (connected && printerService.connectedDevice != null) {
        connectedDevice.value = printerService.connectedDevice;
      } else {
        connectedDevice.value = null;
      }
    });
  }

  void _loadSavedPrinter() {
    try {
      if (printerService.connectedDevice != null) {
        connectedDevice.value = printerService.connectedDevice;
        isConnected.value = printerService.isConnected.value;
      }
    } catch (e) {
      print('Error loading saved printer: $e');
    }
  }

  Future<void> _checkConnection() async {
    try {
      if (connectedDevice.value != null) {
        final isPaired = await PrintBluetoothThermal.connectionStatus;
        if (!isPaired) {
          // Try to reconnect if not connected
          final result = await PrintBluetoothThermal.connect(
            macPrinterAddress: connectedDevice.value!.macAdress,
          );
          isConnected.value = result;
        } else {
          isConnected.value = true;
        }
        printerService.isConnected.value = isConnected.value;
      }
    } catch (e) {
      print('Error checking connection: $e');
      isConnected.value = false;
      printerService.isConnected.value = false;
    }
  }

  // Filter function to identify printer devices
  bool _isPrinterDevice(BluetoothInfo device) {
    final deviceName = device.name.toLowerCase();
    final printerKeywords = [
      'printer',
      'print',
      'thermal',
      'pos',
      'receipt',
      'epson',
      'hp',
      'canon',
      'brother',
      'zebra',
      'star',
      'bixolon',
      'xprinter',
      'rpp',
      'rpp02',
      'rpp02h',
      'rpp02l',
      'rpp02x',
      'rpp02y',
      'rpp02z',
      'rpp02a',
      'rpp02b',
      'rpp02c',
      'rpp02d',
      'rpp02e',
      'rpp02f',
      'rpp02g',
      'rpp02i',
      'rpp02j',
      'rpp02k',
      'rpp02m',
      'rpp02n',
      'rpp02o',
      'rpp02p',
      'rpp02q',
      'rpp02r',
      'rpp02s',
      'rpp02t',
      'rpp02u',
      'rpp02v',
      'rpp02w',
    ];

    return printerKeywords.any((keyword) => deviceName.contains(keyword));
  }

  Future<void> scanForDevices() async {
    try {
      isScanning.value = true;
      availableDevices.clear();

      final bool? bluetoothEnabled =
          await PrintBluetoothThermal.bluetoothEnabled;
      if (bluetoothEnabled == false) {
        isScanning.value = false;
        isConnected.value = false;
        connectedDevice.value = null;
        printerService.isConnected.value = false;
        safeGetSnackbar(
          'Bluetooth Disabled',
          'Please enable Bluetooth to scan for printers',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      final List<BluetoothInfo> allDevices =
          await PrintBluetoothThermal.pairedBluetooths;

      // Filter only printer devices
      final List<BluetoothInfo> printerDevices =
          allDevices.where((device) => _isPrinterDevice(device)).toList();

      availableDevices.value = printerDevices;
    } catch (e) {
      // Error handled silently
    } finally {
      isScanning.value = false;
    }
  }

  Future<void> connectToDevice(BluetoothInfo device) async {
    try {
      isLoading.value = true;

      final result = await PrintBluetoothThermal.connect(
        macPrinterAddress: device.macAdress,
      );

      if (result == true) {
        printerService.connectedDevice = device;
        printerService.isConnected.value = true;

        connectedDevice.value = device;
        isConnected.value = true;

        // Save printer to service
        await printerService.saveConnectedDevice(device);

        // Force UI update
        update();

        safeGetSnackbar(
          'Success',
          'Printer connected successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        safeGetSnackbar(
          'Error',
          'Failed to connect to printer',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      safeGetSnackbar(
        'Error',
        'Failed to connect to printer',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> disconnectDevice() async {
    try {
      isLoading.value = true;
      final result = await PrintBluetoothThermal.disconnect;

      if (result == true) {
        connectedDevice.value = null;
        isConnected.value = false;
        await printerService.clearConnectedDevice();
      }
    } catch (e) {
      // Error handled silently
    } finally {
      isLoading.value = false;
    }
  }

  PaperSize _getPaperSize() {
    switch (printerWidth.value) {
      case '58mm':
        return PaperSize.mm58;
      case '72mm':
        return PaperSize.mm72;
      case '80mm':
        return PaperSize.mm80;
      default:
        return PaperSize.mm80;
    }
  }

  Future<void> printTestReceipt() async {
    if (!isConnected.value || connectedDevice.value == null) {
      return;
    }

    try {
      isLoading.value = true;

      final profile = await CapabilityProfile.load();
      final paperSize = _getPaperSize();
      final generator = Generator(paperSize, profile);

      List<int> allBytes = [];

      // Print multiple copies
      for (int i = 0; i < numberOfCopies.value; i++) {
        List<int> bytes = [];

        bytes += generator.text(
          'Test Print',
          styles: PosStyles(align: PosAlign.center, bold: true),
        );
        bytes += generator.text(
          'DineMatrics Manager',
          styles: PosStyles(align: PosAlign.center),
        );
        bytes += generator.hr();

        bytes += generator.text(
          'This is a test print',
          styles: PosStyles(align: PosAlign.center),
        );
        bytes += generator.text(
          'Date: ${DateTime.now().toString().split('.')[0]}',
          styles: PosStyles(align: PosAlign.center),
        );
        bytes += generator.text(
          'Copy: ${i + 1} of ${numberOfCopies.value}',
          styles: PosStyles(align: PosAlign.center),
        );
        bytes += generator.hr();

        bytes += generator.text(
          'Thank you!',
          styles: PosStyles(align: PosAlign.center),
        );
        bytes += generator.feed(2);
        bytes += generator.cut();

        allBytes.addAll(bytes);
      }

      await PrintBluetoothThermal.writeBytes(allBytes);
    } catch (e) {
      // Print error handled silently
    } finally {
      isLoading.value = false;
    }
  }
}
