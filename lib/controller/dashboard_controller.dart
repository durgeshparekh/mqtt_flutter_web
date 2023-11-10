import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:mqtt_flutter_web/controller/mqtt_controller.dart';

class DashboardController extends GetxController {
  var clientIdController = TextEditingController();
  var usernameController = TextEditingController();
  var passwordController = TextEditingController();
  var topicController = TextEditingController();
  var messageController = TextEditingController();
  var publishTopicController = TextEditingController();

  var brokerConnected = false.obs;
  var receivedMessage = ''.obs;
  var messageList = [].obs;
  var mqttController = MQTTController();

  Future<void> connectToBroker() async {
    if (clientIdController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Client Id should not be empty',
        gravity: ToastGravity.CENTER,
        textColor: Colors.black,
        webPosition: "center",
        webBgColor: "#b2dfdb",
        timeInSecForIosWeb: 2,
      );
    } else {
      if (brokerConnected.isFalse) {
        mqttController.initializeAndConnect(
          hostName: "wss://test.smartnode.in/mqtt",
          portNumber: 8084,
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
  }

  publishMessage() {
    mqttController.publishMessage(
      topic: publishTopicController.text,
      publishMessage: messageController.text,
    );
  }

  void subScribeToTopic() {
    mqttController.subscribeToMQTT(topic: topicController.text);
  }

  void unSubscribeToTopic() {
    mqttController.unSubscribeToMQTT(topic: topicController.text);
    topicController.clear();
  }

  void handleMessage(dynamic message) {
    // Handle the received message here
    debugPrint('Received message in Dashboard: $message');
    // receivedMessage.value = '$topic: $message';
    messageList.add(message);
  }
}
