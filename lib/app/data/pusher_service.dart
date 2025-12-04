import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class PusherService {
  final PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

  // Pusher Configuration
  static const String appId = "1952389";
  static const String key = "976a2c01b088eeeb0342";
  static const String cluster = "eu";

  Future<void> initPusher() async {
    try {
      await pusher.init(
        apiKey: key, // Use 'key' not 'appId'
        cluster: cluster,
        onConnectionStateChange: (currentState, previousState) {
          print("Connection state: $currentState");
        },
        onError: (message, code, e) {
          print("Error: $message");
        },
      );
      await pusher.connect();
    } catch (e) {
      print("Pusher init error: $e");
    }
  }

  Future<void> subscribeToOrders() async {
    await pusher.subscribe(
      channelName: "new-order-created.43",
      onEvent: (event) {
        print("Received event: ${event.eventName}");
        print("Data: ${event.data}");
      },
    );
  }
}
