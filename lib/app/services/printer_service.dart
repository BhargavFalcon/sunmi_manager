import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image/image.dart' as img;
import '../constants/api_constants.dart';

class PrinterService extends GetxService {
  final box = GetStorage();
  final isConnected = false.obs;
  BluetoothInfo? connectedDevice;

  @override
  void onInit() {
    super.onInit();
    _loadSavedPrinter();
    _checkConnection();
  }

  void _loadSavedPrinter() {
    try {
      final savedDeviceJson = box.read(ArgumentConstant.savedPrinterDeviceKey);
      if (savedDeviceJson != null && savedDeviceJson is Map) {
        final macAddress = savedDeviceJson['macAddress'] as String?;
        final name = savedDeviceJson['name'] as String?;
        if (macAddress != null && name != null) {
          connectedDevice = BluetoothInfo(name: name, macAdress: macAddress);
          isConnected.value = true;
        }
      }
    } catch (e) {
      print('Error loading saved printer: $e');
    }
  }

  Future<void> _checkConnection() async {
    try {
      if (connectedDevice != null) {
        final isPaired = await PrintBluetoothThermal.connectionStatus;
        if (!isPaired) {
          // Try to reconnect if not connected
          final result = await PrintBluetoothThermal.connect(
            macPrinterAddress: connectedDevice!.macAdress,
          );
          isConnected.value = result;
        } else {
          isConnected.value = true;
        }
      }
    } catch (e) {
      print('Error checking connection: $e');
      isConnected.value = false;
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

  Future<void> printImageFromUrl(String imageUrl) async {
    if (!isConnected.value || connectedDevice == null) {
      print('⚠️ Printer not connected, cannot print image');
      return;
    }

    try {
      print('📥 Downloading image from URL: $imageUrl');

      // Download image using Dio
      final dio = Dio();
      final response = await dio.get<Uint8List>(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode != 200 || response.data == null) {
        print('❌ Failed to download image: ${response.statusCode}');
        return;
      }

      print('✅ Image downloaded successfully');

      // Decode the image
      final image = img.decodeImage(response.data!);
      if (image == null) {
        print('❌ Failed to decode image');
        return;
      }

      final resizedImage = img.copyResize(
        image,
        width: 384,
        maintainAspect: true,
        interpolation: img.Interpolation.cubic,
      );

      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);

      final bytes = <int>[
        ...generator.image(resizedImage, align: PosAlign.center),
        ...generator.cut(),
      ];

      // Print
      final result = await PrintBluetoothThermal.writeBytes(bytes);

      if (result == true) {
        print('✅ Image print sent successfully');
      } else {
        print('❌ Failed to send image print');
      }
    } catch (e) {
      print('❌ Image print error: $e');
    }
  }
}
