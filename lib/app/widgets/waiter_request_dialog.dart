import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/translation_keys.dart';

class WaiterRequestDialog {
  static bool _isDialogShowing = false;

  static Future<void> show({
    required int tableId,
    String? tableLabel,
  }) async {
    if (Get.context == null) return;

    if (_isDialogShowing) {
      Get.back();
      await Future.delayed(const Duration(milliseconds: 200));
    }

    _isDialogShowing = true;

    Get.dialog(
      PopScope(
        canPop: true,
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
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFF9800),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.notifications_active_outlined,
                      size: 36,
                      color: Color(0xFFFF9800),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Waiter Requested',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Table: ${tableLabel ?? tableId}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _isDialogShowing = false;
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFf85168),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      TranslationKeys.dismiss.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
    ).then((_) {
      _isDialogShowing = false;
    });
  }
}
