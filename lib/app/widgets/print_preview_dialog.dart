import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';
import 'package:managerapp/app/constants/translation_keys.dart';
import 'package:managerapp/app/model/get_order_model.dart' as order_model;
import 'package:managerapp/app/utils/currency_formatter.dart';
import 'package:managerapp/app/utils/date_time_formatter.dart';

class PrintPreviewDialog extends StatefulWidget {
  final order_model.Data orderData;
  final VoidCallback onPrint;
  final bool isPrinting;

  const PrintPreviewDialog({
    super.key,
    required this.orderData,
    required this.onPrint,
    required this.isPrinting,
  });

  static Future<void> show({
    required BuildContext context,
    required order_model.Data orderData,
    required VoidCallback onPrint,
    required bool isPrinting,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => PrintPreviewDialog(
        orderData: orderData,
        onPrint: onPrint,
        isPrinting: isPrinting,
      ),
    );
  }

  @override
  State<PrintPreviewDialog> createState() => _PrintPreviewDialogState();
}

class _PrintPreviewDialogState extends State<PrintPreviewDialog> {
  bool _is80mm = false;

  // ── Exact same constants as SunmiInvoicePrinterService ──
  int get _totalWidth => _is80mm ? 48 : 38;
  int get _itemQtyWidth => _is80mm ? 6 : 4;
  int get _itemNameWidth => _is80mm ? 30 : 15;
  int get _itemPriceWidth => _is80mm ? 12 : 10;
  String get _lineSeparator => List.filled(32, '-').join();

  String _formatPrice(double? price) {
    if (price == null) return CurrencyFormatter.formatPrice('0');
    return CurrencyFormatter.formatPriceFromDouble(price);
  }

  String _formatDateTime(String? dt, [String? timezone]) {
    if (dt == null || dt.isEmpty) return '';
    if (timezone != null && timezone.isNotEmpty) {
      return DateTimeFormatter.formatDateTimeInTimezone(dt, timezone);
    }
    return DateTimeFormatter.formatDateTime(dt);
  }

  String _formatPhoneWithPlus(String? phoneCode, String? phoneNumber) {
    final code = phoneCode?.trim() ?? '';
    final num = phoneNumber?.trim() ?? '';
    if (num.isEmpty) return '';
    if (code.isEmpty) return num.startsWith('+') ? num : '+$num';
    final plusCode = code.startsWith('+') ? code : '+$code';
    return '$plusCode $num';
  }

  // ── Exact same as printer service ──
  String _formatLabelValue(String label, String value) {
    final spacingNeeded = _totalWidth - label.length - value.length;
    final spacing = spacingNeeded > 0 ? List.filled(spacingNeeded, ' ').join() : ' ';
    return '$label$spacing$value';
  }

  String _formatLabelValueMultiLine(String label, String value) {
    const minSpacing = 2;
    if (label.length + value.length + minSpacing <= _totalWidth) {
      return _formatLabelValue(label, value);
    } else {
      final spacing = List.filled(_totalWidth - value.length, ' ').join();
      return '$label\n$spacing$value';
    }
  }

  List<String> _splitLongWord(String word, int maxWidth) {
    final List<String> chunks = [];
    int start = 0;
    while (start < word.length) {
      final end = (start + maxWidth < word.length) ? start + maxWidth : word.length;
      chunks.add(word.substring(start, end));
      start = end;
    }
    return chunks;
  }

  List<String> _wrapText(String text, int maxWidth) {
    if (text.length <= maxWidth) return [text];
    final List<String> lines = [];
    final words = text.split(' ');
    String currentLine = '';
    for (final word in words) {
      if (currentLine.isEmpty) {
        if (word.length > maxWidth) {
          lines.addAll(_splitLongWord(word, maxWidth));
        } else {
          currentLine = word;
        }
      } else {
        final testLine = '$currentLine $word';
        if (testLine.length <= maxWidth) {
          currentLine = testLine;
        } else {
          lines.add(currentLine);
          if (word.length > maxWidth) {
            lines.addAll(_splitLongWord(word, maxWidth));
            currentLine = '';
          } else {
            currentLine = word;
          }
        }
      }
    }
    if (currentLine.isNotEmpty) lines.add(currentLine);
    return lines;
  }

