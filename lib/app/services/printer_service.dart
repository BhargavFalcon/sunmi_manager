import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
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
      if (kDebugMode) {
        print('Error loading saved printer: $e');
      }
    }
  }

  Future<void> _checkConnection() async {
    try {
      if (connectedDevice != null) {
        final isPaired = await PrintBluetoothThermal.connectionStatus;
        if (!isPaired) {
          final result = await PrintBluetoothThermal.connect(
            macPrinterAddress: connectedDevice!.macAdress,
          );
          isConnected.value = result;
        } else {
          isConnected.value = true;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking connection: $e');
      }
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
}
