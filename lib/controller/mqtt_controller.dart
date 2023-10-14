import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

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
    
    mqttBrowserClient!.onSubscribed = onSubscribed;
    mqttBrowserClient!.onUnsubscribed = onUnSubscribed;
    mqttBrowserClient!.onDisconnected = onDisconnected;

    MqttConnectMessage connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .withWillQos(MqttQos.exactlyOnce)
        .startClean();

    mqttBrowserClient!.connectionMessage = connMessage;

    try {
      await mqttBrowserClient!.connect(username, password).then((value) {
        var connectionStatus = value!.state;
        if (connectionStatus == MqttConnectionState.connected) {
          startListeningMessages();

          mqttBrowserClient!.onConnected = onConnected;
        }
      });
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

  void startListeningMessages() {
    mqttBrowserClient!.updates!
        .listen((List<MqttReceivedMessage<MqttMessage>> c) async {
      final MqttPublishMessage? recMess = c[0].payload as MqttPublishMessage?;
      final String receivedMessage =
          MqttPublishPayload.bytesToStringAsString(recMess!.payload.message);
      // _currentState.setReceivedText(recMess.toString());
      debugPrint(receivedMessage);
    });
  }
}
