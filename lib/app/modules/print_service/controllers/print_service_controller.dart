import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/services/printer_service.dart';
import 'package:managerapp/main.dart';
import '../../../constants/api_constants.dart';
import '../../../widgets/app_toast.dart';
import '../../../constants/translation_keys.dart';
import '../../../model/print_service_validate_model.dart';

class PrintServiceController extends GetxController {
  late PrinterService printerService;

  RxBool get isSunmi => printerService.isSunmi;
  RxBool get autoPrintKitchen => printerService.autoPrintKitchen;
  RxInt get kitchenNumberOfCopies => printerService.kitchenCopies;
  RxString get kitchenPaperWidth => printerService.kitchenWidth;
  RxString get receiverPaperWidth => printerService.receiptWidth;
  RxString get orderPaperWidth => printerService.receiptWidth;
  RxBool get autoPrintReceiptWhenPaid => printerService.autoPrintReceipt;
  RxInt get receiptNumberOfCopies => printerService.receiptCopies;

  final connectedPrinters = <Map<String, String>>[].obs;
  RxString get selectedKitchenPrinter => printerService.selectedKitchenPrinter;
  RxString get selectedReceiptPrinter => printerService.selectedReceiptPrinter;

  // --- Print Service Connection States ---
  final apiKeyController = TextEditingController();
  DeviceInfoPlugin? _deviceInfo;
  Dio? _dio;

  final isConnected = false.obs;
  final isConfiguring = false.obs;
  final errorMessage = "".obs;
  final connectionLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    printerService = Get.find<PrinterService>();
    _initDio();
    _loadConnection();
    _loadConnectedPrinters();
  }

  void _initDio() {
    _dio = Dio(BaseOptions(
      baseUrl: ArgumentConstant.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
  }

  void _loadConnection() {
    final savedApiKey = box.read(ArgumentConstant.printServiceApiKeyKey);
    final isConn = box.read(ArgumentConstant.isPrintServiceConnectedKey) ?? false;

    if (savedApiKey != null) {
      apiKeyController.text = savedApiKey;
      isConnected.value = isConn;
    }
  }

  void _loadConnectedPrinters() {
    connectedPrinters.clear();
    if (isSunmi.value) {
      connectedPrinters.add({
        'name': 'Internal Sunmi Printer',
        'type': 'Internal',
        'address': 'Internal',
      });
    }
    update();
  }

  Future<void> testConnection() async {
    final apiKey = apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      errorMessage.value = TranslationKeys.apiKeyRequired.tr;
      return;
    }

    connectionLoading.value = true;
    errorMessage.value = "";

    try {
      final deviceId = await _getDeviceId();
      final deviceName = await _getDeviceName();

      final response = await _dio!.post(
        ArgumentConstant.printServiceVerifyEndpoint,
        data: {
          "api_key": apiKey,
          "device_id": deviceId,
          "device_name": deviceName,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final model = PrintServiceValidateModel.fromJson(data);

        if (model.success != true || model.data == null) {
          errorMessage.value = model.message ?? "Verification failed";
          isConnected.value = false;
        } else {
          // Success
          isConnected.value = true;
          isConfiguring.value = false;
          box.write(ArgumentConstant.printServiceApiKeyKey, apiKey);
          box.write(ArgumentConstant.isPrintServiceConnectedKey, true);
          if (model.data!.token != null) {
            box.write(ArgumentConstant.printServiceTokenKey, model.data!.token);
          }
          AppToast.showSuccess(TranslationKeys.success.tr);
        }
      } else {
        errorMessage.value = "Server returned ${response.statusCode}";
        isConnected.value = false;
      }
    } catch (e) {
      errorMessage.value = "Connection error: ${e.toString()}";
      isConnected.value = false;
    } finally {
      connectionLoading.value = false;
    }
  }

  Future<void> disconnectOldAndConnect() async {
    // Optional: add actual disconnect API call if needed
    await testConnection();
  }

  void toggleConfigure() {
    isConfiguring.value = !isConfiguring.value;
  }

  void done() {
    isConfiguring.value = false;
  }

  String get maskedApiKey {
    final key = apiKeyController.text;
    if (key.length <= 8) return key;
    return "${key.substring(0, 4)}****${key.substring(key.length - 4)}";
  }

  Future<String> _getDeviceId() async {
    _deviceInfo ??= DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo!.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo!.iosInfo;
      return iosInfo.identifierForVendor ?? "ios-device";
    }
    return "unknown-device";
  }

  Future<String> _getDeviceName() async {
    _deviceInfo ??= DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo!.androidInfo;
      return "${androidInfo.brand} ${androidInfo.model}";
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo!.iosInfo;
      return iosInfo.name;
    }
    return "unknown-device";
  }

  Future<void> saveSettings({bool showToast = true}) async {
    await printerService.saveGeneralSettings();
    if (showToast) AppToast.showSuccess(TranslationKeys.success.tr);
  }

  void onPrinterSelected(String section, String? printerName) async {
    if (printerName == null) return;
    if (section == 'kitchen') {
      selectedKitchenPrinter.value = printerName;
    } else {
      selectedReceiptPrinter.value = printerName;
    }
    AppToast.showSuccess('Printer "$printerName" selected.');
  }

  void toggleAutoPrintKitchen() => printerService.toggleAutoPrintKitchen();
  void incrementKitchenCopies() => printerService.incrementKitchenCopies();
  void decrementKitchenCopies() => printerService.decrementKitchenCopies();
  void toggleAutoPrintReceiptWhenPaid() =>
      printerService.toggleAutoPrintReceipt();
  void incrementReceiptCopies() => printerService.incrementReceiptCopies();
  void decrementReceiptCopies() => printerService.decrementReceiptCopies();
}
