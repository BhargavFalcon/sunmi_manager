import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:image/image.dart' as img;
import 'package:get/get.dart';
import 'package:managerapp/main.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../constants/api_constants.dart';
import '../constants/translation_keys.dart';
import '../model/get_order_model.dart' as order_model;
import '../model/receipt_order_response_model.dart';
import '../model/kitchen_ticket_model.dart';
import '../model/wifi_printer_model.dart';
import 'package:intl/intl.dart';
import '../services/printer_service.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_time_formatter.dart';

class EscPosInvoicePrinterService {
  static final Dio _dio = Dio();

  static const Map<String, String> _currencyFallback = {
    '\u20B9': 'Rs',
    '\u20BA': 'TL',
    '\u20BD': 'RUB',
    '\u20A9': 'W',
    '\u20B1': 'PHP',
    '\u20B4': 'UAH',
    '\u20AB': 'D',
    '\u20B5': 'GHS',
    '\u20A1': 'CRC',
    '\u20B2': 'PYG',
    '\u20A6': 'NGN',
    '\u20A8': 'Rs',
    '\u20AA': 'ILS',
    '\u20AE': 'MNT',
    '\u20B3': 'VEF',
    '\u20A3': 'F',
    '\u20A4': 'L',
    '\u20A7': 'Pts',
  };

