import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:get/state_manager.dart';
import 'package:mqtt_flutter_web/controller/dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(DashboardController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('MQTT'),
      ),
      body: Column(
        children: [
          ExpansionTile(
            title: Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: controller.brokerConnected.isTrue
                      ? Colors.green
                      : Colors.red,
                ),
                const SizedBox(width: 10),
                const Text('Not connected'),
              ],
            ),
            initiallyExpanded: controller.brokerConnected.isTrue ? false : true,
            children: [
              Form(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: TextFormField(
                              controller: controller.clientIdController,
                              decoration:
                                  const InputDecoration(labelText: 'Client ID'),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: TextFormField(
                              controller: controller.usernameController,
                              decoration:
                                  const InputDecoration(labelText: 'Username'),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: TextFormField(
                              controller: controller.passwordController,
                              decoration:
                                  const InputDecoration(labelText: 'Password'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => controller.connectToBroker(),
                      icon: Icon(
                        Icons.power_settings_new,
                        color: controller.brokerConnected.isTrue
                            ? Colors.red
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ListTile(
            title: Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextFormField(
                controller: controller.topicController,
                decoration: const InputDecoration(labelText: 'Topic'),
              ),
            ),
            trailing: MaterialButton(
              onPressed: () {
                controller.subScribeToTopic();
              },
              child: const Text('Subscribe'),
            ),
          )
        ],
      ),
    );
  }
}
