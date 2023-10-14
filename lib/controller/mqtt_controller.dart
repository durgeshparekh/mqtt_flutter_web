import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

import 'dashboard_controller.dart';

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
    debugPrint(
        'clientId: $clientId, username: $username, password: $password, portNumber: $portNumber, host: $hostName, keepAlive: $keepAliveTime');
    mqttBrowserClient = MqttBrowserClient(
      hostName,
      clientId!,
      maxConnectionAttempts: 3,
    );
    mqttBrowserClient!.port = portNumber;
    mqttBrowserClient!.keepAlivePeriod = keepAliveTime!;

    mqttBrowserClient!.websocketProtocols =
        MqttClientConstants.protocolsSingleDefault;
    mqttBrowserClient!.onConnected = onConnected;
    mqttBrowserClient!.onSubscribed = onSubscribed;
    mqttBrowserClient!.onUnsubscribed = onUnSubscribed;
    mqttBrowserClient!.onDisconnected = onDisconnected;

    // var controller = Get.find<DashboardController>();

    MqttConnectMessage connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .withWillQos(MqttQos.exactlyOnce)
        // .withWillRetain()
        // .withWillMessage(
        //     'After my death I will give all my property in charity')
        .startClean();

    mqttBrowserClient!.connectionMessage = connMessage;

    try {
      await mqttBrowserClient!.connect(username, password);
    } catch (e) {
      debugPrint('EXAMPLE::client exception - $e');
      mqttBrowserClient!.disconnect();
    }
  }

  Future onConnected() async {
    var controller = Get.find<DashboardController>();
    controller.brokerConnected.value = true;
  }

  Future onSubscribed(String topic) async {
    debugPrint("subscribed on topic: $topic");
  }

  Future onUnSubscribed(String? topic) async {
    debugPrint("unsubscribed on topic: $topic");
  }

  Future onDisconnected() async {
    var controller = Get.find<DashboardController>();
    controller.brokerConnected.value = false;
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
        MqttQos.exactlyOnce,
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
      debugPrint("topic :$topic");
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
}
