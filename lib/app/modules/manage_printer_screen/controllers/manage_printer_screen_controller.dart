import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:managerapp/main.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:screenshot/screenshot.dart';

import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import '../../../services/printer_service.dart';
import '../../../constants/api_constants.dart';
import '../../../constants/sizeConstant.dart';
import '../../../widgets/app_toast.dart';
import '../../../constants/color_constant.dart';
import '../../../constants/translation_keys.dart';
import '../../../model/wifi_printer_model.dart';

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

  // Cached printer profile for fast printing
  CapabilityProfile? _cachedProfile;

  // Constants
  static const _bluetoothInitDelay = Duration(milliseconds: 50);
  static const _bluetoothEnableDelay = Duration(seconds: 1);
  static const _bluetoothPollInterval = Duration(milliseconds: 500);
  static const _bluetoothPollMaxAttempts = 20;
  static const _methodChannelName = 'com.dinemetrics.manager/bluetooth';
  static const _wifiPrintersKey = 'saved_wifi_printers';

  @override
  void onInit() {
    super.onInit();
    printerService = Get.find<PrinterService>();
    _loadSavedPrinter();
    _loadSettings();
    _loadWifiPrinters();
    _syncWithService();
    _checkBluetoothStatus();
    WidgetsBinding.instance.addObserver(this);
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

  Future<void> scanForDevices() async {
    try {
      isScanning.value = true;
      availableDevices.clear();

      final bool? bluetoothEnabled =
          await PrintBluetoothThermal.bluetoothEnabled;
      if (bluetoothEnabled != null) {
        isBluetoothEnabled.value = bluetoothEnabled;
      }
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

      final paperSize = _getPaperSize();
      final printerDots = _getPrinterDots();
      _cachedProfile ??= await CapabilityProfile.load();
      final generator = Generator(paperSize, _cachedProfile!);

      // Capture receipt widget as image (1:1 ratio = no resize = sharp)
      final screenshotController = ScreenshotController();
      final imageBytes = await screenshotController.captureFromLongWidget(
        _buildTestReceiptWidget(printerDots.toDouble()),
        pixelRatio: 1.0,
        delay: Duration.zero,
      );

      // Decode and prepare for thermal printer
      var decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) {
        showPrintToast(TranslationKeys.errorInPrinting.tr, isError: true);
        return;
      }

      // Width must be divisible by 8
      final targetWidth = (decodedImage.width ~/ 8) * 8;
      if (decodedImage.width != targetWidth) {
        decodedImage = img.copyResize(decodedImage, width: targetWidth);
      }
      decodedImage = img.grayscale(decodedImage);

      // Convert to ESC/POS raster + cut
      final imageData = generator.imageRaster(decodedImage);
      final cutBytes = generator.cut();

      List<int> allBytes = [];
      for (int i = 0; i < numberOfCopies.value; i++) {
        allBytes.addAll(imageData);
        allBytes.addAll(cutBytes);
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

      final paperSize = _getPaperSize();
      final printerDots = _getPrinterDots();
      _cachedProfile ??= await CapabilityProfile.load();
      final generator = Generator(paperSize, _cachedProfile!);

      // Capture receipt widget as image
      final screenshotController = ScreenshotController();
      final imageBytes = await screenshotController.captureFromLongWidget(
        _buildTestReceiptWidget(printerDots.toDouble()),
        pixelRatio: 1.0,
        delay: Duration.zero,
      );

      var decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) throw Exception('Failed to decode image');

      // Width must be divisible by 8
      final targetWidth = (decodedImage.width ~/ 8) * 8;
      if (decodedImage.width != targetWidth) {
        decodedImage = img.copyResize(decodedImage, width: targetWidth);
      }
      decodedImage = img.grayscale(decodedImage);

      // Convert to ESC/POS raster + cut
      final imageData = generator.imageRaster(decodedImage);
      final cutBytes = generator.cut();

      List<int> allBytes = [];
      for (int i = 0; i < numberOfCopies.value; i++) {
        allBytes.addAll(imageData);
        allBytes.addAll(cutBytes);
      }

      // Connect via TCP Socket to the IP Camera
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

  /// Builds test receipt widget — width matches printer dots for sharp output
  /// Builds test receipt widget — width matches printer dots for sharp output
  Widget _buildTestReceiptWidget(double width) {
    const headerStyle = TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );
    const subStyle = TextStyle(fontSize: 18, color: Colors.black);
    const bodyStyle = TextStyle(fontSize: 20, color: Colors.black);
    const boldBody = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    return SizedBox(
      width: width,
      child: Material(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Naan Stop',
                style: headerStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                'Winkelcentrum Woensel 1, 5625 AA\nEindhoven, Netherlands',
                style: subStyle,
                textAlign: TextAlign.center,
              ),
              Text(
                'Phone: 626193494',
                style: subStyle,
                textAlign: TextAlign.center,
              ),
              Text(
                'GST: 24AGHPN',
                style: subStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              _dottedLine(),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Order: ORD-0218', style: bodyStyle),
                  Text('13 Dec 2025 06:06 PM', style: bodyStyle),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Customer: Bhargav thummar', style: bodyStyle),
              ),
              const SizedBox(height: 4),
              _dottedLine(),
              const SizedBox(height: 4),
              Row(
                children: [
                  SizedBox(
                    width: 42,
                    child: Text(
                      TranslationKeys.qty.tr,
                      style: boldBody,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      TranslationKeys.itemName.tr,
                      style: boldBody,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: Text(
                      TranslationKeys.price.tr,
                      style: boldBody,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      TranslationKeys.amount.tr,
                      style: boldBody,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _dottedLine(),
              const SizedBox(height: 4),
              _itemRow(
                '1',
                'Naan Imperial (Steak, Egg, Ham, Cheese, Vegetable)',
                '\u20AC9,50',
                '\u20AC9,50',
              ),
              const SizedBox(height: 2),
              _itemRow('1', 'Naan Steak', '\u20AC8,00', '\u20AC8,00'),
              const SizedBox(height: 4),
              _summaryRow('Sub Total:', '\u20AC17,50'),
              _summaryRow('Servicekosten:', '\u20AC0,45'),
              _summaryRow('Boxes:', '\u20AC1,00'),
              _summaryRow('VAT (5.00%) incl.', '\u20AC0,83'),
              _summaryRow('${TranslationKeys.totalTax.tr}:', '\u20AC0,83'),
              _summaryRow(
                '${TranslationKeys.balanceReturned.tr}:',
                '\u20AC0,00',
              ),
              const SizedBox(height: 4),
              _dottedLine(),
              const SizedBox(height: 4),
              _summaryRow(
                '${TranslationKeys.total.tr}:',
                '\u20AC18,95',
                isBold: true,
              ),
              const SizedBox(height: 4),
              _dottedLine(),
              const SizedBox(height: 8),
              Text(
                TranslationKeys.thankYouForVisit.tr,
                style: bodyStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  SizedBox(
                    width: 85,
                    child: Text(TranslationKeys.amount.tr, style: boldBody),
                  ),
                  Expanded(
                    child: Text(
                      TranslationKeys.paymentMethod.tr,
                      style: boldBody,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Text(
                    TranslationKeys.dateAndTime.tr,
                    style: boldBody,
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _dottedLine(),
              const SizedBox(height: 4),
              Row(
                children: [
                  SizedBox(
                    width: 85,
                    child: Text('\u20AC18,95', style: bodyStyle),
                  ),
                  Expanded(
                    child: Text(
                      TranslationKeys.cash.tr,
                      style: bodyStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Text(
                    '13 Dec 2025 05:06 PM',
                    style: bodyStyle,
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dottedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.black),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _itemRow(String qty, String name, String price, String amount) {
    const s = TextStyle(fontSize: 20, color: Colors.black);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 42, child: Text(qty, style: s)),
        Expanded(child: Text(name, style: s)),
        SizedBox(
          width: 70,
          child: Text(price, style: s, textAlign: TextAlign.right),
        ),
        SizedBox(
          width: 80,
          child: Text(amount, style: s, textAlign: TextAlign.right),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    final s = TextStyle(
      fontSize: 20,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      color: Colors.black,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: s), Text(value, style: s)],
      ),
    );
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
    final bool? bluetoothEnabled = await PrintBluetoothThermal.bluetoothEnabled;

    if (bluetoothEnabled == true) {
      _showSnackbar(
        TranslationKeys.bluetoothEnabled.tr,
        TranslationKeys.bluetoothEnabledSuccessfully.tr,
        ColorConstants.successGreen,
      );
      await Future.delayed(_bluetoothInitDelay);
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
      final bool? status = await PrintBluetoothThermal.bluetoothEnabled;
      if (status == true) {
        bluetoothEnabled = true;
        break;
      }
    }

    if (bluetoothEnabled) {
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
