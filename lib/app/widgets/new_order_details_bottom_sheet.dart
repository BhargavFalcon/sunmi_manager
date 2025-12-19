import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/model/notificationModel.dart';
import 'package:managerapp/app/utils/currency_formatter.dart';

class NewOrderDetailsBottomSheet {
  static void show(Order order) {
    final context = Get.context;
    if (context == null) return;

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _buildBottomSheetContent(context, order),
    );
  }

  static Widget _buildBottomSheetContent(BuildContext context, Order order) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: ColorConstants.bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: ColorConstants.getShadow2,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Order #${order.formattedOrderNumber ?? order.orderNumber ?? ''}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              if (order.orderType != null) ...[
                const SizedBox(height: 4),
                Text(
                  _formatOrderType(order.orderType!),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
              if (order.dateTime != null) ...[
                const SizedBox(height: 4),
                Text(
                  order.dateTime!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 8),
              if (order.customer != null && order.customer!.name != null) ...[
                _buildSectionTitle('Customer'),
                const SizedBox(height: 4),
                _buildInfoRow('Name', order.customer!.name!),
                if (order.customer!.phoneNumber != null)
                  _buildInfoRow('Phone', order.customer!.phoneNumber!),
                if (order.deliveryAddress != null)
                  _buildInfoRow('Address', order.deliveryAddress!),
                const SizedBox(height: 8),
              ],
              _buildSectionTitle('Items'),
              const SizedBox(height: 4),
              _buildOrderItemsTable(order),
              const SizedBox(height: 8),
              _buildSectionTitle('Summary'),
              const SizedBox(height: 4),
              _buildPriceSummary(order),
              if (order.payments != null && order.payments!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildSectionTitle('Payments'),
                const SizedBox(height: 4),
                _buildPaymentsList(order.payments!),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  static Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  static Widget _buildOrderItemsTable(Order order) {
    if (order.items == null || order.items!.isEmpty) {
      return const Text('No items found');
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(0.5),
        2: FlexColumnWidth(0.8),
      },
      children: [
        const TableRow(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Item',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Qty',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Amount',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        ...order.items!.map((item) {
          if (item.isDeleted == true) {
            return const TableRow(
              children: [SizedBox(), SizedBox(), SizedBox()],
            );
          }

          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemName ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (item.variationName != null &&
                        item.variationName!.isNotEmpty)
                      Text(
                        '  ${item.variationName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    if (item.modifiers != null && item.modifiers!.isNotEmpty)
                      ...item.modifiers!.map(
                        (modifier) => Padding(
                          padding: const EdgeInsets.only(left: 16, top: 4),
                          child: Text(
                            '  + ${modifier.name}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '${item.quantity ?? 0}',
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  item.formattedAmount ?? item.amount ?? '0',
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  static Widget _buildPriceSummary(Order order) {
    final totals = order.totals;
    if (totals == null) return const SizedBox();

    final taxBreakupMap = _aggregateTaxBreakup(order.items ?? []);

    return Column(
      children: [
        if (totals.subTotal != null)
          _buildSummaryRow(
            'Sub Total',
            CurrencyFormatter.formatPrice(totals.subTotal!),
          ),
        if (totals.discountAmount != null && totals.discountAmount!.isNotEmpty)
          _buildSummaryRow(
            'Discount',
            CurrencyFormatter.formatPrice(totals.discountAmount!),
          ),
        if (order.charges != null && order.charges!.isNotEmpty)
          ...order.charges!.map(
            (charge) => _buildSummaryRow(
              charge.chargeName ?? 'Charge',
              CurrencyFormatter.formatPrice(charge.amount ?? '0'),
            ),
          ),
        if (taxBreakupMap.isNotEmpty)
          ...taxBreakupMap.entries.map((entry) {
            final amount = entry.value.amount ?? '0';
            final formattedAmount = CurrencyFormatter.formatPrice(amount);
            return _buildSummaryRow(entry.key, formattedAmount);
          }),
        if (totals.totalTaxAmount != null && totals.totalTaxAmount!.isNotEmpty)
          _buildSummaryRow(
            'Total Tax',
            CurrencyFormatter.formatPrice(totals.totalTaxAmount!),
          ),
        if (totals.deliveryFee != null && totals.deliveryFee!.isNotEmpty)
          _buildSummaryRow(
            'Delivery Fee',
            CurrencyFormatter.formatPrice(totals.deliveryFee!),
          ),
        if (totals.tipAmount != null &&
            totals.tipAmount!.isNotEmpty &&
            totals.tipAmount != 'null' &&
            totals.tipAmount != '0' &&
            totals.tipAmount != '0.0' &&
            totals.tipAmount != '0.00' &&
            double.tryParse(totals.tipAmount!) != null &&
            double.tryParse(totals.tipAmount!)! > 0)
          _buildSummaryRow(
            'Tip',
            CurrencyFormatter.formatPrice(totals.tipAmount!),
          ),
        const Divider(height: 24),
        if (totals.total != null)
          _buildSummaryRow(
            'Total',
            CurrencyFormatter.formatPrice(totals.total!),
            isTotal: true,
          ),
        if (totals.amountPaid != null && totals.amountPaid!.isNotEmpty)
          _buildSummaryRow(
            'Amount Paid',
            CurrencyFormatter.formatPrice(totals.amountPaid!),
          ),
      ],
    );
  }

  static Map<String, TaxValue> _aggregateTaxBreakup(List<Items> items) {
    final Map<String, Map<String, dynamic>> aggregatedTaxesData = {};

    for (var item in items) {
      if (item.taxBreakup != null && item.taxBreakup!.taxes.isNotEmpty) {
        item.taxBreakup!.taxes.forEach((taxName, taxValue) {
          if (aggregatedTaxesData.containsKey(taxName)) {
            final existing = aggregatedTaxesData[taxName]!;
            final existingAmount =
                double.tryParse(existing['amount'] ?? '0') ?? 0;
            final newAmount = double.tryParse(taxValue.amount ?? '0') ?? 0;
            final totalAmount = existingAmount + newAmount;
            aggregatedTaxesData[taxName] = {
              'amount': totalAmount.toString(),
              'percent': taxValue.percent,
            };
          } else {
            aggregatedTaxesData[taxName] = {
              'amount': taxValue.amount,
              'percent': taxValue.percent,
            };
          }
        });
      }
    }

    final Map<String, TaxValue> aggregatedTaxes = {};
    aggregatedTaxesData.forEach((taxName, data) {
      aggregatedTaxes[taxName] = TaxValue.fromJson(data);
    });

    return aggregatedTaxes;
  }

  static Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildPaymentsList(List<Payments> payments) {
    return Column(
      children:
          payments.map((payment) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    payment.paymentMethod ?? 'Payment',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    CurrencyFormatter.formatPrice(payment.amount ?? '0'),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  static String _formatOrderType(String orderType) {
    switch (orderType.toLowerCase()) {
      case 'dine_in':
        return 'Dine In';
      case 'pickup':
        return 'Pickup';
      case 'delivery':
        return 'Delivery';
      default:
        return orderType;
    }
  }
}
