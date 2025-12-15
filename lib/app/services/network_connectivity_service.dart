import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/color_constant.dart';

class NetworkConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final isConnected = true.obs;
  bool _isDialogShowing = false;

  @override
  void onInit() {
    super.onInit();
    _startListening();
  }

  @override
  void onReady() {
    super.onReady();
    Future.delayed(const Duration(seconds: 1), () {
      if (Get.context != null) {
        _initConnectivity();
      }
    });
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      final hasConnection = result.any((r) => r != ConnectivityResult.none);
      isConnected.value = hasConnection;
      if (!hasConnection) {
        _showNoInternetDialog();
      }
    } catch (e) {
      isConnected.value = false;
      _showNoInternetDialog();
    }
  }

  void _startListening() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      _updateConnectionStatus(result);
    });
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    final hasConnection = result.any((r) => r != ConnectivityResult.none);

    isConnected.value = hasConnection;

    if (!hasConnection && !_isDialogShowing && Get.context != null) {
      _showNoInternetDialog();
    } else if (hasConnection && _isDialogShowing) {
      _hideNoInternetDialog();
    }
  }

  void _showNoInternetDialog() {
    if (_isDialogShowing) return;
    if (Get.context == null) return;
    _isDialogShowing = true;

    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_off, size: 64, color: Colors.red.shade400),
                const SizedBox(height: 16),
                const Text(
                  'No Internet Connection',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Please check your internet connection and try again.',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      await _recheckConnectivity();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ColorConstants.primaryColor,
                      side: BorderSide(
                        color: ColorConstants.primaryColor,
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _recheckConnectivity() async {
    _hideNoInternetDialog();
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final result = await _connectivity.checkConnectivity();
      final hasConnection = result.any((r) => r != ConnectivityResult.none);
      isConnected.value = hasConnection;
      if (!hasConnection) {
        _showNoInternetDialog();
      }
    } catch (e) {
      isConnected.value = false;
      _showNoInternetDialog();
    }
  }

  void _hideNoInternetDialog() {
    if (!_isDialogShowing) return;
    _isDialogShowing = false;
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}
