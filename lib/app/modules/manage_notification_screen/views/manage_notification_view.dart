import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';
import 'package:managerapp/app/constants/translation_keys.dart';
import '../controllers/manage_notification_controller.dart';

class ManageNotificationView extends GetView<ManageNotificationController> {
  const ManageNotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    MySize().init(context);
    return Scaffold(
      backgroundColor: ColorConstants.bgColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(MySize.getHeight(16)),
                child: Column(children: [_buildNotificationGroup()]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + MySize.getHeight(12),
        left: MySize.getWidth(8),
        right: MySize.getWidth(8),
        bottom: MySize.getHeight(12),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: ColorConstants.getShadow2,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Get.back(),
          ),
          Expanded(
            child: Center(
              child: Text(
                TranslationKeys.manageNotifications.tr,
                style: TextStyle(
                  fontSize: MySize.getHeight(20),
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48), // Spacer for centering
        ],
      ),
    );
  }

  Widget _buildNotificationGroup() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MySize.getHeight(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: MySize.getWidth(10),
            offset: Offset(0, MySize.getHeight(4)),
          ),
        ],
      ),
      child: Column(
        children: [
          Obx(
            () => _buildToggleItem(
              title: TranslationKeys.newShopOrders.tr,
              value: controller.newShopOrderNotificationsEnabled.value,
              onToggle: () => controller.toggleNewShopOrderNotifications(),
            ),
          ),
          _buildDivider(),
          Obx(
            () => _buildToggleItem(
              title: TranslationKeys.newKitchenTickets.tr,
              value: controller.kitchenTicketGenerationEnabled.value,
              onToggle: () => controller.toggleKitchenTicketGeneration(),
            ),
          ),
          _buildDivider(),
          Obx(
            () => _buildToggleItem(
              title: TranslationKeys.kitchenTicketStatusChange.tr,
              value: controller.kotStatusChangeEnabled.value,
              onToggle: () => controller.toggleKotStatusChange(),
            ),
          ),
          _buildDivider(),
          Obx(
            () => _buildToggleItem(
              title: TranslationKeys.newTableReservations.tr,
              value: controller.newTableReservationsEnabled.value,
              onToggle: () => controller.toggleNewTableReservations(),
            ),
          ),
          _buildDivider(),
          Obx(
            () => _buildToggleItem(
              title: TranslationKeys.waiterRequest.tr,
              value: controller.waiterRequestEnabled.value,
              onToggle: () => controller.toggleWaiterRequest(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required String title,
    required bool value,
    required VoidCallback onToggle,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MySize.getWidth(16),
        vertical: MySize.getHeight(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: MySize.getHeight(14),
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeColor: ColorConstants.primaryColor,
            onChanged: (v) => onToggle(),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: MySize.getHeight(1),
      indent: MySize.getWidth(16),
      endIndent: MySize.getWidth(16),
      color: Colors.grey.withValues(alpha: 0.1),
    );
  }
}
