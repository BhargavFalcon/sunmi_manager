import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import '../../../services/printer_service.dart';

class PrinterScreenController extends GetxController {
  late PrinterService printerService;
  final isLoading = false.obs;
  final isScanning = false.obs;
  final connectedDevice = Rxn<BluetoothInfo>();
  final availableDevices = <BluetoothInfo>[].obs;
  final isConnected = false.obs;

  @override
  void onInit() {
    super.onInit();
    printerService = Get.find<PrinterService>();
    _loadSavedPrinter();
    _checkConnection();
    _syncWithService();
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
        isConnected.value = isPaired;
        printerService.isConnected.value = isPaired;
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
        if (Get.context != null) {
          Get.snackbar(
            'Bluetooth Disabled',
            'Please enable Bluetooth to scan for devices',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
        isScanning.value = false;
        return;
      }

      final List<BluetoothInfo> allDevices =
          await PrintBluetoothThermal.pairedBluetooths ?? [];

      // Filter only printer devices
      final List<BluetoothInfo> printerDevices =
          allDevices.where((device) => _isPrinterDevice(device)).toList();

      availableDevices.value = printerDevices;

      if (printerDevices.isEmpty && Get.context != null) {
        Get.snackbar(
          'No Printers Found',
          'No paired Bluetooth printers found. Please pair a printer first.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      if (Get.context != null) {
        Get.snackbar(
          'Error',
          'Failed to scan for devices: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
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
        connectedDevice.value = device;
        isConnected.value = true;

        // Save printer to service
        await printerService.saveConnectedDevice(device);

        if (Get.context != null) {
          Get.snackbar(
            'Connected',
            'Successfully connected to ${device.name}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      } else {
        if (Get.context != null) {
          Get.snackbar(
            'Connection Failed',
            'Failed to connect to ${device.name}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      if (Get.context != null) {
        Get.snackbar(
          'Error',
          'Connection error: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
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

        if (Get.context != null) {
          Get.snackbar(
            'Disconnected',
            'Printer disconnected successfully',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      if (Get.context != null) {
        Get.snackbar(
          'Error',
          'Failed to disconnect: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> printTestReceipt() async {
    if (!isConnected.value || connectedDevice.value == null) {
      if (Get.context != null) {
        Get.snackbar(
          'Not Connected',
          'Please connect to a printer first',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
      return;
    }

    try {
      isLoading.value = true;

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

      if (Get.context != null) {
        if (result == true) {
          Get.snackbar(
            'Success',
            'Test print sent successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Failed',
            'Failed to send print',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      if (Get.context != null) {
        Get.snackbar(
          'Error',
          'Print error: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}
