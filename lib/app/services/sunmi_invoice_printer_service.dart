import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_time_formatter.dart';
import '../model/get_order_model.dart' as order_model;
import '../model/receipt_order_response_model.dart';
import '../model/kitchen_ticket_model.dart';
import '../constants/translation_keys.dart';
import 'package:managerapp/app/services/printer_service.dart';
import 'receipt_image_service.dart';


class SunmiInvoicePrinterService {
  static final Dio _dio = Dio();
  final printerService = Get.find<PrinterService>();

  int _getTotalWidth({bool isKitchen = false}) {
    final String width =
        isKitchen
            ? printerService.kitchenWidth.value
            : printerService.receiptWidth.value;
    return width == '80mm' ? 48 : 38;
  }

  String _getLineSeparator({bool isKitchen = false}) {
    final int width = 32;
    return List.filled(width, '-').join();
  }

  static const int _fontSizeTitle = 30;
  static const int _fontSizeSub = 22;
  static const int _fontSizeBody = 20;
  static const int _fontSizeSmall = 18;
  static const int _fontSizeTotal = 25;

  Future<void> _printSep() async => SunmiPrinter.lineWrap(5);
  Future<void> _printLine({bool isKitchen = false}) async {
    await SunmiPrinter.printText(_getLineSeparator(isKitchen: isKitchen));
    await _printSep();
  }

  Future<void> _printCenteredSub(String text) async {
    await SunmiPrinter.printText(
      text,
      style: SunmiTextStyle(
        align: SunmiPrintAlign.CENTER,
        fontSize: _fontSizeSub,
      ),
    );
    await _printSep();
  }

  Future<void> _printLeftBody(String text) async {
    await SunmiPrinter.printText(
      text,
      style: SunmiTextStyle(
        align: SunmiPrintAlign.LEFT,
        fontSize: _fontSizeBody,
      ),
    );
    await _printSep();
  }

  /// Prints only restaurant/branch address at top (centered).
  Future<void> _printBranchAddress(String? branchAddress) async {
    if (branchAddress != null && branchAddress.trim().isNotEmpty) {
      await _printCenteredSub(branchAddress);
    }
  }

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

  String _formatDateTimeString(String? dateTimeString, [String? timezone]) {
    if (timezone != null && timezone.isNotEmpty) {
      return DateTimeFormatter.formatDateTimeInTimezone(
        dateTimeString,
        timezone,
      );
    }
    return DateTimeFormatter.formatDateTime(dateTimeString);
  }

  /// Format phone with + for print (e.g. +91 1234567890).
  String _formatPhoneWithPlus(String? phoneCode, String? phoneNumber) {
    final code = phoneCode?.trim() ?? '';
    final num = phoneNumber?.trim() ?? '';
    if (num.isEmpty) return '';
    if (code.isEmpty) return num.startsWith('+') ? num : '+$num';
    final plusCode = code.startsWith('+') ? code : '+$code';
    return '$plusCode $num';
  }

  String _formatLabelValue(String label, String value, {int? totalWidth}) {
    final int width = totalWidth ?? _getTotalWidth();
    final labelLength = label.length;
    final valueLength = value.length;
    final spacingNeeded = width - labelLength - valueLength;
    final spacing =
        spacingNeeded > 0 ? List.filled(spacingNeeded, ' ').join() : ' ';
    return '$label$spacing$value';
  }

