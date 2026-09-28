import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/api_constants.dart';
import '../constants/translation_keys.dart';
import '../data/NetworkClient.dart';
import '../utils/sound_service.dart';

class NewOrderDialog {
  static bool _isDialogShowing = false;
  static final Set<String> _acknowledgedOrders = {};

  static Future<void> acknowledgeOrderNotification(String orderUuid) async {
    if (_acknowledgedOrders.contains(orderUuid)) return;
    _acknowledgedOrders.add(orderUuid);
    try {
      final endpoint = ArgumentConstant.acknowledgeOrderNotificationEndpoint
          .replaceAll(':order_uuid', orderUuid);
      final networkClient = NetworkClient();
      await networkClient.patch(endpoint);
      debugPrint('🔔 [POS] Acknowledged order notification for: $orderUuid');
    } catch (e) {
      debugPrint('⚠️ [POS] Failed to acknowledge order notification: $e');
      _acknowledgedOrders.remove(orderUuid);
    }
  }

  static Future<void> show({
    required String orderNumber,
    String? orderUuid,
    VoidCallback? onViewOrder,
  }) async {
    if (Get.context == null) return;

    if (orderUuid != null && orderUuid.isNotEmpty) {
      acknowledgeOrderNotification(orderUuid);
    }

    if (_isDialogShowing) {
      Get.back();
      await SoundService.stop();
      await Future.delayed(const Duration(milliseconds: 200));
    }

    _isDialogShowing = true;
    await SoundService.playLoop('audio/new_order.wav');

    Get.dialog(
      PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            _isDialogShowing = false;
            SoundService.stop();
          }
        },
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
                    child: Text(
                      '!',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF9800),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  TranslationKeys.youHaveANewOrder.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Builder(
                  builder: (context) {
                    final prefix = TranslationKeys.orderNumber.tr.replaceAll('#', '').trim();
                    return Text(
                      orderNumber.isNotEmpty ? '$prefix #$orderNumber' : '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
                const SizedBox(height: 24),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _isDialogShowing = false;
                            SoundService.stop();
                            Get.back();
                            onViewOrder?.call();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            TranslationKeys.viewOrder.tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _isDialogShowing = false;
                            SoundService.stop();
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            TranslationKeys.dismiss.tr,
                            textAlign: TextAlign.center,
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
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    ).then((_) {
      if (_isDialogShowing) {
        _isDialogShowing = false;
        SoundService.stop();
      }
    });
  }
}
