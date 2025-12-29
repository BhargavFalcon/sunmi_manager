import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import '../model/invoiceModel.dart';
import '../utils/currency_formatter.dart';

class SunmiInvoicePrinterService {
  static final Dio _dio = Dio();

  Future<Uint8List?> _downloadNetworkImage(String imageUrl) async {
    try {
      final response = await _dio.get<Uint8List>(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200 && response.data != null) {
        final image = img.decodeImage(response.data!);
        if (image != null) {
          final resizedImage = img.copyResize(
            image,
            width: 150,
            maintainAspect: true,
            interpolation: img.Interpolation.cubic,
          );
          return Uint8List.fromList(img.encodePng(resizedImage));
        }
      }
      return null;
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
  }

  String _formatPrice(String? formattedPrice, double? price) {
    if (formattedPrice != null && formattedPrice.isNotEmpty) {
      return formattedPrice;
    }
    if (price != null) {
      return CurrencyFormatter.formatPriceFromDouble(price);
    }
    return CurrencyFormatter.formatPrice('0');
  }

  String _formatPriceFromString(String? priceStr) {
    if (priceStr == null || priceStr.isEmpty) {
      return CurrencyFormatter.formatPrice('0');
    }
    final doublePrice = double.tryParse(priceStr);
    if (doublePrice != null) {
      return CurrencyFormatter.formatPriceFromDouble(doublePrice);
    }
    return priceStr;
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String _formatTime(DateTime dateTime) {
    int hour12 =
        dateTime.hour > 12
            ? dateTime.hour - 12
            : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final hour = hour12.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = _getMonthName(dateTime.month);
    final year = dateTime.year.toString();
    final time = _formatTime(dateTime);
    return '$day $month $year $time';
  }

  DateTime? _parseDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return null;

    try {
      return DateTime.parse(dateTimeString);
    } catch (e) {
      try {
        if (!dateTimeString.contains('-') || !dateTimeString.contains(' ')) {
          return null;
        }
        final parts = dateTimeString.split(' ');
        final dateParts = parts[0].split('-');
        final timeParts = parts[1].split(':');

        if (dateParts.length != 3 || timeParts.length < 2) return null;

        final isYearFirst = dateParts[0].length == 4;
        return DateTime(
          int.parse(isYearFirst ? dateParts[0] : dateParts[2]),
          int.parse(dateParts[1]),
          int.parse(isYearFirst ? dateParts[2] : dateParts[0]),
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );
      } catch (e2) {
        print('Error parsing date: $dateTimeString - $e2');
        return null;
      }
    }
  }

  String _formatDateTimeString(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return '';
    final dateTime = _parseDateTime(dateTimeString);
    return dateTime != null ? _formatDateTime(dateTime) : dateTimeString;
  }

  String _formatLabelValue(String label, String value, {int totalWidth = 38}) {
    final labelLength = label.length;
    final valueLength = value.length;
    final spacingNeeded = totalWidth - labelLength - valueLength;
    final spacing =
        spacingNeeded > 0 ? List.filled(spacingNeeded, ' ').join() : ' ';
    return '$label$spacing$value';
  }

  Future<void> _printLabelValue(
    String label,
    String value, {
    int totalWidth = 38,
    int fontSize = 20,
  }) async {
    final labelLength = label.length;
    final valueLength = value.length;
    final minSpacing = 2;

    if (labelLength + valueLength + minSpacing <= totalWidth) {
      await SunmiPrinter.printText(
        _formatLabelValue(label, value, totalWidth: totalWidth),
        style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: fontSize),
      );
    } else {
      await SunmiPrinter.printText(
        label,
        style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: fontSize),
      );
      final spacing = List.filled(totalWidth - valueLength, ' ').join();
      await SunmiPrinter.printText(
        '$spacing$value',
        style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: fontSize),
      );
    }
  }

  Map<String, Map<String, dynamic>> _aggregateTaxes(List<Items> items) {
    final aggregatedTaxes = <String, Map<String, dynamic>>{};
    for (final item in items) {
      item.taxBreakup?.taxes?.forEach((taxName, taxValue) {
        if (aggregatedTaxes.containsKey(taxName)) {
          final existing = aggregatedTaxes[taxName]!;
          aggregatedTaxes[taxName] = {
            'amount':
                (existing['amount'] as double? ?? 0.0) +
                (taxValue.amount ?? 0.0),
            'percent': existing['percent'] as String? ?? taxValue.percent,
          };
        } else {
          aggregatedTaxes[taxName] = {
            'amount': taxValue.amount,
            'percent': taxValue.percent,
          };
        }
      });
    }
    return aggregatedTaxes;
  }

  Future<void> printInvoice(InvoiceModel invoiceModel, {int copies = 1}) async {
    try {
      if (invoiceModel.invoice == null) {
        print('Error: Invoice data not found');
        return;
      }

      final invoice = invoiceModel.invoice!;
      final restaurant = invoice.restaurant;
      final branch = invoice.branch;
      final order = invoice.order;

      if (order == null) {
        print('Error: Order data not found');
        return;
      }

      final logoUrl = restaurant?.logoUrl;
      final qrCodeUrl = invoice.receiptSettings?.paymentQrCodeUrl;

      for (int i = 0; i < copies; i++) {
        if (logoUrl != null && logoUrl.isNotEmpty) {
          final imageData = await _downloadNetworkImage(logoUrl);
          if (imageData != null) {
            await SunmiPrinter.printImage(
              imageData,
              align: SunmiPrintAlign.CENTER,
            );
            await SunmiPrinter.lineWrap(5);
          }
        }

        await SunmiPrinter.printText(
          restaurant?.name ?? 'Restaurant',
          style: SunmiTextStyle(
            align: SunmiPrintAlign.CENTER,
            fontSize: 30,
            bold: true,
          ),
        );
        await SunmiPrinter.lineWrap(5);

        if (branch?.address != null) {
          await SunmiPrinter.printText(
            branch!.address!,
            style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 22),
          );
          await SunmiPrinter.lineWrap(5);
        }

        if (restaurant?.phoneNumber != null) {
          await SunmiPrinter.printText(
            'Phone: ${restaurant!.phoneNumber}',
            style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 22),
          );
          await SunmiPrinter.lineWrap(5);
        }

        await SunmiPrinter.lineWrap(5);
        await SunmiPrinter.printText("--------------------------------");
        await SunmiPrinter.lineWrap(5);

        final orderLine = 'Order: ${order.formattedOrderNumber ?? "N/A"}';
        final formattedOrderDateTime = _formatDateTimeString(order.dateTime);
        final orderText =
            formattedOrderDateTime.isNotEmpty
                ? '$orderLine   $formattedOrderDateTime'
                : orderLine;

        await SunmiPrinter.printText(
          orderText,
          style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 20),
        );
        await SunmiPrinter.lineWrap(5);

        if (order.customer?.name != null) {
          await SunmiPrinter.printText(
            'Customer: ${order.customer!.name}',
            style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 20),
          );
          await SunmiPrinter.lineWrap(5);
        }

        await SunmiPrinter.lineWrap(5);
        await SunmiPrinter.printText("--------------------------------");
        await SunmiPrinter.lineWrap(5);

        await SunmiPrinter.printText(
          'Qty   Item Name       Price    Amount',
          style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 20),
        );
        await SunmiPrinter.lineWrap(5);
        await SunmiPrinter.printText("--------------------------------");
        await SunmiPrinter.lineWrap(5);

        if (order.items?.isNotEmpty == true) {
          for (final item in order.items!) {
            final qty = item.quantity?.toString() ?? '0';
            final itemName = item.itemName ?? 'N/A';
            final price = _formatPrice(item.formattedPrice, item.price);
            final amount = _formatPrice(
              item.formattedAmount,
              item.amount?.toDouble(),
            );

            final qtyWidth = 4;
            final itemNameWidth = 15;
            final priceWidth = 10;
            final priceAmountSpacing = '   ';

            final qtyPadded = qty.padRight(qtyWidth);
            final displayItemName =
                itemName.length > itemNameWidth
                    ? '${itemName.substring(0, itemNameWidth - 3)}...'
                    : itemName;

            final itemNamePadded = displayItemName.padRight(itemNameWidth);
            final pricePadded = price.padLeft(priceWidth);
            final itemLine =
                '$qtyPadded$itemNamePadded$pricePadded$priceAmountSpacing$amount';

            await SunmiPrinter.printText(
              itemLine,
              style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 20),
            );
            await SunmiPrinter.lineWrap(5);

            if (item.variationName?.isNotEmpty == true) {
              await SunmiPrinter.printText(
                '  (${item.variationName})',
                style: SunmiTextStyle(
                  align: SunmiPrintAlign.LEFT,
                  fontSize: 18,
                ),
              );
              await SunmiPrinter.lineWrap(5);
            }

            if (item.modifiers?.isNotEmpty == true) {
              for (final modifier in item.modifiers!) {
                final modifierPrice = _formatPriceFromString(modifier.price);
                await SunmiPrinter.printText(
                  '  • ${modifier.name ?? ''} (+$modifierPrice)',
                  style: SunmiTextStyle(
                    align: SunmiPrintAlign.LEFT,
                    fontSize: 18,
                  ),
                );
                await SunmiPrinter.lineWrap(5);
              }
            }
            await SunmiPrinter.lineWrap(5);
          }
        }

        await SunmiPrinter.lineWrap(5);

        // Sub Total
        if (order.formattedSubTotal != null || order.subTotal != null) {
          final subTotalValue = _formatPrice(
            order.formattedSubTotal,
            order.subTotal?.toDouble(),
          );
          await SunmiPrinter.printText(
            _formatLabelValue('Sub Total:', subTotalValue),
            style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 20),
          );
          await SunmiPrinter.lineWrap(5);
        }

        final hasDiscount =
            order.discountValue != null &&
            order.discountValue!.isNotEmpty &&
            !['0', '0.0', '0.00'].contains(order.discountValue);
        if (hasDiscount) {
          final discountLabel =
              order.discountType != null &&
                      order.discountType!.toLowerCase().contains('percent')
                  ? 'Discount (${order.discountType})'
                  : 'Discount';
          final discountValue = _formatPrice(
            order.formattedDiscountAmount,
            order.discountAmount,
          );
          await SunmiPrinter.printText(
            _formatLabelValue(discountLabel, '-$discountValue'),
            style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 20),
          );
          await SunmiPrinter.lineWrap(5);
        }

        if (order.charges?.isNotEmpty == true) {
          for (final charge in order.charges!) {
            final chargeValue = _formatPrice(
              charge.formattedAmount,
              charge.amount,
            );
            await _printLabelValue('${charge.chargeName ?? ''}:', chargeValue);
            await SunmiPrinter.lineWrap(5);
          }
        }

        if (order.formattedTipAmount != null || order.tipAmount != null) {
          final tipValue = _formatPrice(
            order.formattedTipAmount,
            order.tipAmount is num
                ? (order.tipAmount as num).toDouble()
                : double.tryParse(order.tipAmount?.toString() ?? '0'),
          );
          if (tipValue.isNotEmpty && tipValue != '0') {
            await SunmiPrinter.printText(
              _formatLabelValue('Tip:', tipValue),
              style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 20),
            );
            await SunmiPrinter.lineWrap(5);
          }
        }

        if (order.items?.isNotEmpty == true) {
          final aggregatedTaxes = _aggregateTaxes(order.items!);
          for (final entry in aggregatedTaxes.entries) {
            final taxName = entry.key;
            final taxData = entry.value;
            final taxAmount = taxData['amount'] as double?;
            final taxPercent = taxData['percent'] as String?;
            final formattedTaxAmount = _formatPrice(null, taxAmount);
            final taxLabel =
                taxPercent?.isNotEmpty == true
                    ? '$taxName ($taxPercent%) incl.'
                    : '$taxName incl.';
            await _printLabelValue(taxLabel, formattedTaxAmount);
            await SunmiPrinter.lineWrap(5);
          }
        }

        if (order.formattedTotalTaxAmount != null ||
            order.totalTaxAmount != null) {
          final totalTaxValue = _formatPrice(
            order.formattedTotalTaxAmount,
            order.totalTaxAmount,
          );
          await SunmiPrinter.printText(
            _formatLabelValue('Total Tax:', totalTaxValue),
            style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 20),
          );
          await SunmiPrinter.lineWrap(5);
        }

        if (invoice.payment?.formattedBalance != null) {
          await SunmiPrinter.printText(
            _formatLabelValue(
              'Balance Returned:',
              invoice.payment!.formattedBalance!,
            ),
            style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 20),
          );
          await SunmiPrinter.lineWrap(5);
        }

        await SunmiPrinter.printText("--------------------------------");
        await SunmiPrinter.lineWrap(5);

        final totalValue = _formatPrice(order.formattedTotal, order.total);
        if (totalValue.isNotEmpty && totalValue != '0') {
          await SunmiPrinter.printText(
            'Total:                   $totalValue',
            style: SunmiTextStyle(
              align: SunmiPrintAlign.CENTER,
              fontSize: 25,
              bold: true,
            ),
          );
        }

        await SunmiPrinter.lineWrap(5);
        await SunmiPrinter.printText("--------------------------------");
        await SunmiPrinter.lineWrap(5);
        await SunmiPrinter.printText(
          'Thank you for your visit!',
          style: SunmiTextStyle(align: SunmiPrintAlign.CENTER),
        );
        await SunmiPrinter.lineWrap(5);
        await SunmiPrinter.printText(
          'PAY FROM YOUR PHONE',
          style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 20),
        );
        await SunmiPrinter.lineWrap(5);

        if (qrCodeUrl != null && qrCodeUrl.isNotEmpty) {
          final qrCodeData = await _downloadNetworkImage(qrCodeUrl);
          if (qrCodeData != null) {
            await SunmiPrinter.printImage(
              qrCodeData,
              align: SunmiPrintAlign.CENTER,
            );
            await SunmiPrinter.lineWrap(5);
          }
        }

        await SunmiPrinter.printText(
          'Scan the QR code to pay Your Bill',
          style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 20),
        );
        await SunmiPrinter.lineWrap(5);
        await SunmiPrinter.printText("--------------------------------");
        await SunmiPrinter.lineWrap(5);

        final payment =
            invoice.payment ??
            (order.payments?.isNotEmpty == true ? order.payments!.first : null);
        if (payment != null) {
          await SunmiPrinter.printText(
            "Amount  Payment Method   Date & Time",
            style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 20),
          );
          await SunmiPrinter.printText("--------------------------------");
          await SunmiPrinter.lineWrap(5);

          final paymentAmount = _formatPrice(
            payment.formattedAmount,
            payment.amount,
          );
          final paymentMethod = payment.paymentMethod ?? 'Cash';
          final formattedPaymentTime = _formatDateTimeString(
            payment.createdAt ?? order.dateTime,
          );

          await SunmiPrinter.printText(
            "$paymentAmount   $paymentMethod   $formattedPaymentTime",
            style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 20),
          );
        }

        await SunmiPrinter.lineWrap(5);
        await SunmiPrinter.cutPaper();
      }
    } catch (e) {
      print('Error printing invoice: $e');
      rethrow;
    }
  }
}
