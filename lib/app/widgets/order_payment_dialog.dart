import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../constants/color_constant.dart';
import '../constants/sizeConstant.dart';
import '../model/getorderModel.dart' as orderModel;
import '../model/tableModel.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_time_formatter.dart';
import '../data/NetworkClient.dart';
import '../constants/api_constants.dart';
import '../constants/translation_keys.dart';
import '../utils/order_helpers.dart' as helpers;

class OrderPaymentController extends GetxController {
  final orderModel.GetOrderModel orderDetails;
  final Tables table;
  final bool allowSplit;
  final NetworkClient networkClient = NetworkClient();

  OrderPaymentController({
    required this.orderDetails,
    required this.table,
    this.allowSplit = true,
  });

  var paymentType = 'Full Payment'.obs;
  var selectedMethod = 'Cash'.obs;
  var amountToPayController = TextEditingController();
  var tipAmount = 0.0.obs;
  var discountAmount = 0.0.obs;
  var discountType = 'fixed'.obs;
  var discountPercentage = 0.0.obs;
  var isProcessing = false.obs;
  var enteredAmount = 0.0.obs;
  var considerReturnAsTip = false.obs;
  var availableQty = <int, int>{}.obs;
  var splitQty = <int, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    final total = orderDetails.data?.order?.totals?.total ?? 0.0;
    amountToPayController.text = total.toStringAsFixed(2);
    enteredAmount.value = total;

    amountToPayController.addListener(() {
      final val = double.tryParse(amountToPayController.text);
      if (val != null) {
        enteredAmount.value = val;
      } else {
        enteredAmount.value = 0.0;
      }
    });

    _initializeSplitBill();

