import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';
import '../constants/image_constants.dart';
import '../constants/translation_keys.dart';

class NewReservationDialog {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _isDialogShowing = false;

  static Future<void> show({
    required String customerName,
    required DateTime reservationDateTime,
    required int partySize,
  }) async {
    if (Get.context == null) return;

    if (_isDialogShowing) {
      Get.back();
      await Future.delayed(const Duration(milliseconds: 200));
    }

    _isDialogShowing = true;
    _playNotificationSound();

    final formattedDate =
        DateFormat('dd MMM, hh:mm a').format(reservationDateTime);

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
                    border: Border.all(color: const Color(0xFFFF9800), width: 2),
                  ),
                  child: Center(
                    child: Image.asset(
                      ImageConstant.tableReservation,
                      height: 32,
                      width: 32,
                      color: const Color(0xFFFF9800),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'New Reservation Received:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  '$customerName - $formattedDate',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Pax: $partySize Person(s)',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
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
                      backgroundColor: Colors.red,
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
                        fontSize: 15,
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

  static Future<void> _playNotificationSound() async {
    try {
      await _audioPlayer.play(AssetSource('audio/new_order.wav'));
    } catch (e) {
      // ignore
    }
  }
}
