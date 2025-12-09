import 'dart:convert';
import 'package:get/get.dart';
import 'package:managerapp/main.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../services/printer_service.dart';
import '../constants/api_constants.dart';

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

    final channelName = "new-order-created.$restaurantId";

    try {
      await pusher.subscribe(
        channelName: channelName,
        onEvent: (event) {
          print("Event Data: ${event.data}");
          if (_isValidEventData(event.data)) {
            _handleOrderEvent(event.data);
          }
        },
      );
    } catch (e) {
      print('Error subscribing to orders: $e');
    }
  }

  void _handleOrderEvent(dynamic eventData) {
    try {
      final autoPrint = box.read(ArgumentConstant.printerAutoPrintKey) ?? true;
      if (!autoPrint || !Get.isRegistered<PrinterService>()) {
        return;
      }

      // Parse the event data
      String dataString = eventData.toString().trim();
      final decoded = jsonDecode(dataString);

      // Extract order data
      if (decoded is Map<String, dynamic>) {
        final order = decoded['order'];
        if (order is Map<String, dynamic>) {
          final imageUrl = order['image_url'] as String?;

          if (imageUrl != null && imageUrl.isNotEmpty) {
            print('📸 Found image URL in order: $imageUrl');
            final printerService = Get.find<PrinterService>();
            printerService.printImageFromUrl(imageUrl);
          } else {
            print('⚠️ No image_url found in order data');
          }
        } else {
          print('⚠️ Order data is not a valid map');
        }
      } else {
        print('⚠️ Event data is not a valid map');
      }
    } catch (e) {
      print('❌ Error handling order event: $e');
    }
  }
}