    if (!allowSplit) {
      paymentType.value = 'Full Payment';
    }
  }

  @override
  void onClose() {
    amountToPayController.dispose();
    super.onClose();
  }

  void _initializeSplitBill() {
    final items = orderDetails.data?.order?.items ?? [];
    for (int i = 0; i < items.length; i++) {
      availableQty[i] = items[i].quantity ?? 0;
      splitQty[i] = 0;
    }
  }

  void resetSplit() {
    _initializeSplitBill();
    _updateSplitAmount();
  }

  void addToSplit(int index, int qty) {
    final available = availableQty[index] ?? 0;
    final toAdd = qty > available ? available : qty;
    if (toAdd > 0) {
      availableQty[index] = available - toAdd;
      splitQty[index] = (splitQty[index] ?? 0) + toAdd;
      availableQty.refresh();
      splitQty.refresh();
      _updateSplitAmount();
    }
  }

  void addAllToSplit(int index) {
    final available = availableQty[index] ?? 0;
    addToSplit(index, available);
  }

  void removeFromSplit(int index, int qty) {
    final currentSplit = splitQty[index] ?? 0;
    final toRemove = qty > currentSplit ? currentSplit : qty;
    if (toRemove > 0) {
      splitQty[index] = currentSplit - toRemove;
      availableQty[index] = (availableQty[index] ?? 0) + toRemove;
      availableQty.refresh();
      splitQty.refresh();
      _updateSplitAmount();
    }
  }

  void removeAllFromSplit(int index) {
    final currentSplit = splitQty[index] ?? 0;
    removeFromSplit(index, currentSplit);
  }

  double get splitTotal {
    final items = orderDetails.data?.order?.items ?? [];
    double total = 0.0;
    for (var i = 0; i < items.length; i++) {
      total += (splitQty[i] ?? 0) * (items[i].price ?? 0.0);
    }
    return total;
  }

  double get splitTax {
    if (totalAmount == 0) return 0.0;
    return (splitTotal / subtotal) * totalTax;
  }

  void _updateSplitAmount() {
    final bool isInclusive = orderDetails.data?.taxInclusive ?? true;
    final splitAmount = isInclusive ? splitTotal : splitTotal + splitTax;
    amountToPayController.text = splitAmount.toStringAsFixed(2);
    enteredAmount.value = splitAmount;
  }

  double get subtotal => orderDetails.data?.order?.totals?.subTotal ?? 0.0;
  double get currentSubtotal =>
      paymentType.value == 'Split Bill' ? splitTotal : subtotal;
  double get totalTax =>
      orderDetails.data?.order?.totals?.totalTaxAmount ?? 0.0;
  double get totalAmount => orderDetails.data?.order?.totals?.total ?? 0.0;

  double get totalBillWithTip {
    final bool isInclusive = orderDetails.data?.taxInclusive ?? true;
    final baseAmountValue =
        paymentType.value == 'Split Bill'
            ? (isInclusive ? splitTotal : splitTotal + splitTax)
            : totalAmount;
    final baseBill = baseAmountValue - discountAmount.value;
    return (baseBill > 0 ? baseBill : 0.0) + tipAmount.value;
  }

  double get payableAmount {
    final bill = totalBillWithTip;
    if (considerReturnAsTip.value && enteredAmount.value > bill) {
      return enteredAmount.value;
    }
    return bill;
  }

  double get returnAmount {
    if (considerReturnAsTip.value) return 0.0;
    final bill = totalBillWithTip;
    final diff = enteredAmount.value - bill;
    return diff > 0 ? diff : 0.0;
  }

  bool get canPay => enteredAmount.value >= (payableAmount - 0.01);

  bool get hasSplitItems => splitQty.values.any((qty) => qty > 0);

  void updatePaymentType(String type, {bool confirmed = false}) {
    if (paymentType.value == 'Split Bill' &&
        type == 'Full Payment' &&
        hasSplitItems &&
        !confirmed) {
      _showSwitchToFullPaymentConfirmation();
      return;
    }

    paymentType.value = type;
    if (type == 'Split Bill') {
      resetSplit();
    } else {
      amountToPayController.text = totalAmount.toStringAsFixed(2);
      enteredAmount.value = totalAmount;
    }
  }

  void _showSwitchToFullPaymentConfirmation() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MySize.getHeight(12)),
        ),
        child: Container(
          width: MySize.getWidth(400),
          padding: EdgeInsets.all(MySize.getHeight(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: MySize.getHeight(60),
                height: MySize.getHeight(60),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.orange.shade200, width: 2),
                ),
                child: Center(
                  child: Text(
                    '!',
                    style: TextStyle(
                      fontSize: MySize.getHeight(32),
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MySize.getHeight(16)),
              Text(
                TranslationKeys.switchingToFullPayment.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: MySize.getHeight(16),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: MySize.getHeight(8)),
              Text(
                TranslationKeys.allSplitItemsWillBeCleared.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: MySize.getHeight(13),
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: MySize.getHeight(24)),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: MySize.getHeight(35),
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              MySize.getHeight(8),
                            ),
                          ),
                        ),
                        child: Text(
                          TranslationKeys.cancel.tr,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: MySize.getHeight(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: MySize.getWidth(12)),
                  Expanded(
                    child: SizedBox(
                      height: MySize.getHeight(35),
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          updatePaymentType('Full Payment', confirmed: true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorConstants.primaryColor,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              MySize.getHeight(8),
                            ),
                          ),
                        ),
                        child: Text(
                          TranslationKeys.confirm.tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: MySize.getHeight(14),
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
      barrierDismissible: false,
    );
  }

  void updateMethod(String method) {
    selectedMethod.value = method;
    if (method == TranslationKeys.card.tr) {
      addTip(0);
      considerReturnAsTip.value = false;
    }
  }

  void addTip(double amount) {
    tipAmount.value = amount;
    _updateAmountToPayWithPayable();
  }

  void addDiscount(
    double amount, {
    String type = 'fixed',
    double? percentageValue,
  }) {
    discountAmount.value = amount;
    if (amount <= 0) {
      discountType.value = 'fixed';
      discountPercentage.value = 0;
    } else {
      discountType.value = type;
      discountPercentage.value =
          (type == 'percentage' && percentageValue != null)
              ? percentageValue
              : 0;
    }
    final bool isInclusive = orderDetails.data?.taxInclusive ?? true;
    final baseAmountValue =
        paymentType.value == 'Split Bill'
            ? (isInclusive ? splitTotal : splitTotal + splitTax)
            : totalAmount;
    if (amount >= baseAmountValue) {
      considerReturnAsTip.value = true;
    } else {
      considerReturnAsTip.value = false;
    }
    _updateAmountToPayWithPayable();
  }

  void _updateAmountToPayWithPayable() {
    final bill = totalBillWithTip;
    enteredAmount.value = bill;
    amountToPayController.text = bill.toStringAsFixed(2);
  }

  String _paymentMethodForApi(String displayMethod) {
    if (displayMethod == TranslationKeys.cash.tr) return 'cash';
    if (displayMethod == TranslationKeys.card.tr) return 'card';
    if (displayMethod == TranslationKeys.upi.tr) return 'upi';
    if (displayMethod == TranslationKeys.bankTransfer.tr)
      return 'bank transfer';
    return displayMethod.toLowerCase();
  }

  void _showPaymentSuccess() {
    safeGetSnackbar(
      TranslationKeys.success.tr,
      TranslationKeys.paymentProcessedSuccessfully.tr,
      backgroundColor: ColorConstants.successGreen,
      colorText: Colors.white,
    );
  }

  void _showPaymentError([String? message]) {
    safeGetSnackbar(
      TranslationKeys.error.tr,
      message ?? TranslationKeys.failedToProcessPayment.tr,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  Future<void> completePayment() async {
    isProcessing.value = true;
    try {
      final amountToPay =
          double.tryParse(amountToPayController.text) ?? payableAmount;

      final billWithoutSurplus = totalBillWithTip;

      double finalTip = tipAmount.value;
      if (considerReturnAsTip.value && amountToPay > billWithoutSurplus) {
        finalTip += amountToPay - billWithoutSurplus;
      }

      final data = <String, dynamic>{
        'order_id': orderDetails.data?.order?.uuid,
        'amount': amountToPay.toStringAsFixed(2),
        'payment_method': _paymentMethodForApi(selectedMethod.value),
      };
      if (finalTip > 0) data['tip_amount'] = finalTip.toStringAsFixed(2);
      if (discountAmount.value > 0) {
        data['discount_type'] = discountType.value;
        data['discount_amount'] = (discountType.value == 'percentage'
                ? discountPercentage.value
                : discountAmount.value)
            .toStringAsFixed(2);
      }
      final response = await networkClient.post(
        ArgumentConstant.paymentsEndpoint,
        data: data,
      );

      if (helpers.isSuccessStatus(response.statusCode)) {
        Get.back(result: true);
        _showPaymentSuccess();
      } else {
        _showPaymentError();
      }
    } catch (e) {
      _showPaymentError('An error occurred: $e');
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> completeSplitPayment() async {
    final orderUuid = orderDetails.data?.order?.uuid;
    if (orderUuid == null || orderUuid.isEmpty) {
      _showPaymentError('Order not found');
      return;
    }

    isProcessing.value = true;
    try {
      final items = orderDetails.data?.order?.items ?? [];
      final splitItems = <Map<String, dynamic>>[];
      for (int i = 0; i < items.length; i++) {
        final qty = splitQty[i] ?? 0;
        if (qty > 0 && items[i].id != null) {
          splitItems.add({'order_item_id': items[i].id, 'quantity': qty});
        }
      }
      if (splitItems.isEmpty) {
        _showPaymentError('No items selected for split payment');
        return;
      }

      final amountToPay =
          double.tryParse(amountToPayController.text) ?? payableAmount;
      double finalTip = tipAmount.value;
      if (considerReturnAsTip.value && amountToPay > totalBillWithTip) {
        finalTip += amountToPay - totalBillWithTip;
      }

      final splitPayload = <String, dynamic>{
        'items': splitItems,
        'payment_method': _paymentMethodForApi(selectedMethod.value),
        'amount': amountToPay.toStringAsFixed(2),
      };
      if (finalTip > 0)
        splitPayload['tip_amount'] = finalTip.toStringAsFixed(2);
      if (discountAmount.value > 0) {
        splitPayload['discount_type'] = discountType.value;
        splitPayload['discount_amount'] = (discountType.value == 'percentage'
                ? discountPercentage.value
                : discountAmount.value)
            .toStringAsFixed(2);
      }
      final endpoint = ArgumentConstant.splitPaymentEndpoint.replaceAll(
        ':order_uuid',
        orderUuid,
      );
      final response = await networkClient.post(
        endpoint,
        data: {'split_type': 'items', 'split': splitPayload},
      );

      if (helpers.isSuccessStatus(response.statusCode)) {
        _showPaymentSuccess();
      } else {
        _showPaymentError();
      }
    } catch (e) {
      _showPaymentError('An error occurred: $e');
    } finally {
      isProcessing.value = false;
    }
  }
}

class OrderPaymentDialog extends StatelessWidget {
  final orderModel.GetOrderModel orderDetails;
  final Tables table;

  const OrderPaymentDialog({
    super.key,
    required this.orderDetails,
    required this.table,
  });

  static Future<bool?> show({
    required orderModel.GetOrderModel orderDetails,
    required Tables table,
    bool allowSplit = true,
  }) {
    if (Get.isRegistered<OrderPaymentController>()) {
      Get.delete<OrderPaymentController>();
    }
    Get.put(
      OrderPaymentController(
        orderDetails: orderDetails,
        table: table,
        allowSplit: allowSplit,
      ),
    );

    return Get.dialog<bool>(
      OrderPaymentDialog(orderDetails: orderDetails, table: table),
      barrierDismissible: true,
      useSafeArea: true,
    ).then((result) {
      if (Get.isRegistered<OrderPaymentController>()) {
        Get.delete<OrderPaymentController>();
      }
      return result;
    });
  }

  @override
  Widget build(BuildContext context) {
    MySize().init(context);
    final controller = Get.find<OrderPaymentController>();
    final isWide = MediaQuery.of(context).size.width > 600;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MySize.getHeight(12)),
      ),
      child: Container(
        width: double.infinity,
        height: MySize.screenHeight * 0.6,
        padding: EdgeInsets.all(MySize.getHeight(8)),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!isWide) ...[
                  _buildPaymentTypeToggle(controller),
                  _buildPaymentInfoButton(),
                ] else ...[
                  _buildPaymentInfoButton(),
                  _buildPaymentTypeToggle(controller),
                  _buildTotalDisplay(controller),
                ],
              ],
            ),
            SizedBox(height: MySize.getHeight(20)),
            Obx(() {
              final currentType = controller.paymentType.value;
              final showSplit =
                  controller.allowSplit && currentType == 'Split Bill';
              return showSplit
                  ? Expanded(child: _buildSplitBillView(context, controller))
                  : Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: _buildRightColumnContent(
                              context,
                              controller,
                            ),
                          ),
                        ),
                        _buildRightColumnButtons(controller),
                      ],
                    ),
                  );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTypeToggle(OrderPaymentController controller) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(MySize.getHeight(8)),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildToggleButton(controller, 'Full Payment'),
            if (controller.allowSplit)
              _buildToggleButton(controller, 'Split Bill'),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalDisplay(OrderPaymentController controller) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'TOTAL ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: MySize.getHeight(12),
          ),
        ),
        Text(
          CurrencyFormatter.formatPrice(controller.totalAmount.toString()),
          style: TextStyle(
            color: ColorConstants.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: MySize.getHeight(12),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentInfoButton() {
    return GestureDetector(
      onTap: () {
        _showPaymentInfoDialog();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MySize.getWidth(12),
          vertical: MySize.getHeight(6),
        ),
        decoration: BoxDecoration(
          color: ColorConstants.primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ColorConstants.primaryColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              color: ColorConstants.primaryColor,
              size: MySize.getHeight(14),
            ),
            SizedBox(width: MySize.getWidth(4)),
            Text(
              TranslationKeys.viewOrder.tr,
              style: TextStyle(
                color: ColorConstants.primaryColor,
                fontSize: MySize.getHeight(12),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentInfoDialog() {
    final controller = Get.find<OrderPaymentController>();
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: EdgeInsets.all(MySize.getHeight(16)),
          constraints: BoxConstraints(
            maxWidth: 400,
            maxHeight: MySize.screenHeight * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${orderDetails.data?.order?.formattedOrderNumber ?? ''}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: MySize.getHeight(16),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(Icons.close, size: MySize.getHeight(20)),
                  ),
                ],
              ),
              SizedBox(height: MySize.getHeight(12)),
              Text(
                DateTimeFormatter.formatDateTime(
                  orderDetails.data?.order?.createdAt,
                ),
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: MySize.getHeight(12),
                ),
              ),
              const Divider(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...?orderDetails.data?.order?.items?.map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.quantity}× ${item.itemName}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: MySize.getHeight(12),
                                  ),
                                ),
                              ),
                              Text(
                                CurrencyFormatter.formatPrice(
                                  item.amount.toString(),
                                ),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: MySize.getHeight(12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (orderDetails.data?.taxes != null &&
                          orderDetails.data!.taxes!.isNotEmpty) ...[
                        const Divider(height: 12),
                        ...?orderDetails.data?.taxes?.map(
                          (tax) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${tax.taxName} (${tax.percent}%)',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: MySize.getHeight(12),
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.formatPrice(
                                    tax.amount.toString(),
                                  ),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: MySize.getHeight(12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (orderDetails.data?.order?.charges != null &&
                          orderDetails.data!.order!.charges!.isNotEmpty) ...[
                        const Divider(height: 12),
                        ...?orderDetails.data?.order?.charges?.map(
                          (charge) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  charge.chargeName ?? '',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: MySize.getHeight(12),
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.formatPrice(
                                    (charge.amount ?? 0).toString(),
                                  ),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: MySize.getHeight(12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const Divider(height: 12),
              // Subtotal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: MySize.getHeight(12),
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatPrice(
                      controller.totalAmount.toString(),
                    ),
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: MySize.getHeight(12),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MySize.getHeight(16)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConstants.primaryColor,
                    padding: EdgeInsets.symmetric(
                      vertical: MySize.getHeight(8),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: MySize.getHeight(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static List<({String label, IconData icon})> _getPaymentMethodConfig() => [
    (
      label: TranslationKeys.cash.tr,
      icon: Icons.account_balance_wallet_outlined,
    ),
    (label: TranslationKeys.card.tr, icon: Icons.credit_card_outlined),
    (label: TranslationKeys.upi.tr, icon: Icons.qr_code_scanner_outlined),
    (
      label: TranslationKeys.bankTransfer.tr,
      icon: Icons.account_balance_outlined,
    ),
  ];

  Widget _buildPaymentMethodsRow(OrderPaymentController controller) {
    final methods = _getPaymentMethodConfig();
    return Row(
      children: [
        for (var i = 0; i < methods.length; i++) ...[
          if (i > 0) SizedBox(width: MySize.getWidth(2)),
          Expanded(
            child: _buildPaymentMethod(
              controller,
              methods[i].label,
              methods[i].icon,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCancelPayRow(
    OrderPaymentController controller, {
    required VoidCallback? onPay,
    required bool canPay,
  }) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: MySize.getHeight(35),
            child: OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                TranslationKeys.cancel.tr,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: MySize.getHeight(12),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: MySize.getWidth(8)),
        Expanded(
          child: SizedBox(
            height: MySize.getHeight(35),
            child: Obx(
              () => ElevatedButton(
                onPressed:
                    (controller.isProcessing.value || !canPay) ? null : onPay,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor:
                      canPay
                          ? ColorConstants.successGreen
                          : Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    controller.isProcessing.value
                        ? const CupertinoActivityIndicator(color: Colors.white)
                        : Text(
                          TranslationKeys.pay.tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: MySize.getHeight(16),
                          ),
                        ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRightColumnContent(
    BuildContext context,
    OrderPaymentController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPaymentMethodsRow(controller),
        SizedBox(height: MySize.getHeight(8)),
        Text(
          TranslationKeys.amountToPay.tr,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: MySize.getHeight(14),
          ),
        ),
        SizedBox(height: MySize.getHeight(8)),
        TextField(
          controller: controller.amountToPayController,
          style: TextStyle(fontSize: MySize.getHeight(14)),
          decoration: InputDecoration(
            fillColor: Colors.grey.shade50,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        SizedBox(height: MySize.getHeight(12)),
        // Tip and Discount side-by-side buttons (using reusable helpers)
        Obx(() {
          final isCard =
              controller.selectedMethod.value == TranslationKeys.card.tr;
          return Row(
            children: [
              if (!isCard) ...[
                Expanded(child: _buildTipButton(context, controller)),
                SizedBox(width: MySize.getWidth(12)),
              ],
              Expanded(child: _buildDiscountButton(context, controller)),
            ],
          );
        }),
        SizedBox(height: MySize.getHeight(12)),
        Obx(
          () => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildSummaryRow(
                  TranslationKeys.totalAmount.tr,
                  controller.totalAmount,
                ),
                if (controller.discountAmount.value > 0)
                  _buildSummaryRow(
                    TranslationKeys.discount.tr,
                    controller.discountAmount.value,
                    color: ColorConstants.successGreen,
                  ),
                if (controller.tipAmount.value > 0)
                  _buildSummaryRow(
                    TranslationKeys.tip.tr,
                    controller.tipAmount.value,
                  ),
                const Divider(height: 12),
                _buildSummaryRow(
                  TranslationKeys.payableAmount.tr,
                  controller.payableAmount,
                  isBold: true,
                ),
                // Show Return Amount only when entered > payable and switch is OFF
                if (controller.returnAmount > 0 &&
                    !controller.considerReturnAsTip.value)
                  _buildSummaryRow(
                    TranslationKeys.returnAmount.tr,
                    controller.returnAmount,
                    color: ColorConstants.successGreen,
                  ),
              ],
            ),
          ),
        ),
        // Switch for considering return as tip (only show if no tip already added AND not Card)
        Obx(() {
          final isCard =
              controller.selectedMethod.value == TranslationKeys.card.tr;
          if (!isCard &&
              controller.returnAmount > 0 &&
              controller.tipAmount.value == 0) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: MySize.getHeight(8)),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      TranslationKeys.considerReturnAsTip.tr,
                      style: TextStyle(
                        fontSize: MySize.getHeight(12),
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  Switch(
                    value: controller.considerReturnAsTip.value,
                    activeColor: ColorConstants.successGreen,
                    onChanged: (val) {
                      controller.considerReturnAsTip.value = val;
                    },
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildRightColumnButtons(OrderPaymentController controller) {
    return Padding(
      padding: EdgeInsets.only(top: MySize.getHeight(12)),
      child: Obx(
        () => _buildCancelPayRow(
          controller,
          onPay: controller.completePayment,
          canPay: controller.canPay,
        ),
      ),
    );
  }

  Widget _buildToggleButton(OrderPaymentController controller, String label) {
    bool isSelected = controller.paymentType.value == label;
    return GestureDetector(
      onTap: () => controller.updatePaymentType(label),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MySize.getWidth(16),
          vertical: MySize.getHeight(6),
        ),
        decoration: BoxDecoration(
          color: isSelected ? ColorConstants.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(MySize.getHeight(6)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: MySize.getHeight(12),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(
    OrderPaymentController controller,
    String method,
    IconData icon,
  ) {
    return Obx(() {
      final isSelected = controller.selectedMethod.value == method;
      final color = isSelected ? ColorConstants.primaryColor : Colors.grey;
      return GestureDetector(
        onTap: () => controller.updateMethod(method),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: MySize.getHeight(6)),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? ColorConstants.primaryColor.withOpacity(0.05)
                    : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  isSelected
                      ? ColorConstants.primaryColor
                      : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: MySize.getHeight(18)),
              SizedBox(height: MySize.getHeight(4)),
              Text(
                method,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: MySize.getHeight(9),
                  color: color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSummaryRow(
    String label,
    double amount, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MySize.getHeight(4)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: MySize.getHeight(12),
            ),
          ),
          Text(
            CurrencyFormatter.formatPrice(amount.toString()),
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: MySize.getHeight(12),
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Tip Button Widget
  Widget _buildTipButton(
    BuildContext context,
    OrderPaymentController controller, {
    bool compact = false,
  }) {
    final hasTip = controller.tipAmount.value > 0;
    final activeColor = ColorConstants.successGreen;

    return SizedBox(
      height: MySize.getHeight(35),
      child: GestureDetector(
        onTap: () {
          if (hasTip) {
            controller.addTip(0);
          } else {
            _showTipSelectionDialog(context, controller);
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 0 : MySize.getWidth(6),
          ),
          decoration: BoxDecoration(
            color: hasTip ? activeColor.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasTip ? activeColor : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.monetization_on_outlined,
                size: MySize.getHeight(16),
                color: hasTip ? activeColor : Colors.grey.shade700,
              ),
              SizedBox(width: MySize.getWidth(compact ? 4 : 6)),
              Flexible(
                child: Text(
                  hasTip
                      ? '${TranslationKeys.tipAdded.tr} ${CurrencyFormatter.formatPrice(controller.tipAmount.value.toString())}'
                      : TranslationKeys.tip.tr,
                  style: TextStyle(
                    fontSize: MySize.getHeight(compact ? 11 : 12),
                    fontWeight: FontWeight.w600,
                    color: hasTip ? activeColor : Colors.grey.shade700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable Discount Button Widget
  Widget _buildDiscountButton(
    BuildContext context,
    OrderPaymentController controller, {
    bool compact = false,
  }) {
    final hasDiscount = controller.discountAmount.value > 0;
    final activeColor = ColorConstants.primaryColor;

    return SizedBox(
      height: MySize.getHeight(35),
      child: GestureDetector(
        onTap: () {
          if (hasDiscount) {
            controller.addDiscount(0);
          } else {
            _showDiscountSelectionDialog(context, controller);
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 0 : MySize.getWidth(6),
          ),
          decoration: BoxDecoration(
            color: hasDiscount ? activeColor.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasDiscount ? activeColor : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_offer_outlined,
                size: MySize.getHeight(16),
                color: hasDiscount ? activeColor : Colors.grey.shade700,
              ),
              SizedBox(width: MySize.getWidth(compact ? 4 : 6)),
              Flexible(
                child: Text(
                  hasDiscount
                      ? '${TranslationKeys.discount.tr} ${CurrencyFormatter.formatPrice(controller.discountAmount.value.toString())}'
                      : TranslationKeys.discount.tr,
                  style: TextStyle(
                    fontSize: MySize.getHeight(compact ? 11 : 12),
                    fontWeight: FontWeight.w600,
                    color: hasDiscount ? activeColor : Colors.grey.shade700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTipSelectionDialog(
    BuildContext context,
    OrderPaymentController controller,
  ) {
    double currentTip = controller.tipAmount.value;
    double subtotal = controller.currentSubtotal;

    RxString activeOption = ''.obs;
    final customController = TextEditingController();

    // Initialize state only if we have a logical match
    if (currentTip > 0 && subtotal > 0) {
      if ((currentTip - subtotal * 0.05).abs() < 0.01) {
        activeOption.value = '5%';
      } else if ((currentTip - subtotal * 0.10).abs() < 0.01) {
        activeOption.value = '10%';
      } else if ((currentTip - subtotal * 0.15).abs() < 0.01) {
        activeOption.value = '15%';
      } else if ((currentTip - subtotal * 0.20).abs() < 0.01) {
        activeOption.value = '20%';
      } else {
        activeOption.value = 'Custom';
        customController.text = currentTip.toStringAsFixed(2);
      }
    }

    RxDouble tempTip = currentTip.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MySize.getHeight(12)),
        ),
        backgroundColor: Colors.white,
        child: Container(
          width: MySize.getWidth(400),
          padding: EdgeInsets.all(MySize.getHeight(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                TranslationKeys.addTip.tr,
                style: TextStyle(
                  fontSize: MySize.getHeight(18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: MySize.getHeight(20)),
              Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildTipOptionBox(
                            controller,
                            '5%',
                            0.05,
                            activeOption,
                            tempTip,
                          ),
                        ),
                        SizedBox(width: MySize.getWidth(8)),
                        Expanded(
                          child: _buildTipOptionBox(
                            controller,
                            '10%',
                            0.10,
                            activeOption,
                            tempTip,
                          ),
                        ),
                        SizedBox(width: MySize.getWidth(8)),
                        Expanded(
                          child: _buildTipOptionBox(
                            controller,
                            '15%',
                            0.15,
                            activeOption,
                            tempTip,
                          ),
                        ),
                        SizedBox(width: MySize.getWidth(8)),
                        Expanded(
                          child: _buildTipOptionBox(
                            controller,
                            '20%',
                            0.20,
                            activeOption,
                            tempTip,
                          ),
                        ),
                        SizedBox(width: MySize.getWidth(8)),
                        Expanded(
                          child: _buildCustomTipBox(
                            activeOption,
                            tempTip,
                            customController,
                          ),
                        ),
                      ],
                    ),
                    if (activeOption.value == 'Custom') ...[
                      SizedBox(height: MySize.getHeight(16)),
                      TextField(
                        controller: customController,
                        style: TextStyle(fontSize: MySize.getHeight(12)),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: TranslationKeys.enterCustomAmount.tr,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              '€', // Using Euro symbol as per screenshots
                              style: TextStyle(
                                fontSize: MySize.getHeight(12),
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 0,
                            minHeight: 0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: MySize.getWidth(12),
                            vertical: MySize.getHeight(12),
                          ),
                        ),
                        onChanged: (val) {
                          tempTip.value = double.tryParse(val) ?? 0.0;
                        },
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: MySize.getHeight(24)),
              // Remove Tip button (only visible if there was a tip)
              if (currentTip > 0)
                Padding(
                  padding: EdgeInsets.only(bottom: MySize.getHeight(12)),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        controller.addTip(0);
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: MySize.getHeight(12),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: Colors.red.shade300),
                      ),
                      child: Text(
                        TranslationKeys.remove.tr,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: MySize.getHeight(12),
                        ),
                      ),
                    ),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: MySize.getHeight(12),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        TranslationKeys.cancel.tr,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: MySize.getHeight(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: MySize.getWidth(12)),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.addTip(tempTip.value);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConstants.primaryColor,
                        padding: EdgeInsets.symmetric(
                          vertical: MySize.getHeight(12),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        TranslationKeys.save.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MySize.getHeight(12),
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
  }

  Widget _buildTipOptionBox(
    OrderPaymentController controller,
    String label,
    double percent,
    RxString activeOption,
    RxDouble tempTip,
  ) {
    final amount = controller.currentSubtotal * percent;
    final isSelected = activeOption.value == label;
    final color = isSelected ? ColorConstants.primaryColor : Colors.black;

    return GestureDetector(
      onTap: () {
        activeOption.value = label;
        tempTip.value = double.parse(amount.toStringAsFixed(2));
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: MySize.getHeight(8)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected ? ColorConstants.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: MySize.getHeight(12),
                color: color,
              ),
            ),
            SizedBox(height: MySize.getHeight(4)),
            Text(
              CurrencyFormatter.formatPrice(amount.toString()),
              style: TextStyle(
                fontSize: MySize.getHeight(10),
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTipBox(
    RxString activeOption,
    RxDouble tempTip,
    TextEditingController customController,
  ) {
    bool isSelected = activeOption.value == 'Custom';
    return GestureDetector(
      onTap: () {
        activeOption.value = 'Custom';
        tempTip.value = double.tryParse(customController.text) ?? 0.0;
      },
      child: Container(
        // width: MySize.getWidth(70), // Removed fixed width for Row layout
        height: MySize.getHeight(46), // Match approx height of others
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(MySize.getHeight(8)),
          border: Border.all(
            color:
                isSelected ? ColorConstants.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          TranslationKeys.custom.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: MySize.getHeight(12),
            color: isSelected ? ColorConstants.primaryColor : Colors.black,
          ),
        ),
      ),
    );
  }

  void _showDiscountSelectionDialog(
    BuildContext context,
    OrderPaymentController controller,
  ) {
    RxBool isFixed = true.obs;
    final amountController = TextEditingController();

    // Pre-fill if existing discount
    if (controller.discountAmount.value > 0) {
      amountController.text = controller.discountAmount.value.toStringAsFixed(
        2,
      );
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MySize.getHeight(12)),
        ),
        backgroundColor: Colors.white,
        child: Container(
          width: MySize.getWidth(400),
          padding: EdgeInsets.all(MySize.getHeight(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                TranslationKeys.addDiscount.tr,
                style: TextStyle(
                  fontSize: MySize.getHeight(18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: MySize.getHeight(20)),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: amountController,
                      style: TextStyle(fontSize: MySize.getHeight(12)),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: TranslationKeys.enterValue.tr,
                        hintStyle: TextStyle(fontSize: MySize.getHeight(12)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: MySize.getWidth(12),
                          vertical: MySize.getHeight(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: MySize.getWidth(12)),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Obx(
                      () => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildDiscountTypeButton(
                            TranslationKeys.fixed.tr,
                            isFixed.value,
                            () => isFixed.value = true,
                          ),
                          _buildDiscountTypeButton(
                            '%',
                            !isFixed.value,
                            () => isFixed.value = false,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MySize.getHeight(24)),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: MySize.getHeight(12),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        TranslationKeys.cancel.tr,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: MySize.getHeight(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: MySize.getWidth(12)),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final rawInput =
                            double.tryParse(amountController.text) ?? 0.0;
                        double amount = rawInput;
                        if (!isFixed.value) {
                          // Percentage: amount = subtotal * pct / 100
                          if (amount > 100) amount = 100;
                          amount = (controller.currentSubtotal * amount) / 100;
                          if (amount > controller.currentSubtotal) {
                            amount = controller.currentSubtotal;
                          }
                          controller.addDiscount(
                            amount,
                            type: 'percentage',
                            percentageValue: rawInput.clamp(0.0, 100.0),
                          );
                        } else {
                          if (amount > controller.currentSubtotal) {
                            amount = controller.currentSubtotal;
                          }
                          controller.addDiscount(amount, type: 'fixed');
                        }
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConstants.primaryColor,
                        padding: EdgeInsets.symmetric(
                          vertical: MySize.getHeight(12),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        TranslationKeys.save.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MySize.getHeight(12),
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
  }

  Widget _buildDiscountTypeButton(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MySize.getWidth(16),
          vertical: MySize.getHeight(10),
        ),
        decoration: BoxDecoration(
          color: isSelected ? ColorConstants.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(7), // Just inside the border
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: MySize.getHeight(12),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Split Bill View - Two columns: Available Items and Items in Split
  Widget _buildSplitBillView(
    BuildContext context,
    OrderPaymentController controller,
  ) {
    final items = orderDetails.data?.order?.items ?? [];
    final isWide = MediaQuery.of(context).size.width > 600;

    return Obx(() {
      // Trigger reactivity by accessing observables
      controller.availableQty.length;
      controller.splitQty.length;

      return Column(
        children: [
          // Headers - stacked vertically on mobile, side by side on tablet
          if (isWide)
            Padding(
              padding: EdgeInsets.only(bottom: MySize.getHeight(8)),
              child: Row(
                children: [
                  // Left header
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          TranslationKeys.availableItems.tr,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: MySize.getHeight(12),
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          TranslationKeys.clickItemToAdd.tr,
                          style: TextStyle(
                            fontSize: MySize.getHeight(9),
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: MySize.getWidth(5)),
                  // Right header with total
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          TranslationKeys.itemsInSplit.tr,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: MySize.getHeight(12),
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Total: ',
                          style: TextStyle(
                            fontSize: MySize.getHeight(10),
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatPrice(
                            (controller.orderDetails.data?.taxInclusive ?? true)
                                ? controller.splitTotal.toString()
                                : (controller.splitTotal + controller.splitTax)
                                    .toString(),
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: MySize.getHeight(10),
                            color: ColorConstants.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          // Mobile: Vertical layout (Available Items on top, Split Items below)
          // Desktop: Horizontal layout (side by side)
          if (!isWide)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Available Items Section Header
                  Padding(
                    padding: EdgeInsets.only(bottom: MySize.getHeight(4)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          TranslationKeys.availableItems.tr,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: MySize.getHeight(12),
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          TranslationKeys.clickItemToAdd.tr,
                          style: TextStyle(
                            fontSize: MySize.getHeight(9),
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Available Items List - Fixed height with scroll
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Builder(
                        builder: (_) {
                          final availableItems = <int>[];
                          for (int i = 0; i < items.length; i++) {
                            if ((controller.availableQty[i] ?? 0) > 0) {
                              availableItems.add(i);
                            }
                          }
                          if (availableItems.isEmpty) {
                            return Center(
                              child: Text(
                                TranslationKeys.noItemsFound.tr,
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: MySize.getHeight(12),
                                ),
                              ),
                            );
                          }
                          return ListView.builder(
                            padding: EdgeInsets.all(MySize.getHeight(4)),
                            itemCount: availableItems.length,
                            itemBuilder: (_, listIndex) {
                              final index = availableItems[listIndex];
                              final item = items[index];
                              final available =
                                  controller.availableQty[index] ?? 0;
                              final price = item.price ?? 0.0;
                              final totalPrice = available * price;
                              return GestureDetector(
                                onTap: () => controller.addToSplit(index, 1),
                                child: Container(
                                  padding: EdgeInsets.all(MySize.getHeight(6)),
                                  margin: EdgeInsets.only(
                                    bottom:
                                        listIndex < availableItems.length - 1
                                            ? MySize.getHeight(8)
                                            : 0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.itemName ?? '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: MySize.getHeight(12),
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(width: MySize.getWidth(4)),
                                          Text(
                                            CurrencyFormatter.formatPrice(
                                              totalPrice.toString(),
                                            ),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: MySize.getHeight(12),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: MySize.getHeight(4)),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              '$available ${TranslationKeys.available.tr}',
                                              style: TextStyle(
                                                fontSize: MySize.getHeight(9),
                                                color: Colors.grey.shade500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _buildSplitActionButton(
                                                '+1',
                                                () => controller.addToSplit(
                                                  index,
                                                  1,
                                                ),
                                              ),
                                              SizedBox(
                                                width: MySize.getWidth(4),
                                              ),
                                              _buildSplitActionButton(
                                                TranslationKeys.all.tr,
                                                () => controller.addAllToSplit(
                                                  index,
                                                ),
                                                isPrimary: true,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: MySize.getHeight(8)),
                  // Items in Split Section Header
                  Padding(
                    padding: EdgeInsets.only(bottom: MySize.getHeight(4)),
                    child: Row(
                      children: [
                        Text(
                          TranslationKeys.itemsInSplit.tr,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: MySize.getHeight(12),
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Total: ',
                          style: TextStyle(
                            fontSize: MySize.getHeight(10),
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatPrice(
                            (controller.orderDetails.data?.taxInclusive ?? true)
                                ? controller.splitTotal.toString()
                                : (controller.splitTotal + controller.splitTax)
                                    .toString(),
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: MySize.getHeight(10),
                            color: ColorConstants.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Items in Split List - Fixed height with scroll
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Builder(
                        builder: (_) {
                          bool hasItems = false;
                          for (int i = 0; i < items.length; i++) {
                            if ((controller.splitQty[i] ?? 0) > 0) {
                              hasItems = true;
                              break;
                            }
                          }
                          if (!hasItems) {
                            return Center(
                              child: Text(
                                TranslationKeys.noItemsInSplit.tr,
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: MySize.getHeight(12),
                                ),
                              ),
                            );
                          }
                          final splitItems = <int>[];
                          for (int i = 0; i < items.length; i++) {
                            if ((controller.splitQty[i] ?? 0) > 0) {
                              splitItems.add(i);
                            }
                          }
                          return ListView.builder(
                            padding: EdgeInsets.all(MySize.getHeight(4)),
                            itemCount: splitItems.length,
                            itemBuilder: (_, listIndex) {
                              final index = splitItems[listIndex];
                              final item = items[index];
                              final splitQty = controller.splitQty[index] ?? 0;
                              final price = item.price ?? 0.0;
                              final totalPrice = splitQty * price;
                              return Container(
                                margin: EdgeInsets.only(
                                  bottom:
                                      listIndex < splitItems.length - 1
                                          ? MySize.getHeight(8)
                                          : 0,
                                ),
                                padding: EdgeInsets.all(MySize.getHeight(6)),
                                decoration: BoxDecoration(
                                  color: ColorConstants.primaryColor
                                      .withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: ColorConstants.primaryColor
                                        .withOpacity(0.2),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.itemName ?? '',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: MySize.getHeight(12),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(width: MySize.getWidth(4)),
                                        Text(
                                          CurrencyFormatter.formatPrice(
                                            totalPrice.toString(),
                                          ),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: MySize.getHeight(12),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: MySize.getHeight(6)),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              GestureDetector(
                                                onTap:
                                                    () => controller
                                                        .removeFromSplit(
                                                          index,
                                                          1,
                                                        ),
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: MySize.getWidth(
                                                      6,
                                                    ),
                                                    vertical: MySize.getHeight(
                                                      2,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    '-',
                                                    style: TextStyle(
                                                      fontSize:
                                                          MySize.getHeight(9),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: MySize.getWidth(
                                                    8,
                                                  ),
                                                  vertical: MySize.getHeight(2),
                                                ),
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    left: BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                    ),
                                                    right: BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                    ),
                                                  ),
                                                ),
                                                child: Text(
                                                  '$splitQty',
                                                  style: TextStyle(
                                                    fontSize: MySize.getHeight(
                                                      8,
                                                    ),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap:
                                                    (controller.availableQty[index] ??
                                                                0) >
                                                            0
                                                        ? () => controller
                                                            .addToSplit(
                                                              index,
                                                              1,
                                                            )
                                                        : null,
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: MySize.getWidth(
                                                      6,
                                                    ),
                                                    vertical: MySize.getHeight(
                                                      2,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    '+',
                                                    style: TextStyle(
                                                      fontSize:
                                                          MySize.getHeight(9),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          (controller.availableQty[index] ??
                                                                      0) >
                                                                  0
                                                              ? Colors
                                                                  .grey
                                                                  .shade700
                                                              : Colors
                                                                  .grey
                                                                  .shade300,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap:
                                              () => controller
                                                  .removeAllFromSplit(index),
                                          child: Text(
                                            TranslationKeys.removeItem.tr,
                                            style: TextStyle(
                                              fontSize: MySize.getHeight(9),
                                              color:
                                                  ColorConstants.primaryColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            // Desktop: Two columns side by side
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column - Available Items
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Builder(
                        builder: (_) {
                          // Filter items that are available
                          final availableItems = <int>[];
                          for (int i = 0; i < items.length; i++) {
                            if ((controller.availableQty[i] ?? 0) > 0) {
                              availableItems.add(i);
                            }
                          }

                          if (availableItems.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(MySize.getHeight(16)),
                                child: Text(
                                  TranslationKeys.noItemsFound.tr,
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: MySize.getHeight(12),
                                  ),
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: EdgeInsets.all(MySize.getHeight(4)),
                            itemCount: availableItems.length,
                            itemBuilder: (_, listIndex) {
                              final index = availableItems[listIndex];
                              final item = items[index];
                              final available =
                                  controller.availableQty[index] ?? 0;
                              final price = item.price ?? 0.0;
                              final totalPrice = available * price;

                              return GestureDetector(
                                onTap: () => controller.addToSplit(index, 1),
                                child: Container(
                                  margin: EdgeInsets.only(
                                    bottom:
                                        listIndex < availableItems.length - 1
                                            ? MySize.getHeight(8)
                                            : 0,
                                  ),
                                  padding: EdgeInsets.all(MySize.getHeight(6)),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Row 1: Item name and price
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.itemName ?? '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: MySize.getHeight(12),
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(width: MySize.getWidth(4)),
                                          Text(
                                            CurrencyFormatter.formatPrice(
                                              totalPrice.toString(),
                                            ),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: MySize.getHeight(12),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: MySize.getHeight(4)),
                                      // Row 2: Available count and action buttons
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              '$available ${TranslationKeys.available.tr}',
                                              style: TextStyle(
                                                fontSize: MySize.getHeight(9),
                                                color: Colors.grey.shade500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _buildSplitActionButton(
                                                '+1',
                                                () => controller.addToSplit(
                                                  index,
                                                  1,
                                                ),
                                              ),
                                              SizedBox(
                                                width: MySize.getWidth(4),
                                              ),
                                              _buildSplitActionButton(
                                                TranslationKeys.all.tr,
                                                () => controller.addAllToSplit(
                                                  index,
                                                ),
                                                isPrimary: true,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: MySize.getWidth(5)),
                  // Right column - Items in Split
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Builder(
                        builder: (_) {
                          // Check if any items are in split
                          bool hasItems = false;
                          for (int i = 0; i < items.length; i++) {
                            if ((controller.splitQty[i] ?? 0) > 0) {
                              hasItems = true;
                              break;
                            }
                          }

                          if (!hasItems) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(MySize.getHeight(16)),
                                child: Text(
                                  TranslationKeys.noItemsInSplit.tr,
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: MySize.getHeight(12),
                                  ),
                                ),
                              ),
                            );
                          }

                          // Filter items that are in split
                          final splitItems = <int>[];
                          for (int i = 0; i < items.length; i++) {
                            if ((controller.splitQty[i] ?? 0) > 0) {
                              splitItems.add(i);
                            }
                          }

                          return ListView.builder(
                            padding: EdgeInsets.all(MySize.getHeight(4)),
                            itemCount: splitItems.length,
                            itemBuilder: (_, listIndex) {
                              final index = splitItems[listIndex];
                              final item = items[index];
                              final splitQty = controller.splitQty[index] ?? 0;
                              final price = item.price ?? 0.0;
                              final totalPrice = splitQty * price;

                              return Container(
                                margin: EdgeInsets.only(
                                  bottom:
                                      listIndex < splitItems.length - 1
                                          ? MySize.getHeight(8)
                                          : 0,
                                ),
                                padding: EdgeInsets.all(MySize.getHeight(6)),
                                decoration: BoxDecoration(
                                  color: ColorConstants.primaryColor
                                      .withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: ColorConstants.primaryColor
                                        .withOpacity(0.2),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.itemName ?? '',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: MySize.getHeight(12),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(width: MySize.getWidth(4)),
                                        Text(
                                          CurrencyFormatter.formatPrice(
                                            totalPrice.toString(),
                                          ),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: MySize.getHeight(12),
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: MySize.getHeight(6)),
                                    // Row 2: Qty changer and Remove button
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // - qty + buttons (Shrunk)
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              GestureDetector(
                                                onTap:
                                                    () => controller
                                                        .removeFromSplit(
                                                          index,
                                                          1,
                                                        ),
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: MySize.getWidth(
                                                      6,
                                                    ),
                                                    vertical: MySize.getHeight(
                                                      2,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    '-',
                                                    style: TextStyle(
                                                      fontSize:
                                                          MySize.getHeight(9),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: MySize.getWidth(
                                                    8,
                                                  ),
                                                  vertical: MySize.getHeight(2),
                                                ),
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    left: BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                    ),
                                                    right: BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                    ),
                                                  ),
                                                ),
                                                child: Text(
                                                  '$splitQty',
                                                  style: TextStyle(
                                                    fontSize: MySize.getHeight(
                                                      8,
                                                    ),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap:
                                                    (controller.availableQty[index] ??
                                                                0) >
                                                            0
                                                        ? () => controller
                                                            .addToSplit(
                                                              index,
                                                              1,
                                                            )
                                                        : null,
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: MySize.getWidth(
                                                      6,
                                                    ),
                                                    vertical: MySize.getHeight(
                                                      2,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    '+',
                                                    style: TextStyle(
                                                      fontSize:
                                                          MySize.getHeight(9),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          (controller.availableQty[index] ??
                                                                      0) >
                                                                  0
                                                              ? Colors
                                                                  .grey
                                                                  .shade700
                                                              : Colors
                                                                  .grey
                                                                  .shade300,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Right side - Remove button
                                        GestureDetector(
                                          onTap:
                                              () => controller
                                                  .removeAllFromSplit(index),
                                          child: Text(
                                            TranslationKeys.removeItem.tr,
                                            style: TextStyle(
                                              fontSize: MySize.getHeight(9),
                                              color:
                                                  ColorConstants.primaryColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: MySize.getHeight(8)),
          // Bottom bar with PAY button
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: MySize.getHeight(35),
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      TranslationKeys.cancel.tr,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: MySize.getHeight(12),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: MySize.getWidth(8)),
              Expanded(
                child: SizedBox(
                  height: MySize.getHeight(35),
                  child: Obx(
                    () => ElevatedButton(
                      onPressed:
                          controller.isProcessing.value ||
                                  controller.splitTotal <= 0
                              ? null
                              : () =>
                                  _showSplitPaymentPopup(context, controller),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: ColorConstants.successGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          controller.isProcessing.value
                              ? const CupertinoActivityIndicator(
                                color: Colors.white,
                              )
                              : Text(
                                TranslationKeys.makePayment.tr,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: MySize.getHeight(16),
                                ),
                              ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildSplitActionButton(
    String label,
    VoidCallback? onTap, {
    bool isNumber = false,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minWidth: MySize.getWidth(24)),
        padding: EdgeInsets.symmetric(
          horizontal: MySize.getWidth(6),
          vertical: MySize.getHeight(4),
        ),
        decoration: BoxDecoration(
          color:
              isPrimary
                  ? ColorConstants.primaryColor
                  : isNumber
                  ? Colors.grey.shade100
                  : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color:
                isPrimary
                    ? ColorConstants.primaryColor
                    : onTap == null
                    ? Colors.grey.shade200
                    : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: MySize.getHeight(9),
            fontWeight: FontWeight.w600,
            color:
                isPrimary
                    ? Colors.white
                    : onTap == null
                    ? Colors.grey.shade400
                    : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  // Reusable Split Payment Popup - Same UI as Full Payment
  void _showSplitPaymentPopup(
    BuildContext context,
    OrderPaymentController controller,
  ) {
    // Initialize split amount in controller (respecting tax inclusivity)
    final bool isInclusive = controller.orderDetails.data?.taxInclusive ?? true;
    final splitAmountTotal =
        isInclusive
            ? controller.splitTotal
            : controller.splitTotal + controller.splitTax;
    controller.amountToPayController.text = splitAmountTotal.toStringAsFixed(2);
    controller.enteredAmount.value = splitAmountTotal;
    controller.tipAmount.value = 0;
    controller.discountAmount.value = 0;
    controller.discountType.value = 'fixed';
    controller.discountPercentage.value = 0;
    controller.considerReturnAsTip.value = (splitAmountTotal <= 0);

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: MySize.getWidth(350),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(MySize.getHeight(16)),
          child: Obx(() {
            final splitPayable = controller.payableAmount;
            final returnAmt = controller.returnAmount;
            final canPaySplit = controller.canPay;

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        Icons.payment,
                        color: ColorConstants.primaryColor,
                        size: MySize.getHeight(20),
                      ),
                      SizedBox(width: MySize.getWidth(8)),
                      Text(
                        TranslationKeys.makePayment.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MySize.getHeight(16),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MySize.getHeight(16)),

                  _buildPaymentMethodsRow(controller),
                  SizedBox(height: MySize.getHeight(12)),

                  // Amount to Pay
                  Text(
                    TranslationKeys.amountToPay.tr,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: MySize.getHeight(12),
                    ),
                  ),
                  SizedBox(height: MySize.getHeight(6)),
                  TextField(
                    controller: controller.amountToPayController,
                    style: TextStyle(fontSize: MySize.getHeight(14)),
                    decoration: InputDecoration(
                      fillColor: Colors.grey.shade50,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: MySize.getWidth(12),
                        vertical: MySize.getHeight(10),
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  SizedBox(height: MySize.getHeight(12)),

                  // Tip and Discount Buttons (using reusable helpers)
                  Obx(() {
                    final isCard =
                        controller.selectedMethod.value ==
                        TranslationKeys.card.tr;
                    return Row(
                      children: [
                        if (!isCard) ...[
                          Expanded(
                            child: _buildTipButton(
                              context,
                              controller,
                              compact: true,
                            ),
                          ),
                          SizedBox(width: MySize.getWidth(8)),
                        ],
                        Expanded(
                          child: _buildDiscountButton(
                            context,
                            controller,
                            compact: true,
                          ),
                        ),
                      ],
                    );
                  }),
                  SizedBox(height: MySize.getHeight(12)),

                  // Summary
                  Container(
                    padding: EdgeInsets.all(MySize.getHeight(10)),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow('Split Amount', splitAmountTotal),
                        if (controller.discountAmount.value > 0)
                          _buildSummaryRow(
                            TranslationKeys.discount.tr,
                            controller.discountAmount.value,
                            color: ColorConstants.successGreen,
                          ),
                        if (controller.tipAmount.value > 0)
                          _buildSummaryRow(
                            TranslationKeys.tip.tr,
                            controller.tipAmount.value,
                          ),
                        const Divider(height: 12),
                        _buildSummaryRow(
                          TranslationKeys.payableAmount.tr,
                          splitPayable,
                          isBold: true,
                        ),
                        if (returnAmt > 0 &&
                            !controller.considerReturnAsTip.value)
                          _buildSummaryRow(
                            TranslationKeys.returnAmount.tr,
                            returnAmt,
                            color: ColorConstants.successGreen,
                          ),
                      ],
                    ),
                  ),

                  // Return as tip switch
                  Obx(() {
                    final isCard =
                        controller.selectedMethod.value ==
                        TranslationKeys.card.tr;
                    if (!isCard &&
                        returnAmt > 0 &&
                        controller.tipAmount.value == 0) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: MySize.getHeight(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                TranslationKeys.considerReturnAsTip.tr,
                                style: TextStyle(
                                  fontSize: MySize.getHeight(11),
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            Switch(
                              value: controller.considerReturnAsTip.value,
                              activeColor: ColorConstants.successGreen,
                              onChanged: (val) {
                                controller.considerReturnAsTip.value = val;
                              },
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  SizedBox(height: MySize.getHeight(12)),
                  _buildCancelPayRow(
                    controller,
                    onPay: controller.completeSplitPayment,
                    canPay: canPaySplit,
                  ),
                ],
              ),
            );
          }),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
