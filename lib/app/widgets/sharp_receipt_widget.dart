import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../model/get_order_model.dart' as order_model;
import '../model/receipt_order_response_model.dart';
import '../constants/translation_keys.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_time_formatter.dart';
import '../utils/order_helpers.dart';

class SharpReceiptWidget extends StatelessWidget {
  final dynamic data; // Can be order_model.Data or ReceiptOrderData
  final double width;

  const SharpReceiptWidget({
    super.key,
    required this.data,
    this.width = 360, // Full-width safe for 58mm
  });

  @override
  Widget build(BuildContext context) {
    if (data is order_model.Data) {
      return _buildFromOrderData(data as order_model.Data);
    } else if (data is ReceiptOrderData) {
      return _buildFromReceiptData(data as ReceiptOrderData);
    }
    return const SizedBox.shrink();
  }

  // ==========================================
  // BUILD: ORDER DATA (Auto-Print / New Order)
  // ==========================================
  Widget _buildFromOrderData(order_model.Data data) {
    final restaurant = data.restaurant;
    final branch = data.branch;
    final order = data.order;

    return Container(
      width: width,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildHeader(restaurant?.name, branch?.address),
          _divider(),
          const SizedBox(height: 12),

          // Metadata Info
          if (order?.createdAt != null && order!.createdAt!.isNotEmpty)
            _labelText(
              '${TranslationKeys.orderCreated.tr}:',
              DateTimeFormatter.formatDateTime(order.createdAt),
            ),
          _buildTimeLabelRow(order?.orderType, order?.dateTime),
          if (order?.customer?.name != null)
            _iconText(Icons.person, order!.customer!.name!),
          if (order?.orderNumber != null)
            _iconText(
              Icons.receipt_long,
              '#${order!.orderNumber}',
              isBold: false,
            ),
          if (order?.orderType != null) _buildOrderTypeInfo(order!.orderType!),
          if (order?.orderType?.toLowerCase().contains('pickup') != true &&
              order?.deliveryAddress != null &&
              order!.deliveryAddress!.isNotEmpty)
            _iconText(Icons.location_on, order.deliveryAddress!),
          if (_formatPhone(
            order?.customer?.phoneCode,
            order?.customer?.phoneNumber,
          ).isNotEmpty)
            _iconText(
              Icons.phone,
              _formatPhone(
                order?.customer?.phoneCode,
                order?.customer?.phoneNumber,
              ),
            ),
          _buildTablePaxInfo(order),
          if (order?.waiter?.name != null && order!.waiter!.name!.trim().isNotEmpty)
            _iconText(
              Icons.badge,
              '${TranslationKeys.waiter.tr}: ${order.waiter!.name!}',
            ),

          const SizedBox(height: 12),
          _divider(),
          const SizedBox(height: 12),

          // Items
          if (order?.items != null)
            for (var item in order!.items!) _buildOrderItemRow(item),

          const SizedBox(height: 12),
          _divider(),
          const SizedBox(height: 12),

          // Totals Section
          _buildOrderTotals(order),

          const SizedBox(height: 16),
          _divider(),
          const SizedBox(height: 12),
          _buildFooter(order?.payments?.isNotEmpty == true ? order!.payments!.first : null),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ==========================================
  // BUILD: RECEIPT DATA (Payment Receipt View)
  // ==========================================
  Widget _buildFromReceiptData(ReceiptOrderData d) {
    final restaurant = d.restaurant;
    final branch = d.branch;
    final order = d.order;
    final summary = d.summary;
    final items = d.receiptItems;

    return Container(
      width: width,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildHeader(restaurant?.name, branch?.address),
          _divider(),
          const SizedBox(height: 12),

          // Metadata Info
          if (d.payment?.createdAt != null && d.payment!.createdAt!.isNotEmpty)
            _labelText(
              '${TranslationKeys.orderCreated.tr}:',
              DateTimeFormatter.formatDateTime(d.payment!.createdAt),
            ),
          _buildTimeLabelRow(order?.orderType, order?.dateTime),
          () {
            final name = _receiptCustomerName(order?.customer);
            return name != null && name.isNotEmpty
                ? _iconText(Icons.person, name)
                : const SizedBox.shrink();
          }(),
          () {
            final phone = _receiptPhoneStr(order?.customer);
            return phone != null && phone.isNotEmpty
                ? _iconText(Icons.phone, phone)
                : const SizedBox.shrink();
          }(),
          if (order?.orderNumber != null)
            _iconText(
              Icons.receipt_long,
              '#${order!.orderNumber}',
              isBold: false,
            ),
          if (order?.orderType != null) _buildOrderTypeInfo(order!.orderType!),
          _buildTablePaxInfo(order),
          if (order?.waiter?.name != null && order!.waiter!.name!.trim().isNotEmpty)
            _iconText(
              Icons.badge,
              '${TranslationKeys.waiter.tr}: ${order.waiter!.name!}',
            ),
          if (order?.orderType?.toLowerCase().contains('pickup') != true &&
              order?.deliveryAddress != null &&
              order!.deliveryAddress!.isNotEmpty)
            _iconText(Icons.location_on, order.deliveryAddress!),

          const SizedBox(height: 12),
          _divider(),
          const SizedBox(height: 12),

          // Items
          if (items != null)
            for (var item in items) _buildReceiptItemEntryRow(item),

          const SizedBox(height: 12),
          _divider(),
          const SizedBox(height: 12),

          // Receipt Totals
          _buildReceiptTotals(summary, d.payment),

          if (d.hasFiskalyData) _buildTseSection(d.fiskaly!),

          const SizedBox(height: 16),
          _divider(),
          const SizedBox(height: 12),
          _buildFooter(d.payment),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildTseSection(ReceiptFiskaly fiskaly) {
    String formatTseDate(String? dtStr) {
      if (dtStr == null || dtStr.isEmpty) return '';
      return DateTimeFormatter.formatDateTimeWithRestaurantTimezone(dtStr);
    }

    final startTime = formatTseDate(fiskaly.startUtc);
    final endTime = formatTseDate(fiskaly.endUtc);
    final tssSerial = fiskaly.tssSerialNumber ?? fiskaly.tssId ?? '';
    final clientSerial = fiskaly.clientSerialNumber ?? fiskaly.clientId ?? '';
    final txNumber = fiskaly.txNumber ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        _divider(),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'TSE',
            style: GoogleFonts.inter(
              fontSize: width > 400 ? 30 : 26,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (startTime.isNotEmpty)
          _labelText('${TranslationKeys.tseStart.tr}:', startTime),
        if (endTime.isNotEmpty)
          _labelText('${TranslationKeys.tseEnd.tr}:', endTime),
        if (tssSerial.isNotEmpty)
          _labelText('${TranslationKeys.tseSerialNumber.tr}:', tssSerial),
        if (clientSerial.isNotEmpty)
          _labelText('${TranslationKeys.tseClientId.tr}:', clientSerial),
        if (txNumber.isNotEmpty)
          _labelText('${TranslationKeys.tseTransactionNumber.tr}:', txNumber),
      ],
    );
  }

  // ==========================================
  // SHARED HEADER & FOOTER
  // ==========================================
  Widget _buildHeader(String? restaurantName, String? branchAddress) {
    return Column(
      children: [
        Text(
          restaurantName ?? TranslationKeys.restaurant.tr,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: width > 400 ? 50 : 43,
            fontWeight: FontWeight.w900,
            color: Colors.black,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        if (branchAddress != null && branchAddress.isNotEmpty)
          Text(
            branchAddress,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: width > 400 ? 28 : 25,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildFooter(dynamic payment) {
    return Column(
      children: [
        Text(
          TranslationKeys.thankYouForVisit.tr.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: width > 400 ? 28 : 25,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        if (payment != null) ...[
          const SizedBox(height: 12),
          _buildPaymentInfo(payment),
        ],
      ],
    );
  }

  // ==========================================
  // REUSABLE ITEM ROW LOGIC
  // ==========================================
  Widget _buildOrderItemRow(order_model.Items item) {
    final modifierList = item.modifiers
        ?.map((m) => {
              'name': m.name ?? '',
              'price': m.price != null
                  ? '+${CurrencyFormatter.formatPriceFromDouble(m.price!, withSymbol: false)}'
                  : null,
            })
        .toList();

    return _buildUnifiedItemRow(
      quantity: item.quantity?.toString() ?? '1',
      itemName: item.itemName ?? '',
      basePrice: item.price,
      amount: item.amount ?? 0.0,
      variationName: item.variationName,
      modifiers: modifierList,
      packagingCharge: item.packagingCharge,
      deposit: item.deposit,
      note: item.note,
    );
  }

  Widget _buildReceiptItemEntryRow(ReceiptItemEntry item) {
    final oi = item.orderItem;
    final modifierList = oi?.displayModifiers
        ?.map((m) => {
              'name': m.name ?? '',
              'price': m.price != null && m.price!.isNotEmpty ? '(+${m.price})' : null,
            })
        .toList();

    return _buildUnifiedItemRow(
      quantity: (item.quantity ?? oi?.quantity)?.toString() ?? '1',
      itemName: oi?.displayItemName ?? '',
      basePrice: oi?.price,
      amount: oi?.amount ?? 0.0,
      variationName: oi?.displayVariationName,
      modifiers: modifierList,
      packagingCharge: oi?.packagingCharge,
      deposit: oi?.deposit,
      note: oi?.note,
    );
  }

  Widget _buildUnifiedItemRow({
    required String quantity,
    required String itemName,
    required double? basePrice,
    required double amount,
    String? variationName,
    List<Map<String, String?>>? modifiers,
    double? packagingCharge,
    double? deposit,
    String? note,
  }) {
    final basePriceStr = (basePrice != null && basePrice > 0)
        ? ' (${CurrencyFormatter.formatPriceFromDouble(basePrice, withSymbol: false)})'
        : '';
    final displayName = '$itemName$basePriceStr';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$quantity x ',
                style: GoogleFonts.inter(fontSize: width > 400 ? 28 : 30),
              ),
              Expanded(
                child: Text(
                  displayName,
                  style: GoogleFonts.inter(
                    fontSize: width > 400 ? 28 : 30,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                CurrencyFormatter.formatPriceFromDouble(amount, withSymbol: false),
                style: GoogleFonts.inter(
                  fontSize: width > 400 ? 28 : 30,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          if (variationName != null && variationName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 38, top: 2),
              child: Text(
                '($variationName)',
                style: GoogleFonts.inter(
                  fontSize: 25,
                  color: Colors.grey[900],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          if (modifiers != null)
            for (var mod in modifiers)
              Padding(
                padding: const EdgeInsets.only(left: 38, top: 1),
                child: Text(
                  '• ${mod['name'] ?? ''} ${mod['price'] != null ? '${mod['price']}' : ''}',
                  style: GoogleFonts.inter(
                    fontSize: 25,
                    color: Colors.grey[900],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
          if (packagingCharge != null && packagingCharge > 0)
            Padding(
              padding: const EdgeInsets.only(left: 38, top: 1),
              child: Text(
                '${TranslationKeys.packagingCharge.tr}: ${CurrencyFormatter.formatPriceFromDouble(packagingCharge, withSymbol: false)}',
                style: GoogleFonts.inter(
                  fontSize: 25,
                  color: Colors.grey[900],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          if (deposit != null && deposit > 0)
            Padding(
              padding: const EdgeInsets.only(left: 38, top: 1),
              child: Text(
                '${TranslationKeys.itemDeposit.tr}: ${CurrencyFormatter.formatPriceFromDouble(deposit, withSymbol: false)}',
                style: GoogleFonts.inter(
                  fontSize: 25,
                  color: Colors.grey[900],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          if (note != null && note.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 38, top: 1),
              child: Text(
                '${TranslationKeys.note.tr}: $note',
                style: GoogleFonts.inter(
                  fontSize: 25,
                  color: Colors.blueGrey[800],
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // TOTALS SECTION
  // ==========================================
  Widget _buildOrderTotals(order_model.Order? order) {
    if (order == null) return const SizedBox.shrink();

    final double totalVal =
        order.totals?.effectiveTotal ?? order.totals?.total ?? 0;

    return Column(
      children: [
        if (order.totals?.subTotal != null)
          _totalRow(
            TranslationKeys.subTotal.tr,
            CurrencyFormatter.formatPriceFromDouble(
              order.totals!.subTotal!.toDouble(),
              withSymbol: false,
            ),
          ),
        if (order.totals?.discountAmount != null &&
            order.totals!.discountAmount! > 0) () {
          final couponCode = order.couponCode;
          final type = order.discountType?.toString().toLowerCase();
          final value = order.discountValue;

          String labelText = TranslationKeys.discount.tr;
          if (couponCode != null && couponCode.isNotEmpty) {
            labelText = '${TranslationKeys.discount.tr} ($couponCode)';
          } else if (type != null && type.isNotEmpty) {
            if (type == 'percent' || type == 'percentage') {
              if (value != null && value > 0) {
                final formattedVal = (value == value.toInt()) ? value.toInt() : value;
                labelText = '${TranslationKeys.discount.tr} ($formattedVal%)';
              } else {
                labelText = '${TranslationKeys.discount.tr} (%)';
              }
            } else if (type == 'fixed') {
              labelText = '${TranslationKeys.discount.tr} (Fixed)';
            }
          }
          return _totalRow(
            labelText,
            '-${CurrencyFormatter.formatPriceFromDouble(order.totals!.discountAmount!, withSymbol: false)}',
          );
        }(),
        if (data is order_model.Data && (data as order_model.Data).taxes != null)
          for (var tax in (data as order_model.Data).taxes!)
            if (tax.amount != null && tax.amount! > 0)
              _totalRow(
                '${tax.taxName ?? TranslationKeys.tax.tr}${tax.percent != null ? ' (${tax.percent}%)' : ''} ${(data as order_model.Data).taxInclusive == true ? TranslationKeys.inc.tr : TranslationKeys.exc.tr}',
                CurrencyFormatter.formatPriceFromDouble(
                  tax.amount!,
                  withSymbol: false,
                ),
              ),
        if (order.charges != null)
          for (var charge in order.charges!)
            if (charge.amount != null && charge.amount! > 0)
              _totalRow(
                charge.chargeName ?? 'Charge',
                CurrencyFormatter.formatPriceFromDouble(
                  charge.amount!,
                  withSymbol: false,
                ),
              ),
        if (order.orderType?.toLowerCase() == 'delivery' &&
            order.totals?.deliveryFee != null &&
            order.totals!.deliveryFee! >= 0)
          _totalRow(
            TranslationKeys.deliveryCharge.tr,
            order.totals!.deliveryFee! == 0
                ? TranslationKeys.free.tr
                : CurrencyFormatter.formatPriceFromDouble(
                    order.totals!.deliveryFee!,
                    withSymbol: false,
                  ),
          ),
        if (order.totals?.tipAmount != null && order.totals!.tipAmount! > 0)
          _totalRow(
            TranslationKeys.tip.tr,
            CurrencyFormatter.formatPriceFromDouble(
              order.totals!.tipAmount!,
              withSymbol: false,
            ),
          ),
        () {
          final voucherPayment = order.payments?.firstWhere(
            (p) => p.voucherAmount != null && p.voucherAmount! > 0,
            orElse: () => order_model.Payments(),
          );
          final voucherAmount = voucherPayment?.voucherAmount;
          final voucherCode = voucherPayment?.voucherCode;
          if (voucherAmount != null && voucherAmount > 0) {
            final label = (voucherCode != null && voucherCode.isNotEmpty)
                ? '${TranslationKeys.voucher.tr} ($voucherCode):'
                : '${TranslationKeys.voucher.tr}:';
            return _totalRow(
              label,
              '-${CurrencyFormatter.formatPriceFromDouble(voucherAmount, withSymbol: false)}',
            );
          }
          return const SizedBox.shrink();
        }(),
        const SizedBox(height: 6),
        _divider(height: 2),
        const SizedBox(height: 6),
        _totalRow(
          TranslationKeys.total.tr,
          CurrencyFormatter.formatPriceFromDouble(totalVal),
          isBold: true,
          fontSize: width > 400 ? 43 : 37,
        ),
        if (order.payments?.isNotEmpty == true) ...[
          () {
            final totalPaid = order.payments!.fold<double>(
              0.0,
              (sum, p) => sum + (p.amountTotal ?? p.amount ?? 0.0),
            );
            final balance = totalPaid - totalVal;
            if (balance > 0) {
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: _totalRow(
                  TranslationKeys.balanceReturned.tr,
                  CurrencyFormatter.formatPriceFromDouble(
                    balance,
                    withSymbol: false,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }(),
        ],
      ],
    );
  }

  Widget _buildReceiptTotals(ReceiptSummary? summary, ReceiptPayment? payment) {
    final double totalVal = summary?.amountTotal ?? summary?.total ?? 0;

    return Column(
      children: [
        if (summary?.subTotal != null)
          _totalRow(
            TranslationKeys.subTotal.tr,
            CurrencyFormatter.formatPriceFromDouble(
              summary!.subTotal!,
              withSymbol: false,
            ),
          ),
        if (summary?.discount != null && summary!.discount! > 0)
          _totalRow(
            TranslationKeys.discount.tr,
            '-${CurrencyFormatter.formatPriceFromDouble(summary.discount!, withSymbol: false)}',
          ),
        if (summary?.taxes != null)
          for (var tax in summary!.taxes!)
            if (tax.amount != null && tax.amount! > 0)
              _totalRow(
                '${tax.name ?? 'Tax'}${tax.percent != null && tax.percent!.isNotEmpty ? ' (${tax.percent}%)' : ''} ${tax.isInclusive == true ? TranslationKeys.inc.tr : TranslationKeys.exc.tr}',
                CurrencyFormatter.formatPriceFromDouble(
                  tax.amount!,
                  withSymbol: false,
                ),
              ),
        if (summary?.extraCharges != null)
          for (var charge in summary!.extraCharges!)
            if (charge.amount != null && charge.amount! > 0)
              _totalRow(
                charge.name ?? 'Charge',
                CurrencyFormatter.formatPriceFromDouble(
                  charge.amount!,
                  withSymbol: false,
                ),
              ),
        if (summary?.deliveryFee != null && summary!.deliveryFee! >= 0)
          _totalRow(
            TranslationKeys.deliveryCharge.tr,
            summary.deliveryFee! == 0
                ? TranslationKeys.free.tr
                : CurrencyFormatter.formatPriceFromDouble(
                    summary.deliveryFee!,
                    withSymbol: false,
                  ),
          ),
        if (summary?.tip != null && summary!.tip! > 0)
          _totalRow(
            TranslationKeys.tip.tr,
            CurrencyFormatter.formatPriceFromDouble(
              summary.tip!,
              withSymbol: false,
            ),
          ),
        if (payment?.voucherAmount != null && payment!.voucherAmount! > 0)
          _totalRow(
            payment.voucherCode != null && payment.voucherCode!.isNotEmpty
                ? '${TranslationKeys.voucher.tr} (${payment.voucherCode}):'
                : '${TranslationKeys.voucher.tr}:',
            '-${CurrencyFormatter.formatPriceFromDouble(payment.voucherAmount!, withSymbol: false)}',
          ),
        const SizedBox(height: 6),
        _divider(height: 2),
        const SizedBox(height: 6),
        _totalRow(
          TranslationKeys.total.tr,
          CurrencyFormatter.formatPriceFromDouble(totalVal),
          isBold: true,
          fontSize: width > 400 ? 43 : 37,
        ),
        if (payment?.balance != null && payment!.balance! > 0) ...[
          const SizedBox(height: 6),
          _totalRow(
            TranslationKeys.balanceReturned.tr,
            CurrencyFormatter.formatPriceFromDouble(
              payment.balance!,
              withSymbol: false,
            ),
          ),
        ],
      ],
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================
  Widget _iconText(dynamic icon, String text, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 35,
            child: icon is IconData
                ? Icon(icon, size: 28, color: Colors.black)
                : Text(icon.toString(), style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: width > 400 ? 28 : 30,
                color: Colors.black,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds delivery/pickup time label row (no icon).
  /// Returns SizedBox.shrink() if dateTime is empty or order type has no label.
  Widget _buildTimeLabelRow(String? orderType, String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return const SizedBox.shrink();
    final label = getTimeLabel(orderType?.toLowerCase() ?? '');
    if (label == null) return const SizedBox.shrink();
    return _labelText('$label:', DateTimeFormatter.formatDateTime(dateTime));
  }

  /// Displays a label+value row without any icon (used for time fields).
  Widget _labelText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: width > 400 ? 26 : 28,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: width > 400 ? 26 : 28,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 25,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider({double height = 1.0}) {
    return Container(width: width, height: height, color: Colors.black);
  }

  Widget _buildOrderTypeInfo(String type) {
    String typeKey = type.toLowerCase();
    String translatedType = type;
    if (typeKey.contains('delivery')) {
      translatedType = TranslationKeys.delivery.tr;
    } else if (typeKey.contains('pickup')) {
      translatedType = TranslationKeys.pickup.tr;
    } else if (typeKey.contains('dine')) {
      translatedType = TranslationKeys.dineIn.tr;
    }

    return _iconText(
      _getOrderTypeIcon(type),
      translatedType.toUpperCase(),
      isBold: false,
    );
  }

  IconData _getOrderTypeIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('delivery')) return Icons.delivery_dining;
    if (t.contains('pickup')) return Icons.shopping_bag;
    if (t.contains('dine')) return Icons.restaurant;
    return Icons.inventory_2;
  }

  String _formatPhone(String? code, String? num) {
    if (num == null || num.isEmpty) return '';
    final c = code?.trim() ?? '';
    final plusCode = c.startsWith('+') ? c : '+$c';
    return '$plusCode ${num.trim()}';
  }

  /// Extract customer name from dynamic/Map customer (ReceiptOrder)
  String? _receiptCustomerName(dynamic customer) {
    if (customer == null) return null;
    if (customer is Map) return customer['name']?.toString();
    try { return customer.name?.toString(); } catch (_) { return null; }
  }

  /// Extract and format phone from dynamic/Map customer (ReceiptOrder)
  String? _receiptPhoneStr(dynamic customer) {
    if (customer == null) return null;
    String? code, num;
    if (customer is Map) {
      code = customer['phone_code']?.toString();
      num  = customer['phone_number']?.toString();
    } else {
      try {
        code = customer.phoneCode?.toString();
        num  = customer.phoneNumber?.toString();
      } catch (_) {}
    }
    return _formatPhone(code, num);
  }

  Widget _buildPaymentInfo(dynamic payment) {
    String method = '';
    String icon = '💳';
    String m = '';

    if (payment is ReceiptPayment) {
      m = payment.paymentMethod?.toLowerCase() ?? '';
    } else if (payment is order_model.Payments) {
      m = payment.paymentMethod?.toLowerCase() ?? '';
    } else if (payment is Map) {
      m = (payment['payment_method'] ?? '').toString().toLowerCase();
    }

    if (m.contains('cash')) {
      method = TranslationKeys.cashPayment.tr;
      icon = '💵';
    } else {
      method = TranslationKeys.onlinePayment.tr;
      icon = '💳';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        '$icon ${method.toUpperCase()}',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 35,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildTablePaxInfo(dynamic order) {
    final tableCode = (order?.table?.tableCode ?? '').toString().trim();
    final numPax = (order?.numberOfPax is int) ? (order.numberOfPax as int) : 0;
    final hasTable = tableCode.isNotEmpty;
    final hasPax = numPax > 0;

    if (hasTable && hasPax) {
      return _iconText(
        Icons.restaurant,
        '$tableCode (${TranslationKeys.cover.tr}: $numPax)',
      );
    } else if (hasTable) {
      return _iconText(Icons.restaurant, tableCode);
    } else if (hasPax) {
      return _iconText(Icons.restaurant, '${TranslationKeys.cover.tr}: $numPax');
    }
    return const SizedBox.shrink();
  }
}
