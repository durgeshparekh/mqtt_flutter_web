import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_flutter_web/controller/dashboard_controller.dart';

class MQTTController {
  MqttBrowserClient? mqttBrowserClient;
  final Random _rnd = Random();
  final String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<void> initializeAndConnect({
    required String hostName,
    required int portNumber,
    int? keepAliveTime,
    String? clientId,
    String? username,
    String? password,
  }) async {
    mqttBrowserClient = MqttBrowserClient(
      hostName,
      clientId!,
      maxConnectionAttempts: 3,
    );
    mqttBrowserClient!.port = portNumber;
    mqttBrowserClient!.keepAlivePeriod = keepAliveTime!;

    mqttBrowserClient!.websocketProtocols =
        MqttClientConstants.protocolsSingleDefault;

    MqttConnectMessage connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .withWillQos(MqttQos.exactlyOnce)
        .startClean();

    mqttBrowserClient!.connectionMessage = connMessage;

    try {
      await mqttBrowserClient!.connect(username, password);
      mqttBrowserClient!.onConnected = onConnected;
      mqttBrowserClient!.onSubscribed = onSubscribed;
      mqttBrowserClient!.onUnsubscribed = onUnSubscribed;
      mqttBrowserClient!.onDisconnected = onDisconnected;

      startListeningMessages();
    } catch (e) {
      debugPrint('EXAMPLE::client exception - $e');
      mqttBrowserClient!.disconnect();
    }
  }

  bool isConnectedToBroker() {
    bool isConnected = false;
    if (mqttBrowserClient!.connectionStatus != null) {
      isConnected = mqttBrowserClient!.connectionStatus!.state ==
          MqttConnectionState.connected;
    }
    return isConnected;
  }

  Future onConnected() async {
    debugPrint("connected successfully");
    return true;
  }

  Future onSubscribed(String topic) async {
    debugPrint("subscribed on topic: $topic");
  }

  Future onUnSubscribed(String? topic) async {
    debugPrint("unsubscribed on topic: $topic");
  }

  Future onDisconnected() async {
    debugPrint("disconnected");

    return true;
  }

  Future publishMessage({
    required String topic,
    required String publishMessage,
  }) async {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(publishMessage);
    try {
      mqttBrowserClient!.publishMessage(
        topic,
        MqttQos.atMostOnce,
        builder.payload!,
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future subscribeToMQTT({required String topic}) async {
    MqttSubscriptionStatus status =
        mqttBrowserClient!.getSubscriptionsStatus(topic);
    if (status == MqttSubscriptionStatus.doesNotExist) {
      mqttBrowserClient!.subscribe(topic, MqttQos.atLeastOnce);
    }
  }

  Future unSubscribeToMQTT({required String topic}) async {
    MqttSubscriptionStatus status =
        mqttBrowserClient!.getSubscriptionsStatus(topic);
    if (status == MqttSubscriptionStatus.active) {
      mqttBrowserClient!.unsubscribe(topic);
    }
  }

  Future<void> disconnect() async => mqttBrowserClient!.disconnect();

  void startListeningMessages() {
    mqttBrowserClient!.updates!
        .listen((List<MqttReceivedMessage<MqttMessage>> c) async {
      final MqttPublishMessage? recMess = c[0].payload as MqttPublishMessage?;
      final String receivedMessage =
          MqttPublishPayload.bytesToStringAsString(recMess!.payload.message);
      // Get the YourController instance
      DashboardController dashboardController = Get.find<DashboardController>();
      // Call the method to handle the message
      dynamic object = {"topic": c[0].topic, "message": receivedMessage};
      dashboardController.handleMessage(json.encode(object));
    });
  }
}
