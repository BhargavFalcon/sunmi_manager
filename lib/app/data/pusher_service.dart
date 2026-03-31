import 'dart:convert';
import 'dart:developer';

import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import '../../main.dart';
import '../model/get_order_model.dart' as order_model;
import '../services/sunmi_invoice_printer_service.dart';
import '../services/escpos_invoice_printer_service.dart';
import '../services/printer_service.dart';
import '../modules/order_screen/controllers/order_screen_controller.dart';
import '../utils/sound_service.dart';
import '../modules/table_screen/controllers/table_screen_controller.dart';
import '../widgets/new_order_dialog.dart';
import '../widgets/new_order_details_bottom_sheet.dart';
import '../widgets/new_reservation_dialog.dart';
import '../widgets/kot_ready_dialog.dart';
import '../widgets/waiter_request_dialog.dart';
import '../modules/mainHome_screen/controllers/main_home_screen_controller.dart';
import '../modules/reservation_screen/controllers/reservation_screen_controller.dart';
import '../data/NetworkClient.dart';
import '../constants/api_constants.dart';
import '../constants/translation_keys.dart';
import '../constants/sizeConstant.dart';
import '../modules/kitchen_tickets_screen/controllers/kitchen_tickets_screen_controller.dart';
import '../model/kitchen_ticket_model.dart';
import '../model/mobile_app_modules_model.dart';

class PusherService {
  WebSocket? _socket;
  Timer? _pingTimer;

  final NetworkClient networkClient = NetworkClient();
  final SunmiInvoicePrinterService _sunmiService = SunmiInvoicePrinterService();
  final EscPosInvoicePrinterService _escPosService =
      EscPosInvoicePrinterService();

  static const String pusherAppCluster = "eu";
  static const String pusherAppId = "zosPDO1J";
  static const String pusherAppKey = "wxidjpbk1bfqn6nr9m9rmve2hkhasdq6";
  static const String pusherHost = "soketi-production-85c0.up.railway.app";
  static const int pusherPort = 443;
  static const bool pusherUseTLS = true;

  bool _isConnected = false;
  final Set<int> _processedKotIds = {};
  final Set<String> _processedOrderUuids = {};
  Future<void> _printingLock = Future.value();

  Future<void> initPusher() async {}

