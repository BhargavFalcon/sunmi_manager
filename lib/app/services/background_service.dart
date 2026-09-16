// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';

import 'package:managerapp/app/constants/api_constants.dart';
import 'package:managerapp/app/services/printer_service.dart';
import 'package:managerapp/app/services/sunmi_invoice_printer_service.dart';
import 'package:managerapp/app/model/get_order_model.dart' as order_model;
import 'package:managerapp/app/model/kitchen_ticket_model.dart';
import 'package:managerapp/app/model/login_models.dart';
import 'package:managerapp/app/utils/language_utils.dart';
import 'package:managerapp/app/utils/locale_string.dart';

class BackgroundServiceManager {
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        autoStartOnBoot: true,
        isForegroundMode: true,
        notificationChannelId: 'dinematrics_bg_service_channel',
        initialNotificationTitle: 'Dinemetrics Ordering',
        initialNotificationContent: 'Listening for new orders...',
        foregroundServiceTypes: [
          AndroidForegroundType.dataSync,
          AndroidForegroundType.connectedDevice,
        ],
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  final box = GetStorage();

  Future<Map<String, dynamic>> loadStorageDataFromDisk() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/GetStorage.gs');
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.trim().isNotEmpty) {
          return jsonDecode(content) as Map<String, dynamic>;
        }
      }
    } catch (_) {}
    return {};
  }

  Future<void> syncStorageFromDisk() async {
    try {
      final diskData = await loadStorageDataFromDisk();
      diskData.forEach((key, value) {
        box.writeInMemory(key, value);
      });
    } catch (_) {}
  }

  await syncStorageFromDisk();

  // Mark PrinterService as background so it avoids GUI or API sync conflicts
  PrinterService.isBackground = true;

  // 1. Setup translations & GetX context for printer services
  try {
    Get.clearTranslations();
    Get.addTranslations(LocaleString().keys);
    final language = LanguageUtils.getLanguage();
    final locale = LanguageUtils.getLocaleFromCode(language);
    Get.updateLocale(locale);
  } catch (_) {}

  // 2. Setup Printer Services in background isolate
  try {
    Get.put(PrinterService(), permanent: true);
  } catch (_) {}

  WebSocket? socket;
  Timer? pingTimer;
  bool isConnected = false;
  int connectionId = 0;
  bool isAppForeground = box.read(ArgumentConstant.isAppForegroundKey) ?? false;
  Future<void>? bgPrintingLock;

  // Background order count key (persisted in storage so kill-state counts survive)
  const String bgCountKey = 'bg_order_count';

  // Keep track of processed order UUIDs to avoid double printing inside the service
  final Set<String> processedOrderUuids = {};

  // Keep track of processed KOT IDs to avoid double printing inside the service
  final Set<int> processedKotIds = {};

  // KOT channels fetched from API (kitchen-monitor channels)
  Set<String> kotChannels = {};

  Future<void> stopSocket() async {
    pingTimer?.cancel();
    pingTimer = null;
    isConnected = false;
    try {
      await socket?.close();
    } catch (_) {}
    socket = null;
  }

  void handleOrder(dynamic eventData) async {
    if (isAppForeground) {
      return;
    }

    await syncStorageFromDisk();

    try {
      Map<String, dynamic>? decoded;
      if (eventData is Map<String, dynamic>) {
        decoded = eventData;
      } else {
        decoded =
            jsonDecode(eventData.toString().trim()) as Map<String, dynamic>?;
      }
      if (decoded == null) return;
      final order = decoded['order'] as Map<String, dynamic>?;
      if (order == null) return;
      final orderUuid = order['uuid'] as String?;
      if (orderUuid == null || orderUuid.isEmpty) return;

      // Strictly only allow Shop, Android, and iOS customer orders
      final placedVia =
          (order['placed_via'] ?? '').toString().toLowerCase().trim();
      if (placedVia.isNotEmpty &&
          placedVia != 'shop' &&
          placedVia != 'android' &&
          placedVia != 'ios') {
        return;
      }

      // Ensure we haven't already processed this order in this session
      if (processedOrderUuids.contains(orderUuid)) {
        return;
      }
      processedOrderUuids.add(orderUuid);

      // Increment background order count
      final int prevCount = (box.read<int>(bgCountKey) ?? 0);
      final int newCount = prevCount + 1;
      await box.write(bgCountKey, newCount);

      // Update notification with count
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: 'Dinemetrics Ordering',
          content:
              newCount == 1
                  ? '1 new order received'
                  : '$newCount new orders received',
        );
      }

      // 1. Play Sound in background
      try {
        final audioPlayer = AudioPlayer();
        await audioPlayer.setReleaseMode(ReleaseMode.release);
        await audioPlayer.play(AssetSource('audio/new_order.wav'));
      } catch (_) {}

      // 2. Fetch Order details using standard HTTP requests
      final token = box.read<String>(ArgumentConstant.tokenKey);
      if (token == null || token.isEmpty) return;

      final dio = Dio(
        BaseOptions(
          baseUrl: ArgumentConstant.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final endpoint = ArgumentConstant.getOrderEndpoint.replaceAll(
        ':order_uuid',
        orderUuid,
      );
      final response = await dio.get(endpoint);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;
        if (resData != null && resData is Map<String, dynamic>) {
          final getOrderModel = order_model.GetOrderModel.fromJson(resData);
          if (getOrderModel.success == true && getOrderModel.data != null) {
            final detailedPlacedVia =
                (getOrderModel.data?.order?.placedVia ?? placedVia)
                    .toString()
                    .toLowerCase()
                    .trim();
            if (detailedPlacedVia != 'shop' &&
                detailedPlacedVia != 'android' &&
                detailedPlacedVia != 'ios') {
              return;
            }

            final printerService = Get.find<PrinterService>();
            await printerService.loadGeneralSettings();

            final autoPrint =
                box.read(ArgumentConstant.autoPrintReceiptKey) ?? true;
            final rawCopies =
                box.read(ArgumentConstant.receiptPrintCopiesKey) ?? 1;
            final int copies = rawCopies is int
                ? rawCopies
                : (int.tryParse(rawCopies.toString()) ?? 1);
            final isConnected =
                await printerService.checkPrinterConnectivity();

            if (isConnected && autoPrint) {
              final completer = Completer<void>();
              final prev = bgPrintingLock;
              bgPrintingLock = completer.future;
              await prev;

              try {
                final sunmiService = SunmiInvoicePrinterService();
                await sunmiService.printInvoice(
                  getOrderModel.data!,
                  copies: copies,
                );
              } finally {
                completer.complete();
              }
            }
          }
        }
      }
    } catch (_) {
    } finally {
      final int latestCount = (box.read<int>(bgCountKey) ?? 0);
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: 'Dinemetrics Ordering',
          content:
              latestCount == 0
                  ? 'Listening for new orders...'
                  : latestCount == 1
                  ? '1 new order received'
                  : '$latestCount new orders received',
        );
      }
    }
  }

  void handleKot(dynamic eventData) async {
    if (isAppForeground) return;

    await syncStorageFromDisk();

    try {
      Map<String, dynamic>? decoded;
      if (eventData is Map<String, dynamic>) {
        decoded = eventData;
      } else {
        decoded =
            jsonDecode(eventData.toString().trim()) as Map<String, dynamic>?;
      }
      if (decoded == null) return;

      final kotId = (decoded['kot_id'] ?? decoded['kot']?['id']) as dynamic;
      if (kotId == null) return;
      final int? kotIdInt =
          kotId is int ? kotId : int.tryParse(kotId.toString());
      if (kotIdInt == null) return;

      if (processedKotIds.contains(kotIdInt)) return;
      processedKotIds.add(kotIdInt);

      final autoPrintKot =
          box.read(ArgumentConstant.autoPrintKitchenKey) ?? true;
      if (!autoPrintKot) return;

      final token = box.read<String>(ArgumentConstant.tokenKey);
      if (token == null || token.isEmpty) return;

      KitchenTicket? kotData;
      final kotMap = decoded['kot'];
      if (kotMap is Map<String, dynamic>) {
        kotData = KitchenTicket.fromJson(kotMap);
      } else {
        final dio = Dio(
          BaseOptions(
            baseUrl: ArgumentConstant.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ),
        );
        final res = await dio.get(
          '${ArgumentConstant.kotsEndpoint}/$kotIdInt',
        );
        if (res.statusCode == 200 || res.statusCode == 201) {
          final data =
              res.data is Map<String, dynamic> ? res.data['data'] : null;
          if (data is Map<String, dynamic>) {
            kotData = KitchenTicket.fromJson(data);
          }
        }
      }

      if (kotData == null) return;

      // Only print KOT for Shop, Android, and iOS customer orders
      final kotPlacedVia = (kotData.order?.placedVia ??
              decoded['kot']?['order']?['placed_via'] ??
              decoded['order']?['placed_via'] ??
              '')
          .toString()
          .toLowerCase()
          .trim();
      if (kotPlacedVia.isNotEmpty &&
          kotPlacedVia != 'shop' &&
          kotPlacedVia != 'android' &&
          kotPlacedVia != 'ios') {
        return;
      }

      final rawCopies =
          box.read(ArgumentConstant.kitchenPrintCopiesKey) ?? 1;
      final int copies = rawCopies is int
          ? rawCopies
          : (int.tryParse(rawCopies.toString()) ?? 1);

      try {
        final audioPlayer = AudioPlayer();
        await audioPlayer.setReleaseMode(ReleaseMode.release);
        await audioPlayer.play(AssetSource('audio/new_order.wav'));
      } catch (_) {}

      if (service is AndroidServiceInstance) {
        final kotNum =
            kotData.kotNumber ?? kotData.order?.orderNumber ?? '$kotIdInt';
        final tablePart = kotData.order?.table is Map
            ? (kotData.order!.table['table_code'] ??
                kotData.order!.table['name'] ??
                '')
            : (kotData.order?.table?.toString() ?? '');
        final desc =
            tablePart.isNotEmpty
                ? 'KOT #$kotNum for Table $tablePart received'
                : 'KOT #$kotNum received';
        service.setForegroundNotificationInfo(
          title: '🍳 New Kitchen Ticket',
          content: desc,
        );
      }

      final printerService = Get.find<PrinterService>();
      final isConnected = await printerService.checkPrinterConnectivity();
      if (isConnected) {
        final completer = Completer<void>();
        final prev = bgPrintingLock;
        bgPrintingLock = completer.future;
        await prev;

        try {
          final sunmiService = SunmiInvoicePrinterService();
          await sunmiService.printKOT(kotData, copies: copies);
        } finally {
          completer.complete();
        }
      }
    } catch (_) {}
  }

  void handleWebSocketMessage(
    dynamic message,
    String orderChannel,
    Set<String> kotChannels,
    int connId,
  ) {
    if (connId != connectionId) return;
    try {
      final decoded = jsonDecode(message.toString());
      final event = decoded['event'] as String?;
      final dataStr = decoded['data'];
      final channel = decoded['channel'] as String?;

      if (event == 'pusher:connection_established') {
        isConnected = true;

        // Subscribe to order channel
        socket?.add(
          jsonEncode({
            "event": "pusher:subscribe",
            "data": {"channel": orderChannel},
          }),
        );

        // Subscribe to all KOT channels
        for (final kotChannel in kotChannels) {
          socket?.add(
            jsonEncode({
              "event": "pusher:subscribe",
              "data": {"channel": kotChannel},
            }),
          );
        }

        pingTimer?.cancel();
        pingTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
          if (isConnected) {
            socket?.add(jsonEncode({"event": "pusher:ping", "data": {}}));
          }
        });
      } else if (event == 'pusher:ping') {
        socket?.add(jsonEncode({"event": "pusher:pong", "data": {}}));
      } else if (event == 'pusher_internal:subscription_succeeded') {
      } else if (event == 'pusher:error') {
      } else if (channel == orderChannel) {
        if (dataStr != null) {
          handleOrder(dataStr);
        }
      } else if (kotChannels.contains(channel)) {
        if (channel != null && channel.contains('.kots.created.')) {
          if (dataStr != null) {
            handleKot(dataStr);
          }
        }
      }
    } catch (_) {}
  }

  void connectPusher(
    int branchId,
    int connId,
    Set<String> resolvedKotChannels,
  ) async {
    if (connId != connectionId || isAppForeground) return;
    try {
      await stopSocket();
      if (connId != connectionId || isAppForeground) return;

      kotChannels = resolvedKotChannels;

      final orderChannel =
          "new-order-created.$branchId.${ArgumentConstant.envSuffix}";
      const scheme = 'wss';
      const host = "soketi-production-85c0.up.railway.app";
      const appKey = "wxidjpbk1bfqn6nr9m9rmve2hkhasdq6";
      const port = 443;
      final url =
          '$scheme://$host:$port/app/$appKey?protocol=7&client=dart&version=1.0.0&flash=false';

      socket = await WebSocket.connect(url);
      if (connId != connectionId || isAppForeground) {
        socket?.close();
        return;
      }

      socket!.listen(
        (message) => handleWebSocketMessage(
          message,
          orderChannel,
          kotChannels,
          connId,
        ),
        onDone: () {
          if (connId != connectionId || isAppForeground) return;
          Future.delayed(
            const Duration(seconds: 5),
            () => connectPusher(
              branchId,
              connId,
              kotChannels,
            ),
          );
        },
        onError: (err) {
          if (connId != connectionId || isAppForeground) return;
          Future.delayed(
            const Duration(seconds: 5),
            () => connectPusher(
              branchId,
              connId,
              kotChannels,
            ),
          );
        },
      );
    } catch (_) {
      if (connId != connectionId || isAppForeground) return;
      Future.delayed(
        const Duration(seconds: 5),
        () => connectPusher(
          branchId,
          connId,
          kotChannels,
        ),
      );
    }
  }

  void startListening() async {
    if (isAppForeground) {
      await stopSocket();
      return;
    }

    await stopSocket();

    connectionId++;
    final currentConnId = connectionId;

    await syncStorageFromDisk();

    final loginModelData = box.read(ArgumentConstant.loginModelKey);
    if (loginModelData != null && loginModelData is Map<String, dynamic>) {
      final loginModel = LoginModel.fromJson(loginModelData);
      final user = loginModel.data?.user;
      final branchId = user?.branchId;

      if (branchId != null) {
        // Restore cached KOT channels first for immediate availability
        Set<String> resolvedKotChannels = {};
        try {
          final cached = box.read(ArgumentConstant.cachedKotChannelsKey);
          if (cached is List && cached.isNotEmpty) {
            resolvedKotChannels.addAll(cached.map((e) => e.toString()));
          }
        } catch (_) {}

        // Fetch fresh kitchen monitor channels from API
        try {
          final token = box.read<String>(ArgumentConstant.tokenKey);
          if (token != null && token.isNotEmpty) {
            final dio = Dio(
              BaseOptions(
                baseUrl: ArgumentConstant.baseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                  'Authorization': 'Bearer $token',
                },
              ),
            );
            final res = await dio.get(
              ArgumentConstant.kitchenMonitorsEndpoint,
            );
            if (res.statusCode == 200 || res.statusCode == 201) {
              final data = res.data;
              if (data is Map<String, dynamic> && data['data'] is List) {
                final suffix = ArgumentConstant.envSuffix;
                for (final m in (data['data'] as List)) {
                  final id = m['id'];
                  if (id != null) {
                    resolvedKotChannels.add(
                      'kitchen-monitors.$branchId.$id.kots.created.$suffix',
                    );
                  }
                }
                await box.write(
                  ArgumentConstant.cachedKotChannelsKey,
                  resolvedKotChannels.toList(),
                );
              }
            }
          }
        } catch (_) {}

        connectPusher(
          branchId,
          currentConnId,
          resolvedKotChannels,
        );
      }
    }
  }

  if (!isAppForeground) {
    startListening();
  }

  // Listeners for communication with main UI isolate
  service.on('stopService').listen((event) async {
    await stopSocket();
    await service.stopSelf();
  });

  service.on('updateConfig').listen((event) async {
    await syncStorageFromDisk();
    if (!isAppForeground) {
      startListening();
    }
  });

  service.on('setAppForeground').listen((event) async {
    if (event != null) {
      final bool foreground = event['isForeground'] ?? false;
      isAppForeground = foreground;
      await box.write(ArgumentConstant.isAppForegroundKey, foreground);

      // Reset background order count and stop background socket when app comes to foreground
      if (foreground) {
        await stopSocket();
        await box.write(bgCountKey, 0);
        if (service is AndroidServiceInstance) {
          service.setForegroundNotificationInfo(
            title: 'Dinemetrics Ordering',
            content: 'Listening for new orders...',
          );
        }
      } else {
        startListening();
      }
    }
  });
}