  Map<String, Map<String, dynamic>> _aggregateTaxes(
    List<order_model.Items> items,
    List<order_model.Taxes>? taxes,
  ) {
    final aggregated = <String, Map<String, dynamic>>{};
    void merge(String name, String percent, double amount) {
      if (aggregated.containsKey(name)) {
        aggregated[name] = {
          'amount': (aggregated[name]!['amount'] as double) + amount,
          'percent': aggregated[name]!['percent'] as String,
        };
      } else {
        aggregated[name] = {'amount': amount, 'percent': percent};
      }
    }

    if (taxes != null && taxes.isNotEmpty) {
      for (final tax in taxes) {
        merge(
          tax.taxName ?? TranslationKeys.tax.tr,
          tax.percent?.toString() ?? '',
          tax.amount ?? 0.0,
        );
      }
    } else {
      for (final item in items) {
        if (item.taxAmount != null && item.taxAmount! > 0) {
          merge(
            TranslationKeys.tax.tr,
            item.taxPercentage?.toString() ?? '',
            item.taxAmount!,
          );
        }
      }
    }
    return aggregated;
  }

  // ── Build the exact same lines as the printer ──
  List<_PreviewLine> _buildLines() {
    final data = widget.orderData;
    final restaurant = data.restaurant;
    final branch = data.branch;
    final order = data.order;
    if (order == null) return [];

    final List<_PreviewLine> lines = [];

    void addCenter(String text, {bool bold = false, double scale = 1.0}) =>
        lines.add(_PreviewLine(text: text, align: TextAlign.center, bold: bold, scale: scale));
    void addLeft(String text, {double scale = 1.0}) =>
        lines.add(_PreviewLine(text: text, align: TextAlign.left, scale: scale));
    void addSep() => lines.add(_PreviewLine(text: _lineSeparator, align: TextAlign.left));

    // Restaurant name
    addCenter(restaurant?.name ?? TranslationKeys.restaurant.tr, bold: true, scale: 1.2);

    // Branch address
    if (branch?.address != null && branch!.address!.trim().isNotEmpty) {
      addCenter(branch.address!);
    }

    addSep();

    // Order line
    final orderLine = '${TranslationKeys.order.tr}: ${order.formattedOrderNumber ?? TranslationKeys.na.tr}';
    final formattedDateTime = _formatDateTime(order.dateTime, restaurant?.timezone);
    final orderText = formattedDateTime.isNotEmpty
        ? _formatLabelValue(orderLine, formattedDateTime)
        : orderLine;
    addLeft(orderText);

    // Table / Pax
    final tableCode = (order.table?.tableCode?.isNotEmpty == true) ? order.table!.tableCode! : null;
    final pax = order.numberOfPax;
    if (tableCode != null || (pax != null && pax > 0)) {
      final tablePart = tableCode != null ? '${TranslationKeys.tableNo.tr}: $tableCode' : '';
      final paxPart = (pax != null && pax > 0) ? '${TranslationKeys.pax.tr}: $pax' : '';
      final tablePaxLine = (tablePart.isNotEmpty && paxPart.isNotEmpty)
          ? _formatLabelValue(tablePart, paxPart)
          : (tablePart.isNotEmpty ? tablePart : paxPart);
      addLeft(tablePaxLine);
    }

    // Waiter
    if (order.waiter?.name != null && order.waiter!.name!.isNotEmpty) {
      addLeft('${TranslationKeys.waiter.tr}: ${order.waiter!.name}');
    }

    // Customer
    if (order.customer?.name != null) {
      addLeft('${TranslationKeys.customer.tr}: ${order.customer!.name}');
    }

    // Phone
    final phoneStr = _formatPhoneWithPlus(
      order.customer?.phoneCode,
      order.customer?.phoneNumber,
    );
    if (phoneStr.isNotEmpty) {
      addLeft('${TranslationKeys.phone.tr}: $phoneStr');
    }

    // Delivery address
    if (order.deliveryAddress != null && order.deliveryAddress!.trim().isNotEmpty) {
      addLeft('${TranslationKeys.address.tr}: ${order.deliveryAddress}');
    }

    addSep();

    // Items header
    addCenter(TranslationKeys.qtyItemNamePriceAmount.tr);
    addSep();

    // Items
    if (order.items?.isNotEmpty == true) {
      for (final item in order.items!) {
        final qty = item.quantity?.toString() ?? '0';
        final itemName = item.itemName ?? TranslationKeys.na.tr;
        final price = _formatPrice(item.price);
        final amount = _formatPrice(item.amount);
        const priceAmountSpacing = '   ';
        final qtyPadded = qty.padRight(_itemQtyWidth);
        final pricePadded = price.padLeft(_itemPriceWidth);
        final priceAmountLine = '$pricePadded$priceAmountSpacing$amount';

        if (itemName.length <= _itemNameWidth) {
          final itemNamePadded = itemName.padRight(_itemNameWidth);
          addLeft('$qtyPadded$itemNamePadded$priceAmountLine');
        } else {
          final nameLines = _wrapText(itemName, _itemNameWidth);
          for (int i = 0; i < nameLines.length; i++) {
            final itemNamePadded = nameLines[i].padRight(_itemNameWidth);
            if (i == 0) {
              addLeft('$qtyPadded$itemNamePadded$priceAmountLine');
            } else {
              final indent = ' '.padRight(_itemQtyWidth);
              addLeft('$indent$itemNamePadded');
            }
          }
        }

        if (item.variationName?.isNotEmpty == true) {
          addLeft('  (${item.variationName})', scale: 0.88);
        }
        if (item.modifiers?.isNotEmpty == true) {
          for (final m in item.modifiers!) {
            final modPrice = _formatPrice(m.price);
            addLeft('  • ${m.name ?? ''} (+$modPrice)', scale: 0.88);
          }
        }
        if (item.note != null && item.note!.isNotEmpty) {
          addLeft('  ${TranslationKeys.note.tr}: ${item.note}', scale: 0.88);
        }
      }
    }

    addSep();

    // Sub Total
    if (order.totals?.subTotal != null) {
      addLeft(_formatLabelValue(
        '${TranslationKeys.subTotal.tr}:',
        _formatPrice(order.totals!.subTotal?.toDouble()),
      ));
    }

    // Discount
    final hasDiscount = (order.discountValue ?? 0) > 0 &&
        (order.totals?.discountAmount ?? 0) > 0;
    if (hasDiscount) {
      final discountLabel = (order.discountType?.toLowerCase().contains('percent') == true)
          ? '${TranslationKeys.discount.tr} (${order.discountType})'
          : TranslationKeys.discount.tr;
      addLeft(_formatLabelValue(
        discountLabel,
        '-${_formatPrice(order.totals!.discountAmount)}',
      ));
    }

    // Charges
    if (order.charges?.isNotEmpty == true) {
      for (final charge in order.charges!) {
        addLeft(_formatLabelValueMultiLine(
          '${charge.chargeName ?? ''}:',
          _formatPrice(charge.amount),
        ));
      }
    }

    // Delivery fee
    if (order.orderType?.toLowerCase() == 'delivery' &&
        (order.totals?.deliveryFee ?? -1) >= 0) {
      final deliveryValue = order.totals!.deliveryFee! == 0
          ? TranslationKeys.free.tr
          : _formatPrice(order.totals!.deliveryFee?.toDouble());
      addLeft(_formatLabelValueMultiLine(
        '${TranslationKeys.deliveryCharge.tr}:',
        deliveryValue,
      ));
    }

    // Tip
    if ((order.totals?.tipAmount ?? 0) > 0) {
      final tipValue = _formatPrice(order.totals!.tipAmount);
      if (tipValue.isNotEmpty && tipValue != '0') {
        addLeft(_formatLabelValue('${TranslationKeys.tip.tr}:', tipValue));
      }
    }

    // Taxes
    if (order.items?.isNotEmpty == true) {
      final aggregated = _aggregateTaxes(order.items!, data.taxes);
      for (final entry in aggregated.entries) {
        final taxName = entry.key;
        final taxPercent = entry.value['percent'] as String?;
        final taxAmount = entry.value['amount'] as double?;
        final taxPrefix = (taxPercent?.isNotEmpty == true)
            ? '$taxName ($taxPercent%)'
            : taxName;
        final isInc = data.taxInclusive == true;
        final taxLabel = '$taxPrefix ${isInc ? TranslationKeys.inc.tr : TranslationKeys.exc.tr}';
        addLeft(_formatLabelValueMultiLine(taxLabel, _formatPrice(taxAmount)));
      }
    }

    // Balance returned
    if (order.payments?.isNotEmpty == true && order.totals?.total != null) {
      final totalPaid = order.payments!.fold<double>(
        0.0, (sum, p) => sum + (p.amount ?? 0.0));
      final balance = totalPaid - (order.totals!.total ?? 0.0);
      if (balance > 0) {
        addLeft(_formatLabelValue(
          '${TranslationKeys.balanceReturned.tr}:',
          _formatPrice(balance),
        ));
      }
    }

    addSep();

    // Total
    final totalValue = _formatPrice(order.totals?.total);
    addCenter('${TranslationKeys.total.tr}:                   $totalValue',
        bold: true, scale: 1.1);

    addSep();

    // Thank you
    addCenter(TranslationKeys.thankYouForVisit.tr);

    addSep();

    // Payments section
    if (order.payments?.isNotEmpty == true) {
      addCenter(TranslationKeys.paymentReceiptHeader.tr);
      addSep();
      for (final payment in order.payments!) {
        final paymentAmount = _formatPrice(payment.amount);
        final paymentMethod = payment.paymentMethod ?? TranslationKeys.cash.tr;
        final formattedPaymentTime = _formatDateTime(
          payment.createdAt ?? order.dateTime,
          restaurant?.timezone,
        );
        addCenter('$paymentAmount  $paymentMethod  $formattedPaymentTime');
      }
    }

    return lines;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: MySize.getWidth(12),
        vertical: MySize.getHeight(24),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: ColorConstants.bgColor,
          borderRadius: BorderRadius.circular(MySize.getHeight(16)),
        ),
        child: Column(
          children: [
            // ── Header ──
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: MySize.getWidth(16),
                vertical: MySize.getHeight(14),
              ),
              decoration: BoxDecoration(
                color: ColorConstants.primaryColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(MySize.getHeight(16)),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.receipt_long, color: Colors.white, size: MySize.getHeight(20)),
                  SizedBox(width: MySize.getWidth(8)),
                  Expanded(
                    child: Text(
                      TranslationKeys.printPreview.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: MySize.getHeight(16),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.close, color: Colors.white, size: MySize.getHeight(22)),
                  ),
                ],
              ),
            ),

            // ── Paper Width Toggle ──
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: MySize.getWidth(16),
                vertical: MySize.getHeight(10),
              ),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    TranslationKeys.paperSize.tr,
                    style: TextStyle(
                      fontSize: MySize.getHeight(13),
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(width: MySize.getWidth(12)),
                  _buildToggleBtn('58mm', !_is80mm, () => setState(() => _is80mm = false)),
                  SizedBox(width: MySize.getWidth(8)),
                  _buildToggleBtn('80mm', _is80mm, () => setState(() => _is80mm = true)),
                ],
              ),
            ),

            const Divider(height: 1),

            // ── Receipt Preview ──
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  vertical: MySize.getHeight(16),
                  horizontal: MySize.getWidth(16),
                ),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    // 58mm ≈ 220px wide, 80mm ≈ 310px wide — mirrors actual paper width difference
                    width: _is80mm ? 310.0 : 220.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: _buildReceiptWidget(),
                  ),
                ),
              ),
            ),

            const Divider(height: 1),

            // ── Bottom Buttons ──
            Container(
              padding: EdgeInsets.fromLTRB(
                MySize.getWidth(12),
                MySize.getHeight(10),
                MySize.getWidth(12),
                MySize.getHeight(20),
              ),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: MySize.getHeight(12)),
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(MySize.getHeight(8)),
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
                  SizedBox(width: MySize.getWidth(12)),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: widget.isPrinting
                          ? null
                          : () {
                              Navigator.of(context).pop();
                              widget.onPrint();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0E9F6E),
                        disabledBackgroundColor:
                            const Color(0xFF0E9F6E).withValues(alpha: 0.6),
                        padding: EdgeInsets.symmetric(vertical: MySize.getHeight(12)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                        ),
                        elevation: 0,
                      ),
                      icon: widget.isPrinting
                          ? SizedBox(
                              width: MySize.getHeight(18),
                              height: MySize.getHeight(18),
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(Icons.print, color: Colors.white, size: MySize.getHeight(18)),
                      label: Text(
                        widget.isPrinting
                            ? TranslationKeys.printing.tr
                            : TranslationKeys.print.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: MySize.getHeight(14),
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

  Widget _buildToggleBtn(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: MySize.getWidth(16),
          vertical: MySize.getHeight(6),
        ),
        decoration: BoxDecoration(
          color: selected ? ColorConstants.primaryColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(MySize.getHeight(20)),
          border: Border.all(
            color: selected ? ColorConstants.primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.bold,
            fontSize: MySize.getHeight(13),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptWidget() {
    final previewLines = _buildLines();
    // Font size scales with paper width — wider paper = slightly bigger font
    final double baseFontSize = _is80mm ? 11.5 : 9.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: previewLines.map((line) {
        return Text(
          line.text,
          textAlign: line.align,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: baseFontSize * line.scale,
            fontWeight: line.bold ? FontWeight.bold : FontWeight.normal,
            height: 1.5,
            color: Colors.black,
          ),
        );
      }).toList(),
    );
  }
}

class _PreviewLine {
  final String text;
  final TextAlign align;
  final bool bold;
  final double scale;

  const _PreviewLine({
    required this.text,
    required this.align,
    this.bold = false,
    this.scale = 1.0,
  });
}
