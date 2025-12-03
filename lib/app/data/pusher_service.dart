import 'package:get/get.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class PusherService extends GetxService {
  static final PusherService _instance = PusherService._internal();
  factory PusherService() => _instance;
  PusherService._internal();

  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
  bool isConnected = false;

  // Pusher Configuration
  static const String appId = "1952389";
  static const String key = "976a2c01b088eeeb0342";
  static const String secret = "a4caf719f474c1c953a1";
  static const String cluster = "eu";

  /// Initialize Pusher connection
  Future<void> init() async {
    try {
      await pusher.init(
        apiKey: key,
        cluster: cluster,
        onConnectionStateChange: onConnectionStateChange,
        onError: onError,
        onSubscriptionSucceeded: onSubscriptionSucceeded,
        onEvent: onEvent,
        onSubscriptionError: onSubscriptionError,
        onDecryptionFailure: onDecryptionFailure,
        onMemberAdded: onMemberAdded,
        onMemberRemoved: onMemberRemoved,
        // Enable logging for debugging
        onAuthorizer: onAuthorizer,
      );

      await pusher.connect();
      isConnected = true;
      print("Pusher initialized and connected successfully");

      await subscribe('my-chanal');
      bind('my-chanal', 'my-event', (PusherEvent event) {
        print('Event received on my-chanal: ${event.data}');
      });
    } catch (e) {
      print("Error initializing Pusher: $e");
      isConnected = false;
    }
  }

  /// Connect to Pusher
  Future<void> connect() async {
    if (!isConnected) {
      try {
        await pusher.connect();
        isConnected = true;
        print("Pusher connected");
      } catch (e) {
        print("Error connecting to Pusher: $e");
      }
    }
  }

  /// Disconnect from Pusher
  Future<void> disconnect() async {
    try {
      await pusher.disconnect();
      isConnected = false;
      print("Pusher disconnected");
    } catch (e) {
      print("Error disconnecting from Pusher: $e");
    }
  }

  /// Subscribe to a channel
  Future<void> subscribe(String channelName) async {
    try {
      await pusher.subscribe(channelName: channelName);
      print("Subscribed to channel: $channelName");
    } catch (e) {
      print("Error subscribing to channel $channelName: $e");
    }
  }

  /// Unsubscribe from a channel
  Future<void> unsubscribe(String channelName) async {
    try {
      await pusher.unsubscribe(channelName: channelName);
      print("Unsubscribed from channel: $channelName");
    } catch (e) {
      print("Error unsubscribing from channel $channelName: $e");
    }
  }

  // Store event callbacks
  final Map<String, Map<String, Function(PusherEvent)>> _eventCallbacks = {};

  /// Bind to an event on a channel
  void bind(
    String channelName,
    String eventName,
    Function(PusherEvent) callback,
  ) {
    try {
      if (!_eventCallbacks.containsKey(channelName)) {
        _eventCallbacks[channelName] = {};
      }
      _eventCallbacks[channelName]![eventName] = callback;
      print("Bound to event $eventName on channel $channelName");
    } catch (e) {
      print("Error binding to event $eventName on channel $channelName: $e");
    }
  }

  /// Unbind from an event on a channel
  void unbind(String channelName, String eventName) {
    try {
      _eventCallbacks[channelName]?.remove(eventName);
      if (_eventCallbacks[channelName]?.isEmpty ?? false) {
        _eventCallbacks.remove(channelName);
      }
      print("Unbound from event $eventName on channel $channelName");
    } catch (e) {
      print(
        "Error unbinding from event $eventName on channel $channelName: $e",
      );
    }
  }

  /// Trigger an event on a channel (client events - note: client events require private/presence channels)
  Future<void> trigger(
    String channelName,
    String eventName,
    dynamic data,
  ) async {
    try {
      // Note: Client events can only be triggered on private or presence channels
      // This requires the channel to be subscribed and the event name to start with 'client-'
      if (!eventName.startsWith('client-')) {
        print("Warning: Client events must start with 'client-' prefix");
      }
      await pusher.trigger(
        PusherEvent(channelName: channelName, eventName: eventName, data: data),
      );
      print("Triggered event $eventName on channel $channelName");
    } catch (e) {
      print("Error triggering event $eventName on channel $channelName: $e");
    }
  }

  // Pusher Event Handlers

  void onConnectionStateChange(dynamic currentState, dynamic previousState) {
    print("Connection state changed from $previousState to $currentState");
    isConnected = currentState == "CONNECTED";
  }

  void onError(String message, int? code, dynamic e) {
    print("Pusher error: $message (code: $code)");
  }

  void onSubscriptionSucceeded(String channelName, dynamic data) {
    print("Successfully subscribed to channel: $channelName");
  }

  void onEvent(PusherEvent event) {
    print("Event received on channel ${event.channelName}: ${event.eventName}");
    print("Event data: ${event.data}");

    // Check if there's a callback registered for this channel and event
    final channelCallbacks = _eventCallbacks[event.channelName];
    if (channelCallbacks != null) {
      final callback = channelCallbacks[event.eventName];
      if (callback != null) {
        callback(event);
      }
    }
  }

  void onSubscriptionError(String message, dynamic e) {
    print("Subscription error: $message");
  }

  void onDecryptionFailure(String event, String reason) {
    print("Decryption failure for event $event: $reason");
  }

  void onMemberAdded(String channelName, PusherMember member) {
    print("Member added to channel $channelName: ${member.userId}");
  }

  void onMemberRemoved(String channelName, PusherMember member) {
    print("Member removed from channel $channelName: ${member.userId}");
  }

  /// Authorizer function for private/presence channels
  dynamic onAuthorizer(String channelName, String socketId, dynamic options) {
    // For private or presence channels, you would typically make an API call
    // to your backend to get the authorization token
    // For now, returning null (public channels don't need authorization)
    return null;
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
