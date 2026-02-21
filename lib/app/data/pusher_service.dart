import 'dart:convert';
import 'dart:developer';
import 'dart:async';
import 'dart:io';
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
import '../constants/sizeConstant.dart';

class PusherService {
  WebSocket? _socket;
  Timer? _pingTimer;

  final NetworkClient networkClient = NetworkClient();
  final SunmiInvoicePrinterService _printerService =
      SunmiInvoicePrinterService();

  static const String pusherAppCluster = "eu";
  static const String pusherAppId = "zosPDO1J";
  static const String pusherAppKey = "wxidjpbk1bfqn6nr9m9rmve2hkhasdq6";
  static const String pusherHost = "soketi-production-85c0.up.railway.app";
  static const int pusherPort = 443;
  static const bool pusherUseTLS = true;

  bool _isConnected = false;

  Future<void> initPusher() async {}

  Future<void> subscribeToOrders(int? restaurantId) async {
    if (restaurantId == null) return;

    final channelName = "new-order-created.$restaurantId";

    try {
      final scheme = pusherUseTLS ? 'wss' : 'ws';
      final url =
          '$scheme://$pusherHost:$pusherPort/app/$pusherAppKey?protocol=7&client=dart&version=1.0.0&flash=false';

      _socket?.close();
      _socket = await WebSocket.connect(url);

      _socket!.listen(
        (message) {
          _handleWebSocketMessage(message, channelName);
        },
        onDone: () {
          _isConnected = false;
          _pingTimer?.cancel();
          Future.delayed(const Duration(seconds: 3), () {
            subscribeToOrders(restaurantId);
          });
        },
        onError: (err) {
          _isConnected = false;
        },
      );
    } catch (_) {
      Future.delayed(const Duration(seconds: 5), () {
        subscribeToOrders(restaurantId);
      });
    }
  }

  void _handleWebSocketMessage(dynamic message, String channelName) async {
    try {
      final decoded = jsonDecode(message.toString());
      final event = decoded['event'] as String?;
      final dataStr = decoded['data'];

      if (event == 'pusher:connection_established') {
        _isConnected = true;

        final subscribeMsg = jsonEncode({
          "event": "pusher:subscribe",
          "data": {"channel": channelName},
        });
        _socket?.add(subscribeMsg);

        _pingTimer?.cancel();
        _pingTimer = Timer.periodic(const Duration(seconds: 120), (timer) {
          if (_isConnected) {
            _socket?.add(jsonEncode({"event": "pusher:ping", "data": {}}));
          }
        });
      } else if (event == 'pusher:ping') {
        _socket?.add(jsonEncode({"event": "pusher:pong", "data": {}}));
      } else if (event == 'pusher_internal:subscription_succeeded') {
        // Successfully subscribed
      } else if (event == 'pusher:error') {
        log('Pusher Error: $dataStr');
      } else {
        if (dataStr != null) {
          await _handleOrderEvent(dataStr);
        }
      }
    } catch (_) {}
  }

  Future<void> _handleOrderEvent(dynamic eventData) async {
    if (!_isValidEventData(eventData)) return;

    try {
      final decoded = _parseEventData(eventData);
      if (decoded == null) return;

      final order = decoded['order'] as Map<String, dynamic>?;
      if (order == null) return;

      final orderUuid = order['uuid'] as String?;
      if (orderUuid == null || orderUuid.isEmpty) return;

      _refreshOrderList();

      final orderNumber = _extractOrderNumber(order);
      final notificationsEnabled =
          box.read(ArgumentConstant.newShopOrderNotificationsKey) ?? true;

      if (notificationsEnabled) {
        NewOrderDialog.show(
          orderNumber: orderNumber,
          onViewOrder: () async {
            final data = await _fetchOrderOnly(orderUuid);
            if (data != null) {
              NewOrderDetailsBottomSheet.show(data);
            }
          },
        );
      }

      await _fetchAndPrintInvoice(orderUuid);
    } catch (_) {}
  }

  Map<String, dynamic>? _parseEventData(dynamic data) {
    if (data == null) return null;
    try {
      if (data is Map<String, dynamic>) {
        return data;
      }
      final decoded = jsonDecode(data.toString().trim());
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}
    return null;
  }

  bool _isValidEventData(dynamic data) {
    if (data == null) return false;

    if (data is Map || data is List) return data.isNotEmpty;

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
    return data['order_number'].toString();
  }

  Future<orderModel.Data?> _fetchOrderOnly(String orderUuid) async {
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

      return getOrderModel.data;
    } catch (_) {
      return null;
    }
  }

  Future<orderModel.Data?> _fetchAndPrintInvoice(String orderUuid) async {
    final data = await _fetchOrderOnly(orderUuid);
    if (data == null) {
      return null;
    }

    final autoPrintEnabled =
        box.read(ArgumentConstant.printerAutoPrintKey) ?? true;

    if (autoPrintEnabled) {
      final copies =
          box.read<int>(ArgumentConstant.printerNumberOfCopiesKey) ?? 1;

      try {
        await _printerService.printInvoice(data, copies: copies);
        showPrintToast(TranslationKeys.printSuccessful.tr);
      } catch (e) {
        showPrintToast(TranslationKeys.errorInPrinting.tr, isError: true);
      }
    }

    return data;
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
