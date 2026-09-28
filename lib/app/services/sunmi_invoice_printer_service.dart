import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import '../model/get_order_model.dart' as order_model;
import '../model/receipt_order_response_model.dart';
import '../model/kitchen_ticket_model.dart';
import 'package:managerapp/app/services/printer_service.dart';
import '../widgets/sharp_receipt_widget.dart';
import '../widgets/kot_receipt_widget.dart';
import '../utils/receipt_image_capture_utils.dart';
import '../model/daily_sales_summary_model.dart';
import '../widgets/daily_summary_receipt_widget.dart';

class SunmiInvoicePrinterService {
  final printerService = Get.find<PrinterService>();

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

  Future<void> printKOT(
    KitchenTicket ticket, {
    int copies = 1,
    String? timezone,
  }) async {
    try {
      final String widthStr = printerService.kitchenWidth.value;
      final double width = widthStr == '80mm' ? 576 : 360;

      final Uint8List imageBytes = await ReceiptCaptureUtils.captureWidget(
        KotReceiptWidget(ticket: ticket, width: width, timezone: timezone),
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

  Future<void> printKOTFromOrder(
    order_model.Data data, {
    int copies = 1,
  }) async {
    final order = data.order;
    if (order == null || order.items == null || order.items!.isEmpty) return;

    final tableMap = <String, dynamic>{
      'table_code': order.table?.tableCode ?? '',
      'name': order.table?.tableCode ?? '',
    };
    final ticket = KitchenTicket(
      id: order.id,
      kotNumber: order.formattedOrderNumber ??
          (order.orderNumber != null ? '${order.orderNumber}' : null),
      createdAt: order.createdAt,
      note: order.note,
      order: KitchenTicketOrder(
        id: order.id,
        uuid: order.uuid,
        orderNumber: order.formattedOrderNumber ?? order.orderNumber,
        formattedOrderNumber: order.formattedOrderNumber,
        orderType: order.orderType,
        table: tableMap,
        note: order.note,
        dateTime: order.dateTime,
        createdAt: order.createdAt,
      ),
      items: order.items?.map((it) {
        return KitchenTicketItem(
          id: it.id,
          itemName: it.itemName,
          quantity: it.quantity,
          variationName: it.variationName,
          note: it.note,
          modifiers: it.modifiers
              ?.map((m) => KitchenTicketModifier(id: m.id, name: m.name))
              .toList(),
        );
      }).toList(),
    );

    await printKOT(
      ticket,
      copies: copies,
      timezone: data.restaurant?.timezone,
    );
  }
}