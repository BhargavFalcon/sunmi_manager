import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:managerapp/main.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';

import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import '../../../services/printer_service.dart';
import '../../../constants/api_constants.dart';
import '../../../constants/sizeConstant.dart';
import '../../../widgets/app_toast.dart';
import '../../../constants/color_constant.dart';
import '../../../constants/translation_keys.dart';
import '../../../utils/printer_helper.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../../model/wifi_printer_model.dart';
import '../../../utils/currency_formatter.dart';

class ManagePrinterScreenController extends GetxController
    with WidgetsBindingObserver {
  late PrinterService printerService;

  // --- Bluetooth State ---
  final isLoading = false.obs;
  final connectingDeviceId = ''.obs;
  final isScanning = false.obs;
  final isInitialLoading = true.obs;
  final connectedDevice = Rxn<BluetoothInfo>();
  final availableDevices = <BluetoothInfo>[].obs;
  final isConnected = false.obs;
  final isBluetoothEnabled = false.obs;

  // --- Printer Settings ---
  final autoPrint = true.obs;
  final numberOfCopies = 1.obs;
  final printerWidth = '58mm'.obs;
  final printerWidthOptions = ['58mm', '80mm'];

  // --- Wifi Printer State ---
  final selectedTab = 0.obs; // 0 for Bluetooth, 1 for WiFi
  final savedWifiPrinters = <WifiPrinterModel>[].obs;
  final deviceNameController = TextEditingController();
  final ipAddressController = TextEditingController();
  final portController = TextEditingController();
  final defaultWifiPrinter = Rxn<WifiPrinterModel>();
  final wifiPaperWidth = '80mm'.obs;

  // --- Sunmi State ---
  final isSunmi = false.obs;
  final sunmiDeviceName = 'Sunmi Device'.obs;

  // Cached printer profile for fast printing
  CapabilityProfile? _cachedProfile;

  // Constants
  static const _bluetoothInitDelay = Duration(milliseconds: 50);
  static const _bluetoothEnableDelay = Duration(seconds: 1);
  static const _bluetoothPollInterval = Duration(milliseconds: 500);
  static const _bluetoothPollMaxAttempts = 20;
  static const _methodChannelName = 'com.dinemetrics.manager/bluetooth';
  static const _wifiPrintersKey = ArgumentConstant.savedWifiPrintersKey;

  @override
  void onInit() {
    super.onInit();
    printerService = Get.find<PrinterService>();
    _checkSunmiStatus();
    _loadSavedPrinter();
    _loadSettings();
    _loadWifiPrinters();
    _syncWithService();
    _checkBluetoothStatus();
    WidgetsBinding.instance.addObserver(this);

    // Initial check when entering the screen
    printerService.checkConnection();
  }

  Future<void> _checkSunmiStatus() async {
    isSunmi.value = await PrinterHelper.isSunmiDevice();
    if (isSunmi.value) {
      try {
        final deviceInfo = DeviceInfoPlugin();
        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          sunmiDeviceName.value = androidInfo.model;
        }
      } catch (_) {}
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    deviceNameController.dispose();
    ipAddressController.dispose();
    portController.dispose();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (selectedTab.value == 0) {
        // App resumed, recheck Bluetooth quietly
        _checkAndResumeBluetooth();
      }
    }
  }

  Future<void> _checkAndResumeBluetooth() async {
    try {
      final bool bluetoothEnabled =
          await PrintBluetoothThermal.bluetoothEnabled;
      isBluetoothEnabled.value = bluetoothEnabled;
      if (bluetoothEnabled && availableDevices.isEmpty && !isConnected.value) {
        if (Get.isDialogOpen == true) {
          Get.back();
        }
        await _checkConnection();
        await _autoScan();
      }
    } catch (_) {
      isBluetoothEnabled.value = false;
    }
  }

  Future<void> _autoScan() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await scanForDevices();
  }

  Future<void> _checkBluetoothStatus() async {
    try {
      final bool bluetoothEnabled =
          await PrintBluetoothThermal.bluetoothEnabled;
      isBluetoothEnabled.value = bluetoothEnabled;
      if (!bluetoothEnabled) {
        _resetConnection();
        isInitialLoading.value = false;
        _showBluetoothEnableDialog();
      } else {
        await _checkConnection();
        await _autoScan();
        isInitialLoading.value = false;
      }
    } catch (e) {
      isBluetoothEnabled.value = false;
      _resetConnection();
      isInitialLoading.value = false;
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

  void _loadWifiPrinters() {
    try {
      final String? jsonStr = box.read(_wifiPrintersKey);
      if (jsonStr != null) {
        final List<dynamic> decodedObj = jsonDecode(jsonStr);
        final printers =
            decodedObj.map((e) => WifiPrinterModel.fromJson(e)).toList();
        savedWifiPrinters.value = printers;

        // Find default printer
        final df = savedWifiPrinters.firstWhereOrNull((p) => p.isDefault);
        if (df != null) {
          defaultWifiPrinter.value = df;
        }
      }
    } catch (e) {
      // Silent fail
    }
  }

  void saveWifiPrinter() {
    if (deviceNameController.text.trim().isEmpty ||
        ipAddressController.text.trim().isEmpty ||
        portController.text.trim().isEmpty) {
      AppToast.showWarning('Please fill all fields');
      return;
    }

    final newPrinter = WifiPrinterModel(
      name: deviceNameController.text.trim(),
      ipAddress: ipAddressController.text.trim(),
      port: portController.text.trim(),
      paperWidth: wifiPaperWidth.value,
      isDefault:
          savedWifiPrinters.isEmpty, // Make default if it's the first one
    );

    savedWifiPrinters.add(newPrinter);
    if (newPrinter.isDefault) {
      defaultWifiPrinter.value = newPrinter;
    }

    _persistWifiPrinters();

    // Clear form
    deviceNameController.clear();
    ipAddressController.clear();
    portController.clear();

    Get.back(); // close the bottom sheet
    AppToast.showSuccess('Device saved successfully');
  }

  void setDefaultWifiPrinter(WifiPrinterModel printer) {
    for (var p in savedWifiPrinters) {
      p.isDefault = false;
    }
    printer.isDefault = true;
    defaultWifiPrinter.value = printer;

    savedWifiPrinters.refresh(); // Triggers UI update
    _persistWifiPrinters();

    AppToast.showSuccess('${printer.name} set as default wifi printer');
  }

  void deleteWifiPrinter(WifiPrinterModel printer) {
    savedWifiPrinters.remove(printer);
    if (printer.isDefault) {
      defaultWifiPrinter.value = null;
      if (savedWifiPrinters.isNotEmpty) {
        setDefaultWifiPrinter(savedWifiPrinters.first);
      }
    }
    _persistWifiPrinters();
  }

  void _persistWifiPrinters() {
    try {
      final jsonList = savedWifiPrinters.map((p) => p.toJson()).toList();
      box.write(_wifiPrintersKey, jsonEncode(jsonList));
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
    // Initial sync
    isConnected.value = printerService.isConnected.value;
    connectedDevice.value = printerService.connectedDevice;

    // Listen for changes
    ever(printerService.isConnected, (connected) {
      isConnected.value = connected;
      connectedDevice.value = printerService.connectedDevice;
      update();
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

  Future<void> scanForDevices() async {
    try {
      isScanning.value = true;
      availableDevices.clear();

      final bool bluetoothEnabled =
          await PrintBluetoothThermal.bluetoothEnabled;
      isBluetoothEnabled.value = bluetoothEnabled;
          if (bluetoothEnabled == false) {
        _resetConnection();
        _showBluetoothEnableDialog();
        return;
      }

      final List<BluetoothInfo> allDevices =
          await PrintBluetoothThermal.pairedBluetooths;
      availableDevices.value = List.from(allDevices);
    } catch (e) {
      // Silent fail
    } finally {
      isScanning.value = false;
    }
  }

  Future<void> connectToDevice(BluetoothInfo device) async {
    try {
      isLoading.value = true;
      connectingDeviceId.value = device.macAdress;

      if (isConnected.value) {
        await PrintBluetoothThermal.disconnect;
      }

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
          TranslationKeys.success.tr,
          TranslationKeys.printerConnectedSuccessfully.tr,
          ColorConstants.successGreen,
        );
      } else {
        _showSnackbar(
          TranslationKeys.error.tr,
          TranslationKeys.failedToConnectPrinter.tr,
          Colors.red,
        );
      }
    } catch (e) {
      _showSnackbar(
        TranslationKeys.error.tr,
        TranslationKeys.failedToConnectPrinter.tr,
        Colors.red,
      );
    } finally {
      isLoading.value = false;
      connectingDeviceId.value = '';
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
      case '80mm':
        return PaperSize.mm80;
      default:
        return PaperSize.mm80;
    }
  }

  /// Returns printer dot width for the paper size
  int _getPrinterDots() {
    switch (printerWidth.value) {
      case '58mm':
        return 384;
      case '80mm':
        return 576;
      default:
        return 576;
    }
  }

  Future<void> printTestReceipt(BuildContext context) async {
    if (selectedTab.value == 1) {
      await _printTestReceiptWifi();
      return;
    }

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
        TranslationKeys.printerNotConnected.tr,
        TranslationKeys.pleaseConnectPrinterFirst.tr,
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
            TranslationKeys.connectionFailed.tr,
            TranslationKeys.failedToConnectPrinter.tr,
            Colors.red,
          );
          return;
        }
        isConnected.value = true;
      }
    } catch (e) {
      _showSnackbar(
        TranslationKeys.connectionError.tr,
        TranslationKeys.errorCheckingConnection.tr,
        Colors.red,
      );
      return;
    }

    try {
      isLoading.value = true;

      final receiptBytes = await _buildTestReceiptBytes();

      List<int> allBytes = [];
      for (int i = 0; i < numberOfCopies.value; i++) {
        allBytes.addAll(receiptBytes);
      }

      final result = await PrintBluetoothThermal.writeBytes(allBytes);
      if (result == true) {
        showPrintToast(TranslationKeys.printSuccessful.tr);
      } else {
        showPrintToast(TranslationKeys.errorInPrinting.tr, isError: true);
      }
    } catch (e) {
      showPrintToast(TranslationKeys.errorInPrinting.tr, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _printTestReceiptWifi() async {
    if (defaultWifiPrinter.value == null) {
      _showSnackbar(
        TranslationKeys.printerNotConnected.tr,
        'Please set a default WiFi printer first',
        Colors.orange,
      );
      return;
    }

    try {
      isLoading.value = true;
      final printer = defaultWifiPrinter.value!;

      final receiptBytes = await _buildTestReceiptBytes();

      List<int> allBytes = [];
      for (int i = 0; i < numberOfCopies.value; i++) {
        allBytes.addAll(receiptBytes);
      }

      // Connect via TCP Socket
      final socket = await Socket.connect(
        printer.ipAddress,
        int.tryParse(printer.port) ?? 9100,
        timeout: const Duration(seconds: 5),
      );

      socket.add(allBytes);
      await socket.flush();
      socket.destroy();

      showPrintToast(TranslationKeys.printSuccessful.tr);
    } catch (e) {
      showPrintToast(TranslationKeys.errorInPrinting.tr, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  static const _currencyFallback = <String, String>{
    '\u20B9': 'Rs',
    '\u20BA': 'TL',
    '\u20BD': 'RUB',
    '\u20AB': 'd',
    '\u20B4': 'UAH',
    '\u20A6': 'NGN',
    '\u20A9': 'W',
    '\u20B1': 'PHP',
    '\u20AA': 'ILS',
    '\u0E3F': 'THB',
    '\u20B5': 'GHS',
    '\u20BC': 'AZN',
    '\u20B8': 'KZT',
    '\u20BE': 'GEL',
    '\u20BF': 'BTC',
    '\u20A1': 'CRC',
    '\u20B2': 'PYG',
    '\u20AE': 'MNT',
    '\u20AD': 'LAK',
  };

  String _escCurrency(String text) {
    String result = text.replaceAll('\u20AC', '\u00D5');
    for (final entry in _currencyFallback.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }
    return result;
  }

  String _tp(String price) {
    return _escCurrency('${CurrencyFormatter.getCurrencySymbol()}$price');
  }

  Future<List<int>> _buildTestReceiptBytes() async {
    final paperSize = _getPaperSize();
    _cachedProfile ??= await CapabilityProfile.load();
    final gen = Generator(paperSize, _cachedProfile!);
    final cs = CurrencyFormatter.getCurrencySymbol();

    const b = PosStyles(align: PosAlign.left, fontType: PosFontType.fontB);
    const c = PosStyles(align: PosAlign.center, fontType: PosFontType.fontB);
    const r = PosStyles(align: PosAlign.right, fontType: PosFontType.fontB);

    List<int> item(String qty, String name, String price, String amount) {
      return gen.row([
        PosColumn(text: qty, width: 1, styles: b),
        PosColumn(text: name, width: 5, styles: b),
        PosColumn(text: _tp(price), width: 3, styles: r),
        PosColumn(text: _tp(amount), width: 3, styles: r),
      ]);
    }

    List<int> summary(String label, String amount) {
      return gen.row([
        PosColumn(text: label, width: 8, styles: b),
        PosColumn(text: _tp(amount), width: 4, styles: r),
      ]);
    }

    List<int> bytes = [];
    bytes += [0x1B, 0x74, 19];

    bytes += gen.text(
      'Naan Stop',
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += gen.text('Winkelcentrum Woensel 1, 5625 AA E', styles: c);
    bytes += gen.text('indhoven, Netherlandsds', styles: c);
    bytes += gen.hr(ch: '-');

    bytes += gen.row([
      PosColumn(text: 'Order: ORD-0616', width: 6, styles: b),
      PosColumn(text: '13 Feb 2026,06:30 AM', width: 6, styles: r),
    ]);
    bytes += gen.text('Customer: bhargav thummar 01', styles: b);
    bytes += gen.text('Phone: +91 9723678343', styles: b);
    bytes += gen.hr(ch: '-');

    bytes += gen.row([
      PosColumn(text: TranslationKeys.qty.tr, width: 2, styles: b),
      PosColumn(text: TranslationKeys.itemName.tr, width: 4, styles: b),
      PosColumn(text: TranslationKeys.price.tr, width: 3, styles: r),
      PosColumn(text: TranslationKeys.amount.tr, width: 3, styles: r),
    ]);
    bytes += gen.hr(ch: '-');

    bytes += item('4', 'Naan Falafel', '13,50', '54,00');
    bytes += gen.text(
      _escCurrency('    \u2022 Fries & Red Bull (+${cs}5,50)'),
      styles: b,
    );

    bytes += item('4', 'Naan Steak', '13,50', '54,00');
    bytes += gen.text(
      _escCurrency('    \u2022 Fries & Red Bull (+${cs}5,50)'),
      styles: b,
    );

    bytes += item('4', 'Test Pizza', '2,00', '8,00');

    bytes += item('4', 'Tacos', '20,50', '82,00');
    bytes += gen.text('    (3 Meats)', styles: b);
    bytes += gen.text(
      _escCurrency('    \u2022 Fries & Red Bull (+${cs}5,50)'),
      styles: b,
    );
    bytes += gen.text(
      _escCurrency('    \u2022 Chicken (+${cs}0,00)'),
      styles: b,
    );
    bytes += gen.text(
      _escCurrency('    \u2022 Barbecue (+${cs}0,00)'),
      styles: b,
    );
    bytes += gen.text(
      _escCurrency('    \u2022 Cheese Topped (+${cs}2,50)'),
      styles: b,
    );

    bytes += item('3', 'Schotel', '14,50', '43,50');
    bytes += gen.text('    (XL)', styles: b);

    bytes += item('3', 'D\u00FCr\u00FCm', '7,00', '21,00');
    bytes += gen.text(
      _escCurrency('    \u2022 Falafel (+${cs}0,00)'),
      styles: b,
    );
    bytes += gen.text(
      _escCurrency('    \u2022 Mayonnaise (+${cs}0,00)'),
      styles: b,
    );

    bytes += item('3', 'Coca Cola', '2,00', '6,00');
    bytes += item('4', 'Red Bull', '3,50', '14,00');
    bytes += item('4', 'Water', '2,00', '8,00');
    bytes += item('4', 'Tiramisu', '5,00', '20,00');
    bytes += item('2', 'Heineken', '4,00', '8,00');
    bytes += item('1', 'Bira 91', '3,00', '3,00');
    bytes += item('1', 'Krombacher', '4,00', '4,00');
    bytes += item('1', 'Carlsberg', '4,00', '4,00');
    bytes += item('1', 'Kingfisher Beer', '4,00', '4,00');

    bytes += summary('Sub Total:', '333,50');
    bytes += summary('Service:', '5,00');
    bytes += summary('VAT Delivery (8%) incl.', '19,44');
    bytes += summary('Vat Non-Alcoholic (15%) incl.', '6,26');
    bytes += summary('VAT Alcohol (9%) incl.', '1,90');
    bytes += gen.hr(ch: '-');

    bytes += gen.row([
      PosColumn(text: '${TranslationKeys.total.tr}:', width: 6, styles: b),
      PosColumn(text: _tp('338,50'), width: 6, styles: r),
    ]);
    bytes += gen.hr(ch: '-');

    bytes += gen.text(TranslationKeys.thankYouForVisit.tr, styles: c);
    bytes += gen.text('PAY FROM YOUR PHONE', styles: c);
    bytes += gen.feed(1);
    bytes += gen.text('Scan the QR code to pay Your Bill', styles: c);
    bytes += gen.hr(ch: '-');

    bytes += gen.row([
      PosColumn(text: TranslationKeys.amount.tr, width: 2, styles: b),
      PosColumn(text: TranslationKeys.paymentMethod.tr, width: 6, styles: c),
      PosColumn(text: TranslationKeys.dateAndTime.tr, width: 4, styles: r),
    ]);
    bytes += gen.hr(ch: '-');
    bytes += gen.row([
      PosColumn(text: _tp('338,50'), width: 3, styles: b),
      PosColumn(text: 'cash', width: 2, styles: c),
      PosColumn(text: '13 Feb 26 07:06AM', width: 7, styles: r),
    ]);
    bytes += gen.feed(0);
    bytes += gen.cut();

    return bytes;
  }

  Future<Uint8List?> _downloadNetworkImage(String imageUrl) async {
    try {
      final dio = Dio();
      final response = await dio.get<Uint8List>(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200 && response.data != null) {
        final image = img.decodeImage(response.data!);
        if (image != null) {
          final resizedImage = img.copyResize(
            image,
            width: 150,
            maintainAspect: true,
            interpolation: img.Interpolation.cubic,
          );
          return Uint8List.fromList(img.encodePng(resizedImage));
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> printSunmiTestReceipt() async {
    try {
      isLoading.value = true;

      const logoUrl =
          'https://devdinemetrics.675481e78b80457bc1bf676e29b8098a.r2.cloudflarestorage.com/logo/eef336783624389bf9e02306a696117f.png?X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=2859767638b8c128376a438c02966539%2F20251218%2Fauto%2Fs3%2Faws4_request&X-Amz-Date=20251218T052249Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Signature=c87171b4215eedfeeeda02584499257b3447ae8137bbf3b7c67d9f6843acf85b';
      const qrCodeUrl =
          'https://devdinemetrics.675481e78b80457bc1bf676e29b8098a.r2.cloudflarestorage.com/payment_qr_code/a84af006694b3001446e01cf0e47b52a.png?X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=2859767638b8c128376a438c02966539%2F20251218%2Fauto%2Fs3%2Faws4_request&X-Amz-Date=20251218T052947Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Signature=b24bd850d113abbe7c701274a21deb88df05dd4260b25ab5c570f74869cdecd8';
      for (int i = 0; i < numberOfCopies.value; i++) {
        final imageData = await _downloadNetworkImage(logoUrl);
        final qrCodeData = await _downloadNetworkImage(qrCodeUrl);
        if (imageData != null) {
          await SunmiPrinter.printImage(
            imageData,
            align: SunmiPrintAlign.CENTER,
          );
          await SunmiPrinter.lineWrap(10);
        }
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
          'Order: ORD-0218   13 Dec 2025 06:06 PM',
          style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 20),
        );
        await SunmiPrinter.lineWrap(10);
        await SunmiPrinter.printText(
          'Table no.: 01                  Pax: 2',
          style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 20),
        );
        await SunmiPrinter.lineWrap(10);
        await SunmiPrinter.printText(
          'Waiter: John Smith',
          style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 20),
        );
        await SunmiPrinter.lineWrap(10);
        await SunmiPrinter.printText(
          'Customer: Bhargav thummar',
          style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 20),
        );
        await SunmiPrinter.lineWrap(10);
        await SunmiPrinter.printText(
          'Customer Address: 123 Sample Street City, Country ZIP',
          style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 20),
        );
        await SunmiPrinter.lineWrap(10);
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
              text: '${TranslationKeys.totalTax.tr}:',
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
              text: '${TranslationKeys.balanceReturned.tr}:',
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
        await SunmiPrinter.printText(
          '${TranslationKeys.total.tr}:                   €18,95',
          style: SunmiTextStyle(
            align: SunmiPrintAlign.CENTER,
            fontSize: 25,
            bold: true,
          ),
        );
        await SunmiPrinter.lineWrap(2);
        await SunmiPrinter.printText("--------------------------------");
        await SunmiPrinter.lineWrap(2);
        await SunmiPrinter.printText(
          'Thank you for your visit!',
          style: SunmiTextStyle(align: SunmiPrintAlign.CENTER),
        );
        await SunmiPrinter.lineWrap(10);
        await SunmiPrinter.printText(
          'PAY FROM YOUR PHONE',
          style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 20),
        );
        await SunmiPrinter.lineWrap(10);
        await SunmiPrinter.printImage(
          qrCodeData!,
          align: SunmiPrintAlign.CENTER,
        );
        await SunmiPrinter.lineWrap(10);
        await SunmiPrinter.printText(
          'Scan the QR code to pay Your Bill',
          style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 20),
        );
        await SunmiPrinter.lineWrap(10);
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
      }

      showPrintToast(TranslationKeys.printSuccessful.tr);
    } catch (e) {
      showPrintToast(TranslationKeys.errorInPrinting.tr, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  void _showSnackbar(String title, String message, Color backgroundColor) {
    if (backgroundColor == ColorConstants.successGreen) {
      AppToast.showSuccess(message, title: title);
    } else if (backgroundColor == Colors.red) {
      AppToast.showError(message, title: title);
    } else {
      AppToast.showWarning(message, title: title);
    }
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
                Text(
                  TranslationKeys.bluetoothDisabled.tr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  TranslationKeys.pleaseEnableBluetoothForPrinter.tr,
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
                          child: Center(
                            child: Text(
                              TranslationKeys.cancel.tr,
                              style: const TextStyle(color: Colors.black),
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
                                    : Text(
                                      TranslationKeys.onBluetooth.tr,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
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
          TranslationKeys.enableBluetooth.tr,
          TranslationKeys.pleaseEnableBluetoothFromSettings.tr,
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
          TranslationKeys.error.tr,
          TranslationKeys.pleaseEnableBluetoothFromSettings.tr,
          Colors.red,
        );
      }
    } catch (_) {
      _showSnackbar(
        TranslationKeys.error.tr,
        TranslationKeys.pleaseEnableBluetoothFromSettings.tr,
        Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleBluetoothEnabled() async {
    await Future.delayed(_bluetoothEnableDelay);
    final bool bluetoothEnabled = await PrintBluetoothThermal.bluetoothEnabled;

    if (bluetoothEnabled == true) {
      isBluetoothEnabled.value = true;
      _showSnackbar(
        TranslationKeys.bluetoothEnabled.tr,
        TranslationKeys.bluetoothEnabledSuccessfully.tr,
        ColorConstants.successGreen,
      );
      await Future.delayed(_bluetoothInitDelay);
      _loadSavedPrinter();
      await _autoScan();
      await _checkConnection();
    } else {
      _showSnackbar(
        TranslationKeys.bluetoothEnabling.tr,
        TranslationKeys.bluetoothEnabling.tr,
        Colors.orange,
      );
    }
  }

  Future<void> _pollBluetoothStatus() async {
    _showSnackbar(
      TranslationKeys.enablingBluetooth.tr,
      TranslationKeys.pleaseAllowBluetoothInDialog.tr,
      Colors.orange,
    );

    bool bluetoothEnabled = false;
    for (int i = 0; i < _bluetoothPollMaxAttempts; i++) {
      await Future.delayed(_bluetoothPollInterval);
      final bool status = await PrintBluetoothThermal.bluetoothEnabled;
      if (status == true) {
        bluetoothEnabled = true;
        break;
      }
    }

    if (bluetoothEnabled) {
      isBluetoothEnabled.value = true;
      _showSnackbar(
        TranslationKeys.bluetoothEnabled.tr,
        TranslationKeys.bluetoothEnabledSuccessfully.tr,
        ColorConstants.successGreen,
      );
      await Future.delayed(_bluetoothInitDelay);
      _loadSavedPrinter();
      await _autoScan();
      await _checkConnection();
    }
  }
}
