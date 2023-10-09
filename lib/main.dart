import 'dart:isolate';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
// import 'package:mqtt_client/mqtt_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MQTTScreen(),
    );
  }
}

class MQTTScreen extends StatefulWidget {
  const MQTTScreen({super.key});

  @override
  State<MQTTScreen> createState() => _MQTTScreenState();
}

class _MQTTScreenState extends State<MQTTScreen> {
  MqttBrowserClient? client;
  TextEditingController topicController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  String receivedMessage = '';

  void connectToMQTT(String username, String password) async {
    var clientId = Random.secure().nextInt(10).toString();
    client = MqttBrowserClient(
      'ws://connect.smartnode.in/mqtt',
      clientId,
      maxConnectionAttempts: 3,
    );
    client?.port = 8083;
    client!.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
    client!.keepAlivePeriod = 10;
    client!.onConnected = onConnected;
    client!.onSubscribed = onSubscribed;
    client!.onUnsubscribed = onUnSubscribed;
    client!.onDisconnected = onDisconnected;

    client?.logging(on: true);

    final connMessage = MqttConnectMessage()
        .authenticateAs(username, password)
        .withClientIdentifier(clientId)
        .withWillTopic('hello')
        .withWillMessage('After my death I will give all my property in charity')
        .startClean()
        .withWillQos(MqttQos.atMostOnce);

    client?.connectionMessage = connMessage;

    try {
      await client?.connect(username, password);
      // Subscribe to topics or handle connection success
    } catch (e) {
      debugPrint('Connection failed: $e');
    }

    client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage? recMess = c[0].payload as MqttPublishMessage?;
      receivedMessage =
          MqttPublishPayload.bytesToStringAsString(recMess!.payload.message);

      debugPrint(
          'Received message:$receivedMessage from topic: ${c[0].topic}>');
    });
  }

  void publishMessage(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);

    client?.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MQTT Flutter Web')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: topicController,
              decoration: const InputDecoration(labelText: 'Topic'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(labelText: 'Message'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                connectToMQTT('nO1cANsTOPuS', r'd$2N@8p&1V#1');
              },
              child: const Text('Connect to MQTT'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                subScribeToTopic(topicController.text);
              },
              child: const Text('Subscribe Message'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                publishMessage(topicController.text, messageController.text);
              },
              child: const Text('Publish Message'),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                width: double.infinity,
                height: 100,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  receivedMessage,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> subScribeToTopic(String topic) async {
    client!.subscribe(topic, MqttQos.atLeastOnce);
  }

  Future<void> onConnected() async {
    debugPrint('Connection successful');
  }

  Future<void> onSubscribed(String topic) async {
    debugPrint('Subscription confirmed for topic $topic');
  }

  void onUnSubscribed(String? topic) async =>
      debugPrint('UnSubscribe confirmed for topic $topic');

  Future<void> disconnect() async => client!.disconnect();

  Future onDisconnected() async {
    debugPrint('Client Disconnected');
  }
}


// flutter run -d web-server --web-hostname <your_local_ip_address> --web-port <desired_port>
