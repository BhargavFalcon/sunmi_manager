import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../constants/color_constant.dart';
import '../../../constants/sizeConstant.dart';
import '../../../constants/translation_keys.dart';
import 'package:managerapp/app/widgets/shared/common_text_field.dart';
import '../controllers/shop_controls_controller.dart';

class ShopControlsView extends GetView<ShopControlsController> {
  const ShopControlsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.bgColor,
      appBar: AppBar(
        title: Text(
          TranslationKeys.shopControls.tr,
          style: TextStyle(fontSize: MySize.getHeight(20), color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CupertinoActivityIndicator(
              radius: 15,
              color: ColorConstants.primaryColor,
            ),
          );
        }
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(MySize.getWidth(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSwitchTile(
                      title: TranslationKeys.acceptNewOrders.tr,
                      description: TranslationKeys.onOffDesc.tr,
                      value: controller.acceptNewOrders.value,
                      onChanged:
                          (val) => controller.acceptNewOrders.value = val,
                    ),
                    SizedBox(height: MySize.getHeight(12)),
                    _buildSwitchTile(
                      title: TranslationKeys.enableScheduleForLater.tr,
                      description: TranslationKeys.scheduleDesc.tr,
                      value: controller.enableScheduleForLater.value,
                      onChanged:
                          (val) =>
                              controller.enableScheduleForLater.value = val,
                    ),
                    SizedBox(height: MySize.getHeight(16)),
                    _buildNumericField(
                      label: TranslationKeys.minOrderAmount.tr,
                      controller: controller.minOrderAmountController,
                      prefix:
                          controller.currencyPosition.value == 'before'
                              ? "${controller.currencySymbol.value} "
                              : null,
                      suffix:
                          controller.currencyPosition.value == 'after'
                              ? " ${controller.currencySymbol.value}"
                              : null,
                    ),
                    SizedBox(height: MySize.getHeight(12)),
                    _buildNumericField(
                      label: TranslationKeys.deliveryFee.tr,
                      controller: controller.deliveryFeeController,
                      prefix:
                          controller.currencyPosition.value == 'before'
                              ? "${controller.currencySymbol.value} "
                              : null,
                      suffix:
                          controller.currencyPosition.value == 'after'
                              ? " ${controller.currencySymbol.value}"
                              : null,
                    ),
                    SizedBox(height: MySize.getHeight(12)),
                    _buildNumericField(
                      label: TranslationKeys.freeDeliveryOverAmount.tr,
                      controller: controller.freeDeliveryAmountController,
                      prefix:
                          controller.currencyPosition.value == 'before'
                              ? "${controller.currencySymbol.value} "
                              : null,
                      suffix:
                          controller.currencyPosition.value == 'after'
                              ? " ${controller.currencySymbol.value}"
                              : null,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(MySize.getWidth(16)),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: MySize.getWidth(16),
                      vertical: MySize.getHeight(12),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD), // Light blue background
                      borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                      border: Border.all(
                        color: const Color(0xFF90CAF9), // Blue border
                        width: 1,
                      ),
                    ),
                    child: Text(
                      TranslationKeys.quickControlsOnly.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: MySize.getHeight(13),
                        color: const Color(0xFF1565C0), // Dark blue text
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: MySize.getHeight(12)),
                  _buildSaveButton(),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.all(MySize.getWidth(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MySize.getHeight(12)),
        boxShadow: ColorConstants.getShadow2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: MySize.getHeight(16),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Switch.adaptive(
                value: value,
                activeColor: ColorConstants.primaryColor,
                onChanged: onChanged,
              ),
            ],
          ),
          SizedBox(height: MySize.getHeight(4)),
          Text(
            description,
            style: TextStyle(
              fontSize: MySize.getHeight(13),
              color: Colors.grey.shade600,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumericField({
    required String label,
    required TextEditingController controller,
    String? prefix,
    String? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: MySize.getHeight(14),
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: MySize.getHeight(4)),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(MySize.getHeight(8)),
            boxShadow: ColorConstants.getShadow2,
          ),
          child: CommonTextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(
                  '^\\d*[${Get.find<ShopControlsController>().decimalSeparator.value}]?\\d*',
                ),
              ),
            ],
            prefix: prefix != null
                ? Padding(
                  padding: EdgeInsets.only(left: MySize.getWidth(16)),
                  child: Text(
                    prefix,
                    style: TextStyle(
                      fontSize: MySize.getHeight(15.0),
                      color: Colors.black87,
                    ),
                  ),
                )
                : null,
            suffix: suffix != null
                ? Padding(
                  padding: EdgeInsets.only(right: MySize.getWidth(16)),
                  child: Text(
                    suffix,
                    style: TextStyle(
                      fontSize: MySize.getHeight(15.0),
                      color: Colors.black87,
                    ),
                  ),
                )
                : null,
            padding: EdgeInsets.symmetric(
              horizontal: MySize.getWidth(16),
              vertical: MySize.getHeight(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            controller.isSaving.value ? null : () => controller.saveSettings(),
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorConstants.primaryColor,
          padding: EdgeInsets.symmetric(vertical: MySize.getHeight(16)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MySize.getHeight(12)),
          ),
        ),
        child:
            controller.isSaving.value
                ? CupertinoActivityIndicator(color: Colors.white)
                : Text(
                  TranslationKeys.save.tr,
                  style: TextStyle(
                    fontSize: MySize.getHeight(16),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
      ),
    );
  }
}
