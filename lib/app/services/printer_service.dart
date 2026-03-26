import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:managerapp/main.dart';
import '../constants/api_constants.dart';
import 'dart:io';
import 'dart:convert';
import 'package:managerapp/app/model/wifi_printer_model.dart';
import 'package:managerapp/app/utils/printer_helper.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import '../data/NetworkClient.dart';

class PrinterService extends GetxService with WidgetsBindingObserver {
  static const _maxRetries = 3;
  final NetworkClient _networkClient = NetworkClient();

  // --- Reactive States ---
  final isConnected = false.obs;
  BluetoothInfo? connectedDevice;
  bool _isConnecting = false;

  final isSunmi = false.obs;

  // Shared Settings
  final autoPrintKitchen = true.obs;
  final kitchenCopies = 1.obs;
  final kitchenWidth = '58mm'.obs;

  final autoPrintReceipt = true.obs;
  final receiptCopies = 1.obs;
  final receiptWidth = '58mm'.obs;

  final selectedKitchenPrinter = ''.obs;
  final selectedReceiptPrinter = ''.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _initService();
  }

  Future<void> _initService() async {
    isSunmi.value = await PrinterHelper.isSunmiDevice();
    _loadSavedPrinter();
    await loadGeneralSettings();
    if (isSunmi.value) {
      await _autoSelectSunmiPrinter();
    }
    _connectWithRetry();
  }

  /// On Sunmi devices, auto-set kitchen and receipt printers to 'Internal Sunmi Printer'
  /// if they haven't been explicitly set yet (or have a legacy value).
  Future<void> _autoSelectSunmiPrinter() async {
    bool changed = false;
    const validInternalPrinter = 'Internal Sunmi Printer';
    final legacyValues = {'', 'Internal', 'Sunmi'};

    if (legacyValues.contains(selectedKitchenPrinter.value)) {
      selectedKitchenPrinter.value = validInternalPrinter;
      box.write(
        ArgumentConstant.selectedKitchenPrinterKey,
        validInternalPrinter,
      );
      changed = true;
    }
    if (legacyValues.contains(selectedReceiptPrinter.value)) {
      selectedReceiptPrinter.value = validInternalPrinter;
      box.write(
        ArgumentConstant.selectedReceiptPrinterKey,
        validInternalPrinter,
      );
      changed = true;
    }
    if (changed) {
      await saveGeneralSettings();
    }
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

  Future<void> loadGeneralSettings() async {
    try {
      // Load local hardware settings
      kitchenWidth.value =
          box.read(ArgumentConstant.kitchenPaperWidthKey) ??
          box.read(ArgumentConstant.printerWidthKey) ??
          '58mm';
      receiptWidth.value =
          box.read(ArgumentConstant.orderPaperWidthKey) ??
          box.read(ArgumentConstant.printerWidthKey) ??
          '58mm';

      selectedKitchenPrinter.value =
          box.read(ArgumentConstant.selectedKitchenPrinterKey) ?? '';
      selectedReceiptPrinter.value =
          box.read(ArgumentConstant.selectedReceiptPrinterKey) ?? '';

      // Sync auto-print settings from API (only if authenticated)
      if (box.hasData(ArgumentConstant.tokenKey)) {
        final response = await _networkClient.get(
          ArgumentConstant.autoPrintSettingsEndpoint,
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = response.data['data'];
          if (data != null) {
            autoPrintKitchen.value = data['auto_print_kot'] ?? true;
            kitchenCopies.value = data['kot_print_copies'] ?? 1;
            autoPrintReceipt.value = data['auto_print_receipt'] ?? true;
            receiptCopies.value = data['receipt_print_copies'] ?? 1;
          }
        }
      }
    } catch (_) {}
  }

  Future<void> saveGeneralSettings() async {
    try {
      // Save local hardware settings
      box.write(ArgumentConstant.kitchenPaperWidthKey, kitchenWidth.value);
      box.write(ArgumentConstant.orderPaperWidthKey, receiptWidth.value);
      box.write(
        ArgumentConstant.selectedKitchenPrinterKey,
        selectedKitchenPrinter.value,
      );
      box.write(
        ArgumentConstant.selectedReceiptPrinterKey,
        selectedReceiptPrinter.value,
      );

      // Save to API for auto print settings (only if authenticated)
      if (box.hasData(ArgumentConstant.tokenKey)) {
        await _networkClient.patch(
          ArgumentConstant.autoPrintSettingsEndpoint,
          data: {
            "auto_print_kot": autoPrintKitchen.value,
            "kot_print_copies": kitchenCopies.value,
            "auto_print_receipt": autoPrintReceipt.value,
            "receipt_print_copies": receiptCopies.value,
          },
        );
      }
    } catch (_) {}
  }

  // --- Helper Methods ---
  void toggleAutoPrintKitchen() {
    autoPrintKitchen.value = !autoPrintKitchen.value;
  }

  void incrementKitchenCopies() {
    if (kitchenCopies.value < 5) {
      kitchenCopies.value++;
    }
  }

  void decrementKitchenCopies() {
    if (kitchenCopies.value > 1) {
      kitchenCopies.value--;
    }
  }

  void setKitchenWidth(String width) {
    kitchenWidth.value = width;
  }

  void toggleAutoPrintReceipt() {
    autoPrintReceipt.value = !autoPrintReceipt.value;
  }

  void incrementReceiptCopies() {
    if (receiptCopies.value < 5) {
      receiptCopies.value++;
    }
  }

  void decrementReceiptCopies() {
    if (receiptCopies.value > 1) {
      receiptCopies.value--;
    }
  }

  void setReceiptWidth(String width) {
    receiptWidth.value = width;
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

  Future<bool> checkPrinterConnectivity(String? printerName) async {
    // 1) Internal (Sunmi) — use cached value to avoid repeated device-info lookups
    if (isSunmi.value) {
      if (printerName == null ||
          printerName.isEmpty ||
          printerName == 'Internal' ||
          printerName == 'Sunmi' ||
          printerName == 'Internal Sunmi Printer') {
        await SunmiPrinterPlus().rebindPrinter();
        return true;
      }
    }

    if (printerName == null || printerName.isEmpty) return false;

    // 2) Bluetooth
    if (connectedDevice != null && connectedDevice!.name == printerName) {
      await checkConnection();
      return isConnected.value;
    }

    // 3) WiFi
    final wifiJson = box.read(ArgumentConstant.savedWifiPrintersKey);
    if (wifiJson != null && wifiJson is String) {
      try {
        final List<dynamic> decoded = jsonDecode(wifiJson);
        final printers =
            decoded.map((e) => WifiPrinterModel.fromJson(e)).toList();
        final printer = printers.firstWhereOrNull((p) => p.name == printerName);

        if (printer != null) {
          try {
            final socket = await Socket.connect(
              printer.ipAddress,
              int.tryParse(printer.port) ?? 9100,
              timeout: const Duration(seconds: 2),
            );
            socket.destroy();
            return true;
          } catch (_) {
            return false;
          }
        }
      } catch (_) {}
    }

    return false;
  }
}
