import 'dart:convert';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../model/notificatioModel.dart';
import '../services/sunmi_invoice_printer_service.dart';

class PusherService {
  final PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

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
                _printInvoice(invoiceModel);
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
}
