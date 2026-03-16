import 'dart:convert';
import 'dart:developer';

import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../main.dart';
import '../model/get_order_model.dart' as order_model;
import '../services/sunmi_invoice_printer_service.dart';
import '../services/escpos_invoice_printer_service.dart';
import '../services/printer_service.dart';
import '../modules/order_screen/controllers/order_screen_controller.dart';
import '../widgets/new_order_dialog.dart';
import '../widgets/new_order_details_bottom_sheet.dart';
import '../widgets/new_reservation_dialog.dart';
import '../modules/reservation_screen/controllers/reservation_screen_controller.dart';
import '../data/NetworkClient.dart';
import '../constants/api_constants.dart';
import '../constants/translation_keys.dart';
import '../constants/sizeConstant.dart';
import '../modules/kitchen_tickets_screen/controllers/kitchen_tickets_screen_controller.dart';
import '../model/kitchen_ticket_model.dart';

class PusherService {
  WebSocket? _socket;
  Timer? _pingTimer;
  static final AudioPlayer _audioPlayer = AudioPlayer();

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
  ) async {
    try {
      final decoded = jsonDecode(message.toString());
      final event = decoded['event'] as String?;
      final dataStr = decoded['data'];
      final channel = decoded['channel'] as String?;
      log('[Pusher] event=$event | channel=$channel');

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
            await _handleOrderEvent(dataStr);
          } else if (channel == reservationChannel) {
            await _handleReservationEvent(dataStr);
          } else if (channel == kotCreatedChannel) {
            await _handleKotCreatedEvent(dataStr);
          } else if (channel == kotUpdatedChannel) {
            await _handleKotUpdatedEvent(dataStr);
          }
        }
      }
    } catch (e) {}
  }

  Future<void> _handleOrderEvent(dynamic eventData) async {
    if (!_isValidEventData(eventData)) return;

    try {
      final decoded = _parseEventData(eventData);
      if (decoded == null) return;

      // Log the full decoded payload for debugging
      try {
        log('[PUSHER][ORDER] payload=${jsonEncode(decoded)}');
      } catch (_) {
        log('[PUSHER][ORDER] payload (non-encodable): ${decoded.toString()}');
      }

      final order = decoded['order'] as Map<String, dynamic>?;
      if (order == null) return;

      final orderUuid = order['uuid'] as String?;
      if (orderUuid == null || orderUuid.isEmpty) return;

      // Log some key order details
      try {
        log(
          '[PUSHER][ORDER] uuid=$orderUuid | number=${_extractOrderNumber(order)}',
        );
      } catch (_) {}

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

      if (response.data is! Map<String, dynamic>) return null;

      final getOrderModel = order_model.GetOrderModel.fromJson(
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

  Future<order_model.Data?> _fetchAndPrintInvoice(String orderUuid) async {
    final data = await _fetchOrderOnly(orderUuid);
    if (data == null) return null;
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
        try {
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
        } catch (_) {}
      }

      if (autoPrintReceipt) {
        showPrintToast(TranslationKeys.printSuccessful.tr);
      }
      _processedOrderUuids.add(orderUuid);
    } finally {
      completer.complete();
    }

    return data;
  }

  Future<void> _handleReservationEvent(dynamic eventData) async {
    try {
      final decoded = _parseEventData(eventData);
      if (decoded == null) return;

      // Log the full decoded payload for debugging
      try {
        log('[PUSHER][RESERVATION] payload=${jsonEncode(decoded)}');
      } catch (_) {
        log(
          '[PUSHER][RESERVATION] payload (non-encodable): ${decoded.toString()}',
        );
      }

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
    if (!Get.isRegistered<ReservationScreenController>()) return;

    try {
      final controller = Get.find<ReservationScreenController>();
      controller.currentReservationsPage.value = 1;
      await controller.fetchReservations();
    } catch (e) {}
  }

  Future<void> _refreshOrderList() async {
    if (!Get.isRegistered<OrderScreenController>()) return;

    try {
      final controller = Get.find<OrderScreenController>();
      controller.currentPage = 1;
      await controller.fetchAllOrders();
    } catch (_) {}
  }

  Future<void> _handleKotCreatedEvent(dynamic eventData) async {
    int? newKotId;
    try {
      if (eventData is Map) {
        newKotId =
            eventData['kot_id'] ??
            (eventData['kot'] != null ? eventData['kot']['id'] : null);
      } else {
        final decoded = jsonDecode(eventData.toString());
        // Log the decoded payload for debugging
        try {
          log('[PUSHER][KOT_CREATED] payload=${jsonEncode(decoded)}');
        } catch (_) {
          log(
            '[PUSHER][KOT_CREATED] payload (non-encodable): ${decoded.toString()}',
          );
        }

        newKotId =
            decoded['kot_id'] ??
            (decoded['kot'] != null ? decoded['kot']['id'] : null);
      }
    } catch (_) {}

    _refreshKitchenTicketsList(newKotId: newKotId);

    // Check sound condition here before playing
    final isKotSoundEnabled =
        box.read(ArgumentConstant.kitchenTicketGenerationKey) ?? true;
    log('[KOT_SOUND] isKotSoundEnabled=$isKotSoundEnabled');
    if (isKotSoundEnabled) {
      log('[KOT_SOUND] Playing sound...');
      _playNotificationSound();
    }

    if (newKotId != null) {
      _fetchAndPrintKOT(newKotId);
    }
  }

  Future<void> _playNotificationSound() async {
    try {
      log('[KOT_SOUND] Audio player play called');
      await _audioPlayer.play(AssetSource('audio/new_order.wav'));
      log('[KOT_SOUND] Audio player play completed');
    } catch (e) {
      log('[KOT_SOUND] Error playing sound: $e');
    }
  }

  Future<void> _handleKotUpdatedEvent(dynamic eventData) async {
    log('[KOT UPDATE] Raw eventData: ${eventData.toString()}');
    // Try to parse and log structured payload
    try {
      final decoded =
          eventData is Map ? eventData : jsonDecode(eventData.toString());
      try {
        log('[PUSHER][KOT_UPDATED] payload=${jsonEncode(decoded)}');
      } catch (_) {
        log(
          '[PUSHER][KOT_UPDATED] payload (non-encodable): ${decoded.toString()}',
        );
      }
    } catch (_) {}

    // Check sound condition here before playing
    final isKotSoundEnabled =
        box.read(ArgumentConstant.kotStatusChangeKey) ?? true;
    if (isKotSoundEnabled) {
      _playNotificationSound();
    }
  }

  Future<void> _refreshKitchenTicketsList({int? newKotId}) async {
    if (!Get.isRegistered<KitchenTicketsScreenController>()) {
      log('[KOT] KitchenTicketsScreenController not registered — skip refresh');
      return;
    }

    try {
      final controller = Get.find<KitchenTicketsScreenController>();
      log('[KOT] Refreshing kitchen tickets list');
      if (newKotId != null) {
        controller.setNewKotId(newKotId);
      }
      await controller.fetchKitchenTickets();
      log('[KOT] Kitchen tickets list refreshed successfully');
    } catch (e) {
      log('[KOT] Error refreshing list: $e');
    }
  }

  Future<void> _fetchAndPrintKOT(int kotId) async {
    final printerService = Get.find<PrinterService>();

    // Refresh settings from server before printing to guarantee we have the latest config
    await printerService.loadGeneralSettings();

    final autoPrintKot = printerService.autoPrintKitchen.value;
    if (!autoPrintKot) return;

    if (_processedKotIds.contains(kotId)) {
      log('[KOT] skipping duplicate print for kotId=$kotId');
      return;
    }

    final completer = Completer<void>();
    final previousTask = _printingLock;
    _printingLock = completer.future;
    await previousTask;

    try {
      // Double check inside the lock
      if (_processedKotIds.contains(kotId)) {
        log('[KOT] skipping duplicate print inside lock for kotId=$kotId');
        return;
      }

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

        // Add a small delay after printing to ensure hardware separation
        await Future.delayed(const Duration(seconds: 2));
      }
    } catch (e) {
      log('[KOT] Error printing: $e');
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
}
