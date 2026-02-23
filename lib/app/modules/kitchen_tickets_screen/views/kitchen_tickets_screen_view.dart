import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/image_constants.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';
import 'package:managerapp/app/constants/translation_keys.dart';
import 'package:managerapp/app/widgets/access_limited_dialog.dart';
import '../../../model/kitchen_ticket_model.dart';
import '../controllers/kitchen_tickets_screen_controller.dart';

class KitchenTicketsScreenView
    extends GetWidget<KitchenTicketsScreenController> {
  const KitchenTicketsScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<KitchenTicketsScreenController>(
      init: KitchenTicketsScreenController(),
      assignId: true,
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.bgColor,
          body: SafeArea(
            child: Obx(() {
              return Stack(
                children: [
                  IgnorePointer(
                    ignoring: controller.showAccessDialog.value,
                    child: Builder(
                      builder: (context) {
                        return Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: MySize.getWidth(16),
                                vertical: MySize.getHeight(12),
                              ),
                              child: Obx(() {
                                return Row(
                                  children: [
                                    Expanded(
                                      child: _FilterTab(
                                        label: TranslationKeys.kitchenStatus.tr,
                                        count: controller.inKitchenCount,
                                        isSelected:
                                            controller.selectedTabIndex.value ==
                                            0,
                                        onTap:
                                            () => controller.updateTabIndex(0),
                                        activeColor:
                                            ColorConstants.primaryColor,
                                      ),
                                    ),
                                    SizedBox(width: MySize.getWidth(12)),
                                    Expanded(
                                      child: _FilterTab(
                                        label: TranslationKeys.foodIsReady.tr,
                                        count: controller.foodIsReadyCount,
                                        isSelected:
                                            controller.selectedTabIndex.value ==
                                            1,
                                        onTap:
                                            () => controller.updateTabIndex(1),
                                        activeColor:
                                            ColorConstants.successGreen,
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: controller.onRefresh,
                                color: ColorConstants.primaryColor,
                                child: Obx(() {
                                  if (controller.isLoading.value &&
                                      controller.tickets.isEmpty) {
                                    return Center(
                                      child: CupertinoActivityIndicator(
                                        radius: MySize.getHeight(8),
                                        color: ColorConstants.primaryColor,
                                      ),
                                    );
                                  }

                                  final tickets = controller.filteredTickets;

                                  if (tickets.isEmpty &&
                                      !controller.isLoading.value) {
                                    return SingleChildScrollView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      child: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.6,
                                        child: Center(
                                          child: Text(
                                            controller.selectedTabIndex.value ==
                                                    0
                                                ? "No items in kitchen"
                                                : "No ready orders",
                                            style: TextStyle(
                                              fontSize: MySize.getHeight(18),
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  final width =
                                      MediaQuery.of(context).size.width;
                                  final orientation =
                                      MediaQuery.of(context).orientation;
                                  final crossAxisCount =
                                      orientation == Orientation.landscape
                                          ? 3
                                          : width > 600
                                          ? 2
                                          : 1;
                                  final rowCount =
                                      (tickets.length / crossAxisCount).ceil();

                                  return ListView.builder(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: MySize.getWidth(8),
                                      vertical: MySize.getHeight(8),
                                    ),
                                    itemCount: rowCount,
                                    itemBuilder: (context, rowIndex) {
                                      final start = rowIndex * crossAxisCount;
                                      final rowTickets =
                                          tickets
                                              .skip(start)
                                              .take(crossAxisCount)
                                              .toList();
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          bottom:
                                              rowIndex < rowCount - 1
                                                  ? MySize.getHeight(4)
                                                  : 0,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: List.generate(
                                            crossAxisCount,
                                            (col) {
                                              if (col < rowTickets.length) {
                                                final ticket = rowTickets[col];
                                                return Expanded(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                      right:
                                                          col < crossAxisCount - 1
                                                              ? MySize.getWidth(
                                                                4,
                                                              )
                                                              : 0,
                                                    ),
                                                    child: _KitchenTicketCard(
                                                      ticket: ticket,
                                                      formattedTime: controller
                                                          .formatTime(
                                                            ticket.createdAt,
                                                          ),
                                                      onPrint:
                                                          () => controller
                                                              .onPrint(ticket),
                                                      onFoodReady:
                                                          () => controller
                                                              .onFoodReady(
                                                                ticket,
                                                              ),
                                                    ),
                                                  ),
                                                );
                                              }
                                              return Expanded(
                                                child: SizedBox.shrink(),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  if (controller.showAccessDialog.value)
                    const AccessLimitedDialog(),
                ],
              );
            }),
          ),
        );
      },
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;

  const _FilterTab({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(MySize.getHeight(8)),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: MySize.getHeight(10),
          horizontal: MySize.getWidth(8),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(MySize.getHeight(8)),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: MySize.getHeight(13),
                ),
              ),
            ),
            SizedBox(width: MySize.getWidth(6)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: MySize.getWidth(6),
                vertical: MySize.getHeight(2),
              ),
              decoration: BoxDecoration(
                color: isSelected ? activeColor : activeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(MySize.getHeight(20)),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : activeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: MySize.getHeight(11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KitchenTicketCard extends StatelessWidget {
  final KitchenTicket ticket;
  final String formattedTime;
  final VoidCallback onPrint;
  final VoidCallback onFoodReady;

  const _KitchenTicketCard({
    required this.ticket,
    required this.formattedTime,
    required this.onPrint,
    required this.onFoodReady,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MySize.getHeight(10)),
        boxShadow: ColorConstants.getShadow2,
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(MySize.getHeight(6)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderTypeIcon(context),
                SizedBox(width: MySize.getWidth(6)),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (ticket.order?.waiter?.name != null &&
                          ticket.order!.waiter!.name!.isNotEmpty)
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                ImageConstant.waiter,
                                width: MySize.getHeight(18),
                                height: MySize.getHeight(18),
                              ),
                              SizedBox(width: MySize.getWidth(6)),
                              Flexible(
                                child: Text(
                                  ticket.order!.waiter!.name!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: MySize.getHeight(14),
                                    color: ColorConstants.grey600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Order ${ticket.order?.orderNumber ?? ''}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: MySize.getHeight(14),
                              color: ColorConstants.grey800,
                            ),
                          ),
                          SizedBox(height: MySize.getHeight(2)),
                          Text(
                            formattedTime,
                            style: TextStyle(
                              fontSize: MySize.getHeight(12),
                              color: ColorConstants.grey600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: MySize.getHeight(3)),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(MySize.getHeight(6)),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: ColorConstants.getShadow2,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(MySize.getHeight(6)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(color: Colors.grey.shade100),
                      child: Row(
                        children: [
                          SizedBox(
                            width: MySize.getWidth(38),
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: MySize.getWidth(4),
                                top: MySize.getWidth(3),
                                bottom: MySize.getWidth(3),
                                right: MySize.getWidth(6),
                              ),
                              child: Text(
                                'NO.',
                                style: TextStyle(
                                  fontSize: MySize.getHeight(11),
                                  fontWeight: FontWeight.w600,
                                  color: ColorConstants.grey800,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: MySize.getWidth(4),
                                top: MySize.getWidth(3),
                                bottom: MySize.getWidth(3),
                                right: MySize.getWidth(6),
                              ),
                              child: Text(
                                'ITEM NAME',
                                style: TextStyle(
                                  fontSize: MySize.getHeight(11),
                                  fontWeight: FontWeight.w600,
                                  color: ColorConstants.grey800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...(ticket.items ?? []).asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (index > 0)
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: Colors.grey.shade300,
                            ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: MySize.getWidth(4),
                              vertical: MySize.getHeight(3),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: MySize.getWidth(38),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: MySize.getWidth(6),
                                    ),
                                    child: Text(
                                      item.itemNumber ?? '',
                                      style: TextStyle(
                                        fontSize: MySize.getHeight(12),
                                        color: ColorConstants.grey800,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${item.quantity ?? 1} x ${item.itemName ?? ''}',
                                        softWrap: true,
                                        style: TextStyle(
                                          fontSize: MySize.getHeight(13),
                                          fontWeight: FontWeight.w600,
                                          color: ColorConstants.grey800,
                                        ),
                                      ),
                                      if (item.modifiers != null)
                                        ...item.modifiers!.map(
                                          (m) => Padding(
                                            padding: EdgeInsets.only(
                                              top: MySize.getHeight(2),
                                            ),
                                            child: Text(
                                              '+ ${m.name ?? ''}',
                                              style: TextStyle(
                                                fontSize: MySize.getHeight(11),
                                                color: ColorConstants.grey600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (item.note != null &&
                                          item.note!.isNotEmpty)
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: MySize.getHeight(2),
                                          ),
                                          child: Text(
                                            '${TranslationKeys.note.tr}: ${item.note!}',
                                            style: TextStyle(
                                              fontSize: MySize.getHeight(11),
                                              color: ColorConstants.grey600,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
            if ((ticket.note != null && ticket.note!.isNotEmpty) ||
                (ticket.order?.note != null && ticket.order!.note!.isNotEmpty))
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: MySize.getHeight(6)),
                padding: EdgeInsets.symmetric(
                  horizontal: MySize.getWidth(10),
                  vertical: MySize.getHeight(8),
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(MySize.getHeight(6)),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Text(
                  '${TranslationKeys.note.tr}: ${ticket.note ?? ticket.order?.note ?? ''}',
                  style: TextStyle(
                    fontSize: MySize.getHeight(11.5),
                    color: Colors.black87,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            SizedBox(height: MySize.getHeight(6)),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(MySize.getHeight(5)),
                    child: InkWell(
                      onTap: onPrint,
                      borderRadius: BorderRadius.circular(MySize.getHeight(5)),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: MySize.getWidth(8),
                          vertical: MySize.getHeight(6),
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: ColorConstants.primaryColor,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(
                            MySize.getHeight(5),
                          ),
                        ),
                        child: Icon(
                          Icons.print,
                          size: MySize.getHeight(24),
                          color: ColorConstants.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  if (ticket.status != 'food_ready') ...[
                    SizedBox(width: MySize.getWidth(3)),
                    Expanded(
                      child: Material(
                        color: ColorConstants.successGreen.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(
                          MySize.getHeight(5),
                        ),
                        child: InkWell(
                          onTap: onFoodReady,
                          borderRadius: BorderRadius.circular(
                            MySize.getHeight(5),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: MySize.getWidth(8),
                              vertical: MySize.getHeight(6),
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: ColorConstants.successGreen,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(
                                MySize.getHeight(5),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: MySize.getHeight(16),
                                    color: ColorConstants.successGreen,
                                  ),
                                  SizedBox(width: MySize.getWidth(4)),
                                  Text(
                                    TranslationKeys.foodIsReady.tr,
                                    style: TextStyle(
                                      fontSize: MySize.getHeight(13),
                                      fontWeight: FontWeight.w600,
                                      color: ColorConstants.successGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTypeIcon(BuildContext context) {
    const boxHeight = 28.0;
    const horizontalPadding = 6.0;
    const iconSize = 22.0;
    final orderType = ticket.order?.orderType;
    if (orderType == 'pickup') {
      return Container(
        height: MySize.getHeight(boxHeight),
        padding: EdgeInsets.symmetric(
          horizontal: MySize.getWidth(horizontalPadding),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(MySize.getHeight(6)),
          border: Border.all(color: Colors.grey.shade300),
        ),
        alignment: Alignment.center,
        child: Image.asset(
          ImageConstant.pickup,
          width: MySize.getHeight(iconSize),
          height: MySize.getHeight(iconSize),
        ),
      );
    }
    if (orderType == 'delivery') {
      return Container(
        height: MySize.getHeight(boxHeight),
        padding: EdgeInsets.symmetric(
          horizontal: MySize.getWidth(horizontalPadding),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(MySize.getHeight(6)),
          border: Border.all(color: Colors.grey.shade300),
        ),
        alignment: Alignment.center,
        child: Image.asset(
          ImageConstant.delivery,
          width: MySize.getHeight(iconSize),
          height: MySize.getHeight(iconSize),
        ),
      );
    }
    final tableData = ticket.order?.table;
    final tableCode =
        tableData != null
            ? (tableData is Map
                    ? (tableData['table_code'] ??
                        tableData['tableCode'] ??
                        tableData['name'])
                    : tableData.toString()) ??
                '—'
            : '—';
    return Container(
      height: MySize.getHeight(boxHeight),
      padding: EdgeInsets.symmetric(
        horizontal: MySize.getWidth(horizontalPadding),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(MySize.getHeight(6)),
        border: Border.all(color: Colors.grey.shade300),
      ),
      alignment: Alignment.center,
      child: Text(
        tableCode,
        style: TextStyle(
          color: ColorConstants.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: MySize.getHeight(10),
        ),
      ),
    );
  }
}
