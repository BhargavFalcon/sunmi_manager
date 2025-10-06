import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';

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
        return Scaffold(
          backgroundColor: ColorConstants.bgColor,
          body: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(
                      12,
                    ).copyWith(top: MediaQuery.of(context).padding.top + 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: ColorConstants.getShadow2,
                    ),
                    child: Center(
                      child: Text(
                        "Cart",
                        style: TextStyle(fontSize: 20, color: Colors.black),
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
                        height: MySize.getHeight(30),
                        width: MySize.getHeight(30),
                        decoration: BoxDecoration(
                          color: ColorConstants.primaryColor.withValues(
                            alpha: 0.10,
                          ),
                          borderRadius: BorderRadius.circular(8),
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
                child: Obx(() {
                  if (controller.cartItems.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: MySize.getHeight(64),
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: MySize.getHeight(16)),
                          Text(
                            "Your cart is empty",
                            style: TextStyle(
                              fontSize: MySize.getHeight(18),
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: controller.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = controller.cartItems[index];
                      final itemId = item['id'] as String;

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
                                    (item['tableNumber'] as String?) ?? "B1",
                                    style: TextStyle(
                                      fontSize: MySize.getHeight(12),
                                      fontWeight: FontWeight.bold,
                                      color: ColorConstants.primaryColor,
                                    ),
                                  ),
                                ),
                                SizedBox(width: MySize.getWidth(12)),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (item['name'] as String?) ??
                                            "Item Name",
                                        style: TextStyle(
                                          fontSize: MySize.getHeight(14),
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: MySize.getHeight(4)),
                                      if ((item['variantName'] as String?) !=
                                              null &&
                                          (item['variantName'] as String)
                                              .trim()
                                              .isNotEmpty)
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF0F2F5),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                    maxWidth: Get.width * 0.5,
                                                  ),
                                                  child: Text(
                                                    item['variantName']
                                                        as String,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize:
                                                          MySize.getHeight(12),
                                                      color: Colors.black87,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 20),
                                                Text(
                                                  () {
                                                    final num? price =
                                                        item['variantPrice']
                                                            as num?;
                                                    return price != null
                                                        ? "₹ ${price.toStringAsFixed(2)}"
                                                        : '';
                                                  }(),
                                                  style: TextStyle(
                                                    fontSize: MySize.getHeight(
                                                      12,
                                                    ),
                                                    color: Colors.black54,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      if (((item['variantName'] as String?) == null ||
                                              (item['variantName'] as String?)
                                                      ?.trim()
                                                      .isEmpty ==
                                                  true) &&
                                          ((item['details'] as String?) != null &&
                                              (item['details'] as String)
                                                  .trim()
                                                  .isNotEmpty))
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 2,
                                          ),
                                          child: Text(
                                            item['details'] as String,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: MySize.getHeight(12),
                                              color: Colors.black54,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      if ((item['variantName'] as String?) !=
                                              null &&
                                          (item['variantName'] as String)
                                              .trim()
                                              .isNotEmpty)
                                        SizedBox(height: MySize.getHeight(4)),
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        onTap: () {
                                          controller.startEditingNote(itemId);
                                        },
                                        child: Builder(
                                          builder: (context) {
                                            final bool isEditing =
                                                (item['editingNote']
                                                    as bool?) ??
                                                false;
                                            final String existingNote =
                                                (item['note'] as String?) ?? '';
                                            if (!isEditing) {
                                              return Text(
                                                existingNote.isEmpty
                                                    ? "+ Add Note"
                                                    : existingNote,
                                                style: TextStyle(
                                                  fontSize: MySize.getHeight(
                                                    12,
                                                  ),
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      existingNote.isEmpty
                                                          ? Colors.grey.shade600
                                                          : Colors.black87,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
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
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    QuantitySelector(
                                      key: ValueKey(item['id']),
                                      initialQuantity:
                                          (item['quantity'] as num?)?.toInt() ??
                                          1,
                                      onQuantityChanged: (newQuantity) {
                                        if (newQuantity == 0) {
                                          controller.removeItem(
                                            item['id'] as String,
                                          );
                                        } else {
                                          controller.updateItemQuantity(
                                            item['id'] as String,
                                            newQuantity,
                                          );
                                        }
                                      },
                                    ),
                                    SizedBox(height: MySize.getHeight(4)),
                                    Text(
                                      "₹${(item['price'] as num?)?.toStringAsFixed(0) ?? '0'}",
                                      style: TextStyle(
                                        fontSize: MySize.getHeight(12),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
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

              Obx(() {
                if (controller.cartItems.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: ColorConstants.getShadow2,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Items:",
                            style: TextStyle(
                              fontSize: MySize.getHeight(14),
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            "${controller.totalItems}",
                            style: TextStyle(
                              fontSize: MySize.getHeight(14),
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: MySize.getHeight(8)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Amount:",
                            style: TextStyle(
                              fontSize: MySize.getHeight(16),
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "₹${controller.totalPrice.toStringAsFixed(0)}",
                            style: TextStyle(
                              fontSize: MySize.getHeight(16),
                              fontWeight: FontWeight.bold,
                              color: ColorConstants.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: MySize.getHeight(16)),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.snackbar(
                              "Checkout",
                              "Order placed successfully!",
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorConstants.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Place Order",
                            style: TextStyle(
                              fontSize: MySize.getHeight(16),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
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
      height: MySize.getHeight(26),
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
              width: MySize.getWidth(26),
              height: MySize.getHeight(26),
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
                    fontSize: MySize.getHeight(16),
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.primaryColor,
                  ),
                ),
              ),
            ),
          ),

          Container(
            width: MySize.getWidth(35),
            height: MySize.getHeight(26),
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
                  fontSize: MySize.getHeight(14),
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
              width: MySize.getWidth(26),
              height: MySize.getHeight(26),
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
                    fontSize: MySize.getHeight(16),
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
