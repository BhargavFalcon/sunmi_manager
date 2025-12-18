import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import '../model/notificatioModel.dart';
import '../utils/currency_formatter.dart';

class SunmiInvoicePrinterService {
  Future<Uint8List?> _downloadNetworkImage(String imageUrl) async {
    try {
      final dio = Dio();
      final response = await dio.get<Uint8List>(
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
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Future<void> printInvoice(InvoiceModel invoiceModel, {int copies = 1}) async {
    try {
      final order = invoiceModel.order;
      if (order == null) {
        print('Error: Order data not found');
        return;
      }

      final invoiceData = order.invoiceData;
      final restaurant = invoiceData?.restaurant;
      final branch = invoiceData?.branch;
      final logoUrl = restaurant?.logoUrl;
      final qrCodeUrl = order.invoiceUrl;

      for (int i = 0; i < copies; i++) {
        if (logoUrl != null && logoUrl.isNotEmpty) {
          final imageData = await _downloadNetworkImage(logoUrl);
          if (imageData != null) {
            await SunmiPrinter.printImage(
              imageData,
              align: SunmiPrintAlign.CENTER,
            );
            await SunmiPrinter.lineWrap(2);
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
        await SunmiPrinter.lineWrap(2);

        if (branch?.address != null) {
          await SunmiPrinter.printText(
            branch!.address!,
            style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 22),
          );
          await SunmiPrinter.lineWrap(2);
        }

        if (restaurant?.phoneNumber != null) {
          await SunmiPrinter.printText(
            'Phone: ${restaurant!.phoneNumber}',
            style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 22),
          );
          await SunmiPrinter.lineWrap(2);
        }

        await SunmiPrinter.lineWrap(2);
        await SunmiPrinter.printText("--------------------------------");
        await SunmiPrinter.lineWrap(2);

        final orderLine = 'Order: ${order.formattedOrderNumber ?? "N/A"}';
        final orderDateTime = order.dateTime ?? '';
        await SunmiPrinter.printText(
          orderLine,
          style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 20),
        );
        await SunmiPrinter.lineWrap(1);

        if (order.customer?.name != null) {
          await SunmiPrinter.printText(
            'Customer: ${order.customer!.name}',
            style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 20),
          );
          await SunmiPrinter.lineWrap(1);
        }

        if (orderDateTime.isNotEmpty) {
          await SunmiPrinter.printText(
            'Order Time: $orderDateTime',
            style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 20),
          );
          await SunmiPrinter.lineWrap(1);
        }

        final printDateTime = DateTime.now();
        final formattedPrintTime =
            '${printDateTime.day} ${_getMonthName(printDateTime.month)} ${printDateTime.year} ${_formatTime(printDateTime)}';
        await SunmiPrinter.printText(
          formattedPrintTime,
          style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT, fontSize: 20),
        );

        await SunmiPrinter.lineWrap(2);
        await SunmiPrinter.printText("--------------------------------");
        await SunmiPrinter.lineWrap(2);

        await SunmiPrinter.printText(
          'Qty   Item Name       Price    Amount',
          style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 20),
        );
        await SunmiPrinter.lineWrap(1);
        await SunmiPrinter.printText("--------------------------------");
        await SunmiPrinter.lineWrap(1);

        if (order.items != null && order.items!.isNotEmpty) {
          for (final item in order.items!) {
            final qty = item.quantity?.toString() ?? '0';
            final itemName = item.itemName ?? 'N/A';
            final price = CurrencyFormatter.formatPrice(item.price ?? '0');
            final amount = CurrencyFormatter.formatPrice(
              item.formattedAmount ?? item.amount ?? '0',
            );

            await SunmiPrinter.printRow(
              cols: [
                SunmiColumn(
                  text: qty,
                  width: 3,
                  style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
                ),
                SunmiColumn(
                  text: itemName,
                  width: 12,
                  style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
                ),
                SunmiColumn(
                  text: price,
                  width: 7,
                  style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
                ),
                SunmiColumn(
                  text: amount,
                  width: 6,
                  style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
                ),
              ],
            );

            if (item.variationName != null && item.variationName!.isNotEmpty) {
              await SunmiPrinter.printText(
                '  (${item.variationName})',
                style: SunmiTextStyle(
                  align: SunmiPrintAlign.LEFT,
                  fontSize: 18,
                ),
              );
            }

            if (item.modifiers != null && item.modifiers!.isNotEmpty) {
              for (final modifier in item.modifiers!) {
                final modifierPrice = CurrencyFormatter.formatPrice(
                  modifier.price ?? '0',
                );
                await SunmiPrinter.printText(
                  '  • ${modifier.name ?? ''} (+$modifierPrice)',
                  style: SunmiTextStyle(
                    align: SunmiPrintAlign.LEFT,
                    fontSize: 18,
                  ),
                );
              }
            }
            await SunmiPrinter.lineWrap(1);
          }
        }

        await SunmiPrinter.lineWrap(2);

        if (order.totals != null) {
          final totals = order.totals!;

          if (totals.subTotal != null) {
            await SunmiPrinter.printRow(
              cols: [
                SunmiColumn(
                  text: 'Sub Total:',
                  width: 25,
                  style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
                ),
                SunmiColumn(
                  text: CurrencyFormatter.formatPrice(totals.subTotal!),
                  width: 7,
                  style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
                ),
              ],
            );
          }

          if (order.discountValue != null &&
              order.discountValue!.isNotEmpty &&
              order.discountValue != '0' &&
              order.discountValue != '0.0' &&
              order.discountValue != '0.00') {
            final discountLabel =
                order.discountType != null &&
                        order.discountType!.toLowerCase().contains('percent')
                    ? 'Discount (${order.discountType})'
                    : 'Discount';
            await SunmiPrinter.printRow(
              cols: [
                SunmiColumn(
                  text: discountLabel,
                  width: 25,
                  style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
                ),
                SunmiColumn(
                  text:
                      '-${CurrencyFormatter.formatPrice(totals.discountAmount ?? '0')}',
                  width: 7,
                  style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
                ),
              ],
            );
          }

          if (order.charges != null && order.charges!.isNotEmpty) {
            for (final charge in order.charges!) {
              await SunmiPrinter.printRow(
                cols: [
                  SunmiColumn(
                    text: '${charge.chargeName ?? ''}:',
                    width: 25,
                    style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
                  ),
                  SunmiColumn(
                    text: CurrencyFormatter.formatPrice(charge.amount ?? '0'),
                    width: 7,
                    style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
                  ),
                ],
              );
            }
          }

          if (order.taxes != null && order.taxes!.isNotEmpty) {
            for (final tax in order.taxes!) {
              await SunmiPrinter.printRow(
                cols: [
                  SunmiColumn(
                    text: '${tax.taxName ?? ''} (${tax.percent ?? ''}%) incl.',
                    width: 25,
                    style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
                  ),
                  SunmiColumn(
                    text: CurrencyFormatter.formatPrice(
                      tax.amount?.toString() ?? '0',
                    ),
                    width: 7,
                    style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
                  ),
                ],
              );
            }

            if (totals.totalTaxAmount != null) {
              await SunmiPrinter.printRow(
                cols: [
                  SunmiColumn(
                    text: 'Total Tax:',
                    width: 25,
                    style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
                  ),
                  SunmiColumn(
                    text: CurrencyFormatter.formatPrice(totals.totalTaxAmount!),
                    width: 7,
                    style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
                  ),
                ],
              );
            }
          }

          await SunmiPrinter.printRow(
            cols: [
              SunmiColumn(
                text: 'Balance Returned:',
                width: 25,
                style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
              ),
              SunmiColumn(
                text: CurrencyFormatter.formatPrice('0'),
                width: 7,
                style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
              ),
            ],
          );
        }

        await SunmiPrinter.printText("--------------------------------");
        await SunmiPrinter.lineWrap(2);

        if (order.totals?.total != null) {
          final total = CurrencyFormatter.formatPrice(order.totals!.total!);
          await SunmiPrinter.printText(
            'Total:                   $total',
            style: SunmiTextStyle(
              align: SunmiPrintAlign.CENTER,
              fontSize: 25,
              bold: true,
            ),
          );
        }

        await SunmiPrinter.lineWrap(2);
        await SunmiPrinter.printText("--------------------------------");
        await SunmiPrinter.lineWrap(2);
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
        await SunmiPrinter.lineWrap(2);

        if (order.payments != null && order.payments!.isNotEmpty) {
          final payment = order.payments!.first;
          await SunmiPrinter.printText(
            "Amount   Payment Method    Date & Time",
            style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 20),
          );
          await SunmiPrinter.printText("--------------------------------");
          await SunmiPrinter.lineWrap(1);

          final paymentAmount = CurrencyFormatter.formatPrice(
            payment.amount ?? '0',
          );
          final paymentMethod = payment.paymentMethod ?? 'Cash';
          final paymentTime = payment.createdAt ?? order.dateTime ?? '';

          await SunmiPrinter.printText(
            "$paymentAmount    $paymentMethod    $paymentTime",
            style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 20),
          );
        }

        await SunmiPrinter.lineWrap(3);
        await SunmiPrinter.cutPaper();
      }
    } catch (e) {
      print('Error printing invoice: $e');
      rethrow;
    }
  }
}