  String _escCurrency(String text) {
    String result = text.replaceAll('\u20AC', '\u00D5');
    for (final entry in _currencyFallback.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }
    return result;
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

  String _formatPhoneWithPlus(String? phoneCode, String? phoneNumber) {
    final code = phoneCode?.trim() ?? '';
    final num = phoneNumber?.trim() ?? '';
    if (num.isEmpty) return '';
    if (code.isEmpty) return num.startsWith('+') ? num : '+$num';
    final plusCode = code.startsWith('+') ? code : '+$code';
    return '$plusCode $num';
  }

  PaperSize _getPaperSize({bool isKitchen = false}) {
    final printerService = Get.find<PrinterService>();
    String width =
        isKitchen
            ? printerService.kitchenWidth.value
            : printerService.receiptWidth.value;

    // If Bluetooth is not available, use WiFi printer's paper width fallback
    if (printerService.connectedDevice == null ||
        !printerService.isConnected.value) {
      final wifiJson = box.read(ArgumentConstant.savedWifiPrintersKey);
      if (wifiJson != null && wifiJson is String) {
        try {
          final List<dynamic> decoded = jsonDecode(wifiJson);
          final printers =
              decoded.map((e) => WifiPrinterModel.fromJson(e)).toList();
          final printer = printers.firstWhereOrNull((p) => p.isDefault);
          if (printer != null) {
            width = printer.paperWidth;
          }
        } catch (_) {}
      }
    }

    switch (width) {
      case '80mm':
        return PaperSize.mm80;
      default:
        return PaperSize.mm58;
    }
  }

  Future<Generator> _getGenerator({bool isKitchen = false}) async {
    final profile = await CapabilityProfile.load();
    return Generator(_getPaperSize(isKitchen: isKitchen), profile);
  }

  Future<void> _sendBytes(List<int> bytes, {String? printerName}) async {
    final printerService = Get.find<PrinterService>();

    // 1) If a specific printer name is provided, try to find and connect to it
    if (printerName != null && printerName.isNotEmpty) {
      // 1a) Check if it's the current Bluetooth printer
      if (printerService.connectedDevice != null &&
          printerService.connectedDevice!.name == printerName) {
        try {
          bool isConnected = await PrintBluetoothThermal.connectionStatus;
          if (!isConnected) {
            isConnected = await PrintBluetoothThermal.connect(
              macPrinterAddress: printerService.connectedDevice!.macAdress,
            );
            printerService.isConnected.value = isConnected;
          }
          if (isConnected) {
            await PrintBluetoothThermal.writeBytes(bytes);
            return;
          }
        } catch (_) {}
      }

      // 1b) Check if it's a saved WiFi printer
      final wifiJson = box.read(ArgumentConstant.savedWifiPrintersKey);
      if (wifiJson != null && wifiJson is String) {
        try {
          final List<dynamic> decoded = jsonDecode(wifiJson);
          final printers =
              decoded.map((e) => WifiPrinterModel.fromJson(e)).toList();
          final printer = printers.firstWhereOrNull(
            (p) => p.name == printerName,
          );
          if (printer != null) {
            final socket = await Socket.connect(
              printer.ipAddress,
              int.tryParse(printer.port) ?? 9100,
              timeout: const Duration(seconds: 5),
            );
            socket.add(bytes);
            await socket.flush();
            socket.destroy();
            return;
          }
        } catch (_) {}
      }
    }

    // 2) Fallback logic if no printerName or targeting failed
    // Try Bluetooth first
    if (printerService.connectedDevice != null) {
      try {
        bool isConnected = printerService.isConnected.value;
        if (isConnected) {
          isConnected = await PrintBluetoothThermal.connectionStatus;
        }
        if (!isConnected) {
          isConnected = await PrintBluetoothThermal.connect(
            macPrinterAddress: printerService.connectedDevice!.macAdress,
          );
          printerService.isConnected.value = isConnected;
        }
        if (isConnected) {
          await PrintBluetoothThermal.writeBytes(bytes);
          return;
        }
      } catch (_) {}
    }

    // Try WiFi default fallback
    final wifiJson = box.read(ArgumentConstant.savedWifiPrintersKey);
    if (wifiJson != null && wifiJson is String) {
      final List<dynamic> decoded = jsonDecode(wifiJson);
      final printers =
          decoded.map((e) => WifiPrinterModel.fromJson(e)).toList();
      final printer = printers.firstWhereOrNull((p) => p.isDefault);
      if (printer != null) {
        final socket = await Socket.connect(
          printer.ipAddress,
          int.tryParse(printer.port) ?? 9100,
          timeout: const Duration(seconds: 5),
        );
        socket.add(bytes);
        await socket.flush();
        socket.destroy();
        return;
      }
    }

    throw Exception('No printer connected');
  }

  String? _receiptCustomerName(dynamic customer) {
    if (customer == null) return null;
    if (customer is Map<String, dynamic>) {
      return customer['name']?.toString();
    }
    return customer.toString();
  }

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

  Future<img.Image?> _downloadNetworkImage(String imageUrl) async {
    try {
      final response = await _dio.get<Uint8List>(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == 200 && response.data != null) {
        final image = img.decodeImage(response.data!);
        if (image != null) {
          return img.copyResize(
            image,
            width: 150,
            maintainAspect: true,
            interpolation: img.Interpolation.cubic,
          );
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> printInvoice(order_model.Data data, {int copies = 1}) async {
    try {
      final restaurant = data.restaurant;
      final branch = data.branch;
      final order = data.order;
      if (order == null) return;

      final logoUrl = restaurant?.logoUrl ?? data.imageUrl;
      final qrCodeUrl = data.receiptSettings?.paymentQrCodeUrl;

      final gen = await _getGenerator();
      final is58mm = _getPaperSize() == PaperSize.mm58;
      final b = PosStyles(
        align: is58mm ? PosAlign.center : PosAlign.left,
        fontType: PosFontType.fontB,
      );
      const c = PosStyles(align: PosAlign.center, fontType: PosFontType.fontB);
      const r = PosStyles(align: PosAlign.right, fontType: PosFontType.fontB);

      List<int> item(String qty, String name, String price, String amount) {
        return gen.row([
          PosColumn(text: qty, width: 2, styles: b),
          PosColumn(text: _escCurrency(name), width: 5, styles: b),
          PosColumn(text: _escCurrency(price), width: 3, styles: r),
          PosColumn(text: _escCurrency(amount), width: 2, styles: r),
        ]);
      }

      List<int> summary(String label, String amount) {
        return gen.row([
          PosColumn(text: _escCurrency(label), width: 9, styles: b),
          PosColumn(text: _escCurrency(amount), width: 3, styles: r),
        ]);
      }

      for (int copy = 0; copy < copies; copy++) {
        List<int> bytes = [];
        bytes += [0x1B, 0x74, 19];

        if (logoUrl != null && logoUrl.isNotEmpty) {
          final logoImage = await _downloadNetworkImage(logoUrl);
          if (logoImage != null) {
            bytes += gen.image(logoImage, align: PosAlign.center);
          }
        }

        bytes += gen.text(
          restaurant?.name ?? TranslationKeys.restaurant.tr,
          styles: const PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ),
        );

        if (branch?.address != null && branch!.address!.trim().isNotEmpty) {
          bytes += gen.text(branch.address!, styles: c);
        }
        bytes += gen.hr(ch: '-');

        final orderNum = order.formattedOrderNumber ?? TranslationKeys.na.tr;
        final formattedDt = _formatDateTimeString(order.dateTime);
        bytes += gen.row([
          PosColumn(
            text: '${TranslationKeys.order.tr}: $orderNum',
            width: 6,
            styles: b,
          ),
          PosColumn(text: formattedDt, width: 6, styles: r),
        ]);

        final tableCode =
            order.table?.tableCode != null && order.table!.tableCode!.isNotEmpty
                ? order.table!.tableCode!
                : null;
        final pax = order.numberOfPax;
        final hasTable = tableCode != null;
        final hasPax = pax != null && pax > 0;
        if (hasTable && hasPax) {
          bytes += gen.row([
            PosColumn(
              text: '${TranslationKeys.tableNo.tr}: $tableCode',
              width: 6,
              styles: b,
            ),
            PosColumn(
              text: '${TranslationKeys.pax.tr}: $pax',
              width: 6,
              styles: r,
            ),
          ]);
        } else if (hasTable) {
          bytes += gen.text(
            '${TranslationKeys.tableNo.tr}: $tableCode',
            styles: b,
          );
        } else if (hasPax) {
          bytes += gen.text('${TranslationKeys.pax.tr}: $pax', styles: r);
        }

        if (order.waiter?.name != null && order.waiter!.name!.isNotEmpty) {
          bytes += gen.text(
            '${TranslationKeys.waiter.tr}: ${order.waiter!.name}',
            styles: b,
          );
        }

        if (order.customer?.name != null) {
          bytes += gen.text(
            '${TranslationKeys.customer.tr}: ${order.customer!.name}',
            styles: b,
          );
        }

        final phoneStr = _formatPhoneWithPlus(
          order.customer?.phoneCode,
          order.customer?.phoneNumber,
        );
        if (phoneStr.isNotEmpty) {
          bytes += gen.text(
            '${TranslationKeys.phone.tr}: $phoneStr',
            styles: b,
          );
        }
        if (order.deliveryAddress != null &&
            order.deliveryAddress!.trim().isNotEmpty) {
          bytes += gen.text(
            '${TranslationKeys.address.tr}: ${order.deliveryAddress}',
            styles: b,
          );
        }

        bytes += gen.hr(ch: '-');

        bytes += gen.row([
          PosColumn(text: TranslationKeys.qty.tr, width: 2, styles: b),
          PosColumn(text: TranslationKeys.itemName.tr, width: 5, styles: b),
          PosColumn(text: TranslationKeys.price.tr, width: 2, styles: r),
          PosColumn(text: TranslationKeys.amount.tr, width: 3, styles: r),
        ]);
        bytes += gen.hr(ch: '-');

        if (order.items?.isNotEmpty == true) {
          for (final orderItem in order.items!) {
            final qty = orderItem.quantity?.toString() ?? '0';
            final itemName = orderItem.itemName ?? TranslationKeys.na.tr;
            final price = _formatPrice(null, orderItem.price);
            final amount = _formatPrice(null, orderItem.amount);
            bytes += item(qty, itemName, price, amount);

            if (orderItem.variationName?.isNotEmpty == true) {
              bytes += gen.text('    (${orderItem.variationName})', styles: b);
            }

            if (orderItem.modifiers?.isNotEmpty == true) {
              for (final modifier in orderItem.modifiers!) {
                final modPrice = _formatPrice(null, modifier.price);
                bytes += gen.text(
                  _escCurrency(
                    '    \u2022 ${modifier.name ?? ''} (+$modPrice)',
                  ),
                  styles: b,
                );
              }
            }
          }
        }

        if (order.totals?.subTotal != null) {
          bytes += summary(
            '${TranslationKeys.subTotal.tr}:',
            _formatPrice(null, order.totals!.subTotal?.toDouble()),
          );
        }

        final hasDiscount =
            order.discountValue != null &&
            order.discountValue! > 0 &&
            order.totals?.discountAmount != null &&
            order.totals!.discountAmount! > 0;
        if (hasDiscount) {
          bytes += summary(
            TranslationKeys.discount.tr,
            '-${_formatPrice(null, order.totals!.discountAmount)}',
          );
        }

        if (order.charges?.isNotEmpty == true) {
          for (final charge in order.charges!) {
            bytes += summary(
              '${charge.chargeName ?? ''}:',
              _formatPrice(null, charge.amount),
            );
          }
        }

        if (order.totals?.tipAmount != null && order.totals!.tipAmount! > 0) {
          bytes += summary(
            '${TranslationKeys.tip.tr}:',
            _formatPrice(null, order.totals!.tipAmount),
          );
        }

        if (order.items?.isNotEmpty == true) {
          final aggregatedTaxes = _aggregateTaxes(order.items!, data.taxes);
          for (final entry in aggregatedTaxes.entries) {
            final taxName = entry.key;
            final taxData = entry.value;
            final taxAmount = taxData['amount'] as double?;
            final taxPercent = taxData['percent'] as String?;
            final formattedTax = _formatPrice(null, taxAmount);
            final taxLabel =
                taxPercent?.isNotEmpty == true
                    ? '$taxName ($taxPercent%) incl.'
                    : '$taxName incl.';
            bytes += summary(taxLabel, formattedTax);
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
            bytes += summary(
              '${TranslationKeys.balanceReturned.tr}:',
              _formatPrice(null, balance),
            );
          }
        }

        bytes += gen.hr(ch: '-');

        final totalValue = _formatPrice(null, order.totals?.total);
        bytes += gen.row([
          PosColumn(text: '${TranslationKeys.total.tr}:', width: 6, styles: b),
          PosColumn(text: _escCurrency(totalValue), width: 6, styles: r),
        ]);
        bytes += gen.hr(ch: '-');

        bytes += gen.text(TranslationKeys.thankYouForVisit.tr, styles: c);

        if (qrCodeUrl != null && qrCodeUrl.isNotEmpty) {
          final qrImage = await _downloadNetworkImage(qrCodeUrl);
          if (qrImage != null) {
            bytes += gen.text(
              TranslationKeys.payFromYourPhone.tr.toUpperCase(),
              styles: c,
            );
            bytes += gen.image(qrImage, align: PosAlign.center);
            bytes += gen.text(TranslationKeys.scanQrCodeToPay.tr, styles: c);
          }
        }

        bytes += gen.hr(ch: '-');

        if (order.payments?.isNotEmpty == true) {
          bytes += gen.row([
            PosColumn(text: TranslationKeys.amount.tr, width: 2, styles: b),
            PosColumn(
              text: TranslationKeys.paymentMethod.tr,
              width: 6,
              styles: c,
            ),
            PosColumn(
              text: TranslationKeys.dateAndTime.tr,
              width: 4,
              styles: r,
            ),
          ]);
          bytes += gen.hr(ch: '-');

          for (final payment in order.payments!) {
            final paymentAmount = _formatPrice(null, payment.amount);
            final paymentMethod =
                payment.paymentMethod ?? TranslationKeys.cash.tr;
            final time = _formatDateTimeString(
              payment.createdAt ?? order.dateTime,
              data.restaurant?.timezone,
            );
            bytes += gen.row([
              PosColumn(text: _escCurrency(paymentAmount), width: 3, styles: b),
              PosColumn(text: paymentMethod, width: 2, styles: c),
              PosColumn(text: time, width: 7, styles: r),
            ]);
          }
        }

        bytes += gen.feed(0);
        bytes += gen.cut();

        final printerName = box.read(
          ArgumentConstant.selectedReceiptPrinterKey,
        );
        await _sendBytes(bytes, printerName: printerName);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> printReceiptFromApi(ReceiptOrderData d, {int copies = 1}) async {
    try {
      final restaurant = d.restaurant;
      final branch = d.branch;
      final order = d.order;
      final receiptSummary = d.summary;
      final payment = d.payment;
      final items = d.receiptItems;
      final timezone = restaurant?.timezone;

      if (order == null || payment == null) return;

      final gen = await _getGenerator();
      final is58mm = _getPaperSize() == PaperSize.mm58;
      final b = PosStyles(
        align: is58mm ? PosAlign.center : PosAlign.left,
        fontType: PosFontType.fontB,
      );
      const c = PosStyles(align: PosAlign.center, fontType: PosFontType.fontB);
      const r = PosStyles(align: PosAlign.right, fontType: PosFontType.fontB);

      List<int> item(String qty, String name, String price, String amount) {
        return gen.row([
          PosColumn(text: qty, width: 2, styles: b),
          PosColumn(text: _escCurrency(name), width: 5, styles: b),
          PosColumn(text: _escCurrency(price), width: 3, styles: r),
          PosColumn(text: _escCurrency(amount), width: 2, styles: r),
        ]);
      }

      List<int> summary(String label, String amount) {
        return gen.row([
          PosColumn(text: _escCurrency(label), width: 8, styles: b),
          PosColumn(text: _escCurrency(amount), width: 4, styles: r),
        ]);
      }

      for (int copy = 0; copy < copies; copy++) {
        List<int> bytes = [];
        bytes += [0x1B, 0x74, 19];

        bytes += gen.text(
          restaurant?.name ?? TranslationKeys.restaurant.tr,
          styles: const PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ),
        );

        if (branch?.address != null && branch!.address!.trim().isNotEmpty) {
          bytes += gen.text(branch.address!, styles: c);
        }
        bytes += gen.hr(ch: '-');

        final orderNum = order.formattedOrderNumber ?? TranslationKeys.na.tr;
        final formattedDt = _formatDateTimeString(order.dateTime);
        bytes += gen.row([
          PosColumn(
            text: '${TranslationKeys.order.tr}: $orderNum',
            width: 6,
            styles: b,
          ),
          PosColumn(text: formattedDt, width: 6, styles: r),
        ]);

        final tableCode =
            order.table?.tableCode != null && order.table!.tableCode!.isNotEmpty
                ? order.table!.tableCode!
                : null;
        final pax = order.numberOfPax;
        final hasTable = tableCode != null;
        final hasPax = pax != null && pax > 0;
        if (hasTable && hasPax) {
          bytes += gen.row([
            PosColumn(
              text: '${TranslationKeys.tableNo.tr}: $tableCode',
              width: 6,
              styles: b,
            ),
            PosColumn(
              text: '${TranslationKeys.pax.tr}: $pax',
              width: 6,
              styles: r,
            ),
          ]);
        } else if (hasTable) {
          bytes += gen.text(
            '${TranslationKeys.tableNo.tr}: $tableCode',
            styles: b,
          );
        } else if (hasPax) {
          bytes += gen.text('${TranslationKeys.pax.tr}: $pax', styles: r);
        }

        if (order.waiter?.name != null && order.waiter!.name!.isNotEmpty) {
          bytes += gen.text(
            '${TranslationKeys.waiter.tr}: ${order.waiter!.name}',
            styles: b,
          );
        }

        final customerName = _receiptCustomerName(order.customer);
        if (customerName != null && customerName.isNotEmpty) {
          bytes += gen.text(
            '${TranslationKeys.customer.tr}: $customerName',
            styles: b,
          );
        }

        final phoneFormatted = _receiptPhoneWithPlus(order.customer);
        if (phoneFormatted != null && phoneFormatted.isNotEmpty) {
          bytes += gen.text(
            '${TranslationKeys.phone.tr}: $phoneFormatted',
            styles: b,
          );
        }
        if (order.deliveryAddress != null &&
            order.deliveryAddress!.trim().isNotEmpty) {
          bytes += gen.text(
            '${TranslationKeys.address.tr}: ${order.deliveryAddress}',
            styles: b,
          );
        }

        bytes += gen.hr(ch: '-');

        bytes += gen.row([
          PosColumn(text: TranslationKeys.qty.tr, width: 2, styles: b),
          PosColumn(text: TranslationKeys.itemName.tr, width: 5, styles: b),
          PosColumn(text: TranslationKeys.price.tr, width: 3, styles: r),
          PosColumn(text: TranslationKeys.amount.tr, width: 2, styles: r),
        ]);
        bytes += gen.hr(ch: '-');

        if (items != null && items.isNotEmpty) {
          for (final entry in items) {
            final oi = entry.orderItem;
            if (oi == null) continue;
            final qty =
                entry.quantity?.toString() ?? oi.quantity?.toString() ?? '0';
            final itemName = oi.displayItemName ?? TranslationKeys.na.tr;
            final price =
                oi.formattedPrice ??
                CurrencyFormatter.formatPriceFromDouble(oi.amount ?? 0);
            final amount =
                oi.formattedLineAmount ??
                CurrencyFormatter.formatPriceFromDouble(
                  (oi.amount ?? 0) * (oi.quantity ?? 1),
                );

            bytes += item(qty, itemName, price, amount);

            if (oi.displayVariationName != null &&
                oi.displayVariationName!.isNotEmpty) {
              bytes += gen.text('    (${oi.displayVariationName})', styles: b);
            }

            if (oi.displayModifiers != null &&
                oi.displayModifiers!.isNotEmpty) {
              for (final m in oi.displayModifiers!) {
                final modPrice = m.price ?? '';
                bytes += gen.text(
                  _escCurrency(
                    '    \u2022 ${m.name ?? ''}${modPrice.isNotEmpty ? ' (+$modPrice)' : ''}',
                  ),
                  styles: b,
                );
              }
            }
          }
        }

        if (receiptSummary != null) {
          if (receiptSummary.subTotal != null) {
            bytes += summary(
              '${TranslationKeys.subTotal.tr}:',
              CurrencyFormatter.formatPriceFromDouble(receiptSummary.subTotal!),
            );
          }

          if (receiptSummary.discount != null && receiptSummary.discount! > 0) {
            bytes += summary(
              TranslationKeys.discount.tr,
              '-${CurrencyFormatter.formatPriceFromDouble(receiptSummary.discount!)}',
            );
          }

          if (receiptSummary.tip != null && receiptSummary.tip! > 0) {
            bytes += summary(
              '${TranslationKeys.tip.tr}:',
              CurrencyFormatter.formatPriceFromDouble(receiptSummary.tip!),
            );
          }

          if (receiptSummary.taxes != null &&
              receiptSummary.taxes!.isNotEmpty) {
            for (final t in receiptSummary.taxes!) {
              final label =
                  t.isInclusive == true && t.percent != null
                      ? '${t.name ?? ''} (${t.percent}%) incl.'
                      : (t.name ?? '');
              final val =
                  t.amount != null
                      ? CurrencyFormatter.formatPriceFromDouble(t.amount!)
                      : '';
              if (label.isNotEmpty && val.isNotEmpty) {
                bytes += summary(label, val);
              }
            }
          }

          if (payment.balance != null && payment.balance! > 0) {
            bytes += summary(
              '${TranslationKeys.balanceReturned.tr}:',
              CurrencyFormatter.formatPriceFromDouble(payment.balance!),
            );
          }
        }

        bytes += gen.hr(ch: '-');

        final totalValue =
            receiptSummary?.total != null
                ? CurrencyFormatter.formatPriceFromDouble(
                  receiptSummary!.total!,
                )
                : (payment.amount != null
                    ? CurrencyFormatter.formatPriceFromDouble(payment.amount!)
                    : '');
        bytes += gen.row([
          PosColumn(text: '${TranslationKeys.total.tr}:', width: 6, styles: b),
          PosColumn(text: _escCurrency(totalValue), width: 6, styles: r),
        ]);
        bytes += gen.hr(ch: '-');

        bytes += gen.text(TranslationKeys.thankYouForVisit.tr, styles: c);
        bytes += gen.hr(ch: '-');

        final paymentAmount =
            payment.amount != null
                ? CurrencyFormatter.formatPriceFromDouble(payment.amount!)
                : CurrencyFormatter.formatPrice('0');
        final paymentMethod = payment.paymentMethod ?? TranslationKeys.cash.tr;
        final formattedPaymentTime = _formatDateTimeString(
          payment.createdAt ?? order.dateTime,
          timezone,
        );

        bytes += gen.row([
          PosColumn(text: TranslationKeys.amount.tr, width: 2, styles: b),
          PosColumn(
            text: TranslationKeys.paymentMethod.tr,
            width: 6,
            styles: c,
          ),
          PosColumn(text: TranslationKeys.dateAndTime.tr, width: 4, styles: r),
        ]);
        bytes += gen.hr(ch: '-');

        bytes += gen.row([
          PosColumn(text: _escCurrency(paymentAmount), width: 3, styles: b),
          PosColumn(text: paymentMethod, width: 2, styles: c),
          PosColumn(text: formattedPaymentTime, width: 7, styles: r),
        ]);

        bytes += gen.feed(0);
        bytes += gen.cut();

        final printerName = box.read(
          ArgumentConstant.selectedReceiptPrinterKey,
        );
        await _sendBytes(bytes, printerName: printerName);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> printKOT(KitchenTicket ticket, {int copies = 1}) async {
    try {
      final order = ticket.order;
      final items = ticket.items;

      final gen = await _getGenerator(isKitchen: true);
      const b = PosStyles(align: PosAlign.left, fontType: PosFontType.fontB);
      const bb = PosStyles(
        align: PosAlign.left,
        fontType: PosFontType.fontB,
        bold: false,
      );
      const c = PosStyles(align: PosAlign.center, fontType: PosFontType.fontB);
      const r = PosStyles(align: PosAlign.right, fontType: PosFontType.fontB);

      for (int i = 0; i < copies; i++) {
        List<int> bytes = [];
        bytes += [0x1B, 0x74, 19];

        bytes += gen.text(
          TranslationKeys.kitchenOrderTicket.tr,
          styles: const PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
            bold: false,
          ),
        );
        bytes += gen.feed(1);

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
          bytes += gen.row([
            PosColumn(
              text: orderPart,
              width: 7,
              styles: const PosStyles(
                align: PosAlign.left,
                height: PosTextSize.size2,
                width: PosTextSize.size1,
                bold: true,
              ),
            ),
            PosColumn(
              text: '${TranslationKeys.table.tr}: $tablePart',
              width: 5,
              styles: const PosStyles(
                align: PosAlign.right,
                height: PosTextSize.size2,
                width: PosTextSize.size1,
                bold: true,
              ),
            ),
          ]);
        } else {
          bytes += gen.text(
            orderPart,
            styles: const PosStyles(
              align: PosAlign.center,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              bold: false,
            ),
          );
        }
        bytes += gen.feed(1);

        final dateStr =
            ticket.createdAt != null
                ? DateFormat(
                  'dd-MM-yyyy',
                ).format(DateTime.parse(ticket.createdAt!))
                : '';
        final timeStr =
            ticket.createdAt != null
                ? DateFormat(
                  'hh:mm a',
                ).format(DateTime.parse(ticket.createdAt!))
                : '';

        if (dateStr.isNotEmpty && timeStr.isNotEmpty) {
          bytes += gen.row([
            PosColumn(
              text: '${TranslationKeys.date.tr}: $dateStr',
              width: 6,
              styles: b,
            ),
            PosColumn(
              text: '${TranslationKeys.time.tr}: $timeStr',
              width: 6,
              styles: r,
            ),
          ]);
        } else if (dateStr.isNotEmpty) {
          bytes += gen.text('${TranslationKeys.date.tr}: $dateStr', styles: c);
        } else if (timeStr.isNotEmpty) {
          bytes += gen.text('${TranslationKeys.time.tr}: $timeStr', styles: c);
        }

        bytes += gen.feed(2);

        // Header
        bytes += gen.row([
          PosColumn(text: TranslationKeys.itemName.tr, width: 9, styles: bb),
          PosColumn(text: TranslationKeys.qty.tr, width: 3, styles: r),
        ]);
        bytes += gen.hr(ch: '-');

        if (items != null && items.isNotEmpty) {
          for (final item in items) {
            final itemName = item.itemName ?? '';
            final qty = item.quantity?.toString() ?? '1';

            bytes += gen.row([
              PosColumn(text: _escCurrency(itemName), width: 9, styles: b),
              PosColumn(text: qty, width: 3, styles: r),
            ]);

            if (item.variationName != null && item.variationName!.isNotEmpty) {
              bytes += gen.text('    (${item.variationName})', styles: b);
            }

            if (item.modifiers != null && item.modifiers!.isNotEmpty) {
              for (final mod in item.modifiers!) {
                bytes += gen.text(
                  _escCurrency('    \u2022 ${mod.name ?? ''}'),
                  styles: b,
                );
              }
            }

            if (item.note != null && item.note!.isNotEmpty) {
              bytes += gen.text(
                '    ${TranslationKeys.note.tr}: ${item.note!}',
                styles: b,
              );
            }

            bytes += gen.hr(ch: '-');
          }
        }

        final orderNote = ticket.note ?? ticket.order?.note;
        if (orderNote != null && orderNote.isNotEmpty) {
          bytes += gen.feed(1);
          bytes += gen.text(
            '${TranslationKeys.note.tr}: $orderNote',
            styles: b,
          );
        }

        bytes += gen.feed(0);
        bytes += gen.cut();

        final printerName = box.read(
          ArgumentConstant.selectedKitchenPrinterKey,
        );
        await _sendBytes(bytes, printerName: printerName);
      }
    } catch (e) {
      rethrow;
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

  Future<void> printAllKOTsFromOrder(
    order_model.Data data, {
    int copies = 1,
  }) async {
    final order = data.order;
    if (order == null || order.items == null || order.items!.isEmpty) return;

    // Groups items by KOT if available, or just print all items as one KOT
    // For now, let's treat it as one KOT for the new order
    final gen = await _getGenerator(isKitchen: true);
    final is58mm = _getPaperSize(isKitchen: true) == PaperSize.mm58;
    final b = PosStyles(
      align: is58mm ? PosAlign.center : PosAlign.left,
      fontType: PosFontType.fontB,
    );
    final bb = PosStyles(
      align: is58mm ? PosAlign.center : PosAlign.left,
      fontType: PosFontType.fontB,
      bold: false,
    );
    const r = PosStyles(align: PosAlign.right, fontType: PosFontType.fontB);

    for (int copy = 0; copy < copies; copy++) {
      List<int> bytes = [];
      bytes += [0x1B, 0x74, 19];

      bytes += gen.text(
        TranslationKeys.kitchenOrderTicket.tr,
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          bold: false,
        ),
      );
      bytes += gen.feed(1);

      String orderPart =
          '${TranslationKeys.order.tr}: ${order.formattedOrderNumber ?? order.orderNumber ?? ''}';
      String tablePart = '';
      if (order.table != null) {
        tablePart = order.table!.tableCode ?? '';
      }

      if (tablePart.isNotEmpty) {
        bytes += gen.row([
          PosColumn(
            text: orderPart,
            width: 7,
            styles: const PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size2,
              width: PosTextSize.size1,
              bold: true,
            ),
          ),
          PosColumn(
            text: '${TranslationKeys.table.tr}: $tablePart',
            width: 5,
            styles: const PosStyles(
              align: PosAlign.right,
              height: PosTextSize.size2,
              width: PosTextSize.size1,
              bold: true,
            ),
          ),
        ]);
      } else {
        bytes += gen.text(
          orderPart,
          styles: const PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
            bold: false,
          ),
        );
      }
      bytes += gen.feed(1);

      final dateStr =
          order.createdAt != null
              ? DateFormat(
                'dd-MM-yyyy',
              ).format(DateTime.parse(order.createdAt!))
              : '';
      final timeStr =
          order.createdAt != null
              ? DateFormat('hh:mm a').format(DateTime.parse(order.createdAt!))
              : '';

      if (dateStr.isNotEmpty && timeStr.isNotEmpty) {
        bytes += gen.row([
          PosColumn(
            text: '${TranslationKeys.date.tr}: $dateStr',
            width: 6,
            styles: b,
          ),
          PosColumn(
            text: '${TranslationKeys.time.tr}: $timeStr',
            width: 6,
            styles: r,
          ),
        ]);
      }

      bytes += gen.feed(2);

      // Header
      bytes += gen.row([
        PosColumn(text: TranslationKeys.itemName.tr, width: 9, styles: bb),
        PosColumn(text: TranslationKeys.qty.tr, width: 3, styles: r),
      ]);
      bytes += gen.hr(ch: '-');

      for (final item in order.items!) {
        final itemName = item.itemName ?? '';
        final qty = item.quantity?.toString() ?? '1';

        bytes += gen.row([
          PosColumn(text: _escCurrency(itemName), width: 9, styles: b),
          PosColumn(text: qty, width: 3, styles: r),
        ]);

        if (item.variationName != null && item.variationName!.isNotEmpty) {
          bytes += gen.text('    (${item.variationName})', styles: b);
        }

        if (item.modifiers != null && item.modifiers!.isNotEmpty) {
          for (final mod in item.modifiers!) {
            bytes += gen.text(
              _escCurrency('    \u2022 ${mod.name ?? ''}'),
              styles: b,
            );
          }
        }

        if (item.note != null && item.note!.isNotEmpty) {
          bytes += gen.text(
            '    ${TranslationKeys.note.tr}: ${item.note!}',
            styles: b,
          );
        }

        bytes += gen.hr(ch: '-');
      }

      if (order.note != null && order.note!.isNotEmpty) {
        bytes += gen.feed(1);
        bytes += gen.text(
          '${TranslationKeys.note.tr}: ${order.note}',
          styles: b,
        );
      }

      bytes += gen.feed(0);
      bytes += gen.cut();

      final printerName = box.read(ArgumentConstant.selectedKitchenPrinterKey);
      await _sendBytes(bytes, printerName: printerName);
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
          tax.taxName ?? 'Tax',
          tax.percent?.toString() ?? '',
          tax.amount ?? 0.0,
        );
      }
    } else {
      for (final item in items) {
        if (item.taxAmount != null && item.taxAmount! > 0) {
          _mergeTax(
            aggregatedTaxes,
            'Tax',
            item.taxPercentage?.toString() ?? '',
            item.taxAmount!,
          );
        }
      }
    }
    return aggregatedTaxes;
  }
}
