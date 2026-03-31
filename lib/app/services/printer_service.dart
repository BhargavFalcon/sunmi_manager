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

  // Shared Settings
  final autoPrintKitchen = true.obs;
  final kitchenCopies = 1.obs;
  final kitchenWidth = '58mm'.obs;

  final autoPrintReceipt = true.obs;
  final receiptCopies = 1.obs;
  final receiptWidth = '58mm'.obs;

  final selectedKitchenPrinter = 'Internal Sunmi Printer'.obs;
  final selectedReceiptPrinter = 'Internal Sunmi Printer'.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _initService();
  }

  Future<void> _initService() async {
    isSunmi.value = await PrinterHelper.isSunmiDevice();
    await loadGeneralSettings();
    if (isSunmi.value) {
      await _autoSelectSunmiPrinter();
    }
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
          box.read(ArgumentConstant.selectedKitchenPrinterKey) ?? 'Internal Sunmi Printer';
      selectedReceiptPrinter.value =
          box.read(ArgumentConstant.selectedReceiptPrinterKey) ?? 'Internal Sunmi Printer';

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

  Future<bool> checkPrinterConnectivity(String? printerName) async {
    // Sunmi exclusive
    await SunmiPrinterPlus().rebindPrinter();
    return true;
  }
}
