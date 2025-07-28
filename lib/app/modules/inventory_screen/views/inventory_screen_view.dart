import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/inventory_screen_controller.dart';

class InventoryScreenView extends GetView<InventoryScreenController> {
  const InventoryScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
    );
  }
}
