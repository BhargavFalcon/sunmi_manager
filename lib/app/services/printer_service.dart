import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:managerapp/main.dart';
import '../constants/api_constants.dart';

class PrinterService extends GetxService with WidgetsBindingObserver {
  static const _maxRetries = 3;

  final isConnected = false.obs;
  BluetoothInfo? connectedDevice;
  bool _isConnecting = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadSavedPrinter();
    _connectWithRetry();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _connectWithRetry();
    }
  }

  /// Attempts to connect to saved printer with retries.
  Future<void> _connectWithRetry() async {
    if (connectedDevice == null) return;
    await Future.delayed(const Duration(seconds: 1));
    for (int i = 0; i < _maxRetries; i++) {
      await checkConnection();
      if (isConnected.value) return;
      await Future.delayed(Duration(seconds: 2 * (i + 1)));
    }
  }

  void _loadSavedPrinter() {
    try {
      final saved = box.read(ArgumentConstant.savedPrinterDeviceKey);
      if (saved is Map) {
        final mac = saved['macAddress'] as String?;
        final name = saved['name'] as String?;
        if (mac != null && name != null) {
          connectedDevice = BluetoothInfo(name: name, macAdress: mac);
        }
      }
    } catch (_) {}
  }

  Future<void> checkConnection() async {
    if (_isConnecting || connectedDevice == null) {
      if (connectedDevice == null) isConnected.value = false;
      return;
    }
    _isConnecting = true;
    try {
      final enabled = await PrintBluetoothThermal.bluetoothEnabled;
      if (enabled != true) {
        isConnected.value = false;
        return;
      }
      // Wake up BT cache (crucial for iOS)
      await PrintBluetoothThermal.pairedBluetooths;

      final connected = await PrintBluetoothThermal.connectionStatus;
      if (connected) {
        isConnected.value = true;
      } else {
        isConnected.value = await PrintBluetoothThermal.connect(
          macPrinterAddress: connectedDevice!.macAdress,
        );
      }
    } catch (_) {
      isConnected.value = false;
    } finally {
      _isConnecting = false;
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