  Future<void> subscribeToOrders(int? branchId) async {
    if (branchId == null) return;

    final orderChannel =
        "new-order-created.$branchId.${ArgumentConstant.envSuffix}";
    final reservationChannel =
        "new-reservation-created.$branchId.${ArgumentConstant.envSuffix}";
    final kotCreatedChannel =
        "kots.created.$branchId.${ArgumentConstant.envSuffix}";
    final kotUpdatedChannel =
        "kots.update.$branchId.${ArgumentConstant.envSuffix}";
    final waiterRequestChannel =
        "active-waiter-requests.$branchId.${ArgumentConstant.envSuffix}";

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
            reservationChannel,
            kotCreatedChannel,
            kotUpdatedChannel,
            waiterRequestChannel,
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
    String reservationChannel,
    String kotCreatedChannel,
    String kotUpdatedChannel,
    String waiterRequestChannel,
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

        // Subscribe to Reservations
        _socket?.add(
          jsonEncode({
            "event": "pusher:subscribe",
            "data": {"channel": reservationChannel},
          }),
        );

        // Subscribe to KOT Created
        _socket?.add(
          jsonEncode({
            "event": "pusher:subscribe",
            "data": {"channel": kotCreatedChannel},
          }),
        );

        // Subscribe to KOT Updated
        _socket?.add(
          jsonEncode({
            "event": "pusher:subscribe",
            "data": {"channel": kotUpdatedChannel},
          }),
        );

        // Subscribe to Waiter Requests
        _socket?.add(
          jsonEncode({
            "event": "pusher:subscribe",
            "data": {"channel": waiterRequestChannel},
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
          } else if (channel == reservationChannel) {
            log('[Pusher] Event: New Reservation | Data: $dataStr');
            await _handleReservationEvent(dataStr);
          } else if (channel == kotCreatedChannel) {
            log('[Pusher] Event: KOT Created | Data: $dataStr');
            await _handleKotCreatedEvent(dataStr);
          } else if (channel == kotUpdatedChannel) {
            log('[Pusher] Event: KOT Updated | Data: $dataStr');
            await _handleKotUpdatedEvent(dataStr);
          } else if (channel == waiterRequestChannel) {
            log('[Pusher] Event: Waiter Request | Data: $dataStr');
            await _handleWaiterRequestEvent(dataStr);
          }
        }
      }
    } catch (e) {}
  }

  Future<void> _handleWaiterRequestEvent(dynamic eventData) async {
    try {
      final isWaiterRequestEnabled =
          box.read(ArgumentConstant.waiterRequestKey) ?? true;
      if (!isWaiterRequestEnabled) return;

      final decoded = _parseEventData(eventData);
      final waiterRequest = decoded?['waiterRequest'] as Map<String, dynamic>?;
      final tableId = waiterRequest?['table_id'];

      if (tableId != null) {
        String? tableLabel;
        // Try to find table label from TableScreenController if registered
        try {
          if (Get.isRegistered<TableScreenController>()) {
            final tableController = Get.find<TableScreenController>();
            final tableModel = tableController.tableModel.value;
            if (tableModel?.data != null) {
              for (var area in tableModel!.data!) {
                if (area.tables != null) {
                  for (var table in area.tables!) {
                    if (table.id == tableId) {
                      tableLabel = table.tableCode;
                      break;
                    }
                  }
                }
                if (tableLabel != null) break;
              }
            }
          }
        } catch (_) {}

        WaiterRequestDialog.show(
          tableId: int.parse(tableId.toString()),
          tableLabel: tableLabel,
        );
        await SoundService.playOnce('audio/new_order.wav');
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
    final isSunmi = printerService.isSunmi.value;

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
          if (isSunmi) {
            await _sunmiService.printInvoice(data, copies: receiptCopies);
          } else {
            await _escPosService.printInvoice(data, copies: receiptCopies);
          }
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

  Future<void> _handleReservationEvent(dynamic eventData) async {
    if (!_hasPermission('Table Reservations')) return;
    try {
      final decoded = _parseEventData(eventData);
      if (decoded == null) return;

      final reservation = decoded['reservation'] as Map<String, dynamic>?;
      if (reservation == null) return;

      final customer = reservation['customer'] as Map<String, dynamic>?;
      final customerName = customer?['name'] as String? ?? 'Guest';

      final reservationDateTimeStr =
          reservation['reservation_date_time'] as String?;
      final partySize = (reservation['party_size'] as int?) ?? 1;

      DateTime reservationDateTime = DateTime.now();
      if (reservationDateTimeStr != null) {
        reservationDateTime =
            DateTime.tryParse(reservationDateTimeStr) ?? DateTime.now();
      }

      _refreshReservationList();

      final notificationsEnabled =
          box.read(ArgumentConstant.newTableReservationsKey) ?? true;

      if (notificationsEnabled) {
        NewReservationDialog.show(
          customerName: customerName,
          reservationDateTime: reservationDateTime,
          partySize: partySize,
        );
      }
    } catch (e) {}
  }

  Future<void> _refreshReservationList() async {
    try {
      if (Get.isRegistered<ReservationScreenController>()) {
        final controller = Get.find<ReservationScreenController>();
        controller.currentReservationsPage.value = 1;
        await controller.fetchReservations();
      }
    } catch (e) {}
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

  Future<void> _handleKotCreatedEvent(dynamic eventData) async {
    if (!_hasPermission('Kitchen Tickets')) return;
    int? newKotId;
    try {
      final decoded = _parseEventData(eventData);
      if (decoded != null) {
        newKotId =
            decoded['kot_id'] ??
            (decoded['kot'] != null ? decoded['kot']['id'] : null);
      }
    } catch (e) {}

    _refreshKitchenTicketsList(newKotId: newKotId);

    // Set new KOT pulse state for animation
    if (Get.isRegistered<MainHomeScreenController>()) {
      Get.find<MainHomeScreenController>().hasNewKotPulse.value = true;
    }

    // Sound alert for new KOT (always play as per user request to shift switch focus to animation)
    _playNotificationSound();

    if (newKotId != null) {
      _fetchAndPrintKOT(newKotId);
    }
  }

  Future<void> _playNotificationSound() async {
    try {
      await SoundService.playOnce('audio/new_order.wav');
    } catch (e) {}
  }

  Future<void> _handleKotUpdatedEvent(dynamic eventData) async {
    if (!_hasPermission('Dine-in')) return;
    try {
      final isKotSoundEnabled =
          box.read(ArgumentConstant.kotStatusChangeKey) ?? true;
      if (isKotSoundEnabled) {
        _playNotificationSound();
      }

      final decoded = _parseEventData(eventData);
      final kot = decoded?['kot'] as Map<String, dynamic>?;
      if (kot != null) {
        final order = kot['order'] as Map<String, dynamic>?;
        final orderNumber =
            order?['order_number']?.toString() ??
            kot['kot_number']?.toString() ??
            '';
        final orderType = order?['order_type']?.toString();
        final items = kot['items'] as List<dynamic>?;

        if (items != null) {
          final readyItems =
              items
                  .where((item) {
                    if (item is! Map<String, dynamic>) return false;
                    final status = item['status']?.toString().toLowerCase();
                    final foodReady = item['food_ready']?.toString();
                    return (status == 'ready' ||
                        foodReady == '1' ||
                        foodReady == 'true');
                  })
                  .cast<Map<String, dynamic>>()
                  .toList();

          if (readyItems.isNotEmpty) {
            final tableData = order?['table'] as Map<String, dynamic>?;
            final tableId = order?['table_id'] ?? tableData?['id'];
            final tableLabel = tableData?['table_code']?.toString();

            final updatedAtRaw =
                kot['updated_at']?.toString() ?? DateTime.now().toString();
            final dt = DateTime.tryParse(updatedAtRaw) ?? DateTime.now();
            final hour =
                dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
            final ampm = dt.hour >= 12 ? 'PM' : 'AM';
            final updatedAt =
                '${dt.day} ${_getMonthName(dt.month)}, ${hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $ampm';

            if (orderType?.toLowerCase().contains('dine') ?? false) {
              if (tableId != null) {
                Get.find<MainHomeScreenController>().addReadyItems(
                  int.parse(tableId.toString()),
                  readyItems,
                  updatedAt,
                  tableLabel: tableLabel,
                );
              } else {
                KotReadyDialog.show(
                  orderNumber: orderNumber,
                  readyItems: readyItems,
                  orderType: orderType,
                  readyTime: updatedAt,
                  tableCode: tableLabel,
                );
              }
            } else {
              KotReadyDialog.show(
                orderNumber: orderNumber,
                readyItems: readyItems,
                orderType: orderType,
                readyTime: updatedAt,
                tableCode: tableLabel,
              );
            }
          }
        }
      }
    } catch (e) {}
  }

  Future<void> _refreshKitchenTicketsList({int? newKotId}) async {
    try {
      if (Get.isRegistered<KitchenTicketsScreenController>()) {
        final controller = Get.find<KitchenTicketsScreenController>();
        if (newKotId != null) {
          controller.setNewKotId(newKotId);
        }
        await controller.fetchKitchenTickets();
      }
    } catch (e) {}
  }

  Future<void> _fetchAndPrintKOT(int kotId) async {
    final printerService = Get.find<PrinterService>();
    await printerService.loadGeneralSettings();

    final autoPrintKot = printerService.autoPrintKitchen.value;
    if (!autoPrintKot) return;

    if (_processedKotIds.contains(kotId)) return;

    final completer = Completer<void>();
    final previousTask = _printingLock;
    _printingLock = completer.future;
    await previousTask;

    try {
      if (_processedKotIds.contains(kotId)) return;

      final kotData = await _fetchKotOnly(kotId);
      if (kotData == null) return;

      final kotCopies = printerService.kitchenCopies.value;
      final isSunmi = printerService.isSunmi.value;

      final kitchenPrinter = box.read(
        ArgumentConstant.selectedKitchenPrinterKey,
      );
      final isConnected = await printerService.checkPrinterConnectivity(
        kitchenPrinter,
      );
      if (isConnected) {
        if (isSunmi) {
          await _sunmiService.printKOT(kotData, copies: kotCopies);
        } else {
          await _escPosService.printKOT(kotData, copies: kotCopies);
        }
        _processedKotIds.add(kotId);
        showPrintToast(TranslationKeys.printSuccessful.tr);
        await Future.delayed(const Duration(seconds: 2));
      }
    } catch (e) {
    } finally {
      completer.complete();
    }
  }

  Future<KitchenTicket?> _fetchKotOnly(int kotId) async {
    try {
      final response = await networkClient.get(
        '${ArgumentConstant.kotsEndpoint}/$kotId',
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        return null;
      }

      if (response.data is! Map<String, dynamic>) return null;

      final data = response.data['data'];
      if (data == null || data is! Map<String, dynamic>) return null;

      return KitchenTicket.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  static const _months = [
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

  String _getMonthName(int month) {
    if (month < 1 || month > 12) return '';
    return _months[month - 1];
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
