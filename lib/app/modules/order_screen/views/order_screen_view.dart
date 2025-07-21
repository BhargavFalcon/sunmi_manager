import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/order_screen_controller.dart';

class OrderScreenView extends GetView<OrderScreenController> {
  const OrderScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order'), centerTitle: true),
    );
  }
}
