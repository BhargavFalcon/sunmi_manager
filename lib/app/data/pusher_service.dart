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
import '../model/login_models.dart';
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
  bool _shouldReconnect = false;
  int? _currentBranchId;
  int _connectionId = 0;

  final Set<String> _processedOrderUuids = {};
  Future<void> _printingLock = Future.value();

  Future<void> initPusher() async {}

  Future<void> subscribeToOrders(int? branchId) async {
    if (branchId == null) return;
    if (_currentBranchId == branchId && _socket != null && _isConnected) {
      return;
    }

    final orderChannel =
        "new-order-created.$branchId.${ArgumentConstant.envSuffix}";

    try {
      _shouldReconnect = true;
      _currentBranchId = branchId;
      final connectionId = ++_connectionId;
      await _disposeSocket();

      final scheme = pusherUseTLS ? 'wss' : 'ws';
      final url =
          '$scheme://$pusherHost:$pusherPort/app/$pusherAppKey?protocol=7&client=dart&version=1.0.0&flash=false';

      final socket = await WebSocket.connect(url);
      if (!_isConnectionActive(connectionId, branchId)) {
        await socket.close();
        return;
      }
      _socket = socket;

      socket.listen(
        (message) {
          if (!_isConnectionActive(connectionId, branchId)) return;
          _handleWebSocketMessage(
            message,
            orderChannel,
          );
        },
        onDone: () {
          if (!_isConnectionCurrent(connectionId)) return;
          _isConnected = false;
          _pingTimer?.cancel();
          _pingTimer = null;
          _scheduleReconnect(
            branchId,
            const Duration(seconds: 3),
            connectionId,
          );
        },
        onError: (err) {
          if (!_isConnectionCurrent(connectionId)) return;
          _isConnected = false;
          _pingTimer?.cancel();
          _pingTimer = null;
          _scheduleReconnect(
            branchId,
            const Duration(seconds: 5),
            connectionId,
          );
        },
      );
    } catch (_) {
      _scheduleReconnect(branchId, const Duration(seconds: 5), _connectionId);
    }
  }

  Future<void> disconnect() async {
    _shouldReconnect = false;
    _currentBranchId = null;
    _isConnected = false;
    _pingTimer?.cancel();
    _pingTimer = null;
    _processedOrderUuids.clear();
    ++_connectionId;
    await _disposeSocket();
  }

  bool _isConnectionCurrent(int connectionId) => connectionId == _connectionId;

  bool _isConnectionActive(int connectionId, int branchId) {
    return _isConnectionCurrent(connectionId) &&
        _shouldReconnect &&
        _currentBranchId == branchId;
  }

  void _scheduleReconnect(int branchId, Duration delay, int connectionId) {
    if (!_isConnectionActive(connectionId, branchId)) return;
    Future.delayed(delay, () {
      if (!_isConnectionActive(connectionId, branchId)) return;
      subscribeToOrders(branchId);
    });
  }

  Future<void> _disposeSocket() async {
    final socket = _socket;
    _socket = null;
    if (socket == null) return;
    try {
      await socket.close();
    } catch (_) {}
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
    } catch (_) {
      return;
    }
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

      final orderData = await _fetchOrderOnly(orderUuid);
      if (!_shouldNotifyCurrentUserForOrderData(orderData, fallbackOrder: order)) {
        return;
      }

      // Strict Filter: ONLY allow notifications & auto-print for Shop, Android, and iOS customer orders
      final placedVia = (orderData?.order?.placedVia ?? order['placed_via'] ?? '')
          .toString()
          .toLowerCase()
          .trim();
      final isAllowedChannel =
          placedVia == 'shop' || placedVia == 'android' || placedVia == 'ios';
      if (!isAllowedChannel) {
        return;
      }

      _refreshOrderList();

      final orderNumber =
          orderData?.order?.orderNumber?.toString() ?? _extractOrderNumber(order);
      final notificationsEnabled =
          box.read(ArgumentConstant.newShopOrderNotificationsKey) ?? true;

      if (notificationsEnabled) {
        NewOrderDialog.show(
          orderNumber: orderNumber,
          onViewOrder: () async {
            final data = orderData ?? await _fetchOrderOnly(orderUuid);
            if (data != null) {
              NewOrderDetailsBottomSheet.show(data);
            }
          },
        );
      }

      if (orderData != null) {
        await _printInvoiceData(orderData, orderUuid);
      } else {
        await _fetchAndPrintInvoice(orderUuid);
      }
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

  bool _shouldNotifyCurrentUserForOrder(Map<String, dynamic> order) {
    final currentUserId = _getCurrentUserId();
    if (currentUserId == null || _isCurrentUserAdmin()) {
      return true;
    }

    final assignedUserIds = <int>{};
    _addCandidateUserId(assignedUserIds, order['waiter_id']);
    _addCandidateUserId(assignedUserIds, order['assigned_user_id']);
    _addCandidateUserId(assignedUserIds, order['assigned_to']);

    final waiter = order['waiter'];
    if (waiter is Map<String, dynamic>) {
      _addCandidateUserId(assignedUserIds, waiter['id']);
    }

    if (assignedUserIds.isEmpty) {
      return true;
    }

    return assignedUserIds.contains(currentUserId);
  }

  bool _shouldNotifyCurrentUserForOrderData(
    order_model.Data? orderData, {
    required Map<String, dynamic> fallbackOrder,
  }) {
    final currentUserId = _getCurrentUserId();
    if (currentUserId == null || _isCurrentUserAdmin()) {
      return true;
    }

    final detailedOrder = orderData?.order;
    final assignedUserIds = <int>{};

    _addCandidateUserId(assignedUserIds, detailedOrder?.waiter?.id);

    if (assignedUserIds.isEmpty) {
      return _shouldNotifyCurrentUserForOrder(fallbackOrder);
    }

    return assignedUserIds.contains(currentUserId);
  }

  int? _getCurrentUserId() {
    try {
      final loginModelData = box.read(ArgumentConstant.loginModelKey);
      if (loginModelData is Map<String, dynamic>) {
        return LoginModel.fromJson(loginModelData).data?.user?.id;
      }
    } catch (_) {}
    return null;
  }

  bool _isCurrentUserAdmin() {
    try {
      final loginModelData = box.read(ArgumentConstant.loginModelKey);
      if (loginModelData is Map<String, dynamic>) {
        final user = LoginModel.fromJson(loginModelData).data?.user;
        final roleName = user?.role?.name?.toLowerCase() ?? '';
        final displayName = user?.role?.displayName?.toLowerCase() ?? '';
        return roleName.contains('admin') || displayName.contains('admin');
      }
    } catch (_) {}
    return false;
  }

  void _addCandidateUserId(Set<int> userIds, dynamic value) {
    final parsed = _parseInt(value);
    if (parsed != null) {
      userIds.add(parsed);
    }
  }

  int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
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

    await _printInvoiceData(data, orderUuid);

    return data;
  }

  Future<void> _printInvoiceData(
    order_model.Data data,
    String orderUuid,
  ) async {
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
          await _sunmiService.printSharpInvoice(data, copies: receiptCopies);
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
  }



  Future<void> _refreshOrderList() async {
    try {
      if (Get.isRegistered<OrderScreenController>()) {
        final controller = Get.find<OrderScreenController>();
        controller.currentPage = 1;
        await controller.fetchAllOrders();
      }
    } catch (_) {
      return;
    }
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
