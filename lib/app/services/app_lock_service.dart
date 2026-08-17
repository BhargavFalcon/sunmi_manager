import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../main.dart';
import '../constants/api_constants.dart';
import '../routes/app_pages.dart';

class AppLockService extends GetxService with WidgetsBindingObserver {
  bool _wasPaused = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state.name == 'hidden') {
      _wasPaused = true;
    } else if (state == AppLifecycleState.resumed) {
      if (_wasPaused) {
        _wasPaused = false;
        final token = box.read<String>(ArgumentConstant.tokenKey);
        final savedPin = box.read<String>(ArgumentConstant.savedPinKey);
        if (token != null &&
            token.isNotEmpty &&
            savedPin != null &&
            savedPin.isNotEmpty) {
          if (Get.currentRoute != Routes.LOGIN_SCREEN) {
            Get.offAllNamed(Routes.LOGIN_SCREEN);
          }
        }
      }
    }
  }
}
