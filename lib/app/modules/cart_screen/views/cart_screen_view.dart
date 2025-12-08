import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/image_constants.dart';
import 'package:managerapp/app/utils/currency_formatter.dart';

import '../controllers/cart_screen_controller.dart';
import 'widgets/cart_note_editor.dart';

class CartScreenView extends GetWidget<CartScreenController> {
  const CartScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartScreenController>(
      assignId: true,
      init: CartScreenController(),
      builder: (controller) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.fetchTableFromArguments();
          controller.fetchTablesAreas();
          if (controller.cartItems.isNotEmpty) {
            controller.syncOrderTypeFromCartItems();
          }
        });

        return Scaffold(
          backgroundColor: ColorConstants.bgColor,
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12).copyWith(
                          top: MediaQuery.of(context).padding.top + 12,
                          bottom: 15.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: ColorConstants.getShadow2,
                        ),
                        child: Center(
                          child: Text(
                            "Cart",
                            style: TextStyle(
                              fontSize: 17.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        top: MediaQuery.of(context).padding.top + 8,
                        child: InkWell(
                          hoverColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap: () {
                            Get.back();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 30.0,
                            width: 30.0,
                            decoration: BoxDecoration(
                              color: ColorConstants.primaryColor.withValues(
                                alpha: 0.10,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.arrow_back,
                              color: ColorConstants.primaryColor,
                              size: 20.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Obx(() {
                    if (!controller.hasTable) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Pax',
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(width: 12.0),
                          Container(
                            width: 60.0,
                            height: 36.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: controller.paxController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 10,
                                ),
                                isDense: true,
                              ),
                              onChanged: (value) {
                                final intValue = int.tryParse(value);
                                if (intValue != null && intValue > 0) {
                                  controller.updatePax(intValue);
                                } else if (value.isEmpty) {
                                  controller.pax.value = 1;
                                }
                              },
                            ),
                          ),
                          Spacer(),
                          Image.asset(
                            ImageConstant.table,
                            width: 24.0,
                            height: 24.0,
                            color: ColorConstants.primaryColor,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(width: 5.0),
                          Text(
                            controller.selectedTable.value!.tableCode ?? '',
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(width: 12.0),
                          InkWell(
                            hoverColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onTap: () {
                              _showAvailableTablesBottomSheet(
                                context,
                                controller,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.settings_outlined,
                                size: 18.0,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  Expanded(
                    child: Obx(() {
                      if (controller.cartItems.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 64.0,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(height: 16.0),
                              Text(
                                "Your cart is empty",
                                style: TextStyle(
                                  fontSize: 19.0,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.only(
                          left: 8,
                          right: 8,
                          top: 8,
                          bottom: 280,
                        ),
                        itemCount: controller.cartItems.length,
                        itemBuilder: (context, index) {
                          final item = controller.cartItems[index];
                          final itemId = item.cartItemId ?? '';
                          final selectedVariation = item.selectedVariation;
                          final selectedExtras = item.selectedExtras;

                          return Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: ColorConstants.getShadow2,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: ColorConstants.primaryColor
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        item.itemNumber ?? '',
                                        style: TextStyle(
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.bold,
                                          color: ColorConstants.primaryColor,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12.0),
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.itemName ?? "Item Name",
                                            style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4.0),
                                          if (selectedVariation != null)
                                            Text(
                                              selectedVariation.variation ?? '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 13.0,
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          if (selectedExtras != null &&
                                              selectedExtras.isNotEmpty)
                                            Padding(
                                              padding: EdgeInsets.only(
                                                top: 4.0,
                                              ),
                                              child: Wrap(
                                                spacing: 4.0,
                                                runSpacing: 4.0,
                                                children:
                                                    selectedExtras.map<Widget>((
                                                      extra,
                                                    ) {
                                                      return Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 4,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: const Color(
                                                            0xFFF0F2F5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                6,
                                                              ),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              extra.name ?? '',
                                                              style: TextStyle(
                                                                fontSize: 12.0,
                                                                color:
                                                                    Colors
                                                                        .black87,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                            if (extra.price !=
                                                                    null &&
                                                                extra
                                                                        .price
                                                                        ?.isNotEmpty ==
                                                                    true) ...[
                                                              SizedBox(
                                                                width: 4.0,
                                                              ),
                                                              Text(
                                                                CurrencyFormatter.formatPrice(
                                                                  extra.price ??
                                                                      '0',
                                                                ),
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      12.0,
                                                                  color:
                                                                      Colors
                                                                          .black54,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                            ],
                                                          ],
                                                        ),
                                                      );
                                                    }).toList(),
                                              ),
                                            ),
                                          if (selectedVariation != null)
                                            SizedBox(height: 4.0),
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            onTap: () {
                                              controller.startEditingNote(
                                                itemId,
                                              );
                                            },
                                            child: Builder(
                                              builder: (context) {
                                                final bool isEditing =
                                                    item.cartEditingNote;
                                                final String existingNote =
                                                    item.cartNote ?? '';
                                                if (!isEditing) {
                                                  return Text(
                                                    existingNote.isEmpty
                                                        ? "+ Add Note"
                                                        : existingNote,
                                                    style: TextStyle(
                                                      fontSize: 13.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          existingNote.isEmpty
                                                              ? Colors
                                                                  .grey
                                                                  .shade600
                                                              : Colors.black87,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  );
                                                }

                                                return CartNoteEditor(
                                                  itemId: itemId,
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        QuantitySelector(
                                          key: ValueKey(itemId),
                                          initialQuantity: item.quantity.value,
                                          onQuantityChanged: (newQuantity) {
                                            if (newQuantity == 0) {
                                              controller.removeItem(itemId);
                                            } else {
                                              controller.updateItemQuantity(
                                                itemId,
                                                newQuantity,
                                              );
                                            }
                                          },
                                        ),
                                        SizedBox(height: 4.0),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Price: ',
                                              style: TextStyle(
                                                fontSize: 11.0,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            Text(
                                              CurrencyFormatter.formatPriceFromDouble(
                                                item.cartTotalPrice ?? 0.0,
                                              ),
                                              style: TextStyle(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 2.0),
                                        Obx(
                                          () => Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Amount: ',
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              Text(
                                                CurrencyFormatter.formatPriceFromDouble(
                                                  (item.cartTotalPrice ?? 0.0) *
                                                      item.quantity.value,
                                                ),
                                                style: TextStyle(
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
              Obx(() {
                if (controller.cartItems.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: ColorConstants.getShadow2,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            hoverColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onTap: () {
                              _showAddDiscountDialog(context, controller);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.local_offer_outlined,
                                      size: 16.0,
                                      color: Colors.black.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                    SizedBox(width: 4.0),
                                    Text(
                                      "Add Discount",
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black.withValues(
                                          alpha: 0.6,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Items",
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                "${controller.totalItems}",
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Sub Total",
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                CurrencyFormatter.formatPriceFromDouble(
                                  controller.totalPrice,
                                ),
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          Obx(() {
                            if (controller.discountValue.value == 0.0) {
                              return const SizedBox.shrink();
                            }
                            return Column(
                              children: [
                                SizedBox(height: 2.0),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          controller.discountType.value ==
                                                  'Percent'
                                              ? "Discount (${controller.discountValue.value.toStringAsFixed(0)}%)"
                                              : "Discount",
                                          style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF10B981),
                                          ),
                                        ),
                                        SizedBox(width: 2.0),
                                        InkWell(
                                          onTap: () {
                                            controller.removeDiscount();
                                          },
                                          child: Icon(
                                            Icons.delete_outline_outlined,
                                            size: 14.0,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "- ${CurrencyFormatter.formatPriceFromDouble(controller.discountAmount)}",
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }),
                          Obx(() {
                            if (!controller.isTaxIncluded.value) {
                              return const SizedBox.shrink();
                            }
                            return Column(
                              children: [
                                SizedBox(height: 2.0),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                            vertical: 4.0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color(
                                              0xFF10B981,
                                            ).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                size: 12.0,
                                                color: Color(0xFF10B981),
                                              ),
                                              SizedBox(width: 4.0),
                                              Text(
                                                "Tax Inclusive",
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF10B981),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "Tax included in item prices",
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }),
                          Obx(() {
                            final groupedTaxes = controller.groupedTaxes;
                            if (groupedTaxes.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            final sortedTaxes =
                                groupedTaxes.entries.toList()
                                  ..sort((a, b) => a.key.compareTo(b.key));

                            return Column(
                              children:
                                  sortedTaxes.map((entry) {
                                    return Column(
                                      children: [
                                        SizedBox(height: 2.0),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "${entry.key} incl.",
                                              style: TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            Text(
                                              CurrencyFormatter.formatPriceFromDouble(
                                                entry.value,
                                              ),
                                              style: TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  }).toList(),
                            );
                          }),
                          SizedBox(height: 2.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total",
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Obx(
                                () => Text(
                                  CurrencyFormatter.formatPriceFromDouble(
                                    controller.finalTotal,
                                  ),
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    color: ColorConstants.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 10.0),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    Get.back();
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF374151),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    controller.submitOrder(status: 'kot');
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: ColorConstants.primaryColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      "Submit",
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    controller.submitOrder(
                                      createPayment: true,
                                      status: 'billed',
                                    );
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF10B981),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      "Bill & Payment",
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              Obx(() {
                if (controller.isSubmittingOrder.value) {
                  return Container(
                    color: Colors.black.withValues(alpha: 0.2),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CupertinoActivityIndicator(
                          radius: 12,
                          color: ColorConstants.primaryColor,
                        ),
                      ),
                    ),
                  );
                }
                return SizedBox.shrink();
              }),
            ],
          ),
        );
      },
    );
  }

  void _showAvailableTablesBottomSheet(
    BuildContext context,
    CartScreenController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (_) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            builder:
                (_, scrollController) => Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: ColorConstants.bgColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    boxShadow: ColorConstants.getShadow2,
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Available Tables',
                              style: TextStyle(
                                fontSize: 19.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              child: Icon(
                                Icons.close,
                                size: 24.0,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Obx(() {
                          if (controller.tableAreasList.isEmpty) {
                            return Center(
                              child: Text(
                                'No tables available',
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: controller.tableAreasList.length,
                            itemBuilder: (context, areaIndex) {
                              final area = controller.tableAreasList[areaIndex];
                              final availableTables =
                                  area.tables
                                      ?.where(
                                        (table) =>
                                            table.availableStatus
                                                    ?.toLowerCase() ==
                                                'available' &&
                                            table.status?.toLowerCase() ==
                                                'active',
                                      )
                                      .toList() ??
                                  [];

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Text(
                                      area.name ?? 'Unnamed Area',
                                      style: TextStyle(
                                        fontSize: 17.0,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  if (availableTables.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 20,
                                      ),
                                      child: Text(
                                        'No available tables',
                                        style: TextStyle(
                                          fontSize: 13.0,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    )
                                  else
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            crossAxisSpacing: 12,
                                            mainAxisSpacing: 12,
                                            childAspectRatio: 1.2,
                                          ),
                                      itemCount: availableTables.length,
                                      itemBuilder: (context, tableIndex) {
                                        final table =
                                            availableTables[tableIndex];
                                        final isSelected =
                                            controller
                                                .selectedTable
                                                .value
                                                ?.id ==
                                            table.id;

                                        return InkWell(
                                          onTap: () {
                                            controller.selectedTable.value =
                                                table;
                                            final capacity =
                                                table.seatingCapacity ?? 1;
                                            controller.pax.value = capacity;
                                            controller.paxController.text =
                                                capacity.toString();
                                            Navigator.of(context).pop();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color:
                                                    isSelected
                                                        ? ColorConstants
                                                            .primaryColor
                                                        : Colors.grey.shade300,
                                                width: isSelected ? 2 : 1,
                                              ),
                                              boxShadow:
                                                  isSelected
                                                      ? [
                                                        BoxShadow(
                                                          color: ColorConstants
                                                              .primaryColor
                                                              .withValues(
                                                                alpha: 0.2,
                                                              ),
                                                          blurRadius: 4,
                                                          spreadRadius: 1,
                                                        ),
                                                      ]
                                                      : null,
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        ColorConstants
                                                            .tableGreen,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    table.tableCode ??
                                                        '${table.id}',
                                                    style: TextStyle(
                                                      fontSize: 13.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 4.0),
                                                Text(
                                                  '${table.seatingCapacity ?? 0} Seat(s)',
                                                  style: TextStyle(
                                                    fontSize: 11.0,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  SizedBox(height: 20.0),
                                ],
                              );
                            },
                          );
                        }),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
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
    );
  }

  void _showAddDiscountDialog(
    BuildContext context,
    CartScreenController controller,
  ) {
    final discountValueController = TextEditingController(
      text:
          controller.discountValue.value > 0
              ? controller.discountValue.value.toString()
              : '',
    );
    final discountTypeController = controller.discountType;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Obx(
          () => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: ColorConstants.bgColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Add Discount',
                    style: TextStyle(
                      fontSize: 21.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: discountValueController,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter Discount Value',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: ColorConstants.primaryColor,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      MenuAnchor(
                        builder: (context, menuController, child) {
                          return InkWell(
                            onTap: () {
                              if (menuController.isOpen) {
                                menuController.close();
                              } else {
                                menuController.open();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    discountTypeController.value,
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    size: 20,
                                    color: Colors.grey.shade700,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        menuChildren: [
                          MenuItemButton(
                            onPressed: () {
                              discountTypeController.value = 'Fixed';
                            },
                            child: Row(
                              children: [
                                if (discountTypeController.value == 'Fixed')
                                  Icon(
                                    Icons.check,
                                    size: 16,
                                    color: ColorConstants.primaryColor,
                                  ),
                                if (discountTypeController.value == 'Fixed')
                                  const SizedBox(width: 8),
                                const Text('Fixed'),
                              ],
                            ),
                          ),
                          MenuItemButton(
                            onPressed: () {
                              discountTypeController.value = 'Percent';
                            },
                            child: Row(
                              children: [
                                if (discountTypeController.value == 'Percent')
                                  Icon(
                                    Icons.check,
                                    size: 16,
                                    color: ColorConstants.primaryColor,
                                  ),
                                if (discountTypeController.value == 'Percent')
                                  const SizedBox(width: 8),
                                const Text('Percent'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          hoverColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          hoverColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap: () {
                            final value =
                                double.tryParse(discountValueController.text) ??
                                0.0;
                            if (value > 0) {
                              if (discountTypeController.value == 'Fixed') {
                                if (value > controller.totalPrice) {
                                  controller.setDiscount(
                                    controller.totalPrice,
                                    discountTypeController.value,
                                  );
                                } else {
                                  controller.setDiscount(
                                    value,
                                    discountTypeController.value,
                                  );
                                }
                              } else {
                                if (value > 100.0) {
                                  controller.setDiscount(
                                    100.0,
                                    discountTypeController.value,
                                  );
                                } else {
                                  controller.setDiscount(
                                    value,
                                    discountTypeController.value,
                                  );
                                }
                              }
                            }
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: ColorConstants.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'Save',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class QuantitySelector extends StatefulWidget {
  final int initialQuantity;
  final Function(int) onQuantityChanged;
  final int minQuantity;
  final int maxQuantity;

  const QuantitySelector({
    super.key,
    required this.initialQuantity,
    required this.onQuantityChanged,
    this.minQuantity = 1,
    this.maxQuantity = 99,
  });

  @override
  State<QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  late TextEditingController _controller;
  late int _currentQuantity;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _currentQuantity = widget.initialQuantity;
    _controller = TextEditingController(text: _currentQuantity.toString());
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(QuantitySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialQuantity != widget.initialQuantity) {
      _currentQuantity = widget.initialQuantity;
      _controller.text = _currentQuantity.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateQuantity(int newQuantity) {
    if (newQuantity >= widget.minQuantity &&
        newQuantity <= widget.maxQuantity) {
      setState(() {
        _currentQuantity = newQuantity;
        _controller.text = newQuantity.toString();
      });
      widget.onQuantityChanged(newQuantity);
    }
  }

  void _increment() {
    _updateQuantity(_currentQuantity + 1);
  }

  void _decrement() {
    if (_currentQuantity <= widget.minQuantity) {
      widget.onQuantityChanged(0);
    } else {
      _updateQuantity(_currentQuantity - 1);
    }
  }

  void _onTextChanged(String value) {
    if (value.isEmpty) {
      return;
    }

    int? quantity = int.tryParse(value);
    if (quantity != null) {
      if (quantity >= widget.minQuantity && quantity <= widget.maxQuantity) {
        setState(() {
          _currentQuantity = quantity;
        });
        widget.onQuantityChanged(quantity);
      } else {
        _controller.text = _currentQuantity.toString();
      }
    } else {
      _controller.text = _currentQuantity.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: ColorConstants.primaryColor),
        color: Colors.pink.shade50,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _decrement,
            child: Container(
              width: 26.0,
              height: 26.0,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  bottomLeft: Radius.circular(6),
                ),
              ),
              child: Center(
                child: Text(
                  '-',
                  style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.primaryColor,
                  ),
                ),
              ),
            ),
          ),

          Container(
            width: 35.0,
            height: 26.0,
            decoration: BoxDecoration(color: Colors.transparent),
            child: Center(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.2,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  isDense: true,
                ),
                onChanged: _onTextChanged,
                onSubmitted: (value) {
                  _onTextChanged(value);
                  _focusNode.unfocus();
                },
                onTapOutside: (event) {
                  _focusNode.unfocus();
                },
              ),
            ),
          ),

          GestureDetector(
            onTap: _currentQuantity < widget.maxQuantity ? _increment : null,
            child: Container(
              width: 26.0,
              height: 26.0,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
              ),
              child: Center(
                child: Text(
                  '+',
                  style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                    color:
                        _currentQuantity < widget.maxQuantity
                            ? ColorConstants.primaryColor
                            : Colors.grey.shade400,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
