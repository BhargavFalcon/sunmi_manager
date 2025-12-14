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
      if (!bluetoothEnabled) {
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
      availableDevices.value =
          allDevices.where((device) => _isPrinterDevice(device)).toList();
    } catch (e) {
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
        await printerService.saveConnectedDevice(device);
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

  // Helper function to encode Euro symbol (€) to 0xD5 for CP858
  String _encodeEuroSymbol(String text) {
    return text.replaceAll('€', String.fromCharCode(0xD5));
  }

  // Helper function to create text with Euro symbol encoding if needed
  List<int> _createTextWithEuro(
    Generator generator,
    String text, {
    PosAlign align = PosAlign.left,
    bool bold = false,
    PosTextSize? height,
    PosTextSize? width,
    PosFontType? fontType,
  }) {
    // Only encode if text contains Euro symbol
    final encodedText = text.contains('€') ? _encodeEuroSymbol(text) : text;

    return generator.text(
      encodedText,
      styles: PosStyles(
        align: align,
        bold: bold,
        height: height ?? PosTextSize.size1,
        width: width ?? PosTextSize.size1,
        fontType: fontType ?? PosFontType.fontB,
      ),
    );
  }

  Future<void> printTestReceipt() async {
    if (connectedDevice.value == null) {
      safeGetSnackbar(
        'Printer Not Connected',
        'Please connect a printer first',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final isPaired = await PrintBluetoothThermal.connectionStatus;
      if (!isPaired) {
        final reconnectResult = await PrintBluetoothThermal.connect(
          macPrinterAddress: connectedDevice.value!.macAdress,
        );
        if (!reconnectResult) {
          safeGetSnackbar(
            'Connection Failed',
            'Could not connect to printer.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
        isConnected.value = true;
      }
    } catch (e) {
      safeGetSnackbar(
        'Connection Error',
        'Error checking printer connection',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      final profile = await CapabilityProfile.load();
      final generator = Generator(_getPaperSize(), profile);
      List<int> allBytes = [];

      for (int i = 0; i < numberOfCopies.value; i++) {
        List<int> bytes = [];

        // Enable condensed mode and set CP858 code table
        bytes += [0x0F]; // SI - Shift In (Enable condensed mode)
        bytes += [0x1B, 0x74, 0x13]; // ESC t 19 (CP858 code table)

        // Header Section - Business Name (Bold, Centered)
        bytes += _createTextWithEuro(
          generator,
          'Naan Stop',
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          fontType: PosFontType.fontB,
        );
        bytes += generator.feed(1);

        // Address (Centered)
        bytes += _createTextWithEuro(
          generator,
          'Winkelcentrum Woensel 1, 5625 AA Eindhoven, Netherlandsds',
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          fontType: PosFontType.fontB,
        );

        // Phone (Centered)
        bytes += _createTextWithEuro(
          generator,
          'Phone:626193494',
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          fontType: PosFontType.fontB,
        );

        // GST (Centered)
        bytes += _createTextWithEuro(
          generator,
          'GST: 24AGHPN',
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          fontType: PosFontType.fontB,
        );

        bytes += generator.hr(ch: '-');

        bytes += generator.row([
          PosColumn(
            text: 'Order: ORD-0218',
            width: 6,
            styles: PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB,
            ),
          ),
          PosColumn(
            text: '13 Dec 2025 06:06 PM',
            width: 6,
            styles: PosStyles(
              align: PosAlign.right,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB,
            ),
          ),
        ]);

        bytes += generator.text(
          'Customer: Bhargav thummar',
          styles: PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
            fontType: PosFontType.fontB,
          ),
        );
        bytes += generator.hr(ch: '-');

        bytes += generator.row([
          PosColumn(
            text: 'Qty',
            width: 2,
            styles: PosStyles(
              align: PosAlign.left,
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB,
            ),
          ),
          PosColumn(
            text: 'Item Name',
            width: 6,
            styles: PosStyles(
              align: PosAlign.left,
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB,
            ),
          ),
          PosColumn(
            text: 'Price',
            width: 2,
            styles: PosStyles(
              align: PosAlign.right,
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB,
            ),
          ),
          PosColumn(
            text: 'Amount',
            width: 2,
            styles: PosStyles(
              align: PosAlign.right,
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB,
            ),
          ),
        ]);
        bytes += generator.hr();

        // Item 1
        bytes += generator.row([
          PosColumn(
            text: '1',
            width: 1,
            styles: PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB,
            ),
          ),
          PosColumn(
            text: 'Naan Imperial (Steak, Egg, Ham, Cheese, Vegetable)',
            width: 7,
            styles: PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB,
            ),
          ),
          PosColumn(
            text: _encodeEuroSymbol('€9,50'),
            width: 2,
            styles: PosStyles(
              align: PosAlign.right,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB,
            ),
          ),
          PosColumn(
            text: _encodeEuroSymbol('€9,50'),
            width: 2,
            styles: PosStyles(
              align: PosAlign.right,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB,
            ),
          ),
        ]);

        // Item 2
        bytes += generator.row([
          PosColumn(
            text: '1',
            width: 1,
            styles: PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB,
            ),
          ),
          PosColumn(
            text: 'Naan Steak',
            width: 7,
            styles: PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB,
            ),
          ),
          PosColumn(
            text: _encodeEuroSymbol('€8,00'),
            width: 2,
            styles: PosStyles(
              align: PosAlign.right,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB,
            ),
          ),
          PosColumn(
            text: _encodeEuroSymbol('€8,00'),
            width: 2,
            styles: PosStyles(
              align: PosAlign.right,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB,
            ),
          ),
        ]);

        bytes += generator.feed(1);

        // Summary of Charges
        bytes += generator.row([
          PosColumn(
            text: 'Sub Total:',
            width: 8,
            styles: PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB,
            ),
          ),
          PosColumn(
            text: _encodeEuroSymbol('€17,50'),
            width: 4,
            styles: PosStyles(
              align: PosAlign.right,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB,
            ),
          ),
        ]);

        bytes += generator.row([
          PosColumn(
            text: 'Servicekosten :',
            width: 8,
            styles: PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB,
            ),
          ),
          PosColumn(
            text: _encodeEuroSymbol('€0,45'),
            width: 4,
            styles: PosStyles(
              align: PosAlign.right,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB,
            ),
          ),
        ]);

        bytes += generator.row([
          PosColumn(
            text: 'Boxes :',
            width: 8,
            styles: PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB,
            ),
          ),
          PosColumn(
            text: _encodeEuroSymbol('€1,00'),
            width: 4,
            styles: PosStyles(
              align: PosAlign.right,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB,
            ),
          ),
        ]);

        bytes += generator.row([
          PosColumn(
            text: 'VAT (5.00%) incl.',
            width: 8,
            styles: PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB,
            ),
          ),
          PosColumn(
            text: _encodeEuroSymbol('€0,83'),
            width: 4,
            styles: PosStyles(
              align: PosAlign.right,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB,
            ),
          ),
        ]);

        bytes += generator.row([
          PosColumn(
            text: 'Total Tax:',
            width: 8,
            styles: PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB,
            ),
          ),
          PosColumn(
            text: _encodeEuroSymbol('€0,83'),
            width: 4,
            styles: PosStyles(
              align: PosAlign.right,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB,
            ),
          ),
        ]);

        bytes += generator.row([
          PosColumn(
            text: 'Balance Returned:',
            width: 8,
            styles: PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB,
            ),
          ),
          PosColumn(
            text: _encodeEuroSymbol('€0,00'),
            width: 4,
            styles: PosStyles(
              align: PosAlign.right,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB,
            ),
          ),
        ]);

        bytes += generator.hr();

        // Total (Bold)
        bytes += generator.row([
          PosColumn(
            text: 'Total:',
            width: 8,
            styles: PosStyles(
              align: PosAlign.left,
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB,
            ),
          ),
          PosColumn(
            text: _encodeEuroSymbol('€18,95'),
            width: 4,
            styles: PosStyles(
              align: PosAlign.right,
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB,
            ),
          ),
        ]);

        bytes += generator.hr(ch: '-');

        // Footer - Thank you message
        bytes += _createTextWithEuro(
          generator,
          'Thank you for your visit!',
          align: PosAlign.center,
        );
        bytes += generator.feed(1);

        bytes += generator.row([
          PosColumn(
            text: 'Amount',
            width: 2,
            styles: PosStyles(
              align: PosAlign.left,
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB,
            ),
          ),
          PosColumn(
            text: 'Payment Method',
            width: 5,
            styles: PosStyles(
              align: PosAlign.center,
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB,
            ),
          ),
          PosColumn(
            text: 'Date & Time',
            width: 5,
            styles: PosStyles(
              align: PosAlign.right,
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB,
            ),
          ),
        ]);
        bytes += generator.hr();

        // Payment Details
        bytes += generator.row([
          PosColumn(
            text: _encodeEuroSymbol('€18,95'),
            width: 2,
            styles: PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB,
            ),
          ),
          PosColumn(
            text: 'Cash',
            width: 3,
            styles: PosStyles(
              align: PosAlign.center,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB,
            ),
          ),
          PosColumn(
            text: '13 Dec 2025 05:06 PM',
            width: 7,
            styles: PosStyles(
              align: PosAlign.right,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              fontType: PosFontType.fontB,
            ),
          ),
        ]);

        // Disable condensed mode before cut
        bytes += [0x12]; // DC2 - Device Control 2 (Disable condensed mode)
        bytes += generator.cut();
        allBytes.addAll(bytes);
      }

      final result = await PrintBluetoothThermal.writeBytes(allBytes);
      if (result == true) {
        safeGetSnackbar(
          'Print Sent',
          'Receipt sent successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        safeGetSnackbar(
          'Print Failed',
          'Failed to send print data',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Print error: $e');
      safeGetSnackbar(
        'Print Error',
        'Error: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
