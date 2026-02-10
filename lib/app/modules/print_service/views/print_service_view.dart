import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';
import 'package:managerapp/app/constants/translation_keys.dart';
import '../controllers/print_service_controller.dart';

class PrintServiceView extends GetWidget<PrintServiceController> {
  const PrintServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    MySize().init(context);
    return Scaffold(
      backgroundColor: ColorConstants.bgColor,
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(MySize.getHeight(12)).copyWith(
                  top:
                      MediaQuery.of(context).padding.top + MySize.getHeight(12),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: ColorConstants.getShadow2,
                ),
                child: Center(
                  child: Text(
                    TranslationKeys.printService.tr,
                    style: TextStyle(
                      fontSize: MySize.getHeight(20),
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: MySize.getWidth(12),
                top: MediaQuery.of(context).padding.top + MySize.getHeight(8),
                child: InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: MySize.getHeight(30),
                    width: MySize.getHeight(30),
                    decoration: BoxDecoration(
                      color: ColorConstants.primaryColor.withValues(
                        alpha: 0.10,
                      ),
                      borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: ColorConstants.primaryColor,
                      size: MySize.getHeight(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(MySize.getHeight(8)),
              child: Obx(() {
                if (controller.isConnected.value &&
                    !controller.isConfiguring.value) {
                  return _buildConnectedStatus();
                } else {
                  return _buildConnectionSetup();
                }
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionSetup() {
    return Container(
      padding: EdgeInsets.all(MySize.getHeight(8)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MySize.getHeight(12)),
        boxShadow: ColorConstants.getShadow2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.wifi,
                size: MySize.getHeight(18),
                color: Colors.blueGrey,
              ),
              SizedBox(width: MySize.getWidth(8)),
              Text(
                TranslationKeys.connection.tr,
                style: TextStyle(
                  fontSize: MySize.getHeight(16),
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
          SizedBox(height: MySize.getHeight(16)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TranslationKeys.domainUrl.tr,
                      style: TextStyle(
                        fontSize: MySize.getHeight(12),
                        color: Colors.blueGrey,
                      ),
                    ),
                    SizedBox(height: MySize.getHeight(4)),
                    TextField(
                      controller: controller.domainController,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: MySize.getWidth(10),
                          vertical: MySize.getHeight(12),
                        ),
                        hintText: TranslationKeys.domainHint.tr,
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: MySize.getHeight(13),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            MySize.getHeight(8),
                          ),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            MySize.getHeight(8),
                          ),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: MySize.getWidth(12)),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TranslationKeys.apiKey.tr,
                      style: TextStyle(
                        fontSize: MySize.getHeight(12),
                        color: Colors.blueGrey,
                      ),
                    ),
                    SizedBox(height: MySize.getHeight(4)),
                    TextField(
                      controller: controller.apiKeyController,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: MySize.getWidth(10),
                          vertical: MySize.getHeight(12),
                        ),
                        hintText: TranslationKeys.apiKeyHint.tr,
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: MySize.getHeight(13),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            MySize.getHeight(8),
                          ),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            MySize.getHeight(8),
                          ),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: MySize.getHeight(8)),
          if (controller.errorMessage.value.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: MySize.getHeight(12)),
              child: Text(
                controller.errorMessage.value,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: MySize.getHeight(12),
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      controller.isLoading.value
                          ? null
                          : () => controller.testConnection(),
                  icon:
                      controller.isLoading.value
                          ? SizedBox(
                            width: MySize.getHeight(16),
                            height: MySize.getHeight(16),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Icon(Icons.link, size: MySize.getHeight(18)),
                  label: Text(TranslationKeys.testConnection.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConstants.successGreen,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: MySize.getHeight(14),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              if (controller.isConnected.value) ...[
                SizedBox(width: MySize.getWidth(12)),
                SizedBox(
                  width: MySize.getWidth(100),
                  child: ElevatedButton.icon(
                    onPressed: () => controller.done(),
                    icon: Icon(Icons.check, size: MySize.getHeight(18)),
                    label: Text(TranslationKeys.done.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: MySize.getHeight(14),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          MySize.getHeight(8),
                        ),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedStatus() {
    return Container(
      padding: EdgeInsets.all(MySize.getHeight(8)),
      decoration: BoxDecoration(
        color: ColorConstants.successGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(MySize.getHeight(12)),
        border: Border.all(color: ColorConstants.successGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: MySize.getHeight(8),
                    height: MySize.getHeight(8),
                    decoration: BoxDecoration(
                      color: ColorConstants.successGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: MySize.getWidth(8)),
                  Icon(
                    Icons.wifi,
                    size: MySize.getHeight(18),
                    color: ColorConstants.successGreen,
                  ),
                  SizedBox(width: MySize.getWidth(8)),
                  Text(
                    TranslationKeys.connectedAndPolling.tr,
                    style: TextStyle(
                      fontSize: MySize.getHeight(16),
                      fontWeight: FontWeight.bold,
                      color: ColorConstants.successGreen,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => controller.toggleConfigure(),
                child: Row(
                  children: [
                    Icon(
                      Icons.settings,
                      size: MySize.getHeight(16),
                      color: ColorConstants.successGreen,
                    ),
                    SizedBox(width: MySize.getWidth(4)),
                    Text(
                      TranslationKeys.configure.tr,
                      style: TextStyle(
                        fontSize: MySize.getHeight(14),
                        color: ColorConstants.successGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: MySize.getHeight(12)),
          Text(
            '${TranslationKeys.url.tr}: ${controller.domainController.text}',
            style: TextStyle(
              fontSize: MySize.getHeight(14),
              color: ColorConstants.successGreen,
            ),
          ),
          SizedBox(height: MySize.getHeight(4)),
          Text(
            '${TranslationKeys.key.tr}: ${controller.maskedApiKey}',
            style: TextStyle(
              fontSize: MySize.getHeight(14),
              color: ColorConstants.successGreen,
            ),
          ),
        ],
      ),
    );
  }
}
