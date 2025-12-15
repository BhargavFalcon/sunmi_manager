import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/main.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../../../services/printer_service.dart';
import '../../../constants/api_constants.dart';
import '../../../constants/sizeConstant.dart';
import '../../../constants/color_constant.dart';

class PrinterScreenController extends GetxController {
  late PrinterService printerService;
  final isLoading = false.obs;
  final isScanning = false.obs;
  final connectedDevice = Rxn<BluetoothInfo>();
  final availableDevices = <BluetoothInfo>[].obs;
  final isConnected = false.obs;
  final autoPrint = true.obs;
  final numberOfCopies = 1.obs;
  final printerWidth = '58mm'.obs;
  final printerWidthOptions = ['58mm', '72mm', '80mm'];

  // Constants
  static const _bluetoothInitDelay = Duration(milliseconds: 50);
  static const _bluetoothEnableDelay = Duration(seconds: 1);
  static const _bluetoothPollInterval = Duration(milliseconds: 500);
  static const _bluetoothPollMaxAttempts = 20;
  static const _methodChannelName = 'com.dinemetrics.manager/bluetooth';

  @override
  void onInit() {
    super.onInit();
    printerService = Get.find<PrinterService>();
    _loadSavedPrinter();
    _loadSettings();
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
        _resetConnection();
        _showSnackbar(
          'Bluetooth Disabled',
          'Please enable Bluetooth to use printer features',
          Colors.orange,
        );
      } else {
        await _checkConnection();
      }
    } catch (e) {
      _resetConnection();
    }
  }

  void _resetConnection() {
    isConnected.value = false;
    connectedDevice.value = null;
    printerService.isConnected.value = false;
  }

  void _loadSettings() {
    try {
      autoPrint.value = box.read(ArgumentConstant.printerAutoPrintKey) ?? true;
      numberOfCopies.value =
          box.read(ArgumentConstant.printerNumberOfCopiesKey) ?? 1;
      printerWidth.value = box.read(ArgumentConstant.printerWidthKey) ?? '58mm';
    } catch (e) {
      // Silent fail - use defaults
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
      // Silent fail
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
      // Silent fail
    }
  }

  Future<void> _checkConnection() async {
    try {
      if (connectedDevice.value == null) return;

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
    } catch (e) {
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
        _resetConnection();
        _showSnackbar(
          'Bluetooth Disabled',
          'Please enable Bluetooth to scan for printers',
          Colors.orange,
        );
        return;
      }

      final List<BluetoothInfo> allDevices =
          await PrintBluetoothThermal.pairedBluetooths;
      availableDevices.value = allDevices.where(_isPrinterDevice).toList();
    } catch (e) {
      // Silent fail
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
        _showSnackbar(
          'Success',
          'Printer connected successfully',
          Colors.green,
        );
      } else {
        _showSnackbar('Error', 'Failed to connect to printer', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Error', 'Failed to connect to printer', Colors.red);
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
      // Silent fail
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
    // Check Bluetooth status
    try {
      final bool bluetoothEnabled =
          await PrintBluetoothThermal.bluetoothEnabled;
      if (!bluetoothEnabled) {
        _showBluetoothEnableDialog();
        return;
      }
    } catch (e) {
      _showBluetoothEnableDialog();
      return;
    }

    // Check if printer is connected
    if (connectedDevice.value == null) {
      _showSnackbar(
        'Printer Not Connected',
        'Please connect a printer first',
        Colors.orange,
      );
      return;
    }

    // Ensure connection is active
    try {
      final isPaired = await PrintBluetoothThermal.connectionStatus;
      if (!isPaired) {
        final reconnectResult = await PrintBluetoothThermal.connect(
          macPrinterAddress: connectedDevice.value!.macAdress,
        );
        if (!reconnectResult) {
          _showSnackbar(
            'Connection Failed',
            'Could not connect to printer.',
            Colors.red,
          );
          return;
        }
        isConnected.value = true;
      }
    } catch (e) {
      _showSnackbar(
        'Connection Error',
        'Error checking printer connection',
        Colors.red,
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
        _showSnackbar('Print Sent', 'Receipt sent successfully', Colors.green);
      } else {
        _showSnackbar('Print Failed', 'Failed to send print data', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Print Error', 'Error: ${e.toString()}', Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> printSunmiTestReceipt() async {
    try {
      isLoading.value = true;

      await SunmiPrinter.printText(
        'Naan Stop',
        style: SunmiTextStyle(
          align: SunmiPrintAlign.CENTER,
          fontSize: 30,
          bold: true,
        ),
      );
      await SunmiPrinter.lineWrap(5);
      await SunmiPrinter.printText(
        'Winkelcentrum Woensel 15625 AA Eindhoven, Netherlandsds',
        style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 22),
      );
      await SunmiPrinter.lineWrap(5);
      await SunmiPrinter.printText(
        'Phone:626193494',
        style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 22),
      );
      await SunmiPrinter.lineWrap(5);
      await SunmiPrinter.printText(
        'GST: 24AGHPN',
        style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 22),
      );
      await SunmiPrinter.lineWrap(2);
      await SunmiPrinter.printText("--------------------------------");
      await SunmiPrinter.lineWrap(2);
      await SunmiPrinter.printText(
        'Order: ORD-0218  13 Dec 2025 06:06 PM',
        style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 20),
      );
      await SunmiPrinter.lineWrap(3);
      await SunmiPrinter.printText(
        'Customer: Bhargav thummar',
        style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 20),
      );
      await SunmiPrinter.lineWrap(2);
      await SunmiPrinter.printText("--------------------------------");
      await SunmiPrinter.lineWrap(2);
      await SunmiPrinter.printText(
        'Qty   Item Name       Price    Amount',
        style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 20),
      );
      await SunmiPrinter.lineWrap(2);
      await SunmiPrinter.printText("--------------------------------");
      await SunmiPrinter.lineWrap(2);
      await SunmiPrinter.printRow(
        cols: [
          SunmiColumn(
            text: '1',
            width: 3,
            style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
          ),
          SunmiColumn(
            text: 'Naan Imperial (Steak, Egg, Ham, Cheese, Vegetable)',
            width: 15,
            style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
          ),
          SunmiColumn(
            text: '€9,50',
            width: 7,
            style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
          ),
          SunmiColumn(
            text: '€9,50',
            width: 7,
            style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
          ),
        ],
      );
      await SunmiPrinter.printRow(
        cols: [
          SunmiColumn(
            text: '1',
            width: 3,
            style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
          ),
          SunmiColumn(
            text: 'Naan Steak',
            width: 16,
            style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
          ),
          SunmiColumn(
            text: '€8,00',
            width: 6,
            style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
          ),
          SunmiColumn(
            text: '€8,00',
            width: 7,
            style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
          ),
        ],
      );
      await SunmiPrinter.lineWrap(20);
      await SunmiPrinter.printRow(
        cols: [
          SunmiColumn(
            text: 'Sub Total:',
            width: 25,
            style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
          ),
          SunmiColumn(
            text: '€17,50',
            width: 7,
            style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
          ),
        ],
      );

      await SunmiPrinter.printRow(
        cols: [
          SunmiColumn(
            text: 'Servicekosten:',
            width: 25,
            style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
          ),
          SunmiColumn(
            text: '€0,45',
            width: 7,
            style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
          ),
        ],
      );

      await SunmiPrinter.printRow(
        cols: [
          SunmiColumn(
            text: 'Boxes:',
            width: 25,
            style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
          ),
          SunmiColumn(
            text: '€1,00',
            width: 7,
            style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
          ),
        ],
      );

      await SunmiPrinter.printRow(
        cols: [
          SunmiColumn(
            text: 'VAT (5.00%) incl.',
            width: 25,
            style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
          ),
          SunmiColumn(
            text: '€0,83',
            width: 7,
            style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
          ),
        ],
      );

      await SunmiPrinter.printRow(
        cols: [
          SunmiColumn(
            text: 'Total Tax:',
            width: 25,
            style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
          ),
          SunmiColumn(
            text: '€0,83',
            width: 7,
            style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
          ),
        ],
      );

      await SunmiPrinter.printRow(
        cols: [
          SunmiColumn(
            text: 'Balance Returned:',
            width: 25,
            style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
          ),
          SunmiColumn(
            text: '€0,00',
            width: 7,
            style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
          ),
        ],
      );
      await SunmiPrinter.printText("--------------------------------");
      await SunmiPrinter.lineWrap(4);
      await SunmiPrinter.printRow(
        cols: [
          SunmiColumn(
            text: 'Total:',
            width: 25,
            style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, bold: true),
          ),
          SunmiColumn(
            text: '€18,95',
            width: 7,
            style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT, bold: true),
          ),
        ],
      );
      await SunmiPrinter.lineWrap(2);
      await SunmiPrinter.printText("--------------------------------");
      await SunmiPrinter.lineWrap(2);
      await SunmiPrinter.printText(
        'Thank you for your visit!',
        style: SunmiTextStyle(align: SunmiPrintAlign.CENTER),
      );
      await SunmiPrinter.lineWrap(2);
      await SunmiPrinter.printText("--------------------------------");
      await SunmiPrinter.lineWrap(2);
      await SunmiPrinter.printText(
        "Amount   Payment Method    Date & Time",
        style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 20),
      );
      await SunmiPrinter.printText("--------------------------------");
      await SunmiPrinter.lineWrap(2);
      await SunmiPrinter.printText(
        "€18,95    Cash    13 Dec 2025 05:06 PM",
        style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 20),
      );
      await SunmiPrinter.lineWrap(3);
      await SunmiPrinter.cutPaper();

      _showSnackbar(
        'Print Sent',
        'Sunmi receipt sent successfully',
        Colors.green,
      );
    } catch (e) {
      _showSnackbar('Print Error', 'Error: ${e.toString()}', Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method for showing snackbars
  void _showSnackbar(String title, String message, Color backgroundColor) {
    safeGetSnackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
    );
  }

  void _showBluetoothEnableDialog() {
    Get.dialog(
      Obx(
        () => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: ColorConstants.bgColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Bluetooth Disabled',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Bluetooth is currently disabled. Please enable Bluetooth to use the printer.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap:
                            isLoading.value
                                ? null
                                : () {
                                  Get.back();
                                },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap:
                            isLoading.value
                                ? null
                                : () async {
                                  Get.back();
                                  await _enableBluetooth();
                                },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                isLoading.value
                                    ? Colors.grey
                                    : ColorConstants.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child:
                                isLoading.value
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : const Text(
                                      'On Bluetooth',
                                      style: TextStyle(color: Colors.white),
                                    ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _enableBluetooth() async {
    try {
      isLoading.value = true;

      if (!Platform.isAndroid) {
        _showSnackbar(
          'Enable Bluetooth',
          'Please enable Bluetooth from Settings',
          Colors.orange,
        );
        return;
      }

      try {
        const platform = MethodChannel(_methodChannelName);
        final bool? result = await platform.invokeMethod('enableBluetooth');

        if (result == true) {
          await _handleBluetoothEnabled();
        } else {
          await _pollBluetoothStatus();
        }
      } on PlatformException {
        _showSnackbar(
          'Error',
          'Failed to enable Bluetooth. Please enable it manually from device settings.',
          Colors.red,
        );
      }
    } catch (_) {
      _showSnackbar(
        'Error',
        'Failed to enable Bluetooth. Please enable it manually from device settings.',
        Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleBluetoothEnabled() async {
    await Future.delayed(_bluetoothEnableDelay);
    final bool? bluetoothEnabled = await PrintBluetoothThermal.bluetoothEnabled;

    if (bluetoothEnabled == true) {
      _showSnackbar(
        'Bluetooth Enabled',
        'Bluetooth has been enabled successfully',
        Colors.green,
      );
      await Future.delayed(_bluetoothInitDelay);
    } else {
      _showSnackbar(
        'Bluetooth Enabling',
        'Bluetooth is being enabled. Please wait...',
        Colors.orange,
      );
    }
  }

  Future<void> _pollBluetoothStatus() async {
    _showSnackbar(
      'Enabling Bluetooth',
      'Please allow Bluetooth in the dialog that appeared',
      Colors.orange,
    );

    bool bluetoothEnabled = false;
    for (int i = 0; i < _bluetoothPollMaxAttempts; i++) {
      await Future.delayed(_bluetoothPollInterval);
      final bool? status = await PrintBluetoothThermal.bluetoothEnabled;
      if (status == true) {
        bluetoothEnabled = true;
        break;
      }
    }

    if (bluetoothEnabled) {
      _showSnackbar(
        'Bluetooth Enabled',
        'Bluetooth has been enabled successfully',
        Colors.green,
      );
      await Future.delayed(_bluetoothInitDelay);
      _loadSavedPrinter();
      await _autoScan();
      await _checkConnection();
    }
  }
}
