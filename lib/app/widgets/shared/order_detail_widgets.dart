import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';
import 'package:managerapp/app/constants/translation_keys.dart';
import 'package:managerapp/app/utils/currency_formatter.dart';
import 'package:managerapp/app/utils/date_time_formatter.dart';
import 'package:managerapp/app/utils/order_helpers.dart';

/// Shared order detail UI widgets extracted from order_screen_view.dart
/// and new_order_details_bottom_sheet.dart to eliminate code duplication.
///
/// All methods accept an optional [fontSize] parameter to allow callers
/// to customize text sizes (order_screen uses 13, bottom_sheet uses 12).
class OrderDetailWidgets {
  OrderDetailWidgets._();

  /// Builds a single table row for an order item.
  /// [fontSize] is either a logical size (when [fontSizeAlreadyScaled] is false)
  /// scaled via MySize.getHeight, or an already-scaled size in pixels when true.
  static TableRow buildTableRow({
    required String itemName,
    required List<String> details,
    required String qty,
    required String price,
    required String amount,
    double fontSize = 13,
    bool fontSizeAlreadyScaled = false,
  }) {
    final effectiveFontSize = fontSizeAlreadyScaled
        ? fontSize
        : MySize.getHeight(fontSize);
    return TableRow(
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      children: [
        Padding(
          padding: EdgeInsets.all(MySize.getWidth(6)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                itemName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: effectiveFontSize,
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
                                fontSize: effectiveFontSize,
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
          padding: EdgeInsets.all(MySize.getWidth(6)),
          child: Text(
            qty,
            style: TextStyle(fontSize: effectiveFontSize),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(MySize.getWidth(6)),
          child: Text(
            price,
            style: TextStyle(fontSize: effectiveFontSize),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(MySize.getWidth(6)),
          child: Text(
            amount,
            style: TextStyle(fontSize: effectiveFontSize),
          ),
        ),
      ],
    );
  }

  /// Builds a price row with label and value.
  static Widget buildPriceRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
    double fontSize = 13,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: MySize.getHeight(4)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: MySize.getHeight(fontSize),
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: MySize.getHeight(fontSize),
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a detail row with label and value.
  static Widget buildDetailRow(
    String label,
    String value, {
    double fontSize = 13,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: MySize.getHeight(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MySize.getWidth(80),
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: MySize.getHeight(fontSize),
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: MySize.getHeight(fontSize),
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the order items table widget.
  /// Uses dynamic to work with both orderModel.Data and orderDetailsModel.Data.
  static Widget buildOrderItemsTable(
    dynamic orderData, {
    double fontSize = 13,
    double headerFontSize = 11,
    double emptyFontSize = 14,
  }) {
    final orderDetails = orderData.order;
    final items = orderDetails?.items ?? [];
    if (items.isEmpty) {
      return Container(
        padding: EdgeInsets.all(MySize.getHeight(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: ColorConstants.getShadow2,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(MySize.getHeight(8)),
        ),
        child: Center(
          child: Text(
            TranslationKeys.noItemsFound.tr,
            style: TextStyle(
              fontSize: MySize.getHeight(emptyFontSize),
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: ColorConstants.getShadow2,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(MySize.getHeight(8)),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(0.8),
          2: FlexColumnWidth(1),
          3: FlexColumnWidth(1),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(MySize.getHeight(8)),
              ),
            ),
            children: [
              Padding(
                padding: EdgeInsets.all(MySize.getWidth(6)),
                child: Text(
                  TranslationKeys.itemNames.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MySize.getHeight(headerFontSize),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(MySize.getWidth(6)),
                child: Text(
                  TranslationKeys.qty.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MySize.getHeight(headerFontSize),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(MySize.getWidth(6)),
                child: Text(
                  TranslationKeys.priceHeader.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MySize.getHeight(headerFontSize),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(MySize.getWidth(6)),
                child: Text(
                  TranslationKeys.amountHeader.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MySize.getHeight(headerFontSize),
                  ),
                ),
              ),
            ],
          ),
          ...items.asMap().entries.map((entry) {
            final item = entry.value;
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

            return buildTableRow(
              itemName: item.itemName ?? 'N/A',
              details: List<String>.from(details),
              qty: item.quantity?.toString() ?? '0',
              price: CurrencyFormatter.formatPrice(priceStr),
              amount: CurrencyFormatter.formatPrice(amountStr),
              fontSize: fontSize,
            );
          }).toList(),
        ],
      ),
    );
  }

  /// Builds the price summary widget.
  /// Uses dynamic to work with both orderModel.Data and orderDetailsModel.Data.
  static Widget buildPriceSummary(
    dynamic orderData, {
    double fontSize = 13,
    double titleFontSize = 15,
  }) {
    final orderDetails = orderData.order;
    final totals = orderDetails?.totals;
    final itemsCount = orderDetails?.items?.length ?? 0;
    final taxes = orderData.taxes ?? [];
    final charges = orderDetails?.charges ?? [];
    final taxIncluded = isTaxIncluded(orderData);

    return Container(
      padding: EdgeInsets.all(MySize.getHeight(8)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MySize.getHeight(8)),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: MySize.getHeight(3),
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${TranslationKeys.items.tr}${itemsCount > 0 ? ' ($itemsCount)' : ''}',
            textAlign: TextAlign.start,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: MySize.getHeight(titleFontSize),
            ),
          ),
          SizedBox(height: MySize.getHeight(8)),

          if (totals?.subTotal != null)
            buildPriceRow(
              '${TranslationKeys.subTotal.tr}:',
              CurrencyFormatter.formatPrice(totals!.subTotal.toString()),
              fontSize: fontSize,
            ),

          if (charges.isNotEmpty)
            ...charges.map((charge) {
              final chargeAmount =
                  charge.amount is num
                      ? (charge.amount as num).toDouble()
                      : double.tryParse(charge.amount?.toString() ?? '0') ??
                          0.0;
              if (chargeAmount <= 0) return const SizedBox.shrink();
              return buildPriceRow(
                charge.chargeName ?? TranslationKeys.charge.tr,
                CurrencyFormatter.formatPrice(chargeAmount.toString()),
                fontSize: fontSize,
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
                  taxIncluded ? ' ${TranslationKeys.incl.tr}:' : ':';
              final taxLabel =
                  percent.isNotEmpty
                      ? '${tax.taxName ?? TranslationKeys.tax.tr} ($percent%)$taxSuffix'
                      : '${tax.taxName ?? TranslationKeys.tax.tr}$taxSuffix';
              return buildPriceRow(
                taxLabel,
                formattedAmount,
                fontSize: fontSize,
              );
            }),

          ...() {
            if (totals?.tipAmount == null) return <Widget>[];
            final tipAmountStr =
                totals!.tipAmount is num
                    ? totals.tipAmount.toString()
                    : (totals.tipAmount?.toString() ?? '0');
            if (!isValidAmount(tipAmountStr)) return <Widget>[];
            return [
              buildPriceRow(
                '${TranslationKeys.tip.tr}:',
                CurrencyFormatter.formatPrice(tipAmountStr),
                fontSize: fontSize,
              ),
            ];
          }(),
          ...() {
            if (orderDetails!.totals!.discountAmount == null) return <Widget>[];
            final discountValue =
                orderDetails.totals!.discountAmount is num
                    ? (orderDetails.totals!.discountAmount as num).toDouble()
                    : double.tryParse(
                          orderDetails.totals!.discountAmount.toString(),
                        ) ??
                        0.0;
            if (discountValue <= 0) return <Widget>[];
            final couponCode = orderDetails.couponCode;
            final discountLabel =
                couponCode != null && couponCode.isNotEmpty
                    ? '${TranslationKeys.discount.tr} ($couponCode):'
                    : '${TranslationKeys.discount.tr}:';
            return [
              buildPriceRow(
                discountLabel,
                '-${CurrencyFormatter.formatPrice(discountValue.toString())}',
                valueColor: const Color(0xFF0B9F6E),
                fontSize: fontSize,
              ),
            ];
          }(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: MySize.getHeight(8)),
            child: const Divider(height: 1, thickness: 1, color: Colors.grey),
          ),

          if (totals?.total != null)
            buildPriceRow(
              '${TranslationKeys.total.tr}:',
              CurrencyFormatter.formatPrice(totals!.total.toString()),
              isBold: true,
              valueColor: Colors.red,
              fontSize: fontSize,
            ),
        ],
      ),
    );
  }

  /// Formats phone with + prefix for display (e.g. +91 1234567890).
  static String _formatPhoneWithPlus(String? phoneCode, String? phoneNumber) {
    final code = phoneCode?.trim() ?? '';
    final num = phoneNumber?.trim() ?? '';
    if (num.isEmpty) return '';
    if (code.isEmpty) return num.startsWith('+') ? num : '+$num';
    final plusCode = code.startsWith('+') ? code : '+$code';
    return '$plusCode $num';
  }

  /// Builds the customer details card.
  /// Uses dynamic to work with both orderModel.Customer and orderDetailsModel.Customer.
  static Widget buildCustomerDetails(
    dynamic customer, {
    double fontSize = 13,
    double titleFontSize = 15,
  }) {
    return Container(
      padding: EdgeInsets.all(MySize.getWidth(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MySize.getHeight(8)),
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
                Icons.person,
                size: MySize.getHeight(20),
                color: ColorConstants.primaryColor,
              ),
              SizedBox(width: MySize.getWidth(8)),
              Text(
                TranslationKeys.customerDetails.tr,
                style: TextStyle(
                  fontSize: MySize.getHeight(titleFontSize),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: MySize.getHeight(12)),
          if (customer.name != null && customer.name!.isNotEmpty)
            buildDetailRow(
              TranslationKeys.name.tr,
              customer.name!,
              fontSize: fontSize,
            ),
          if (customer.email != null && customer.email!.isNotEmpty)
            buildDetailRow(
              TranslationKeys.email.tr,
              customer.email!,
              fontSize: fontSize,
            ),
          if (customer.phoneNumber != null && customer.phoneNumber!.isNotEmpty)
            buildDetailRow(
              TranslationKeys.phone.tr,
              _formatPhoneWithPlus(customer.phoneCode, customer.phoneNumber),
              fontSize: fontSize,
            ),
        ],
      ),
    );
  }

  /// Builds the waiter details card: icon + waiter name only.
  /// Uses dynamic to work with both orderModel.Waiter and orderDetailsModel.Waiter.
  static Widget buildWaiterDetails(
    dynamic waiter, {
    double fontSize = 13,
    double titleFontSize = 15,
  }) {
    final hasName = waiter.name != null && waiter.name!.trim().isNotEmpty;
    final hasId = waiter.id != null;

    if (!hasName && !hasId) {
      return const SizedBox.shrink();
    }

    final waiterName = waiter.name?.trim() ?? '';

    return Container(
      padding: EdgeInsets.all(MySize.getWidth(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MySize.getHeight(8)),
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
      child: Row(
        children: [
          Icon(
            Icons.restaurant,
            size: MySize.getHeight(20),
            color: ColorConstants.primaryColor,
          ),
          SizedBox(width: MySize.getWidth(8)),
          Expanded(
            child: Text(
              waiterName.isNotEmpty ? waiterName : '—',
              style: TextStyle(
                fontSize: MySize.getHeight(titleFontSize),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the order time info widget.
  /// Uses dynamic to work with both orderModel.Order and orderDetailsModel.Order.
  /// [dateFormatter] allows different formatters to be used.
  static Widget buildOrderTimeInfo(
    dynamic orderDetails, {
    double fontSize = 13,
    String Function(String?)? dateFormatter,
  }) {
    if (orderDetails == null) return const SizedBox.shrink();

    final formatter = dateFormatter ?? DateTimeFormatter.formatDateTimeWithRestaurantTimezone;
    final createdAt = orderDetails.createdAt ?? '';
    final orderType = orderDetails.orderType?.toLowerCase() ?? '';
    final dateTimeString = orderDetails.dateTime ?? '';

    final List<String> timeInfoList = [];

    if (createdAt.isNotEmpty) {
      final formattedCreatedAt = formatter(createdAt);
      timeInfoList.add(
        '${TranslationKeys.orderCreated.tr}: $formattedCreatedAt',
      );
    }

    if (dateTimeString.isNotEmpty) {
      final formattedDateTime = formatter(dateTimeString);
      final timeLabel = getTimeLabel(orderType);
      if (timeLabel != null) {
        timeInfoList.add('$timeLabel: $formattedDateTime');
      }
    }

    if (timeInfoList.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(MySize.getWidth(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: ColorConstants.getShadow2,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(MySize.getHeight(8)),
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
                      bottom:
                          entry.key < timeInfoList.length - 1
                              ? MySize.getHeight(8)
                              : 0,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: MySize.getHeight(18),
                          color: ColorConstants.primaryColor,
                        ),
                        SizedBox(width: MySize.getWidth(8)),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: MySize.getHeight(fontSize),
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
}
