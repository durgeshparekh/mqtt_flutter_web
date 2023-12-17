import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mqtt_flutter_web/controller/dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(DashboardController());
    return Scaffold(
      appBar: AppBar(title: const Text('MQTT')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Obx(() {
              debugPrint(
                  'brokerConnected: ${controller.brokerConnected.value}');
              return ExpansionTile(
                title: ListTile(
                  leading: CircleAvatar(
                    radius: 10,
                    backgroundColor: controller.brokerConnected.isTrue
                        ? Colors.green
                        : Colors.red,
                  ),
                  title: Text(
                    controller.brokerConnected.isTrue
                        ? 'Connected'
                        : 'Not connected',
                  ),
                ),
                initiallyExpanded: true,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _customTextField(
                          labelText: 'Client ID',
                          textEditingController: controller.clientIdController,
                        ),
                        const SizedBox(width: 30),
                        _customTextField(
                          labelText: 'Username',
                          textEditingController: controller.usernameController,
                        ),
                        const SizedBox(width: 30),
                        _customTextField(
                          labelText: 'Password',
                          textEditingController: controller.passwordController,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: _customButton(
                      onPressed: () => controller.connectToBroker(),
                      buttonText: controller.brokerConnected.isTrue
                          ? 'Disconnect'
                          : 'Connect',
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 20),
            SizedBox(
              height: 100,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _customTextField(
                      labelText: 'Topic',
                      textEditingController: controller.topicController,
                    ),
                    const SizedBox(width: 50),
                    _customButton(
                      onPressed: () => controller.subScribeToTopic(),
                      buttonText: 'Subscribe',
                    ),
                    const SizedBox(width: 100),
                    _customButton(
                      onPressed: () => controller.unSubscribeToTopic(),
                      buttonText: 'Unsubscribe',
                    ),
                    const SizedBox(width: 100),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1, color: Colors.grey),
            SizedBox(
              height: 80,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _customTextField(
                      labelText: 'Publish Topic',
                      textEditingController: controller.publishTopicController,
                    ),
                    const SizedBox(width: 30),
                    _customTextField(
                      labelText: 'Publish Message',
                      textEditingController: controller.messageController,
                    ),
                    const SizedBox(width: 50),
                    _customButton(
                      onPressed: () => controller.publishMessage(),
                      buttonText: 'Publish',
                    ),
                    const SizedBox(width: 50),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Obx(
              () => Container(
                width: double.infinity,
                height: 100,
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  border: Border.all(color: Colors.grey),
                ),
                child: ListView.builder(
                  itemCount: controller.messageList.length,
                  itemBuilder: (context, index) {
                    return Text(
                      controller.messageList[index].toString(),
                      style: const TextStyle(fontSize: 16),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            _customButton(
              onPressed: () => controller.messageList.clear(),
              buttonText: 'Clear Messages',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  _customButton({required VoidCallback onPressed, required String buttonText}) {
    return MaterialButton(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.teal.shade100,
      onPressed: onPressed,
      child: Text(buttonText),
    );
  }

  _customTextField(
      {required String labelText,
      required TextEditingController textEditingController}) {
    return Container(
      width: 250,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: const BoxDecoration(
        color: Color.fromARGB(89, 178, 212, 223),
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: TextFormField(
        controller: textEditingController,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.black),
          border: InputBorder.none, // Remove the default border
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
        ),
      ),
    );
  }
}
