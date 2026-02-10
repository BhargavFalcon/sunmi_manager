import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../main.dart';
import '../../../constants/api_constants.dart';
import '../../../data/NetworkClient.dart';

/// Single printer mapping row: kitchen + assigned local printer + thermal + test.
class PrinterMappingModel {
  PrinterMappingModel({
    required this.id,
    required this.kitchenName,
    required this.printerAlias,
    this.assignedLocalPrinter,
    this.isThermal = true,
  });
  final String id;
  final String kitchenName;
  final String printerAlias;
  String? assignedLocalPrinter;
  bool isThermal;
}

class PrintServiceController extends GetxController {
  final networkClient = NetworkClient();
  final isLoading = false.obs;
  final isConnected = false.obs;
  final isConfiguring = false.obs;
  final errorMessage = ''.obs;

  /// Printer fetch state for Printer Setup section
  final isFetchingPrinters = false.obs;
  /// Non-empty when fetch failed (e.g. "1" for "Failed to fetch printers. 1")
  final printersFetchError = ''.obs;

  /// When fetch succeeds: list of printer mappings and available local printer names
  final printerMappings = <PrinterMappingModel>[].obs;
  final localPrinterNames = <String>[].obs;

  /// Cash drawer: open after print toggle
  final openDrawerAfterPrint = false.obs;

  final domainController = TextEditingController();
  final apiKeyController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadConnection();
  }

  void _loadConnection() {
    final savedUrl = box.read(ArgumentConstant.printServiceUrlKey);
    final savedKey = box.read(ArgumentConstant.printServiceApiKeyKey);
    final savedStatus =
        box.read(ArgumentConstant.isPrintServiceConnectedKey) ?? false;
    final savedOpenDrawer =
        box.read(ArgumentConstant.printServiceOpenDrawerAfterPrintKey) ??
            false;

    if (savedUrl != null) domainController.text = savedUrl;
    if (savedKey != null) apiKeyController.text = savedKey;
    isConnected.value = savedStatus;
    openDrawerAfterPrint.value = savedOpenDrawer;

    if (!isConnected.value) {
      isConfiguring.value = true;
    } else {
      fetchPrinters();
    }
  }

  Future<void> fetchPrinters() async {
    if (!isConnected.value) return;
    try {
      isFetchingPrinters.value = true;
      printersFetchError.value = '';
      // In a real app this would call the print service API to list printers
      await Future.delayed(const Duration(milliseconds: 800));
      // Simulate success: populate mappings and local printers
      const usbPrinter = 'STMicroelectronics_USB_Portable_Printer';
      localPrinterNames.value = [usbPrinter, 'Other_Local_Printer'];
      printerMappings.value = [
        PrinterMappingModel(
          id: '1',
          kitchenName: 'Brother Printer',
          printerAlias: 'Brother Printer',
          assignedLocalPrinter: usbPrinter,
          isThermal: true,
        ),
        PrinterMappingModel(
          id: '2',
          kitchenName: '3rd Printer',
          printerAlias: '3rd Printer',
          assignedLocalPrinter: usbPrinter,
          isThermal: true,
        ),
      ];
      // On real API failure set: printersFetchError.value = '1';
    } catch (e) {
      printersFetchError.value = '1';
      printerMappings.clear();
      localPrinterNames.clear();
    } finally {
      isFetchingPrinters.value = false;
    }
  }

  void setMappingAssignedPrinter(String mappingId, String? printerName) {
    final idx = printerMappings.indexWhere((m) => m.id == mappingId);
    if (idx >= 0) printerMappings[idx].assignedLocalPrinter = printerName;
    printerMappings.refresh();
  }

  void setMappingThermal(String mappingId, bool value) {
    final idx = printerMappings.indexWhere((m) => m.id == mappingId);
    if (idx >= 0) printerMappings[idx].isThermal = value;
    printerMappings.refresh();
  }

  void testPrint(String mappingId) {
    // TODO: call print service test print API
  }

  void setOpenDrawerAfterPrint(bool value) {
    openDrawerAfterPrint.value = value;
    box.write(ArgumentConstant.printServiceOpenDrawerAfterPrintKey, value);
  }

  Future<void> testConnection() async {
    if (domainController.text.isEmpty || apiKeyController.text.isEmpty) {
      errorMessage.value = 'Please enter both Domain URL and API Key';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // In a real scenario, we would call a health check API on the print service
      // For now, we simulate a successful connection
      await Future.delayed(const Duration(seconds: 1));

      isConnected.value = true;
      box.write(ArgumentConstant.printServiceUrlKey, domainController.text);
      box.write(ArgumentConstant.printServiceApiKeyKey, apiKeyController.text);
      box.write(ArgumentConstant.isPrintServiceConnectedKey, true);

      // Transition to status view on success
      isConfiguring.value = false;
    } catch (e) {
      isConnected.value = false;
      errorMessage.value = 'Connection failed. Please check your settings.';
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
    domainController.dispose();
    apiKeyController.dispose();
    super.onClose();
  }
}
