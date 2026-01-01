import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import '../utils/currency_formatter.dart';
import '../model/getorderModel.dart' as orderModel;
import '../constants/translation_keys.dart';

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

  Map<String, Map<String, dynamic>> _aggregateTaxes(
    List<orderModel.Items> items,
    List<orderModel.Taxes>? taxes,
  ) {
    final aggregatedTaxes = <String, Map<String, dynamic>>{};

    // Use taxes from data if available
    if (taxes != null && taxes.isNotEmpty) {
      for (final tax in taxes) {
        final taxName = tax.taxName ?? 'Tax';
        final taxPercent = tax.percent?.toString() ?? '';
        final taxAmount = tax.amount ?? 0.0;

        if (aggregatedTaxes.containsKey(taxName)) {
          final existing = aggregatedTaxes[taxName]!;
          aggregatedTaxes[taxName] = {
            'amount': (existing['amount'] as double? ?? 0.0) + taxAmount,
            'percent': existing['percent'] as String? ?? taxPercent,
          };
        } else {
          aggregatedTaxes[taxName] = {
            'amount': taxAmount,
            'percent': taxPercent,
          };
        }
      }
    } else {
      // Fallback: aggregate from items if taxes list is not available
      for (final item in items) {
        if (item.taxAmount != null && item.taxAmount! > 0) {
          final taxName = 'Tax';
          final taxPercent = item.taxPercentage?.toString() ?? '';
          final taxAmount = item.taxAmount!;

          if (aggregatedTaxes.containsKey(taxName)) {
            final existing = aggregatedTaxes[taxName]!;
            aggregatedTaxes[taxName] = {
              'amount': (existing['amount'] as double? ?? 0.0) + taxAmount,
              'percent': existing['percent'] as String? ?? taxPercent,
            };
          } else {
            aggregatedTaxes[taxName] = {
              'amount': taxAmount,
              'percent': taxPercent,
            };
          }
        }
      }
    }
    return aggregatedTaxes;
  }

  Future<void> printInvoice(orderModel.Data data, {int copies = 1}) async {
    try {
      final restaurant = data.restaurant;
      final branch = data.branch;
      final order = data.order;

      if (order == null) {
        return;
      }

      final logoUrl = restaurant?.logoUrl ?? data.imageUrl;
      final qrCodeUrl = data.receiptSettings?.paymentQrCodeUrl;

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
          restaurant?.name ?? TranslationKeys.restaurant.tr,
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

        if (order.customer?.phoneNumber != null) {
          await SunmiPrinter.printText(
            '${TranslationKeys.phone.tr}: ${order.customer!.phoneNumber}',
            style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 22),
          );
          await SunmiPrinter.lineWrap(5);
        }

        await SunmiPrinter.lineWrap(5);
        await SunmiPrinter.printText("--------------------------------");
        await SunmiPrinter.lineWrap(5);

        final orderLine =
            '${TranslationKeys.order.tr}: ${order.formattedOrderNumber ?? TranslationKeys.na.tr}';
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
            '${TranslationKeys.customer.tr}: ${order.customer!.name}',
            style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 20),
          );
          await SunmiPrinter.lineWrap(5);
        }

        await SunmiPrinter.lineWrap(5);
        await SunmiPrinter.printText("--------------------------------");
        await SunmiPrinter.lineWrap(5);

        await SunmiPrinter.printText(
          TranslationKeys.qtyItemNamePriceAmount.tr,
          style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 20),
        );
        await SunmiPrinter.lineWrap(5);
        await SunmiPrinter.printText("--------------------------------");
        await SunmiPrinter.lineWrap(5);

        if (order.items?.isNotEmpty == true) {
          for (final item in order.items!) {
            final qty = item.quantity?.toString() ?? '0';
            final itemName = item.itemName ?? TranslationKeys.na.tr;
            final price = _formatPrice(null, item.price);
            final amount = _formatPrice(null, item.amount);

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
                final modifierPrice = _formatPrice(null, modifier.price);
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
        if (order.totals?.subTotal != null) {
          final subTotalValue = _formatPrice(
            null,
            order.totals!.subTotal?.toDouble(),
          );
          await SunmiPrinter.printText(
            _formatLabelValue('${TranslationKeys.subTotal.tr}:', subTotalValue),
            style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 20),
          );
          await SunmiPrinter.lineWrap(5);
        }

        final hasDiscount =
            order.discountValue != null &&
            order.discountValue! > 0 &&
            order.totals?.discountAmount != null &&
            order.totals!.discountAmount! > 0;
        if (hasDiscount) {
          final discountLabel =
              order.discountType != null &&
                      order.discountType!.toLowerCase().contains('percent')
                  ? '${TranslationKeys.discount.tr} (${order.discountType})'
                  : TranslationKeys.discount.tr;
          final discountValue = _formatPrice(
            null,
            order.totals!.discountAmount,
          );
          await SunmiPrinter.printText(
            _formatLabelValue(discountLabel, '-$discountValue'),
            style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 20),
          );
          await SunmiPrinter.lineWrap(5);
        }

        if (order.charges?.isNotEmpty == true) {
          for (final charge in order.charges!) {
            final chargeValue = _formatPrice(null, charge.amount);
            await _printLabelValue('${charge.chargeName ?? ''}:', chargeValue);
            await SunmiPrinter.lineWrap(5);
          }
        }

        if (order.totals?.tipAmount != null && order.totals!.tipAmount! > 0) {
          final tipValue = _formatPrice(null, order.totals!.tipAmount);
          if (tipValue.isNotEmpty && tipValue != '0') {
            await SunmiPrinter.printText(
              _formatLabelValue('${TranslationKeys.tip.tr}:', tipValue),
              style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 20),
            );
            await SunmiPrinter.lineWrap(5);
          }
        }

        if (order.items?.isNotEmpty == true) {
          final aggregatedTaxes = _aggregateTaxes(order.items!, data.taxes);
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

        if (order.totals?.totalTaxAmount != null) {
          final totalTaxValue = _formatPrice(
            null,
            order.totals!.totalTaxAmount,
          );
          await SunmiPrinter.printText(
            _formatLabelValue('${TranslationKeys.totalTax.tr}:', totalTaxValue),
            style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 20),
          );
          await SunmiPrinter.lineWrap(5);
        }

        // Calculate balance returned if payment exists
        if (order.payments?.isNotEmpty == true && order.totals?.total != null) {
          final totalPaid = order.payments!.fold<double>(
            0.0,
            (sum, payment) => sum + (payment.amount ?? 0.0),
          );
          final total = order.totals!.total ?? 0.0;
          final balance = totalPaid - total;
          if (balance > 0) {
            final balanceValue = _formatPrice(null, balance);
            await SunmiPrinter.printText(
              _formatLabelValue(
                '${TranslationKeys.balanceReturned.tr}:',
                balanceValue,
              ),
              style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 20),
            );
            await SunmiPrinter.lineWrap(5);
          }
        }

        await SunmiPrinter.printText("--------------------------------");
        await SunmiPrinter.lineWrap(5);

        final totalValue = _formatPrice(null, order.totals?.total);
        if (totalValue.isNotEmpty && totalValue != '0') {
          await SunmiPrinter.printText(
            '${TranslationKeys.total.tr}:                   $totalValue',
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
          TranslationKeys.thankYouForVisit.tr,
          style: SunmiTextStyle(align: SunmiPrintAlign.CENTER),
        );
        await SunmiPrinter.lineWrap(5);
        await SunmiPrinter.printText(
          TranslationKeys.payFromYourPhone.tr.toUpperCase(),
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
          TranslationKeys.scanQrCodeToPay.tr,
          style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 20),
        );
        await SunmiPrinter.lineWrap(5);
        await SunmiPrinter.printText("--------------------------------");
        await SunmiPrinter.lineWrap(5);

        if (order.payments?.isNotEmpty == true) {
          await SunmiPrinter.printText(
            "Amount Payment Method   Date & Time",
            style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 20),
          );
          await SunmiPrinter.printText("--------------------------------");
          await SunmiPrinter.lineWrap(5);

          for (final payment in order.payments!) {
            final paymentAmount = _formatPrice(null, payment.amount);
            final paymentMethod =
                payment.paymentMethod ?? TranslationKeys.cash.tr;
            final formattedPaymentTime = _formatDateTimeString(
              payment.createdAt ?? order.dateTime,
            );

            await SunmiPrinter.printText(
              "$paymentAmount  $paymentMethod  $formattedPaymentTime",
              style: SunmiTextStyle(
                align: SunmiPrintAlign.CENTER,
                fontSize: 20,
              ),
            );
            await SunmiPrinter.lineWrap(5);
          }
        }

        await SunmiPrinter.lineWrap(5);
        await SunmiPrinter.cutPaper();
      }
    } catch (e) {
      rethrow;
    }
  }
}
