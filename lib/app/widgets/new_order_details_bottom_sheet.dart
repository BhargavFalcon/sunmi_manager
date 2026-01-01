import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/utils/currency_formatter.dart';
import '../model/getorderModel.dart' as orderModel;
import '../model/RestaurantDetailsModel.dart';
import '../services/sunmi_invoice_printer_service.dart';
import '../constants/image_constants.dart';
import '../constants/translation_keys.dart';
import '../../main.dart';
import '../constants/api_constants.dart';

class NewOrderDetailsBottomSheet {
  static void show(orderModel.Data orderData) {
    final context = Get.context;
    if (context == null) return;

    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (builderContext) {
        final draggableController = DraggableScrollableController();

        return DraggableScrollableSheet(
          controller: draggableController,
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder:
              (context, scrollController) => _buildBottomSheetContent(
                builderContext,
                orderData,
                screenHeight,
                scrollController,
                draggableController,
              ),
        );
      },
    );
  }

  static Widget _buildBottomSheetContent(
    BuildContext context,
    orderModel.Data orderData,
    double screenHeight,
    ScrollController scrollController,
    DraggableScrollableController draggableController,
  ) {
    final orderDetails = orderData.order;
    if (orderDetails == null) {
      return Container(
        decoration: BoxDecoration(
          color: ColorConstants.bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: ColorConstants.getShadow2,
        ),
        child: Center(
          child: Text(
            TranslationKeys.noItemsFound.tr,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: ColorConstants.getShadow2,
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        child: _buildOrderDetailsContent(context, orderData, orderDetails),
      ),
    );
  }

  static Widget _buildOrderDetailsContent(
    BuildContext context,
    orderModel.Data orderData,
    orderModel.Order orderDetails,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(ImageConstant.order, height: 24, width: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${orderDetails.formattedOrderNumber ?? orderDetails.id?.toString() ?? ''} (${_formatOrderType(orderDetails.orderType)})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildOrderTimeInfo(orderDetails),
            const SizedBox(height: 8),
            if (orderDetails.customer != null &&
                _hasCustomerInfo(orderDetails.customer!))
              _buildCustomerDetails(orderDetails.customer!),
            if (orderDetails.customer != null &&
                _hasCustomerInfo(orderDetails.customer!))
              const SizedBox(height: 8),
            Builder(
              builder: (context) {
                final shouldShowWaiter =
                    (orderDetails.customer == null ||
                        !_hasCustomerInfo(orderDetails.customer)) &&
                    _isDineInOrder(orderDetails.orderType) &&
                    _hasWaiterInfo(orderDetails.waiter);

                if (!shouldShowWaiter) return const SizedBox.shrink();

                return Column(
                  children: [
                    _buildWaiterDetails(orderDetails.waiter!),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
            _buildOrderItemsTable(orderData),
            const SizedBox(height: 8),
            _buildPriceSummary(orderData),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: ColorConstants.getShadow2,
                      ),
                      child: Text(
                        TranslationKeys.close.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _printInvoice(orderData),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: ColorConstants.getShadow2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.print,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            TranslationKeys.print.tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  static Widget _buildOrderTimeInfo(orderModel.Order orderDetails) {
    final createdAt = orderDetails.createdAt ?? '';
    final orderType = orderDetails.orderType?.toLowerCase() ?? '';
    final dateTimeString = orderDetails.dateTime ?? '';

    final List<String> timeInfoList = [];

    if (createdAt.isNotEmpty) {
      final formattedCreatedAt = _formatOrderDateTime(createdAt);
      timeInfoList.add(
        '${TranslationKeys.orderCreated.tr}: $formattedCreatedAt',
      );
    }

    if (dateTimeString.isNotEmpty) {
      final formattedDateTime = _formatOrderDateTime(dateTimeString);
      final timeLabel = _getTimeLabel(orderType);
      if (timeLabel != null) {
        timeInfoList.add('$timeLabel: $formattedDateTime');
      }
    }

    if (timeInfoList.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: ColorConstants.getShadow2,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            timeInfoList
                .asMap()
                .entries
                .map(
                  (entry) => Padding(
                    padding: EdgeInsets.only(
                      bottom: entry.key < timeInfoList.length - 1 ? 8 : 0,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 18,
                          color: ColorConstants.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  static String? _getTimeLabel(String orderType) {
    if (orderType == 'delivery' || orderType == 'delivery_order') {
      return TranslationKeys.deliveryTime.tr;
    } else if (orderType == 'pickup' || orderType == 'pickup_order') {
      return TranslationKeys.pickupTime.tr;
    }
    return null;
  }

  static String _formatOrderDateTime(String dateTimeString) {
    try {
      DateTime? dateTime = _parseDateTime(dateTimeString);
      if (dateTime == null) return dateTimeString;

      return _formatToDisplayString(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  static DateTime? _parseDateTime(String dateTimeString) {
    try {
      return DateTime.parse(dateTimeString);
    } catch (e) {
      return _parseCustomFormat(dateTimeString);
    }
  }

  static DateTime? _parseCustomFormat(String dateTimeString) {
    if (!dateTimeString.contains(' ')) return null;

    final parts = dateTimeString.split(' ');
    if (parts.length < 2) return null;

    final dateParts = parts[0].split('-');
    final timeParts = parts[1].split(':');

    if (dateParts.length != 3 || timeParts.length < 2) return null;

    try {
      return DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
        timeParts.length > 2 ? int.parse(timeParts[2]) : 0,
      );
    } catch (e) {
      return null;
    }
  }

  static String _formatToDisplayString(DateTime dateTime) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final year = dateTime.year;
    final hour12 =
        dateTime.hour > 12
            ? dateTime.hour - 12
            : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$month $day, $year $hour12:$minute $period';
  }

  static String _formatOrderType(String? orderType) {
    if (orderType == null || orderType.isEmpty) {
      return TranslationKeys.na.tr;
    }
    switch (orderType.toLowerCase()) {
      case 'dine_in':
        return TranslationKeys.dineIn.tr;
      case 'pickup':
        return TranslationKeys.pickup.tr;
      case 'delivery':
        return TranslationKeys.delivery.tr;
      default:
        return TranslationKeys.na.tr;
    }
  }

  static Widget _buildOrderItemsTable(orderModel.Data orderData) {
    final orderDetails = orderData.order;
    final items = orderDetails?.items ?? [];
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: ColorConstants.getShadow2,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            TranslationKeys.noItemsFound.tr,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: ColorConstants.getShadow2,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(0.7),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(0.8),
          3: FlexColumnWidth(1),
          4: FlexColumnWidth(1),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            children: [
              const Padding(
                padding: EdgeInsets.all(6),
                child: Text(
                  'No',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(
                  TranslationKeys.itemNames.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(
                  TranslationKeys.qty.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(
                  TranslationKeys.priceHeader.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(
                  TranslationKeys.amountHeader.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final itemNumber = item.itemNumber ?? 'M${index + 1}';
            final modifiers = item.modifiers ?? [];
            final details =
                modifiers
                    .map(
                      (m) =>
                          '${m.name ?? ''}${m.price != null && m.price! > 0 ? ' : ${CurrencyFormatter.formatPrice(m.price!.toString())}' : ''}',
                    )
                    .toList();
            if (item.variationName != null && item.variationName!.isNotEmpty) {
              details.insert(0, 'Variation: ${item.variationName}');
            }
            final priceStr =
                item.price is num
                    ? item.price.toString()
                    : (item.price?.toString() ?? '0');
            final amountStr =
                item.amount is num
                    ? item.amount.toString()
                    : (item.amount?.toString() ?? '0');

            return _buildTableRow(
              itemName: item.itemName ?? 'N/A',
              details: details,
              qty: item.quantity?.toString() ?? '0',
              price: CurrencyFormatter.formatPrice(priceStr),
              amount: CurrencyFormatter.formatPrice(amountStr),
              itemNumber: itemNumber,
            );
          }).toList(),
        ],
      ),
    );
  }

  static TableRow _buildTableRow({
    required String itemName,
    required List<String> details,
    required String qty,
    required String price,
    required String amount,
    String itemNumber = 'M1',
  }) {
    return TableRow(
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(6),
          child: Text(
            itemNumber,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                itemName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              if (details.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      details
                          .map(
                            (detail) => Text(
                              detail,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          )
                          .toList(),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(6),
          child: Text(qty, style: const TextStyle(fontSize: 12)),
        ),
        Padding(
          padding: const EdgeInsets.all(6),
          child: Text(price, style: const TextStyle(fontSize: 12)),
        ),
        Padding(
          padding: const EdgeInsets.all(6),
          child: Text(amount, style: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  static Widget _buildPriceSummary(orderModel.Data orderData) {
    final orderDetails = orderData.order;
    final totals = orderDetails?.totals;
    final itemsCount = orderDetails?.items?.length ?? 0;
    final taxes = orderData.taxes ?? [];
    final charges = orderDetails?.charges ?? [];
    final isTaxIncluded = _isTaxIncluded(orderData);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${TranslationKeys.items.tr}${itemsCount > 0 ? ' ($itemsCount)' : ''}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),

          if (totals?.subTotal != null)
            _buildPriceRow(
              '${TranslationKeys.subTotal.tr}:',
              CurrencyFormatter.formatPrice(totals!.subTotal.toString()),
            ),

          ...() {
            if (orderDetails?.discountValue == null) return <Widget>[];
            final discountValue =
                orderDetails!.discountValue is num
                    ? (orderDetails.discountValue as num).toDouble()
                    : double.tryParse(orderDetails.discountValue.toString()) ??
                        0.0;
            if (discountValue <= 0) return <Widget>[];
            return [
              _buildPriceRow(
                '${TranslationKeys.discount.tr}:',
                '-${CurrencyFormatter.formatPrice(discountValue.toString())}',
              ),
            ];
          }(),

          if (charges.isNotEmpty)
            ...charges.map((charge) {
              final chargeAmount =
                  charge.amount is num
                      ? (charge.amount as num).toDouble()
                      : double.tryParse(charge.amount?.toString() ?? '0') ??
                          0.0;
              if (chargeAmount <= 0) return const SizedBox.shrink();
              return _buildPriceRow(
                charge.chargeName ?? TranslationKeys.charge.tr,
                CurrencyFormatter.formatPrice(chargeAmount.toString()),
              );
            }),

          if (taxes.isNotEmpty)
            ...taxes.map((tax) {
              final taxAmount =
                  tax.amount is num
                      ? (tax.amount as num).toDouble()
                      : double.tryParse(tax.amount?.toString() ?? '0') ?? 0.0;
              if (taxAmount <= 0) return const SizedBox.shrink();

              final formattedAmount = CurrencyFormatter.formatPrice(
                taxAmount.toString(),
              );
              final percent = tax.percent?.toString() ?? '';
              final taxSuffix =
                  isTaxIncluded ? ' ${TranslationKeys.incl.tr}:' : ':';
              final taxLabel =
                  percent.isNotEmpty
                      ? '${tax.taxName ?? TranslationKeys.tax.tr} ($percent%)$taxSuffix'
                      : '${tax.taxName ?? TranslationKeys.tax.tr}$taxSuffix';
              return _buildPriceRow(taxLabel, formattedAmount);
            }),

          ...() {
            if (totals?.tipAmount == null) return <Widget>[];
            final tipAmountStr =
                totals!.tipAmount is num
                    ? totals.tipAmount.toString()
                    : (totals.tipAmount?.toString() ?? '0');
            if (!_isValidAmount(tipAmountStr)) return <Widget>[];
            return [
              _buildPriceRow(
                '${TranslationKeys.tip.tr}:',
                CurrencyFormatter.formatPrice(tipAmountStr),
              ),
            ];
          }(),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, thickness: 1, color: Colors.grey),
          ),

          if (totals?.total != null)
            _buildPriceRow(
              '${TranslationKeys.total.tr}:',
              CurrencyFormatter.formatPrice(totals!.total.toString()),
              isBold: true,
              valueColor: Colors.red,
            ),
        ],
      ),
    );
  }

  static Widget _buildPriceRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildCustomerDetails(orderModel.Customer customer) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, size: 20, color: ColorConstants.primaryColor),
              const SizedBox(width: 8),
              Text(
                TranslationKeys.customerDetails.tr,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (customer.name != null && customer.name!.isNotEmpty)
            _buildDetailRow(TranslationKeys.name.tr, customer.name!),
          if (customer.email != null && customer.email!.isNotEmpty)
            _buildDetailRow(TranslationKeys.email.tr, customer.email!),
          if (customer.phoneNumber != null && customer.phoneNumber!.isNotEmpty)
            _buildDetailRow(
              TranslationKeys.phone.tr,
              '${customer.phoneCode ?? ''}${customer.phoneNumber}',
            ),
        ],
      ),
    );
  }

  static bool _hasCustomerInfo(orderModel.Customer? customer) {
    if (customer == null) return false;
    return (customer.name != null && customer.name!.isNotEmpty) ||
        (customer.email != null && customer.email!.isNotEmpty) ||
        (customer.phoneNumber != null && customer.phoneNumber!.isNotEmpty);
  }

  static bool _isDineInOrder(String? orderType) {
    if (orderType == null) return false;
    final type = orderType.toLowerCase().replaceAll(' ', '_');
    return type == 'dine_in' || type == 'dinein' || type == 'dine in';
  }

  static bool _hasWaiterInfo(orderModel.Waiter? waiter) {
    if (waiter == null) return false;
    return (waiter.name != null && waiter.name!.trim().isNotEmpty) ||
        waiter.id != null ||
        (waiter.email != null && waiter.email!.trim().isNotEmpty) ||
        (waiter.phoneNumber != null && waiter.phoneNumber!.trim().isNotEmpty);
  }

  static Widget _buildWaiterDetails(orderModel.Waiter waiter) {
    final hasName = waiter.name != null && waiter.name!.trim().isNotEmpty;
    final hasId = waiter.id != null;

    if (!hasName && !hasId) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.restaurant,
                size: 20,
                color: ColorConstants.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                TranslationKeys.waiter.tr,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (waiter.name != null && waiter.name!.trim().isNotEmpty)
            _buildDetailRow(TranslationKeys.name.tr, waiter.name!),
          if (waiter.email != null && waiter.email!.trim().isNotEmpty)
            _buildDetailRow(TranslationKeys.email.tr, waiter.email!),
          if (waiter.phoneNumber != null &&
              waiter.phoneNumber!.trim().isNotEmpty)
            _buildDetailRow(
              TranslationKeys.phone.tr,
              '${waiter.phoneCode ?? ''}${waiter.phoneNumber}',
            ),
        ],
      ),
    );
  }

  static Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  static Branches? _getBranch() {
    try {
      final storedData = box.read(ArgumentConstant.restaurantDetailsKey);
      if (storedData == null || storedData is! Map<String, dynamic>) {
        return null;
      }
      final restaurantDetails = RestaurantModel.fromJson(storedData);
      if (restaurantDetails.data?.branches == null ||
          restaurantDetails.data!.branches!.isEmpty) {
        return null;
      }
      return restaurantDetails.data!.branches!.first;
    } catch (e) {
      return null;
    }
  }

  static bool _isTaxIncluded(orderModel.Data orderData) {
    if (orderData.taxInclusive != null) {
      return orderData.taxInclusive == true;
    }
    final branch = _getBranch();
    return branch?.taxesIncluded == true;
  }

  static void _printInvoice(orderModel.Data orderData) {
    if (orderData.order == null) {
      return;
    }
    final printerService = SunmiInvoicePrinterService();
    printerService.printInvoice(orderData);
  }

  static bool _isValidAmount(String? amount) {
    if (amount == null ||
        amount.isEmpty ||
        amount == 'null' ||
        amount == '0' ||
        amount == '0.0' ||
        amount == '0.00') {
      return false;
    }
    final value = double.tryParse(amount);
    return value != null && value > 0;
  }
}
