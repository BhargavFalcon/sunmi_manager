import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/main.dart';
import '../constants/api_constants.dart';
import 'package:managerapp/app/utils/printer_helper.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import '../data/NetworkClient.dart';

class PrinterService extends GetxService with WidgetsBindingObserver {
  final NetworkClient _networkClient = NetworkClient();

  // --- Reactive States ---
  final isSunmi = true.obs;

  // KOT / Kitchen Print Settings (via Sunmi SDK)
  final autoPrintKitchen = true.obs;
  final kitchenCopies = 1.obs;
  final kitchenWidth = '80mm'.obs;

  // Receipt / Order Print Settings (via Sunmi SDK)
  final autoPrintReceipt = true.obs;
  final receiptCopies = 1.obs;
  final receiptWidth = '80mm'.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _initService();
  }

  Future<void> _initService() async {
    isSunmi.value = await PrinterHelper.isSunmiDevice();
    await loadGeneralSettings();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  Future<void> loadGeneralSettings() async {
    try {
      // Load local hardware settings
      kitchenWidth.value =
          box.read(ArgumentConstant.kitchenPaperWidthKey) ?? '80mm';
      receiptWidth.value =
          box.read(ArgumentConstant.orderPaperWidthKey) ??
          box.read(ArgumentConstant.printerWidthKey) ??
          '80mm';

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
      box.write(ArgumentConstant.printerWidthKey, receiptWidth.value);

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

  /// Checks Sunmi printer connectivity
  Future<bool> checkPrinterConnectivity([String? printerName]) async {
    if (isSunmi.value) {
      await SunmiPrinterPlus().rebindPrinter();
      return true;
    }
    return false;
  }
}
