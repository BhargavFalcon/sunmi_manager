import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/api_constants.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';
import 'package:managerapp/app/constants/translation_keys.dart';
import 'package:managerapp/app/data/NetworkClient.dart';
import 'package:managerapp/app/model/receipt_order_response_model.dart';
import 'package:managerapp/app/utils/currency_formatter.dart';
import 'package:managerapp/app/utils/date_time_formatter.dart';
import 'package:managerapp/app/utils/order_helpers.dart' as helpers;

/// Dialog that fetches and displays payment receipt for a given [paymentId].
/// Opened when user taps the eye (view) button on a payment row.
class PaymentReceiptDialog extends StatefulWidget {
  const PaymentReceiptDialog({super.key, required this.paymentId});

  final int paymentId;

  @override
  State<PaymentReceiptDialog> createState() => _PaymentReceiptDialogState();
}

class _PaymentReceiptDialogState extends State<PaymentReceiptDialog> {
  final NetworkClient _networkClient = NetworkClient();

  ReceiptOrderResponse? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchReceipt();
  }

  Future<void> _fetchReceipt() async {
    setState(() {
      _loading = true;
      _error = null;
      _data = null;
    });
    try {
      final endpoint = ArgumentConstant.paymentReceiptEndpoint
          .replaceAll(':id', widget.paymentId.toString());
      final response = await _networkClient.get(endpoint);
      if (!helpers.isSuccessStatus(response.statusCode)) {
        setState(() {
          _loading = false;
          _error = TranslationKeys.somethingWentWrong.tr;
        });
        return;
      }
      if (response.data is! Map<String, dynamic>) {
        setState(() {
          _loading = false;
          _error = TranslationKeys.somethingWentWrong.tr;
        });
        return;
      }
      final model = ReceiptOrderResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      if (model.success != true || model.data == null) {
        setState(() {
          _loading = false;
          _error = TranslationKeys.somethingWentWrong.tr;
        });
        return;
      }
      setState(() {
        _data = model;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = TranslationKeys.somethingWentWrong.tr;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    MySize().init(context);
    final size = MediaQuery.of(context).size;
    final isFullScreen = _loading;
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.zero,
      child: Container(
        color: Colors.white,
        constraints: BoxConstraints(
          maxHeight: isFullScreen ? size.height : size.height * 0.85,
          maxWidth: size.width,
        ),
        child: Column(
          mainAxisSize: _loading ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (!_loading) _buildHeader(),
            Flexible(
              child: _loading
                  ? Center(
                      child: CupertinoActivityIndicator(
                        radius: MySize.getHeight(8),
                        color: ColorConstants.primaryColor,
                      ),
                    )
                  : SingleChildScrollView(
                      child: _error != null
                          ? Padding(
                              padding: EdgeInsets.all(MySize.getHeight(24)),
                              child: Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: MySize.getHeight(14),
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            )
                          : _data?.data != null
                              ? _buildReceiptContent(_data!.data!)
                              : const SizedBox.shrink(),
                    ),
            ),
            if (!_loading) _buildFooter(),
          ],
        ),
      ),
    );
  }

  void _onPrint() {
    if (Platform.isIOS) {
      safeGetSnackbar(
        TranslationKeys.warning.tr,
        TranslationKeys.printOnlyAvailableOnAndroid.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade700,
      );
      return;
    }
    safeGetSnackbar(
      TranslationKeys.warning.tr,
      TranslationKeys.receiptPrintNotSupported.tr,
      snackPosition: SnackPosition.TOP,
    );
  }

  Widget _buildHeader() {
    final paymentId = _data?.data?.payment?.id ?? widget.paymentId;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: MySize.getWidth(8),
        vertical: MySize.getHeight(12),
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(MySize.getHeight(8)),
        ),
      ),
      child: Text(
        '${TranslationKeys.payment.tr} #$paymentId',
        style: TextStyle(
          fontSize: MySize.getHeight(18),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MySize.getWidth(8),
        vertical: MySize.getHeight(8),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.grey.shade800,
                padding: EdgeInsets.symmetric(vertical: MySize.getHeight(8)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(MySize.getHeight(12)),
                ),
              ),
              child: Text(
                TranslationKeys.close.tr,
                style: TextStyle(fontSize: MySize.getHeight(15)),
              ),
            ),
          ),
          SizedBox(width: MySize.getWidth(12)),
          Expanded(
            child: TextButton(
              onPressed: _onPrint,
              style: TextButton.styleFrom(
                backgroundColor: ColorConstants.successGreen,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: MySize.getHeight(8)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(MySize.getHeight(12)),
                ),
              ),
              child: Text(
                TranslationKeys.print.tr,
                style: TextStyle(fontSize: MySize.getHeight(15)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptContent(ReceiptOrderData d) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MySize.getWidth(8),
        vertical: MySize.getHeight(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildOrderDetailsSection(d),
          SizedBox(height: MySize.getHeight(12)),
          _buildItemsTable(d),
          SizedBox(height: MySize.getHeight(12)),
          _buildSummarySection(d),
          SizedBox(height: MySize.getHeight(12)),
          _buildPaymentTransactionSection(d),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsSection(ReceiptOrderData d) {
    final order = d.order;
    final orderNum = order?.formattedOrderNumber ?? '';
    final paymentId = d.payment?.id;
    final paymentIdStr = paymentId != null
        ? '${order?.formattedOrderNumber ?? ""}.$paymentId'
        : '';
    final timezone = d.restaurant?.timezone;
    final dateTime = DateTimeFormatter.formatDateTimeInTimezone(
      order?.dateTime,
      timezone,
    );
    final tableCode = order?.table?.tableCode ?? '';
    final pax = order?.numberOfPax?.toString() ?? '';
    final waiterName = order?.waiter?.name ?? '';

    return Column(
      children: [
        _detailRow('${TranslationKeys.order.tr}:', orderNum),
        _detailRow('${TranslationKeys.paymentId.tr}:', paymentIdStr),
        _detailRow('${TranslationKeys.dateAndTime.tr}:', dateTime),
        _detailRow('${TranslationKeys.tableNo.tr}:', tableCode),
        _detailRow('${TranslationKeys.pax.tr}:', pax),
        _detailRow('${TranslationKeys.waiter.tr}:', waiterName),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MySize.getHeight(2)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: MySize.getHeight(12),
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: MySize.getHeight(12),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeaderCell(String text) {
    return Padding(
      padding: EdgeInsets.all(MySize.getWidth(6)),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: MySize.getHeight(11),
        ),
      ),
    );
  }

  Widget _tableHeaderCellCentered(String text) {
    return Padding(
      padding: EdgeInsets.all(MySize.getWidth(6)),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: MySize.getHeight(11),
          ),
        ),
      ),
    );
  }

  Widget _buildItemsTable(ReceiptOrderData d) {
    final items = d.receiptItems ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: ColorConstants.getShadow2,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(MySize.getHeight(8)),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(2),
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
              _tableHeaderCell(TranslationKeys.qty.tr),
              _tableHeaderCell(TranslationKeys.itemNames.tr),
              _tableHeaderCell(TranslationKeys.priceHeader.tr),
              _tableHeaderCell(TranslationKeys.amountHeader.tr),
            ],
          ),
          ...items.map((entry) {
            final oi = entry.orderItem;
            final qty = entry.quantity?.toString() ?? '';
            final itemName = oi?.displayItemName ?? '';
            final details = <String>[];
            if (oi?.displayVariationName != null &&
                oi!.displayVariationName!.isNotEmpty) {
              details.add(oi.displayVariationName!);
            }
            for (final m in oi?.displayModifiers ?? []) {
              final price = m.price != null && m.price!.isNotEmpty
                  ? ' (+${m.price})'
                  : '';
              details.add('• ${m.name ?? ""}$price');
            }
            final price = oi?.formattedPrice ?? '';
            final amount = oi?.formattedLineAmount ?? '';
            final effectiveFontSize = MySize.getHeight(10);
            return TableRow(
              decoration: const BoxDecoration(
                border: Border.symmetric(
                  horizontal: BorderSide(color: Colors.grey, width: 0.5),
                ),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.all(MySize.getWidth(6)),
                  child: Text(
                    qty,
                    style: TextStyle(fontSize: effectiveFontSize),
                  ),
                ),
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
                          children: details
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
          }),
        ],
      ),
    );
  }

  Widget _buildSummarySection(ReceiptOrderData d) {
    final s = d.summary;
    if (s == null) return const SizedBox.shrink();

    final subTotalStr = s.subTotal != null
        ? CurrencyFormatter.formatPrice(s.subTotal!.toString())
        : '';
    final totalStr = s.total != null
        ? CurrencyFormatter.formatPrice(s.total!.toString())
        : '';
    final balance = d.payment?.balance ?? 0.0;
    final balanceStr = CurrencyFormatter.formatPrice(balance.toString());

    final hasDiscount = s.discount != null && s.discount! > 0;
    final hasTip = s.tip != null && s.tip! > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _detailRow(TranslationKeys.subTotal.tr, subTotalStr),
        if (hasDiscount)
          _detailRow(
            TranslationKeys.discount.tr,
            '-${CurrencyFormatter.formatPrice(s.discount!.toString())}',
          ),
        if (hasTip)
          _detailRow(
            TranslationKeys.tip.tr,
            '+${CurrencyFormatter.formatPrice(s.tip!.toString())}',
          ),
        ...(s.taxes ?? []).map((t) {
          final label = t.isInclusive == true
              ? '${t.name ?? ""} (${t.percent ?? ""}%) incl.'
              : (t.name ?? '');
          final val = t.amount != null
              ? CurrencyFormatter.formatPrice(t.amount!.toString())
              : '';
          return _detailRow(label, val);
        }),
        Divider(
          height: MySize.getHeight(12),
          color: ColorConstants.successGreen,
          thickness: MySize.getHeight(1.5),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: MySize.getHeight(4)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                TranslationKeys.total.tr,
                style: TextStyle(
                  fontSize: MySize.getHeight(14),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                totalStr,
                style: TextStyle(
                  fontSize: MySize.getHeight(14),
                  fontWeight: FontWeight.bold,
                  color: ColorConstants.successGreen,
                ),
              ),
            ],
          ),
        ),
        if (balance > 0)
          _detailRow(TranslationKeys.balanceReturned.tr, balanceStr),
      ],
    );
  }

  Widget _buildPaymentTransactionSection(ReceiptOrderData d) {
    final p = d.payment;
    if (p == null) return const SizedBox.shrink();

    final amountStr = p.amount != null
        ? CurrencyFormatter.formatPrice(p.amount!.toString())
        : '';
    final method = p.paymentMethod ?? '';
    final methodDisplay = method.toLowerCase() == 'cash'
        ? TranslationKeys.cash.tr
        : method;
    final timezone = d.restaurant?.timezone;
    final dateTime = DateTimeFormatter.formatDateTimeInTimezone(
      p.createdAt,
      timezone,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: ColorConstants.getShadow2,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(MySize.getHeight(8)),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(1.2),
          2: FlexColumnWidth(1.5),
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
              _tableHeaderCellCentered(TranslationKeys.amount.tr),
              _tableHeaderCellCentered(TranslationKeys.paymentMethod.tr),
              _tableHeaderCellCentered(TranslationKeys.dateAndTime.tr),
            ],
          ),
          TableRow(
            decoration: const BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
            children: [
              Padding(
                padding: EdgeInsets.all(MySize.getWidth(8)),
                child: Center(
                  child: Text(
                    amountStr,
                    style: TextStyle(
                      fontSize: MySize.getHeight(12),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(MySize.getWidth(8)),
                child: Center(
                  child: Text(
                    methodDisplay,
                    style: TextStyle(fontSize: MySize.getHeight(12)),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(MySize.getWidth(8)),
                child: Center(
                  child: Text(
                    dateTime,
                    style: TextStyle(fontSize: MySize.getHeight(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
