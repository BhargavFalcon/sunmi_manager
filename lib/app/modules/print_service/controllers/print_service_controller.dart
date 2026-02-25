import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/main.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../../constants/api_constants.dart';
import '../../../model/print_service_validate_model.dart';
import '../../../widgets/app_toast.dart';
import '../../../constants/translation_keys.dart';

import '../../../data/NetworkClient.dart';

class PrintServiceController extends GetxController {
  final NetworkClient _networkClient = NetworkClient();
  // ── Printing Rules ───────────────────────────────────────────────────────
  final autoPrintKitchen = true.obs;
  final kitchenNumberOfCopies = 1.obs;
  final kitchenPaperWidth = '58mm'.obs;
  final autoPrintReceiptWhenPaid = true.obs;
  final receiptNumberOfCopies = 1.obs;
  final orderPaperWidth = '58mm'.obs;

  // ── Print Service Connection ─────────────────────────────────────────────
  final isConnected = false.obs;
  final isConfiguring = false.obs;
  final errorMessage = ''.obs;
  final connectionLoading = false.obs;

  final apiKeyController = TextEditingController();

  // Single DeviceInfoPlugin instance
  final _deviceInfo = DeviceInfoPlugin();

  // Cached Dio instance (rebuilt when API key changes)
  late Dio _dio;

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _loadConnection();
  }

  @override
  void onClose() {
    apiKeyController.dispose();
    super.onClose();
  }

  // ── Printing Rules Methods ───────────────────────────────────────────────

  Future<void> _loadSettings() async {
    try {
      kitchenPaperWidth.value =
          box.read(ArgumentConstant.kitchenPaperWidthKey) ?? '58mm';
      orderPaperWidth.value =
          box.read(ArgumentConstant.orderPaperWidthKey) ?? '58mm';

      final response = await _networkClient.get(
        ArgumentConstant.autoPrintSettingsEndpoint,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        if (data != null) {
          autoPrintKitchen.value = data['auto_print_kot'] ?? true;
          kitchenNumberOfCopies.value = data['kot_print_copies'] ?? 1;
          autoPrintReceiptWhenPaid.value = data['auto_print_receipt'] ?? true;
          receiptNumberOfCopies.value = data['receipt_print_copies'] ?? 1;
        }
      }
    } catch (_) {}
  }

  Future<void> saveSettings({bool showToast = true}) async {
    try {
      box.write(ArgumentConstant.kitchenPaperWidthKey, kitchenPaperWidth.value);
      box.write(ArgumentConstant.orderPaperWidthKey, orderPaperWidth.value);

      await _networkClient.patch(
        ArgumentConstant.autoPrintSettingsEndpoint,
        data: {
          "auto_print_kot": autoPrintKitchen.value,
          "kot_print_copies": kitchenNumberOfCopies.value,
          "auto_print_receipt": autoPrintReceiptWhenPaid.value,
          "receipt_print_copies": receiptNumberOfCopies.value,
        },
      );

      if (showToast) AppToast.showSuccess(TranslationKeys.success.tr);
    } catch (_) {}
  }

  void toggleAutoPrintKitchen() {
    autoPrintKitchen.value = !autoPrintKitchen.value;
    saveSettings(showToast: false);
  }

  void incrementKitchenCopies() {
    if (kitchenNumberOfCopies.value < 5) {
      kitchenNumberOfCopies.value++;
      saveSettings();
    }
  }

  void decrementKitchenCopies() {
    if (kitchenNumberOfCopies.value > 1) {
      kitchenNumberOfCopies.value--;
      saveSettings();
    }
  }

  void toggleAutoPrintReceiptWhenPaid() {
    autoPrintReceiptWhenPaid.value = !autoPrintReceiptWhenPaid.value;
    saveSettings(showToast: false);
  }

  void incrementReceiptCopies() {
    if (receiptNumberOfCopies.value < 5) {
      receiptNumberOfCopies.value++;
      saveSettings();
    }
  }

  void decrementReceiptCopies() {
    if (receiptNumberOfCopies.value > 1) {
      receiptNumberOfCopies.value--;
      saveSettings();
    }
  }

  // ── Print Service Connection Methods ─────────────────────────────────────

  void _loadConnection() {
    final savedKey = box.read(ArgumentConstant.printServiceApiKeyKey);
    final savedStatus =
        box.read(ArgumentConstant.isPrintServiceConnectedKey) ?? false;
    if (savedKey != null) {
      apiKeyController.text = savedKey;
      _initDio(savedKey);
    }
    isConnected.value = savedStatus;
    if (!isConnected.value) isConfiguring.value = true;
  }

  /// Initialises (or re-initialises) the Dio client for the given [apiKey].
  /// Only X-Branch-Key is sent — no Authorization token — so logs are clean.
  void _initDio(String apiKey) {
    _dio = Dio(
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
      )
      ..interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
      );
  }

  /// Returns [deviceId, deviceName] in parallel.
  Future<(String, String)> _getDeviceInfo() async {
    final results = await Future.wait([_getDeviceId(), _getDeviceName()]);
    return (results[0], results[1]);
  }

  Future<String> _getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final a = await _deviceInfo.androidInfo;
        if (a.id.isNotEmpty) return a.id;
      } else if (Platform.isIOS) {
        final i = await _deviceInfo.iosInfo;
        if (i.identifierForVendor?.isNotEmpty == true) {
          return i.identifierForVendor!;
        }
      } else if (Platform.isWindows) {
        return (await _deviceInfo.windowsInfo).deviceId;
      } else if (Platform.isMacOS) {
        final m = await _deviceInfo.macOsInfo;
        final guid = m.systemGUID;
        return (guid != null && guid.isNotEmpty) ? guid : m.model;
      }
    } catch (_) {}
    return 'unknown';
  }

  Future<String> _getDeviceName() async {
    try {
      if (Platform.isAndroid) {
        final a = await _deviceInfo.androidInfo;
        final n = '${a.manufacturer} ${a.model}'.trim();
        return n.isEmpty ? 'Android Device' : n;
      } else if (Platform.isIOS) {
        final i = await _deviceInfo.iosInfo;
        return i.name.isNotEmpty ? i.name : 'iPhone';
      } else if (Platform.isWindows) {
        return (await _deviceInfo.windowsInfo).computerName;
      } else if (Platform.isMacOS) {
        final m = await _deviceInfo.macOsInfo;
        return m.computerName.isNotEmpty ? m.computerName : m.model;
      }
    } catch (_) {}
    return 'Unknown Device';
  }

  Future<void> testConnection() async {
    final apiKey = apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      errorMessage.value = 'Please enter API Key';
      return;
    }

    try {
      connectionLoading.value = true;
      errorMessage.value = '';
      _initDio(apiKey); // ensure Dio has latest API key

      final (deviceId, deviceName) = await _getDeviceInfo();

      final response = await _dio.post<Map<String, dynamic>>(
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
            model.message?.isNotEmpty == true
                ? model.message!
                : 'Connection failed. Please check your API key.';
        return;
      }

      // ✅ Success
      isConnected.value = true;
      box.write(ArgumentConstant.printServiceApiKeyKey, apiKey);
      if (model.data!.token != null) {
        box.write(ArgumentConstant.printServiceTokenKey, model.data!.token);
      }
      box.write(ArgumentConstant.isPrintServiceConnectedKey, true);
      isConfiguring.value = false;
    } on DioException catch (e) {
      isConnected.value = false;
      final responseData = e.response?.data;
      if (responseData is Map) {
        final msg = responseData['message']?.toString() ?? '';

        // 409 — another device is already connected
        if (msg.toLowerCase().contains('already')) {
          String connectedName = '';
          String connectedId = '';
          final errors = responseData['errors'];
          if (errors is Map) {
            connectedName =
                (errors['connected_device_name'] as String?)?.trim() ?? '';
            connectedId =
                (errors['connected_device_id'] as String?)?.trim() ?? '';
          }
          connectionLoading.value = false;
          _showAlreadyConnectedDialog(
            deviceName: connectedName,
            deviceId: connectedId,
          );
          return;
        }

        errorMessage.value =
            msg.isNotEmpty
                ? msg
                : 'Connection failed. Please check your API key and network.';
      } else {
        errorMessage.value =
            'Connection failed. Please check your API key and network.';
      }
    } catch (_) {
      isConnected.value = false;
      errorMessage.value =
          'Connection failed. Please check your API key and network.';
    } finally {
      connectionLoading.value = false;
    }
  }

  /// Disconnects the old connected device (by its ID), then retries connection.
  Future<void> disconnectOldAndConnect({
    required String connectedDeviceId,
  }) async {
    final apiKey = apiKeyController.text.trim();
    if (apiKey.isEmpty) return;

    try {
      errorMessage.value = '';
      connectionLoading.value = true;
      _initDio(apiKey);

      await _dio.post(
        ArgumentConstant.printServiceOldDisconnectEndpoint,
        data: {'device_id': connectedDeviceId},
      );
    } catch (_) {
      // Proceed to reconnect even if disconnect fails
    } finally {
      connectionLoading.value = false;
    }

    await testConnection();
  }

  void _showAlreadyConnectedDialog({
    required String deviceName,
    required String deviceId,
  }) {
    final label = deviceName.isNotEmpty ? deviceName : 'Another device';
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Double ring icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF4C6C).withValues(alpha: 0.1),
                ),
                child: Center(
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFF4C6C).withValues(alpha: 0.15),
                    ),
                    child: const Icon(
                      Icons.devices,
                      color: Color(0xFFFF4C6C),
                      size: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '$label is already connected for Print Service.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Do you want to disconnect $label and connect this device instead?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black54,
                        side: const BorderSide(color: Color(0xFFE0E0E0)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'No',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        disconnectOldAndConnect(connectedDeviceId: deviceId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4C6C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Yes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
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
      barrierDismissible: false,
    );
  }

  void toggleConfigure() => isConfiguring.value = true;
  void done() {
    if (isConnected.value) isConfiguring.value = false;
  }

  String get maskedApiKey {
    if (apiKeyController.text.length <= 8) return '********';
    return '${apiKeyController.text.substring(0, 8)}***';
  }
}
