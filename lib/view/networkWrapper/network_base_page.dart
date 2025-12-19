import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../view_models/controller/networkControllers/network_controller.dart';
import '../noInternetScreen/no_internet_screen.dart';

class NetworkBasePage extends StatelessWidget {
  final Widget child;
  const NetworkBasePage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final NetworkController controller = Get.find();

    return Obx(() {
      if (!controller.isConnected.value) {
        return const NoInternetScreen();
      }
      return child;
    });
  }
}