  List<String> _splitLongWord(String word, int maxWidth) {
    final List<String> chunks = [];
    int start = 0;
    while (start < word.length) {
      final end =
          (start + maxWidth < word.length) ? start + maxWidth : word.length;
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

  Future<void> _printIconText(
    String icon,
    String text, {
    int fontSize = 20,
    bool bold = false,
  }) async {
    final int totalWidth = _getTotalWidth();
    // Assuming icon + space takes roughly 3 characters width
    final int indentWidth = 3;
    final int maxWidth = totalWidth - indentWidth;

    if (text.length <= maxWidth) {
      await SunmiPrinter.printText(
        '$icon  $text',
        style: SunmiTextStyle(
          align: SunmiPrintAlign.LEFT,
          fontSize: fontSize,
          bold: bold,
        ),
      );
    } else {
      final lines = _wrapText(text, maxWidth);
      for (int i = 0; i < lines.length; i++) {
        if (i == 0) {
          await SunmiPrinter.printText(
            '$icon  ${lines[i]}',
            style: SunmiTextStyle(
              align: SunmiPrintAlign.LEFT,
              fontSize: fontSize,
              bold: bold,
            ),
          );
        } else {
          final indent = List.filled(indentWidth, ' ').join();
          await SunmiPrinter.printText(
            '$indent${lines[i]}',
            style: SunmiTextStyle(
              align: SunmiPrintAlign.LEFT,
              fontSize: fontSize,
              bold: bold,
            ),
          );
        }
      }
    }
    await _printSep();
  }

  Future<void> _printLabelValue(
    String label,
    String value, {
    int? totalWidth,
    int fontSize = 20,
    bool isKitchen = false,
  }) async {
    final int width = totalWidth ?? _getTotalWidth(isKitchen: isKitchen);
    final labelLength = label.length;
    final valueLength = value.length;
    final minSpacing = 2;

    if (labelLength + valueLength + minSpacing <= width) {
      await SunmiPrinter.printText(
        _formatLabelValue(label, value, totalWidth: width),
        style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: fontSize),
      );
    } else {
      await SunmiPrinter.printText(
        label,
        style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: fontSize),
      );
      final spacing = List.filled(width - valueLength, ' ').join();
      await SunmiPrinter.printText(
        '$spacing$value',
        style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: fontSize),
      );
    }
  }

  void _mergeTax(
    Map<String, Map<String, dynamic>> into,
    String name,
    String percent,
    double amount,
  ) {
    if (into.containsKey(name)) {
      final existing = into[name]!;
      into[name] = {
        'amount': (existing['amount'] as double? ?? 0.0) + amount,
        'percent': existing['percent'] as String? ?? percent,
      };
    } else {
      into[name] = {'amount': amount, 'percent': percent};
    }
  }

  Map<String, Map<String, dynamic>> _aggregateTaxes(
    List<order_model.Items> items,
    List<order_model.Taxes>? taxes,
  ) {
    final aggregatedTaxes = <String, Map<String, dynamic>>{};

    if (taxes != null && taxes.isNotEmpty) {
      for (final tax in taxes) {
        _mergeTax(
          aggregatedTaxes,
          tax.taxName ?? TranslationKeys.tax.tr,
          tax.percent?.toString() ?? '',
          tax.amount ?? 0.0,
        );
      }
    } else {
      for (final item in items) {
        if (item.taxAmount != null && item.taxAmount! > 0) {
          _mergeTax(
            aggregatedTaxes,
            TranslationKeys.tax.tr,
            item.taxPercentage?.toString() ?? '',
            item.taxAmount!,
          );
        }
      }
    }
    return aggregatedTaxes;
  }

  Future<void> printInvoice(order_model.Data data, {int copies = 1}) async {
    await printWoltStyleInvoice(data, copies: copies);
  }

  // Keeping original logic below as _printInvoiceLegacy if needed for fallback
  Future<void> _printInvoiceLegacy(order_model.Data data, {int copies = 1}) async {
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
            await _printSep();
          }
        }

        await SunmiPrinter.printText(
          restaurant?.name ?? TranslationKeys.restaurant.tr,
          style: SunmiTextStyle(
            align: SunmiPrintAlign.CENTER,
            fontSize: _fontSizeTitle,
            bold: true,
          ),
        );
        await _printSep();
        await _printBranchAddress(branch?.address);
        await _printSep();
        await _printLine();

        final formattedOrderDateTime = _formatDateTimeString(order.dateTime);
        if (formattedOrderDateTime.isNotEmpty) {
          await _printIconText('🕒', formattedOrderDateTime);
        }

        if (order.customer?.name != null && order.customer!.name!.isNotEmpty) {
          await _printIconText('👤', order.customer!.name!);
        }

        final orderNo = order.orderNumber ?? '';
        if (orderNo.isNotEmpty) {
          await _printIconText('  ', '#$orderNo');
        }

        final orderType = order.orderType ?? '';
        if (orderType.isNotEmpty) {
          String typeIcon = '🚗';
          if (orderType.toLowerCase().contains('pickup')) {
            typeIcon = '🛍️';
          } else if (orderType.toLowerCase().contains('dine')) {
            typeIcon = '🍽️';
          }
          await _printIconText(typeIcon, orderType);
        }

        final address = order.deliveryAddress ?? '';
        if (address.isNotEmpty) {
          await _printIconText('📍', address);
        }

        final phoneStr = _formatPhoneWithPlus(
          order.customer?.phoneCode,
          order.customer?.phoneNumber,
        );
        if (phoneStr.isNotEmpty) {
          await _printIconText('📞', phoneStr);
        }

        final tableCode = order.table?.tableCode ?? '';
        final pax = order.numberOfPax;
        if (tableCode.isNotEmpty || (pax != null && pax > 0)) {
          final tablePart =
              tableCode.isNotEmpty
                  ? '${TranslationKeys.tableNo.tr}: $tableCode'
                  : '';
          final paxPart =
              (pax != null && pax > 0)
                  ? '(${TranslationKeys.cover.tr}: $pax)'
                  : '';
          final tablePaxLine = [
            tablePart,
            paxPart,
          ].where((e) => e.isNotEmpty).join(' ');
          await _printIconText('🍽️', tablePaxLine);
        }

        if (order.waiter?.name != null && order.waiter!.name!.isNotEmpty) {
          await _printIconText(
            '🤵',
            '${TranslationKeys.waiter.tr}: ${order.waiter!.name!}',
          );
        }
        await _printSep();
        await _printLine();

        final int totalWidth = _getTotalWidth(isKitchen: false);

        if (order.items?.isNotEmpty == true) {
          for (final item in order.items!) {
            final qty = item.quantity?.toString() ?? '0';
            final itemName = item.itemName ?? TranslationKeys.na.tr;
            final amount = _formatPrice(null, item.amount);

            final qtyStr = '$qty x ';
            final indentWidth = qtyStr.length;
            final amountWidth = amount.length;
            final availableWidthForName =
                totalWidth - indentWidth - amountWidth - 1;

            final nameLines = _wrapText(itemName, availableWidthForName);

            for (int i = 0; i < nameLines.length; i++) {
              if (i == 0) {
                final paddedName = nameLines[i].padRight(
                  availableWidthForName + 1,
                );
                await SunmiPrinter.printText(
                  '$qtyStr$paddedName$amount',
                  style: SunmiTextStyle(
                    align: SunmiPrintAlign.LEFT,
                    fontSize: _fontSizeBody,
                  ),
                );
              } else {
                final indent = ' '.padRight(indentWidth);
                await SunmiPrinter.printText(
                  '$indent${nameLines[i]}',
                  style: SunmiTextStyle(
                    align: SunmiPrintAlign.LEFT,
                    fontSize: _fontSizeBody,
                  ),
                );
              }
              await _printSep();
            }

            final variationIndent = ' '.padRight(indentWidth);
            if (item.variationName?.isNotEmpty == true) {
              final varLines = _wrapText(
                '(${item.variationName})',
                availableWidthForName,
              );
              for (final line in varLines) {
                await SunmiPrinter.printText(
                  '$variationIndent$line',
                  style: SunmiTextStyle(
                    align: SunmiPrintAlign.LEFT,
                    fontSize: _fontSizeSmall,
                  ),
                );
                await _printSep();
              }
            }
            if (item.modifiers?.isNotEmpty == true) {
              for (final modifier in item.modifiers!) {
                final modifierPrice = _formatPrice(null, modifier.price);
                final modLines = _wrapText(
                  '• ${modifier.name ?? ''} (+$modifierPrice)',
                  availableWidthForName,
                );
                for (final line in modLines) {
                  await SunmiPrinter.printText(
                    '$variationIndent$line',
                    style: SunmiTextStyle(
                      align: SunmiPrintAlign.LEFT,
                      fontSize: _fontSizeSmall,
                    ),
                  );
                  await _printSep();
                }
              }
            }
            if (item.note != null && item.note!.isNotEmpty) {
              final noteLines = _wrapText(
                '${TranslationKeys.note.tr}: ${item.note}',
                availableWidthForName,
              );
              for (final line in noteLines) {
                await SunmiPrinter.printText(
                  '$variationIndent$line',
                  style: SunmiTextStyle(
                    align: SunmiPrintAlign.LEFT,
                    fontSize: _fontSizeSmall,
                  ),
                );
                await _printSep();
              }
            }
            await _printLine();
          }
        }
        await _printSep();

        if (order.totals?.subTotal != null) {
          await _printLeftBody(
            _formatLabelValue(
              '${TranslationKeys.subTotal.tr}:',
              _formatPrice(null, order.totals!.subTotal?.toDouble()),
            ),
          );
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
          await _printLeftBody(
            _formatLabelValue(
              discountLabel,
              '-${_formatPrice(null, order.totals!.discountAmount)}',
            ),
          );
        }

        if (order.charges?.isNotEmpty == true) {
          for (final charge in order.charges!) {
            final chargeValue = _formatPrice(null, charge.amount);
            await _printLabelValue('${charge.chargeName ?? ''}:', chargeValue);
            await _printSep();
          }
        }

        if (order.orderType?.toLowerCase() == 'delivery' &&
            order.totals?.deliveryFee != null &&
            order.totals!.deliveryFee! >= 0) {
          final deliveryValue =
              order.totals!.deliveryFee! == 0
                  ? TranslationKeys.free.tr
                  : _formatPrice(null, order.totals!.deliveryFee!.toDouble());
          await _printLabelValue(
            '${TranslationKeys.deliveryCharge.tr}:',
            deliveryValue,
          );
          await _printSep();
        }

        if (order.totals?.tipAmount != null && order.totals!.tipAmount! > 0) {
          final tipValue = _formatPrice(null, order.totals!.tipAmount);
          if (tipValue.isNotEmpty && tipValue != '0') {
            await _printLeftBody(
              _formatLabelValue('${TranslationKeys.tip.tr}:', tipValue),
            );
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

            final taxPrefix =
                taxPercent?.isNotEmpty == true
                    ? '$taxName ($taxPercent%)'
                    : taxName;
            final isInc = data.taxInclusive == true;
            final taxLabel =
                '$taxPrefix ${isInc ? TranslationKeys.inc.tr : TranslationKeys.exc.tr}';

            await _printLabelValue(taxLabel, formattedTaxAmount);
            await _printSep();
          }
        }

        if (order.payments?.isNotEmpty == true && order.totals?.total != null) {
          final totalPaid = order.payments!.fold<double>(
            0.0,
            (sum, payment) => sum + (payment.amount ?? 0.0),
          );
          final total = order.totals!.total ?? 0.0;
          final balance = totalPaid - total;
          if (balance > 0) {
            await _printLeftBody(
              _formatLabelValue(
                '${TranslationKeys.balanceReturned.tr}:',
                _formatPrice(null, balance),
              ),
            );
          }
        }

        await _printLine();

        final totalValue = _formatPrice(null, order.totals?.total);
        if (totalValue.isNotEmpty && totalValue != '0') {
          final int totalWidthForFontSize25 = _getTotalWidth() == 48 ? 34 : 26;
          await SunmiPrinter.printText(
            _formatLabelValue(
              '${TranslationKeys.total.tr}:',
              totalValue,
              totalWidth: totalWidthForFontSize25,
            ),
            style: SunmiTextStyle(
              align: SunmiPrintAlign.LEFT,
              fontSize: _fontSizeTotal,
              bold: true,
            ),
          );
        }

        await _printSep();
        await _printLine();
        await SunmiPrinter.printText(
          TranslationKeys.thankYouForVisit.tr,
          style: SunmiTextStyle(align: SunmiPrintAlign.CENTER),
        );
        await _printSep();
        if (qrCodeUrl != null && qrCodeUrl.isNotEmpty) {
          final qrCodeData = await _downloadNetworkImage(qrCodeUrl);
          if (qrCodeData != null) {
            await SunmiPrinter.printText(
              TranslationKeys.payFromYourPhone.tr.toUpperCase(),
              style: SunmiTextStyle(
                align: SunmiPrintAlign.CENTER,
                fontSize: _fontSizeBody,
              ),
            );
            await _printSep();
            await SunmiPrinter.printImage(
              qrCodeData,
              align: SunmiPrintAlign.CENTER,
            );
            await _printSep();
          }
          await SunmiPrinter.printText(
            TranslationKeys.scanQrCodeToPay.tr,
            style: SunmiTextStyle(
              align: SunmiPrintAlign.CENTER,
              fontSize: _fontSizeBody,
            ),
          );
          await _printSep();
        }
        await _printLine();

        if (order.payments?.isNotEmpty == true) {
          for (final payment in order.payments!) {
            final method = (payment.paymentMethod ?? '').toLowerCase();
            final isOnline =
                method.contains('stripe') ||
                method.contains('multisafepay') ||
                method.contains('online') ||
                method.contains('card');

            if (isOnline) {
              await SunmiPrinter.printText(
                '💳 ${TranslationKeys.onlinePayment.tr}',
                style: SunmiTextStyle(
                  align: SunmiPrintAlign.CENTER,
                  fontSize: _fontSizeBody,
                  bold: true,
                ),
              );
              await SunmiPrinter.printText(
                TranslationKeys.customerPaidOnline.tr,
                style: SunmiTextStyle(
                  align: SunmiPrintAlign.CENTER,
                  fontSize: _fontSizeSmall,
                ),
              );
            } else {
              final paymentAmount = _formatPrice(null, payment.amount);
              await SunmiPrinter.printText(
                '💵 ${TranslationKeys.cashPayment.tr}',
                style: SunmiTextStyle(
                  align: SunmiPrintAlign.CENTER,
                  fontSize: _fontSizeBody,
                  bold: true,
                ),
              );
              await SunmiPrinter.printText(
                '${TranslationKeys.amountPaid.tr}: $paymentAmount',
                style: SunmiTextStyle(
                  align: SunmiPrintAlign.CENTER,
                  fontSize: _fontSizeSmall,
                ),
              );
            }
            await _printSep();
          }
        }

        await _printSep();
        await SunmiPrinter.cutPaper();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> printWoltStyleInvoice(order_model.Data data, {int copies = 1}) async {
    try {
      final String widthStr = printerService.receiptWidth.value;
      final double width = widthStr == '80mm' ? 576 : 384;

      final imageData = await ReceiptImageService.generateReceiptImage(data, width: width);

      for (int i = 0; i < copies; i++) {
        await SunmiPrinter.printImage(
          imageData,
          align: SunmiPrintAlign.CENTER,
        );
        await SunmiPrinter.lineWrap(5);
        await SunmiPrinter.cutPaper();
      }
    } catch (e) {
      rethrow;
    }
  }


  Future<void> printReceiptFromApi(ReceiptOrderData d, {int copies = 1}) async {
    try {
      final String widthStr = printerService.receiptWidth.value;
      final double width = widthStr == '80mm' ? 576 : 384;

      final imageData = await ReceiptImageService.generateReceiptImageFromApi(d, width: width);

      for (int i = 0; i < copies; i++) {
        await SunmiPrinter.printImage(
          imageData,
          align: SunmiPrintAlign.CENTER,
        );
        await SunmiPrinter.lineWrap(5);
        await SunmiPrinter.cutPaper();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _printReceiptFromApiLegacy(ReceiptOrderData d, {int copies = 1}) async {
    try {
      final restaurant = d.restaurant;
      final branch = d.branch;
      final order = d.order;
      final summary = d.summary;
      final payment = d.payment;
      final items = d.receiptItems;
      if (order == null || payment == null) return;

      for (int i = 0; i < copies; i++) {
        await SunmiPrinter.printText(
          restaurant?.name ?? TranslationKeys.restaurant.tr,
          style: SunmiTextStyle(
            align: SunmiPrintAlign.CENTER,
            fontSize: _fontSizeTitle,
            bold: true,
          ),
        );
        await _printSep();

        await _printBranchAddress(branch?.address);
        await _printSep();
        await _printLine();

        final formattedOrderDateTime = _formatDateTimeString(order.dateTime);
        if (formattedOrderDateTime.isNotEmpty) {
          await _printIconText('🕒', formattedOrderDateTime);
        }

        final customerName = _receiptCustomerName(order.customer);
        if (customerName != null && customerName.isNotEmpty) {
          await _printIconText('👤', customerName);
        }

        final orderNo = order.orderNumber ?? '';
        if (orderNo.isNotEmpty) {
          await _printIconText('  ', '#$orderNo');
        }

        final orderType = order.orderType ?? '';
        if (orderType.isNotEmpty) {
          String typeIcon = '🚗';
          if (orderType.toLowerCase().contains('pickup')) {
            typeIcon = '🛍️';
          } else if (orderType.toLowerCase().contains('dine')) {
            typeIcon = '🍽️';
          }
          await _printIconText(typeIcon, orderType);
        }

        final address = order.deliveryAddress ?? '';
        if (address.isNotEmpty) {
          await _printIconText('📍', address);
        }

        final phoneStr = _receiptPhoneWithPlus(order.customer);
        if (phoneStr != null && phoneStr.isNotEmpty) {
          await _printIconText('📞', phoneStr);
        }

        final tableCode = order.table?.tableCode ?? '';
        final pax = order.numberOfPax;
        if (tableCode.isNotEmpty || (pax != null && pax > 0)) {
          final tablePart =
              tableCode.isNotEmpty
                  ? '${TranslationKeys.tableNo.tr}: $tableCode'
                  : '';
          final paxPart =
              (pax != null && pax > 0)
                  ? '(${TranslationKeys.cover.tr}: $pax)'
                  : '';
          final tablePaxLine = [
            tablePart,
            paxPart,
          ].where((e) => e.isNotEmpty).join(' ');
          await _printIconText('🍽️', tablePaxLine);
        }

        if (order.waiter?.name != null && order.waiter!.name!.isNotEmpty) {
          await _printIconText(
            '🤵',
            '${TranslationKeys.waiter.tr}: ${order.waiter!.name!}',
          );
        }

        await _printSep();
        await _printLine();

        final int totalWidth = _getTotalWidth(isKitchen: false);

        if (items != null && items.isNotEmpty) {
          for (final entry in items) {
            final oi = entry.orderItem;
            if (oi == null) continue;
            final qty =
                entry.quantity?.toString() ?? oi.quantity?.toString() ?? '0';
            final itemName = oi.displayItemName ?? TranslationKeys.na.tr;
            final amount =
                oi.formattedLineAmount ??
                CurrencyFormatter.formatPriceFromDouble(
                  (oi.amount ?? 0) * (oi.quantity ?? 1),
                );

            final qtyStr = '$qty x ';
            final indentWidth = qtyStr.length;
            final amountWidth = amount.length;
            final availableWidthForName =
                totalWidth - indentWidth - amountWidth - 1;

            final nameLines = _wrapText(itemName, availableWidthForName);

            for (int j = 0; j < nameLines.length; j++) {
              if (j == 0) {
                final paddedName = nameLines[j].padRight(
                  availableWidthForName + 1,
                );
                await SunmiPrinter.printText(
                  '$qtyStr$paddedName$amount',
                  style: SunmiTextStyle(
                    align: SunmiPrintAlign.LEFT,
                    fontSize: _fontSizeBody,
                  ),
                );
              } else {
                final indent = ' '.padRight(indentWidth);
                await SunmiPrinter.printText(
                  '$indent${nameLines[j]}',
                  style: SunmiTextStyle(
                    align: SunmiPrintAlign.LEFT,
                    fontSize: _fontSizeBody,
                  ),
                );
              }
              await _printSep();
            }

            final variationIndent = ' '.padRight(indentWidth);
            if (oi.displayVariationName != null &&
                oi.displayVariationName!.isNotEmpty) {
              final varLines = _wrapText(
                '(${oi.displayVariationName})',
                availableWidthForName,
              );
              for (final line in varLines) {
                await SunmiPrinter.printText(
                  '$variationIndent$line',
                  style: SunmiTextStyle(
                    align: SunmiPrintAlign.LEFT,
                    fontSize: _fontSizeSmall,
                  ),
                );
                await _printSep();
              }
            }

            if (oi.displayModifiers != null &&
                oi.displayModifiers!.isNotEmpty) {
              for (final m in oi.displayModifiers!) {
                final modPrice = m.price ?? '';
                final modLines = _wrapText(
                  '• ${m.name ?? ''}${modPrice.isNotEmpty ? ' (+$modPrice)' : ''}',
                  availableWidthForName,
                );
                for (final line in modLines) {
                  await SunmiPrinter.printText(
                    '$variationIndent$line',
                    style: SunmiTextStyle(
                      align: SunmiPrintAlign.LEFT,
                      fontSize: _fontSizeSmall,
                    ),
                  );
                  await _printSep();
                }
              }
            }

            if (oi.note != null && oi.note!.isNotEmpty) {
              final noteLines = _wrapText(
                '${TranslationKeys.note.tr}: ${oi.note}',
                availableWidthForName,
              );
              for (final line in noteLines) {
                await SunmiPrinter.printText(
                  '$variationIndent$line',
                  style: SunmiTextStyle(
                    align: SunmiPrintAlign.LEFT,
                    fontSize: _fontSizeSmall,
                  ),
                );
                await _printSep();
              }
            }

            await _printLine();
          }
        }

        await _printSep();

        if (summary != null) {
          if (summary.subTotal != null) {
            await _printLeftBody(
              _formatLabelValue(
                '${TranslationKeys.subTotal.tr}:',
                CurrencyFormatter.formatPriceFromDouble(summary.subTotal!),
              ),
            );
          }

          if (summary.discount != null && summary.discount! > 0) {
            await _printLeftBody(
              _formatLabelValue(
                TranslationKeys.discount.tr,
                '-${CurrencyFormatter.formatPriceFromDouble(summary.discount!)}',
              ),
            );
          }

          if (summary.tip != null && summary.tip! > 0) {
            await _printLeftBody(
              _formatLabelValue(
                '${TranslationKeys.tip.tr}:',
                CurrencyFormatter.formatPriceFromDouble(summary.tip!),
              ),
            );
          }

          if (order.orderType?.toLowerCase() == 'delivery' &&
              summary.deliveryFee != null &&
              summary.deliveryFee! >= 0) {
            final deliveryValue =
                summary.deliveryFee! == 0
                    ? TranslationKeys.free.tr
                    : CurrencyFormatter.formatPriceFromDouble(
                      summary.deliveryFee!,
                    );
            await _printLeftBody(
              _formatLabelValue(
                '${TranslationKeys.deliveryCharge.tr}:',
                deliveryValue,
              ),
            );
          }

          if (summary.taxes != null && summary.taxes!.isNotEmpty) {
            for (final t in summary.taxes!) {
              final isInc = d.taxInclusive == true;
              final label =
                  t.percent != null
                      ? '${t.name ?? ''} (${t.percent}%) ${isInc ? TranslationKeys.inc.tr : TranslationKeys.exc.tr}'
                      : '${t.name ?? ''} ${isInc ? TranslationKeys.inc.tr : TranslationKeys.exc.tr}';
              final val =
                  t.amount != null
                      ? CurrencyFormatter.formatPriceFromDouble(t.amount!)
                      : '';
              if (label.isNotEmpty && val.isNotEmpty) {
                await _printLabelValue(label, val);
                await _printSep();
              }
            }
          }

          if (payment.balance != null && payment.balance! > 0) {
            await _printLeftBody(
              _formatLabelValue(
                '${TranslationKeys.balanceReturned.tr}:',
                CurrencyFormatter.formatPriceFromDouble(payment.balance!),
              ),
            );
          }
        }

        await _printLine();

        final totalValue =
            summary?.total != null
                ? CurrencyFormatter.formatPriceFromDouble(summary!.total!)
                : (payment.amount != null
                    ? CurrencyFormatter.formatPriceFromDouble(payment.amount!)
                    : '');
        if (totalValue.isNotEmpty && totalValue != '0') {
          final int totalWidthForFontSize25 = _getTotalWidth() == 48 ? 38 : 30;
          await SunmiPrinter.printText(
            _formatLabelValue(
              '${TranslationKeys.total.tr}:',
              totalValue,
              totalWidth: totalWidthForFontSize25,
            ),
            style: SunmiTextStyle(
              align: SunmiPrintAlign.LEFT,
              fontSize: _fontSizeTotal,
              bold: true,
            ),
          );
        }

        await _printSep();
        await _printLine();
        await SunmiPrinter.printText(
          TranslationKeys.thankYouForVisit.tr,
          style: SunmiTextStyle(align: SunmiPrintAlign.CENTER),
        );
        await _printSep();
        await _printLine();

        final method = (payment.paymentMethod ?? '').toLowerCase();
        final isOnline =
            method.contains('stripe') ||
            method.contains('multisafepay') ||
            method.contains('online') ||
            method.contains('card');

        if (isOnline) {
          await SunmiPrinter.printText(
            '💳 ${TranslationKeys.onlinePayment.tr}',
            style: SunmiTextStyle(
              align: SunmiPrintAlign.CENTER,
              fontSize: _fontSizeBody,
              bold: true,
            ),
          );
          await SunmiPrinter.printText(
            TranslationKeys.customerPaidOnline.tr,
            style: SunmiTextStyle(
              align: SunmiPrintAlign.CENTER,
              fontSize: _fontSizeSmall,
            ),
          );
        } else {
          final paymentAmount =
              payment.amount != null
                  ? CurrencyFormatter.formatPriceFromDouble(payment.amount!)
                  : CurrencyFormatter.formatPrice('0');
          await SunmiPrinter.printText(
            '💵 ${TranslationKeys.cashPayment.tr}',
            style: SunmiTextStyle(
              align: SunmiPrintAlign.CENTER,
              fontSize: _fontSizeBody,
              bold: true,
            ),
          );
          await SunmiPrinter.printText(
            '${TranslationKeys.amountPaid.tr}: $paymentAmount',
            style: SunmiTextStyle(
              align: SunmiPrintAlign.CENTER,
              fontSize: _fontSizeSmall,
            ),
          );
        }
        await _printSep();
        await _printSep();
        await SunmiPrinter.cutPaper();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> printKOT(KitchenTicket ticket, {int copies = 1}) async {
    try {
      final int totalWidth = _getTotalWidth(isKitchen: true);
      final order = ticket.order;
      final items = ticket.items;

      for (int i = 0; i < copies; i++) {
        await SunmiPrinter.printText(
          TranslationKeys.kitchenOrderTicket.tr,
          style: SunmiTextStyle(
            align: SunmiPrintAlign.CENTER,
            fontSize: _fontSizeTitle,
            bold: false,
          ),
        );
        await _printSep();

        String orderPart =
            '${TranslationKeys.order.tr}: ${order?.orderNumber ?? ticket.kotNumber ?? ''}';
        String tablePart = '';
        if (order?.table != null) {
          if (order!.table is Map) {
            tablePart = order.table['table_code'] ?? order.table['name'] ?? '';
          } else {
            tablePart = order.table.toString();
          }
        }

        if (tablePart.isNotEmpty) {
          await SunmiPrinter.printText(
            _formatLabelValue(
              orderPart,
              '${TranslationKeys.table.tr}: $tablePart',
              totalWidth: totalWidth - 4,
            ),
            style: SunmiTextStyle(
              align: SunmiPrintAlign.LEFT,
              fontSize: _fontSizeSub,
              bold: false,
            ),
          );
        } else {
          await SunmiPrinter.printText(
            orderPart,
            style: SunmiTextStyle(
              align: SunmiPrintAlign.CENTER,
              fontSize: _fontSizeTotal,
              bold: false,
            ),
          );
        }
        await _printSep();

        final dateStr =
            ticket.createdAt != null
                ? DateTimeFormatter.formatDateOnly(ticket.createdAt!)
                : '';
        final timeStr =
            ticket.createdAt != null
                ? DateTimeFormatter.formatTimeOnly(ticket.createdAt!)
                : '';

        if (dateStr.isNotEmpty && timeStr.isNotEmpty) {
          await SunmiPrinter.printText(
            _formatLabelValue(
              '${TranslationKeys.date.tr}: $dateStr',
              '${TranslationKeys.time.tr}: $timeStr',
              totalWidth: totalWidth - 4,
            ),
            style: SunmiTextStyle(
              align: SunmiPrintAlign.LEFT,
              fontSize: _fontSizeSub,
            ),
          );
          await _printSep();
        } else if (dateStr.isNotEmpty) {
          await SunmiPrinter.printText(
            dateStr,
            style: SunmiTextStyle(
              align: SunmiPrintAlign.CENTER,
              fontSize: _fontSizeSub,
            ),
          );
          await _printSep();
        } else if (timeStr.isNotEmpty) {
          await SunmiPrinter.printText(
            timeStr,
            style: SunmiTextStyle(
              align: SunmiPrintAlign.CENTER,
              fontSize: _fontSizeSub,
            ),
          );
          await _printSep();
        }

        await SunmiPrinter.lineWrap(2);

        // Header
        await SunmiPrinter.printText(
          _formatLabelValue(
            TranslationKeys.itemName.tr,
            TranslationKeys.qty.tr,
            totalWidth: totalWidth,
          ),
          style: SunmiTextStyle(
            align: SunmiPrintAlign.LEFT,
            fontSize: _fontSizeBody,
            bold: false,
          ),
        );
        await _printSep();
        await _printSep();
        await SunmiPrinter.printText(_getLineSeparator(isKitchen: true));
        await _printSep();

        if (items != null && items.isNotEmpty) {
          for (final item in items) {
            final itemName = item.itemName ?? '';
            final qty = item.quantity?.toString() ?? '1';

            // Print name and qty
            await _printLabelValue(itemName, qty, totalWidth: totalWidth);
            await _printSep();

            if (item.variationName != null && item.variationName!.isNotEmpty) {
              await SunmiPrinter.printText(
                '  (${item.variationName})',
                style: SunmiTextStyle(
                  align: SunmiPrintAlign.LEFT,
                  fontSize: _fontSizeSmall,
                ),
              );
              await _printSep();
            }

            if (item.modifiers != null && item.modifiers!.isNotEmpty) {
              for (final mod in item.modifiers!) {
                await SunmiPrinter.printText(
                  '  • ${mod.name ?? ''}',
                  style: SunmiTextStyle(
                    align: SunmiPrintAlign.LEFT,
                    fontSize: _fontSizeSmall,
                  ),
                );
                await _printSep();
              }
            }

            if (item.note != null && item.note!.isNotEmpty) {
              await SunmiPrinter.printText(
                '  ${TranslationKeys.note.tr}: ${item.note!}',
                style: SunmiTextStyle(
                  align: SunmiPrintAlign.LEFT,
                  fontSize: _fontSizeSmall,
                ),
              );
              await _printSep();
            }

            await SunmiPrinter.printText(_getLineSeparator(isKitchen: true));
            await _printSep();
          }
        }

        final orderNote = ticket.note ?? ticket.order?.note;
        if (orderNote != null && orderNote.isNotEmpty) {
          await SunmiPrinter.lineWrap(1);
          await SunmiPrinter.printText(
            '${TranslationKeys.note.tr}: $orderNote',
            style: SunmiTextStyle(
              align: SunmiPrintAlign.LEFT,
              fontSize: _fontSizeBody,
              bold: false,
            ),
          );
          await _printSep();
        }

        await SunmiPrinter.lineWrap(2);
        await SunmiPrinter.cutPaper();
      }
    } catch (e) {
      rethrow;
    }
  }

  String? _receiptCustomerName(dynamic customer) {
    if (customer == null) return null;
    if (customer is Map<String, dynamic>) {
      return customer['name']?.toString();
    }
    return customer.toString();
  }

  /// Extract phone from receipt customer (dynamic/Map) and format with +.
  String? _receiptPhoneWithPlus(dynamic customer) {
    if (customer == null) return null;
    String? code;
    String? num;
    if (customer is Map<String, dynamic>) {
      code = customer['phone_code']?.toString().trim();
      num = customer['phone_number']?.toString().trim();
    }
    if (num == null || num.isEmpty) return null;
    return _formatPhoneWithPlus(code, num);
  }

  Future<void> printKOTFromOrder(
    order_model.Data data, {
    int copies = 1,
  }) async {
    final int totalWidth = _getTotalWidth(isKitchen: true);
    final order = data.order;
    if (order == null || order.items == null || order.items!.isEmpty) return;

    for (int i = 0; i < copies; i++) {
      await SunmiPrinter.printText(
        TranslationKeys.kitchenOrderTicket.tr,
        style: SunmiTextStyle(
          align: SunmiPrintAlign.CENTER,
          fontSize: _fontSizeTitle,
          bold: true,
        ),
      );
      await _printSep();

      String orderPart =
          '${TranslationKeys.order.tr}: ${order.formattedOrderNumber ?? order.orderNumber ?? ''}';
      String tablePart = '';
      if (order.table?.tableCode != null &&
          order.table!.tableCode!.isNotEmpty) {
        tablePart = '${TranslationKeys.table.tr}: ${order.table!.tableCode}';
      }

      if (tablePart.isNotEmpty) {
        await SunmiPrinter.printText(
          _formatLabelValue(orderPart, tablePart, totalWidth: totalWidth - 4),
          style: SunmiTextStyle(
            align: SunmiPrintAlign.LEFT,
            fontSize: _fontSizeSub,
            bold: false,
          ),
        );
      } else {
        await _printCenteredSub(orderPart);
      }

      final dateStr =
          order.createdAt != null
              ? DateTimeFormatter.formatDateOnly(order.createdAt!)
              : '';
      final timeStr =
          order.createdAt != null
              ? DateTimeFormatter.formatTimeOnly(order.createdAt!)
              : '';

      if (dateStr.isNotEmpty && timeStr.isNotEmpty) {
        await SunmiPrinter.printText(
          _formatLabelValue(
            '${TranslationKeys.date.tr}: $dateStr',
            '${TranslationKeys.time.tr}: $timeStr',
            totalWidth: totalWidth - 4,
          ),
          style: SunmiTextStyle(
            align: SunmiPrintAlign.LEFT,
            fontSize: _fontSizeSub,
            bold: false,
          ),
        );
      } else if (dateStr.isNotEmpty) {
        await _printCenteredSub('${TranslationKeys.date.tr}: $dateStr');
      } else if (timeStr.isNotEmpty) {
        await _printCenteredSub('${TranslationKeys.time.tr}: $timeStr');
      }

      await _printLine(isKitchen: true);
      await SunmiPrinter.printText(
        _formatLabelValue(
          TranslationKeys.itemName.tr,
          TranslationKeys.qty.tr,
          totalWidth: totalWidth,
        ),
        style: SunmiTextStyle(
          align: SunmiPrintAlign.LEFT,
          fontSize: _fontSizeBody,
        ),
      );
      await _printLine(isKitchen: true);

      for (final item in order.items!) {
        final itemName = item.itemName ?? '';
        final qty = item.quantity?.toString() ?? '1';
        await _printLabelValue(itemName, qty, totalWidth: totalWidth);

        if (item.variationName != null && item.variationName!.isNotEmpty) {
          await _printLeftBody('  (${item.variationName})');
        }

        if (item.modifiers != null && item.modifiers!.isNotEmpty) {
          for (final mod in item.modifiers!) {
            await _printLeftBody('  \u2022 ${mod.name ?? ''}');
          }
        }

        if (item.note != null && item.note!.isNotEmpty) {
          await _printLeftBody('  ${TranslationKeys.note.tr}: ${item.note}');
        }
        await _printLine(isKitchen: true);
      }

      if (order.note != null && order.note!.isNotEmpty) {
        await _printLeftBody('${TranslationKeys.note.tr}: ${order.note}');
      }

      await SunmiPrinter.lineWrap(5);
      await SunmiPrinter.cutPaper();
    }
  }
}
