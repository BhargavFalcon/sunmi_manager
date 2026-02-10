import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../main.dart';
import '../../../constants/api_constants.dart';
import '../../../data/NetworkClient.dart';

class PrintServiceController extends GetxController {
  final networkClient = NetworkClient();
  final isLoading = false.obs;
  final isConnected = false.obs;
  final isConfiguring = false.obs;
  final errorMessage = ''.obs;

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

    if (savedUrl != null) domainController.text = savedUrl;
    if (savedKey != null) apiKeyController.text = savedKey;
    isConnected.value = savedStatus;

    if (!isConnected.value) {
      isConfiguring.value = true;
    }
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
