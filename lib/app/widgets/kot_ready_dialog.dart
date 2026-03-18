import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/color_constant.dart';
import '../constants/image_constants.dart';
import '../constants/translation_keys.dart';

class KotReadyDialog {
  static bool _isDialogShowing = false;

  static Future<void> show({
    required String orderNumber,
    required List<Map<String, dynamic>> readyItems,
    String? orderType,
    String? readyTime,
    String? tableCode,
  }) async {
    if (Get.context == null) return;

    if (_isDialogShowing) {
      Get.back();
      await Future.delayed(const Duration(milliseconds: 200));
    }

    _isDialogShowing = true;

    await Get.dialog(
      PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) _isDialogShowing = false;
        },
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: _getIconForOrderType(orderType),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Food is Ready!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.grey800,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (tableCode != null && tableCode.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    tableCode,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ColorConstants.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  'Order #$orderNumber',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (readyTime != null && readyTime.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    readyTime,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const Divider(height: 16),
                Flexible(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: readyItems.length,
                    separatorBuilder: (context, index) => const Divider(height: 12),
                    itemBuilder: (context, index) {
                      final item = readyItems[index];
                      final itemName = item['item_name'] ?? '';
                      final variation = item['variation_name'] ?? '';
                      final quantity = item['quantity']?.toString() ?? '1';
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${quantity}x',
                              style: TextStyle(
                                color: ColorConstants.successGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    itemName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  if (variation.toString().isNotEmpty)
                                    Text(
                                      variation,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  if (item['modifiers'] != null &&
                                      (item['modifiers'] as List).isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 1),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: (item['modifiers'] as List)
                                            .map((mod) => Text(
                                                  '+ ${mod['name'] ?? ''}',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color:
                                                        Colors.blueGrey.shade600,
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _isDialogShowing = false;
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConstants.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      TranslationKeys.dismiss.tr,
                      style: const TextStyle(
                        fontSize: 14,
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
    _isDialogShowing = false;
  }

  static Widget _getIconForOrderType(String? orderType) {
    String imagePath;
    switch (orderType?.toLowerCase()) {
      case 'delivery':
        imagePath = ImageConstant.delivery;
        break;
      case 'pickup':
        imagePath = ImageConstant.pickup;
        break;
      case 'dinein':
      case 'dine_in':
        imagePath = ImageConstant.dinein;
        break;
      default:
        return const Icon(
          Icons.restaurant,
          size: 36,
        );
    }

    return Image.asset(
      imagePath,
      height: 36,
      width: 36,
      color: ColorConstants.primaryColor, // Ensure consistent color
    );
  }
}
