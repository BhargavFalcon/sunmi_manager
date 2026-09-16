import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import '../utils/date_time_formatter.dart';
import '../model/get_order_model.dart' as order_model;
import '../model/receipt_order_response_model.dart';
import '../model/kitchen_ticket_model.dart';
import '../constants/translation_keys.dart';
import 'package:managerapp/app/services/printer_service.dart';
import '../utils/order_helpers.dart' as helpers;
import '../widgets/sharp_receipt_widget.dart';
import '../utils/receipt_image_capture_utils.dart';
import '../model/daily_sales_summary_model.dart';
import '../widgets/daily_summary_receipt_widget.dart';

class SunmiInvoicePrinterService {
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

  String _formatDateTimeString(String? dateTimeString, [String? timezone]) {
    if (timezone != null && timezone.isNotEmpty) {
      return DateTimeFormatter.formatDateTimeInTimezone(
        dateTimeString,
        timezone,
      );
    }
    return DateTimeFormatter.formatDateTimeWithRestaurantTimezone(dateTimeString);
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

  Future<void> printInvoice(order_model.Data data, {int copies = 1}) async {
    await printSharpInvoice(data, copies: copies);
  }

  Future<void> printReceiptFromApi(ReceiptOrderData d, {int copies = 1}) async {
    await printSharpReceiptFromApi(d, copies: copies);
  }

  Future<void> printSharpInvoice(
    order_model.Data data, {
    int copies = 1,
  }) async {
    try {
      final String widthStr = printerService.receiptWidth.value;
      final double width = widthStr == '80mm' ? 576 : 360;

      final Uint8List imageBytes = await ReceiptCaptureUtils.captureWidget(
        SharpReceiptWidget(data: data, width: width),
        width: width,
      );

      for (int i = 0; i < copies; i++) {
        await SunmiPrinter.printImage(
          imageBytes,
          align: SunmiPrintAlign.CENTER,
        );
        await SunmiPrinter.lineWrap(1);
        await SunmiPrinter.cutPaper();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> printSharpReceiptFromApi(
    ReceiptOrderData d, {
    int copies = 1,
  }) async {
    try {
      final String widthStr = printerService.receiptWidth.value;
      final double width = widthStr == '80mm' ? 576 : 360;

      final Uint8List imageBytes = await ReceiptCaptureUtils.captureWidget(
        SharpReceiptWidget(data: d, width: width),
        width: width,
      );

      for (int i = 0; i < copies; i++) {
        await SunmiPrinter.printImage(
          imageBytes,
          align: SunmiPrintAlign.CENTER,
        );
        await SunmiPrinter.lineWrap(1);
        await SunmiPrinter.cutPaper();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> printDailySalesSummary(
    DailySalesSummaryData data, {
    int copies = 1,
  }) async {
    try {
      final String widthStr = printerService.receiptWidth.value;
      final double width = widthStr == '80mm' ? 576 : 360;

      final Uint8List imageBytes = await ReceiptCaptureUtils.captureWidget(
        DailySummaryReceiptWidget(data: data, width: width),
        width: width,
      );

      for (int i = 0; i < copies; i++) {
        await SunmiPrinter.printImage(
          imageBytes,
          align: SunmiPrintAlign.CENTER,
        );
        await SunmiPrinter.lineWrap(1);
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

        if (order?.dateTime != null && order!.dateTime!.isNotEmpty) {
          final kotOrderType = (order.orderType ?? '').toLowerCase();
          final timeLabel = helpers.getTimeLabel(kotOrderType);
          if (timeLabel != null) {
            final formattedDt = _formatDateTimeString(order.dateTime);
            await _printLeftBody('$timeLabel: $formattedDt');
          }
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
          _formatLabelValue(
            orderPart,
            tablePart,
            totalWidth: totalWidth - 4,
          ),
          style: SunmiTextStyle(
            align: SunmiPrintAlign.LEFT,
            fontSize: _fontSizeSub,
            bold: false,
          ),
        );
      } else {
        await _printCenteredSub(orderPart);
      }

      final tz = data.restaurant?.timezone;
      final dateStr =
          order.createdAt != null
              ? DateTimeFormatter.formatDateOnly(order.createdAt!, tz)
              : '';
      final timeStr =
          order.createdAt != null
              ? DateTimeFormatter.formatTimeOnly(order.createdAt!, tz)
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