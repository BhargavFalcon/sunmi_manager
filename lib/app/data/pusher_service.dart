import 'dart:convert';
import 'dart:developer';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:get/get.dart';
import '../../main.dart';
import '../model/getorderModel.dart' as orderModel;
import '../services/sunmi_invoice_printer_service.dart';
import '../modules/order_screen/controllers/order_screen_controller.dart';
import '../widgets/new_order_dialog.dart';
import '../widgets/new_order_details_bottom_sheet.dart';
import '../data/NetworkClient.dart';
import '../constants/api_constants.dart';
import '../constants/translation_keys.dart';

class PusherService {
  final PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
  final NetworkClient networkClient = NetworkClient();
  final SunmiInvoicePrinterService _printerService =
      SunmiInvoicePrinterService();

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
    } catch (_) {}
  }

  Future<void> subscribeToOrders(int? restaurantId) async {
    if (restaurantId == null) return;

    final channelName = "new-order-created.$restaurantId";

    try {
      await pusher.subscribe(
        channelName: channelName,
        onEvent: (event) async {
          if (event is! PusherEvent) return;
          await _handleOrderEvent(event);
        },
      );
    } catch (e) {
      log("Error subscribing to Pusher channel: $e");
    }
  }

  Future<void> _handleOrderEvent(PusherEvent event) async {
    if (!_isValidEventData(event.data)) return;

    try {
      final decoded = _parseEventData(event.data);
      if (decoded == null) return;

      final order = decoded['order'] as Map<String, dynamic>?;
      if (order == null) return;

      final orderUuid = order['uuid'] as String?;
      if (orderUuid == null || orderUuid.isEmpty) return;

      _refreshOrderList();

      final notificationsEnabled =
          box.read(ArgumentConstant.newShopOrderNotificationsKey) ?? true;

      final orderNumber = _extractOrderNumber(order);
      orderModel.Data? fetchedOrderData;

      if (notificationsEnabled) {
        NewOrderDialog.show(
          orderNumber: orderNumber,
          onViewOrder: () {
            if (fetchedOrderData != null) {
              NewOrderDetailsBottomSheet.show(fetchedOrderData);
            }
          },
        );
      }

      fetchedOrderData = await _fetchAndPrintInvoice(orderUuid);
    } catch (_) {}
  }

  Map<String, dynamic>? _parseEventData(dynamic data) {
    try {
      final decoded = jsonDecode(data.toString().trim());
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}
    return null;
  }

  bool _isValidEventData(dynamic data) {
    if (data == null) return false;

    final dataString = data.toString().trim();
    if (dataString.isEmpty || dataString == '{}') return false;

    try {
      final decoded = jsonDecode(dataString);
      if (decoded is Map) return decoded.isNotEmpty;
      if (decoded is List) return decoded.isNotEmpty;
      return true;
    } catch (_) {
      return false;
    }
  }

  String _extractOrderNumber(Map<String, dynamic> data) {
    return data['order_number'] as String? ??
        data['formatted_order_number'] as String? ??
        TranslationKeys.na.tr;
  }

  Future<orderModel.Data?> _fetchAndPrintInvoice(String orderUuid) async {
    try {
      final endpoint = ArgumentConstant.getOrderEndpoint.replaceAll(
        ':order_uuid',
        orderUuid,
      );
      final response = await networkClient.get(endpoint);

      if (response.statusCode != 200 && response.statusCode != 201) {
        return null;
      }

      if (response.data is! Map<String, dynamic>) return null;

      final getOrderModel = orderModel.GetOrderModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (getOrderModel.success != true || getOrderModel.data == null) {
        return null;
      }

      final autoPrintEnabled =
          box.read(ArgumentConstant.printerAutoPrintKey) ?? true;
      if (autoPrintEnabled) {
        _printerService.printInvoice(getOrderModel.data!);
      }

      return getOrderModel.data;
    } catch (_) {
      return null;
    }
  }

  Future<void> _refreshOrderList() async {
    if (!Get.isRegistered<OrderScreenController>()) return;

    try {
      final controller = Get.find<OrderScreenController>();
      controller.currentPage = 1;
      await controller.fetchAllOrders();
    } catch (_) {}
  }
}
