import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../main.dart';
import '../../../constants/api_constants.dart';
import '../../../model/print_service_validate_model.dart';
import '../../../services/printer_service.dart';

class PrintServiceController extends GetxController {
  final isLoading = false.obs;
  final isConnected = false.obs;
  final isConfiguring = false.obs;
  final errorMessage = ''.obs;

  final printerMappings = <PrinterSetting>[].obs;
  final localPrinterNames = <String>[].obs;

  final assignedLocalPrinterMap = <String, String>{}.obs;

  /// Cash drawer: open after print toggle
  final openDrawerAfterPrint = false.obs;

  final apiKeyController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadConnection();
  }

  void _loadConnection() {
    final savedKey = box.read(ArgumentConstant.printServiceApiKeyKey);
    final savedStatus =
        box.read(ArgumentConstant.isPrintServiceConnectedKey) ?? false;
    final savedOpenDrawer =
        box.read(ArgumentConstant.printServiceOpenDrawerAfterPrintKey) ?? false;

    if (savedKey != null) apiKeyController.text = savedKey;
    isConnected.value = savedStatus;
    openDrawerAfterPrint.value = savedOpenDrawer;

    if (!isConnected.value) {
      isConfiguring.value = true;
    } else {
      _loadSavedPrinterMappings();
      _loadLocalPrinterNames();
    }
  }

  void _loadSavedPrinterMappings() {
    final saved = box.read(ArgumentConstant.printServicePrinterSettingsKey);
    if (saved is List && saved.isNotEmpty) {
      try {
        printerMappings.value =
            saved
                .map((e) => PrinterSetting.fromJson(e as Map<String, dynamic>))
                .toList();
      } catch (_) {
        printerMappings.clear();
      }
    } else {
      printerMappings.clear();
    }
  }

  void _loadLocalPrinterNames() {
    // Same source as Manage Printer screen: PrinterService + savedPrinterDeviceKey
    final names = <String>[];
    if (Get.isRegistered<PrinterService>()) {
      final printerService = Get.find<PrinterService>();
      if (printerService.isConnected.value &&
          printerService.connectedDevice != null) {
        names.add(printerService.connectedDevice!.name);
      }
    }
    if (names.isEmpty) {
      final saved = box.read(ArgumentConstant.savedPrinterDeviceKey);
      if (saved is Map && saved['name'] != null) {
        names.add(saved['name'] as String);
      }
    }
    localPrinterNames.value = names;
  }

  String? getAssignedLocalPrinter(String mappingId) =>
      assignedLocalPrinterMap[mappingId];

  void setMappingAssignedPrinter(String mappingId, String? printerName) {
    if (printerName != null) {
      assignedLocalPrinterMap[mappingId] = printerName;
    } else {
      assignedLocalPrinterMap.remove(mappingId);
    }
    assignedLocalPrinterMap.refresh();
  }

  void setOpenDrawerAfterPrint(bool value) {
    openDrawerAfterPrint.value = value;
    box.write(ArgumentConstant.printServiceOpenDrawerAfterPrintKey, value);
  }

  /// Constant device ID – never changes. Uses OS-level id so it survives app uninstall/reinstall.
  /// Android: ANDROID_ID (same after reinstall). iOS: identifierForVendor. Windows/macOS: device id.
  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        final id = android.id;
        if (id.isNotEmpty) return id;
      }
      if (Platform.isIOS) {
        final ios = await deviceInfo.iosInfo;
        final id = ios.identifierForVendor;
        if (id != null && id.isNotEmpty) return id;
      }
      if (Platform.isWindows) {
        final win = await deviceInfo.windowsInfo;
        return win.deviceId;
      }
      if (Platform.isMacOS) {
        final mac = await deviceInfo.macOsInfo;
        final guid = mac.systemGUID;
        if (guid != null && guid.isNotEmpty) return guid;
        return mac.model;
      }
    } catch (_) {}
    return 'unknown';
  }

  Future<String> _getDeviceName() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        final name = '${android.manufacturer} ${android.model}'.trim();
        return name.isEmpty ? 'Android Device' : name;
      }
      if (Platform.isIOS) {
        final ios = await deviceInfo.iosInfo;
        return ios.name.isNotEmpty ? ios.name : 'iPhone';
      }
      if (Platform.isWindows) {
        final win = await deviceInfo.windowsInfo;
        return win.computerName;
      }
      if (Platform.isMacOS) {
        final mac = await deviceInfo.macOsInfo;
        return mac.computerName.isNotEmpty ? mac.computerName : mac.model;
      }
    } catch (_) {}
    return 'Unknown Device';
  }

  Future<void> testConnection() async {
    if (apiKeyController.text.trim().isEmpty) {
      errorMessage.value = 'Please enter API Key';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final deviceId = await _getDeviceId();
      final deviceName = await _getDeviceName();
      final apiKey = apiKeyController.text.trim();

      // Use a separate Dio instance so we do NOT send auth token (only X-Branch-Key).
      final dio = Dio(
        BaseOptions(
          baseUrl: ArgumentConstant.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-Branch-Key': apiKey,
          },
        ),
      );

      final response = await dio.post<Map<String, dynamic>>(
        ArgumentConstant.printServiceVerifyEndpoint,
        data: {'device_id': deviceId, 'device_name': deviceName},
      );

      final data = response.data;
      if (data == null) {
        errorMessage.value = 'Invalid response from server.';
        return;
      }

      final model = PrintServiceValidateModel.fromJson(data);
      if (model.success != true || model.data == null) {
        errorMessage.value =
            model.message ?? 'Connection failed. Please check your API key.';
        return;
      }

      isConnected.value = true;
      box.write(ArgumentConstant.printServiceApiKeyKey, apiKey);
      if (model.data!.token != null) {
        box.write(ArgumentConstant.printServiceTokenKey, model.data!.token);
      }
      box.write(ArgumentConstant.isPrintServiceConnectedKey, true);

      final settings = model.data!.printerSettings;
      if (settings != null && settings.isNotEmpty) {
        final active = settings.where((s) => s.isActive == true).toList();
        printerMappings.value = active;
        box.write(
          ArgumentConstant.printServicePrinterSettingsKey,
          active.map((s) => s.toJson()).toList(),
        );
      } else {
        printerMappings.clear();
        box.remove(ArgumentConstant.printServicePrinterSettingsKey);
      }
      isConfiguring.value = false;
    } on DioException catch (e) {
      isConnected.value = false;
      final msg =
          e.response?.data is Map
              ? (e.response!.data as Map)['message']?.toString()
              : null;
      errorMessage.value =
          msg ??
          e.message ??
          'Connection failed. Please check your API key and network.';
    } catch (e) {
      isConnected.value = false;
      errorMessage.value =
          'Connection failed. Please check your API key and network.';
    } finally {
      isLoading.value = false;
    }
  }

  void toggleConfigure() {
    isConfiguring.value = true;
  }

  void done() {
    if (isConnected.value) {
      isConfiguring.value = false;
    }
  }

  String get maskedApiKey {
    if (apiKeyController.text.length <= 8) return '********';
    return '${apiKeyController.text.substring(0, 8)}***';
  }

  @override
  void onClose() {
    apiKeyController.dispose();
    super.onClose();
  }
}
