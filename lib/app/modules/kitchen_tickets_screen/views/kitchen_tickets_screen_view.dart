import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/image_constants.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';
import 'package:managerapp/app/constants/translation_keys.dart';
import 'package:managerapp/app/widgets/access_limited_dialog.dart';
import '../controllers/kitchen_tickets_screen_controller.dart';

class KitchenTicketsScreenView extends GetView<KitchenTicketsScreenController> {
  const KitchenTicketsScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    MySize().init(context);
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
                        if (controller.tickets.isEmpty) {
                          return Center(
                            child: Text(
                              TranslationKeys.kitchenTickets.tr,
                              style: TextStyle(
                                fontSize: MySize.getHeight(18),
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }
                        final width = MediaQuery.of(context).size.width;
                        final orientation = MediaQuery.of(context).orientation;
                        final crossAxisCount =
                            orientation == Orientation.landscape
                                ? 3
                                : width > 600
                                ? 2
                                : 1;
                        final tickets = controller.tickets;
                        final rowCount =
                            (tickets.length / crossAxisCount).ceil();
                        return ListView.builder(
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(crossAxisCount, (col) {
                                  if (col < rowTickets.length) {
                                    final ticket = rowTickets[col];
                                    return Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          right:
                                              col < crossAxisCount - 1
                                                  ? MySize.getWidth(4)
                                                  : 0,
                                        ),
                                        child: _KitchenTicketCard(
                                          ticket: ticket,
                                          onPrint:
                                              () => controller.onPrint(ticket),
                                          onFoodReady:
                                              () => controller.onFoodReady(
                                                ticket,
                                              ),
                                        ),
                                      ),
                                    );
                                  }
                                  return Expanded(child: SizedBox.shrink());
                                }),
                              ),
                            );
                          },
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

class _KitchenTicketCard extends StatelessWidget {
  final KitchenTicketDummy ticket;
  final VoidCallback onPrint;
  final VoidCallback onFoodReady;

  const _KitchenTicketCard({
    required this.ticket,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        ticket.orderId,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MySize.getHeight(14),
                          color: ColorConstants.grey800,
                        ),
                      ),
                      SizedBox(height: MySize.getHeight(2)),
                      Text(
                        ticket.time,
                        style: TextStyle(
                          fontSize: MySize.getHeight(12),
                          color: ColorConstants.grey600,
                        ),
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
                    ...ticket.items.asMap().entries.map((entry) {
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
                                      item.no,
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
                                        item.itemName,
                                        softWrap: true,
                                        style: TextStyle(
                                          fontSize: MySize.getHeight(13),
                                          fontWeight: FontWeight.w600,
                                          color: ColorConstants.grey800,
                                        ),
                                      ),
                                      ...item.modifiers.map(
                                        (m) => Padding(
                                          padding: EdgeInsets.only(
                                            top: MySize.getHeight(2),
                                          ),
                                          child: Text(
                                            m.name,
                                            style: TextStyle(
                                              fontSize: MySize.getHeight(11),
                                              color: ColorConstants.grey600,
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
                        ],
                      );
                    }),
                  ],
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
                  SizedBox(width: MySize.getWidth(3)),
                  Expanded(
                    child: Material(
                      color: ColorConstants.successGreen.withValues(
                        alpha: 0.12,
                      ),
                      borderRadius: BorderRadius.circular(MySize.getHeight(5)),
                      child: InkWell(
                        onTap: () {},
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
    if (ticket.orderType == 'pickup') {
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
    if (ticket.orderType == 'delivery') {
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
    final tableCode = ticket.tableCode ?? '—';
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
