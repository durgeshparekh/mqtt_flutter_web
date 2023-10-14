import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mqtt_flutter_web/controller/mqtt_controller.dart';

class DashboardController extends GetxController {
  var clientIdController = TextEditingController();
  var usernameController = TextEditingController();
  var passwordController = TextEditingController();
  var topicController = TextEditingController();
  var messageController = TextEditingController();

  var brokerConnected = false.obs;
  var mqttController = MQTTController();

  // nO1cANsTOPuS
  // "d\$2N@8p&1V#1"

  Future<void> connectToBroker() async {
    if (brokerConnected.isFalse) {
      mqttController.initializeAndConnect(
        hostName: "ws://test.smartnode.in/mqtt",
        portNumber: 8083,
        keepAliveTime: 10,
        clientId: clientIdController.text,
        username: usernameController.text,
        password: passwordController.text,
      );
      brokerConnected.value = await mqttController.onConnected();
    } else {
      mqttController
          .disconnect()
          .then((value) => brokerConnected.value = false);
    }
  }

  publishMessage() {
    mqttController.publishMessage(
      topic: topicController.text,
      publishMessage: messageController.text,
    );
  }

  void subScribeToTopic() {
    mqttController.subscribeToMQTT(topic: topicController.text);
  }

  void unSubscribeToTopic() {
    mqttController.unSubscribeToMQTT(topic: topicController.text);
  }
}
