import 'dart:convert';
import 'package:managerapp/app/model/notificationModel.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../model/invoiceModel.dart';
import '../services/sunmi_invoice_printer_service.dart';
import '../widgets/new_order_dialog.dart';
import '../modules/order_screen/controllers/order_screen_controller.dart';
import '../model/notificationModel.dart' as notification;
import '../widgets/new_order_details_bottom_sheet.dart';
import '../constants/api_constants.dart';

class PusherService {
  final PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
  final box = GetStorage();

  static const String appId = "1952389";
  static const String key = "976a2c01b088eeeb0342";
  static const String cluster = "eu";

  Future<void> initPusher() async {
    try {
      await pusher.init(
        apiKey: key,
        cluster: cluster,
        onConnectionStateChange: (currentState, previousState) {},
        onError: (message, code, e) {},
      );
      await pusher.connect();
    } catch (e) {}
  }

  bool _isValidEventData(dynamic data) {
    if (data == null) {
      return false;
    }

    final dataString = data.toString().trim();

    if (dataString.isEmpty) {
      return false;
    }

    if (dataString == '{}') {
      return false;
    }

    try {
      final decoded = jsonDecode(dataString);

      if (decoded is Map) {
        if (decoded.isEmpty) {
          return false;
        }
        return true;
      }

      if (decoded is List) {
        if (decoded.isEmpty) {
          return false;
        }
        return true;
      }

      return true;
    } catch (e) {
      return dataString.isNotEmpty;
    }
  }

  Future<void> subscribeToOrders(int? restaurantId) async {
    if (restaurantId == null) {
      return;
    }

    final channelName = "new-invoice-created.$restaurantId";
    final orderChannelName = "new-order-created.$restaurantId";

    try {
      await pusher.subscribe(
        channelName: orderChannelName,
        onEvent: (event) async {
          print("Order Event Data: ${event.data}");
          if (_isValidEventData(event.data)) {
            try {
              final dataString = event.data.toString().trim();
              final decoded = jsonDecode(dataString);
              if (decoded is Map<String, dynamic>) {
                final notificationModel = NotificationModel.fromJson(decoded);
                print(
                  " ++++++++++++Notification Model Created: ${notificationModel.order!.formattedOrderNumber}",
                );

                final orderNumber =
                    notificationModel.order?.orderNumber?.toString() ?? 'N/A';

                await _refreshOrderList();

                final notificationsEnabled =
                    box.read(ArgumentConstant.newShopOrderNotificationsKey) ??
                    true;
                if (notificationsEnabled) {
                  NewOrderDialog.show(
                    orderNumber: orderNumber,
                    order: notificationModel.order,
                    onViewOrder: () {
                      if (notificationModel.order != null) {
                        _showOrderDetailsBottomSheet(notificationModel.order!);
                      }
                    },
                  );
                }
              }
            } catch (e) {
              print("Error parsing event data to NotificationModel: $e");
            }
          }
        },
      );
    } catch (e) {
      print('Error subscribing to orders: $e');
    }

    try {
      await pusher.subscribe(
        channelName: channelName,
        onEvent: (event) {
          print("Event Data: ${event.data}");
          if (_isValidEventData(event.data)) {
            try {
              final dataString = event.data.toString().trim();
              final decoded = jsonDecode(dataString);
              if (decoded is Map<String, dynamic>) {
                final invoiceModel = InvoiceModel.fromJson(decoded);
                print(
                  "Invoice Model Created: ${invoiceModel.invoice!.order!.formattedOrderNumber}",
                );
                final autoPrintEnabled =
                    box.read(ArgumentConstant.printerAutoPrintKey) ?? true;
                if (autoPrintEnabled) {
                  _printInvoice(invoiceModel);
                }
              }
            } catch (e) {
              print("Error parsing event data to InvoiceModel: $e");
            }
          }
        },
      );
    } catch (e) {
      print('Error subscribing to orders: $e');
    }
  }

  void _printInvoice(InvoiceModel invoiceModel) {
    try {
      final printerService = SunmiInvoicePrinterService();
      printerService.printInvoice(invoiceModel);
    } catch (e) {
      print('Error printing invoice: $e');
    }
  }

  Future<void> _refreshOrderList() async {
    try {
      if (Get.isRegistered<OrderScreenController>()) {
        final controller = Get.find<OrderScreenController>();
        controller.currentPage = 1;
        await controller.fetchAllOrders();
      }
    } catch (e) {
      print('Error refreshing order list: $e');
    }
  }

  void _showOrderDetailsBottomSheet(notification.Order order) {
    try {
      NewOrderDetailsBottomSheet.show(order);
    } catch (e) {
      print('Error showing order details: $e');
    }
  }
}
