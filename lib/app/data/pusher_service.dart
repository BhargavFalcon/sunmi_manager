import 'dart:convert';
import 'dart:developer';

import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import '../../main.dart';
import '../model/get_order_model.dart' as order_model;
import '../services/sunmi_invoice_printer_service.dart';
import '../services/printer_service.dart';
import '../modules/order_screen/controllers/order_screen_controller.dart';
import '../widgets/new_order_dialog.dart';
import '../widgets/new_order_details_bottom_sheet.dart';
import '../data/NetworkClient.dart';
import '../model/mobile_app_modules_model.dart';
import '../constants/api_constants.dart';
import '../constants/translation_keys.dart';
import '../constants/sizeConstant.dart';

class PusherService {
  WebSocket? _socket;
  Timer? _pingTimer;

  final NetworkClient networkClient = NetworkClient();
  final SunmiInvoicePrinterService _sunmiService = SunmiInvoicePrinterService();

  static const String pusherAppCluster = "eu";
  static const String pusherAppId = "zosPDO1J";
  static const String pusherAppKey = "wxidjpbk1bfqn6nr9m9rmve2hkhasdq6";
  static const String pusherHost = "soketi-production-85c0.up.railway.app";
  static const int pusherPort = 443;
  static const bool pusherUseTLS = true;

  bool _isConnected = false;

  final Set<String> _processedOrderUuids = {};
  Future<void> _printingLock = Future.value();

  Future<void> initPusher() async {}

  Future<void> subscribeToOrders(int? branchId) async {
    if (branchId == null) return;

    final orderChannel =
        "new-order-created.$branchId.${ArgumentConstant.envSuffix}";

    try {
      final scheme = pusherUseTLS ? 'wss' : 'ws';
      final url =
          '$scheme://$pusherHost:$pusherPort/app/$pusherAppKey?protocol=7&client=dart&version=1.0.0&flash=false';

      _socket?.close();
      _socket = await WebSocket.connect(url);

      _socket!.listen(
        (message) {
          _handleWebSocketMessage(
            message,
            orderChannel,
          );
        },
        onDone: () {
          _isConnected = false;
          _pingTimer?.cancel();
          Future.delayed(const Duration(seconds: 3), () {
            subscribeToOrders(branchId);
          });
        },
        onError: (err) {
          _isConnected = false;
        },
      );
    } catch (_) {
      Future.delayed(const Duration(seconds: 5), () {
        subscribeToOrders(branchId);
      });
    }
  }

  void _handleWebSocketMessage(
    dynamic message,
    String orderChannel,
  ) async {
    try {
      final decoded = jsonDecode(message.toString());
      final event = decoded['event'] as String?;
      final dataStr = decoded['data'];
      final channel = decoded['channel'] as String?;

      if (event == 'pusher:connection_established') {
        _isConnected = true;

        // Subscribe to Orders
        _socket?.add(
          jsonEncode({
            "event": "pusher:subscribe",
            "data": {"channel": orderChannel},
          }),
        );



        _pingTimer?.cancel();
        _pingTimer = Timer.periodic(const Duration(seconds: 120), (timer) {
          if (_isConnected) {
            _socket?.add(jsonEncode({"event": "pusher:ping", "data": {}}));
          }
        });
      } else if (event == 'pusher:ping') {
        _socket?.add(jsonEncode({"event": "pusher:pong", "data": {}}));
      } else if (event == 'pusher_internal:subscription_succeeded') {
      } else if (event == 'pusher:error') {
      } else {
        // This is where actual data events land
        if (dataStr != null) {
          if (channel == orderChannel) {
            log('[Pusher] Event: New Order | Data: $dataStr');
            await _handleOrderEvent(dataStr);
          }
        }
      }
    } catch (e) {}
  }



  Future<void> _handleOrderEvent(dynamic eventData) async {
    if (!_hasPermission('All Orders')) return;
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
    } catch (e) {
      return false;
    }
  }

  String _extractOrderNumber(Map<String, dynamic> data) {
    return data['order_number'].toString();
  }

  Future<order_model.Data?> _fetchOrderOnly(String orderUuid) async {
    try {
      final endpoint = ArgumentConstant.getOrderEndpoint.replaceAll(
        ':order_uuid',
        orderUuid,
      );
      final response = await networkClient.get(endpoint);

      if (response.statusCode != 200 && response.statusCode != 201) {
        return null;
      }

      if (response.data is! Map<String, dynamic>) {
        return null;
      }

      final getOrderModel = order_model.GetOrderModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (getOrderModel.success != true || getOrderModel.data == null) {
        return null;
      }

      return getOrderModel.data;
    } catch (e) {
      return null;
    }
  }

  Future<order_model.Data?> _fetchAndPrintInvoice(String orderUuid) async {
    final data = await _fetchOrderOnly(orderUuid);
    if (data == null) {
      return null;
    }
    final printerService = Get.find<PrinterService>();

    // Refresh settings from server before printing to guarantee we have the latest config
    await printerService.loadGeneralSettings();

    final autoPrintReceipt = printerService.autoPrintReceipt.value;
    final receiptCopies = printerService.receiptCopies.value;

    final completer = Completer<void>();
    final previousTask = _printingLock;
    _printingLock = completer.future;
    await previousTask;

    try {
      // 1) Print Receipt (Order)
      if (autoPrintReceipt) {
        final receiptPrinter = box.read(
          ArgumentConstant.selectedReceiptPrinterKey,
        );
        final isConnected = await printerService.checkPrinterConnectivity(
          receiptPrinter,
        );
        if (isConnected) {
          await _sunmiService.printInvoice(data, copies: receiptCopies);
          // Add a small delay after printing to ensure hardware separation
          await Future.delayed(const Duration(seconds: 2));
        }
      }

      if (autoPrintReceipt) {
        showPrintToast(TranslationKeys.printSuccessful.tr);
      }
      _processedOrderUuids.add(orderUuid);
    } catch (_) {
    } finally {
      completer.complete();
    }

    return data;
  }



  Future<void> _refreshOrderList() async {
    try {
      if (Get.isRegistered<OrderScreenController>()) {
        final controller = Get.find<OrderScreenController>();
        controller.currentPage = 1;
        await controller.fetchAllOrders();
      }
    } catch (e) {}
  }







  bool _hasPermission(String permissionName) {
    try {
      final modulesData = box.read(ArgumentConstant.mobileAppModulesKey);
      if (modulesData != null && modulesData is Map<String, dynamic>) {
        final modules = MobileAppModulesModel.fromJson(modulesData);
        final permissions = modules.data?.managerAppPermissions;
        if (permissions != null) {
          return permissions.any(
            (p) => p.toLowerCase() == permissionName.toLowerCase(),
          );
        }
      }
    } catch (_) {}
    // If no permissions are found, default to true or false?
    // Usually, in these apps, if permissions are missing it might mean they aren't loaded yet.
    // But as per user request, we should only enable if it's there.
    return false;
  }
}
